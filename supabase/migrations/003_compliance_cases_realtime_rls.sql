-- ============================================================================
-- Compliance Cases & Extended RLS for Super_Admin
-- ============================================================================
-- Super_Admin สามารถร้องขอสิทธิ์เข้าถึงข้อมูลผู้ใช้ (device, UID, chat, maps) 
-- ได้ตลอดจนกว่า case จะปิด — แม้ผู้ใช้จะล็อกเอาท์แล้วก็ตาม
-- ใช้สำหรับ: ธนาคาร, กรณีทางกฎหมาย, compliance, การตรวจสอบ
-- ============================================================================

-- 1. Compliance Cases Table
-- Super_Admin สร้าง case เพื่อเข้าถึงข้อมูลผู้ใช้จนกว่าจะปิด case
CREATE TABLE IF NOT EXISTS public.compliance_cases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  target_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_by uuid NOT NULL REFERENCES auth.users(id),
  case_type text NOT NULL CHECK (case_type IN ('banking', 'legal', 'fraud', 'investigation', 'data_request', 'other')),
  reason text NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'closed', 'escalated')),
  notes text,
  reference_number text, -- เลขอ้างอิงภายนอก เช่น เลขคดี
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  closed_at timestamptz,
  closed_by uuid REFERENCES auth.users(id)
);

CREATE INDEX IF NOT EXISTS idx_compliance_cases_target_user ON public.compliance_cases(target_user_id);
CREATE INDEX IF NOT EXISTS idx_compliance_cases_status ON public.compliance_cases(status);
CREATE INDEX IF NOT EXISTS idx_compliance_cases_created_by ON public.compliance_cases(created_by);

COMMENT ON TABLE public.compliance_cases IS 'กรณี compliance ที่ Super_Admin สร้างเพื่อเข้าถึงข้อมูลผู้ใช้จนกว่าจะปิด case';

ALTER TABLE public.compliance_cases ENABLE ROW LEVEL SECURITY;

-- 2. Compliance Case Access Log (audit trail)
-- บันทึกทุกครั้งที่ Super_Admin เข้าถึงข้อมูลผ่าน compliance case
CREATE TABLE IF NOT EXISTS public.compliance_access_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  case_id uuid NOT NULL REFERENCES public.compliance_cases(id) ON DELETE CASCADE,
  accessed_by uuid NOT NULL REFERENCES auth.users(id),
  resource_type text NOT NULL, -- 'user_devices', 'messages', 'scan_logs', 'gps_locations', etc.
  resource_id uuid,
  action text NOT NULL CHECK (action IN ('view', 'export', 'delete')),
  ip_address inet,
  user_agent text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_compliance_access_logs_case ON public.compliance_access_logs(case_id);

COMMENT ON TABLE public.compliance_access_logs IS 'Audit log สำหรับการเข้าถึงข้อมูลผ่าน compliance case';

ALTER TABLE public.compliance_access_logs ENABLE ROW LEVEL SECURITY;

-- 3. GPS/Location Tracking Log (สำหรับ Maps)
CREATE TABLE IF NOT EXISTS public.user_location_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  device_id text,
  latitude numeric(10,7) NOT NULL,
  longitude numeric(10,7) NOT NULL,
  accuracy numeric,
  altitude numeric,
  speed numeric,
  heading numeric,
  source text DEFAULT 'app' CHECK (source IN ('app', 'gps', 'network', 'manual')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_location_logs_user ON public.user_location_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_user_location_logs_created ON public.user_location_logs(created_at DESC);

COMMENT ON TABLE public.user_location_logs IS 'ประวัติตำแหน่ง GPS ของผู้ใช้ สำหรับ Maps และ tracking';

ALTER TABLE public.user_location_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- ฟังก์ชันตรวจสอบ Super_Admin (global, reusable)
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_roles ar
    WHERE ar.user_id = auth.uid()
      AND ar.role = 'super_admin'::public.admin_role_type
      AND (ar.is_active IS NULL OR ar.is_active = true)
  );
$$;

COMMENT ON FUNCTION public.is_super_admin() IS 'ตรวจสอบว่า current user เป็น Super_Admin หรือไม่';
GRANT EXECUTE ON FUNCTION public.is_super_admin() TO authenticated;

-- ฟังก์ชันตรวจสอบว่ามี active compliance case สำหรับ target user หรือไม่
CREATE OR REPLACE FUNCTION public.has_active_compliance_case(p_target_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.compliance_cases cc
    WHERE cc.target_user_id = p_target_user_id
      AND cc.status = 'active'
      AND public.is_super_admin()
  );
$$;

COMMENT ON FUNCTION public.has_active_compliance_case(uuid) IS 'ตรวจสอบว่า Super_Admin มี active compliance case สำหรับ user นี้หรือไม่';
GRANT EXECUTE ON FUNCTION public.has_active_compliance_case(uuid) TO authenticated;

-- ฟังก์ชันตรวจสอบว่า current Super_Admin มี active case สำหรับ target user (ที่ตัวเองสร้าง หรือเป็น super_admin)
CREATE OR REPLACE FUNCTION public.can_access_user_data(p_target_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT 
    -- เป็นเจ้าของข้อมูลเอง
    auth.uid() = p_target_user_id
    OR
    -- เป็น Super_Admin และมี active case สำหรับ user นี้
    (public.is_super_admin() AND public.has_active_compliance_case(p_target_user_id));
$$;

COMMENT ON FUNCTION public.can_access_user_data(uuid) IS 'ตรวจสอบว่าสามารถเข้าถึงข้อมูลของ user ได้หรือไม่ (ตัวเอง หรือ Super_Admin with active case)';
GRANT EXECUTE ON FUNCTION public.can_access_user_data(uuid) TO authenticated;

-- ============================================================================
-- RLS Policies for compliance_cases
-- ============================================================================

-- เฉพาะ Super_Admin สร้าง/ดู/แก้ไข compliance cases
CREATE POLICY "Super_Admin manages compliance_cases"
  ON public.compliance_cases FOR ALL
  TO authenticated
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- ============================================================================
-- RLS Policies for compliance_access_logs
-- ============================================================================

-- เฉพาะ Super_Admin ดู audit logs
CREATE POLICY "Super_Admin views compliance_access_logs"
  ON public.compliance_access_logs FOR SELECT
  TO authenticated
  USING (public.is_super_admin());

-- Super_Admin บันทึก access log
CREATE POLICY "Super_Admin inserts compliance_access_logs"
  ON public.compliance_access_logs FOR INSERT
  TO authenticated
  WITH CHECK (public.is_super_admin() AND accessed_by = auth.uid());

-- ============================================================================
-- RLS Policies for user_devices
-- ============================================================================

-- ลบ policies เดิม (ถ้ามี)
DROP POLICY IF EXISTS "Users read own devices" ON public.user_devices;
DROP POLICY IF EXISTS "Users insert own devices" ON public.user_devices;
DROP POLICY IF EXISTS "Users update own devices" ON public.user_devices;

-- ผู้ใช้เห็นเฉพาะอุปกรณ์ของตัวเอง; Super_Admin with active case เห็นได้
CREATE POLICY "Users read own devices or Super_Admin with case"
  ON public.user_devices FOR SELECT
  TO authenticated
  USING (public.can_access_user_data(user_id));

-- ผู้ใช้ลงทะเบียนอุปกรณ์ของตัวเอง
CREATE POLICY "Users insert own devices"
  ON public.user_devices FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- ผู้ใช้อัปเดตอุปกรณ์ของตัวเอง
CREATE POLICY "Users update own devices"
  ON public.user_devices FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Super_Admin with case สามารถลบอุปกรณ์ได้ (สำหรับ compliance)
CREATE POLICY "Super_Admin with case can delete devices"
  ON public.user_devices FOR DELETE
  TO authenticated
  USING (public.is_super_admin() AND public.has_active_compliance_case(user_id));

-- ============================================================================
-- RLS Policies for user_location_logs (GPS/Maps)
-- ============================================================================

-- ผู้ใช้เห็นเฉพาะตำแหน่งของตัวเอง; Super_Admin with active case เห็นได้
CREATE POLICY "Users read own locations or Super_Admin with case"
  ON public.user_location_logs FOR SELECT
  TO authenticated
  USING (public.can_access_user_data(user_id));

-- ผู้ใช้บันทึกตำแหน่งของตัวเอง
CREATE POLICY "Users insert own locations"
  ON public.user_location_logs FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Super_Admin with case สามารถลบตำแหน่งได้ (สำหรับ compliance/GDPR)
CREATE POLICY "Super_Admin with case can delete locations"
  ON public.user_location_logs FOR DELETE
  TO authenticated
  USING (public.is_super_admin() AND public.has_active_compliance_case(user_id));

-- ============================================================================
-- RLS Policies for Chat (conversations, messages, etc.)
-- ============================================================================

-- conversations: ผู้ใช้เห็นเฉพาะ conversation ที่ตัวเองเป็น participant
DROP POLICY IF EXISTS "Users read own conversations" ON public.conversations;
DROP POLICY IF EXISTS "Participants can view conversations" ON public.conversations;

CREATE POLICY "Users read conversations they participate in"
  ON public.conversations FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.conversation_participants cp
      WHERE cp.conversation_id = conversations.id AND cp.user_id = auth.uid()
    )
    OR
    -- Super_Admin with active case for any participant
    (public.is_super_admin() AND EXISTS (
      SELECT 1 FROM public.conversation_participants cp
      JOIN public.compliance_cases cc ON cc.target_user_id = cp.user_id AND cc.status = 'active'
      WHERE cp.conversation_id = conversations.id
    ))
  );

-- messages: ผู้ใช้เห็นเฉพาะ messages ใน conversation ที่ตัวเองเป็น participant
DROP POLICY IF EXISTS "Users read messages in their conversations" ON public.messages;
DROP POLICY IF EXISTS "Participants can view messages" ON public.messages;

CREATE POLICY "Users read messages in their conversations"
  ON public.messages FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.conversation_participants cp
      WHERE cp.conversation_id = messages.conversation_id AND cp.user_id = auth.uid()
    )
    OR
    -- Super_Admin with active case for sender
    (public.is_super_admin() AND public.has_active_compliance_case(messages.sender_id))
  );

-- messages INSERT: ผู้ใช้ส่งข้อความใน conversation ที่ตัวเองเป็น participant
DROP POLICY IF EXISTS "Users send messages" ON public.messages;
DROP POLICY IF EXISTS "Participants can send messages" ON public.messages;

CREATE POLICY "Users send messages in their conversations"
  ON public.messages FOR INSERT
  TO authenticated
  WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.conversation_participants cp
      WHERE cp.conversation_id = messages.conversation_id AND cp.user_id = auth.uid()
    )
  );

-- conversation_participants: ผู้ใช้เห็นเฉพาะ participants ใน conversation ที่ตัวเองอยู่
DROP POLICY IF EXISTS "Users view participants" ON public.conversation_participants;

CREATE POLICY "Users view conversation participants"
  ON public.conversation_participants FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.conversation_participants cp2
      WHERE cp2.conversation_id = conversation_participants.conversation_id AND cp2.user_id = auth.uid()
    )
    OR
    (public.is_super_admin() AND public.has_active_compliance_case(conversation_participants.user_id))
  );

-- ============================================================================
-- Update scan_logs RLS to include compliance case check
-- ============================================================================

-- ลบ policy เดิมและสร้างใหม่ที่รวม compliance case
DROP POLICY IF EXISTS "Users read own scan_logs" ON public.scan_logs;

CREATE POLICY "Users read own scan_logs or Super_Admin with case"
  ON public.scan_logs FOR SELECT
  TO authenticated
  USING (
    auth.uid() = scan_logs.user_id
    OR public.is_super_admin()
    OR public.has_active_compliance_case(scan_logs.user_id)
  );

-- ============================================================================
-- Enable Realtime for relevant tables
-- ============================================================================

-- เปิด Realtime สำหรับ chat และ location
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.conversation_participants;
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_location_logs;
ALTER PUBLICATION supabase_realtime ADD TABLE public.compliance_cases;

-- ============================================================================
-- Trigger: Auto-update updated_at for compliance_cases
-- ============================================================================

CREATE OR REPLACE FUNCTION public.update_compliance_case_timestamp()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  IF NEW.status = 'closed' AND OLD.status != 'closed' THEN
    NEW.closed_at = now();
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_compliance_cases_updated ON public.compliance_cases;
CREATE TRIGGER trg_compliance_cases_updated
  BEFORE UPDATE ON public.compliance_cases
  FOR EACH ROW
  EXECUTE FUNCTION public.update_compliance_case_timestamp();

-- ============================================================================
-- Summary:
-- ============================================================================
-- 1. compliance_cases: Super_Admin สร้าง case เพื่อเข้าถึงข้อมูลผู้ใช้
-- 2. compliance_access_logs: Audit trail ทุกการเข้าถึง
-- 3. user_location_logs: GPS/Maps tracking
-- 4. RLS ให้ผู้ใช้เห็นเฉพาะข้อมูลตัวเอง
-- 5. Super_Admin with active case เข้าถึงได้จนกว่าจะปิด case
-- 6. Realtime enabled สำหรับ chat และ location
-- ============================================================================
