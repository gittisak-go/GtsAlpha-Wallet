-- scan_logs: ลบการแทรกแบบไม่ระบุตัวตน และกำหนด RLS ให้เฉพาะผู้ใช้/อุปกรณ์ที่เชื่อมต่อ + Super_Admin
-- ประวัติการใช้งานชัดเจน (user_id, device_id, created_at). การเข้าถึงสำหรับ compliance ทำได้เฉพาะ Super_Admin เท่านั้น

-- ฟังก์ชันตรวจสอบว่า current user เป็น Super_Admin (จาก admin_roles ที่มีอยู่แล้วในโปรเจกต์)
CREATE OR REPLACE FUNCTION public.is_scan_logs_super_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.admin_roles ar
    WHERE ar.user_id = auth.uid()
      AND ar.role = 'super_admin'::public.admin_role_type
      AND (ar.is_active IS NULL OR ar.is_active = true)
  );
$$;

COMMENT ON FUNCTION public.is_scan_logs_super_admin() IS 'ใช้ใน RLS ของ scan_logs: เฉพาะ Super_Admin (ผู้รับผิดชอบ compliance/นโยบาย) จึงเข้าถึงข้อมูลทั้งหมดได้';

GRANT EXECUTE ON FUNCTION public.is_scan_logs_super_admin() TO authenticated;

-- ลบนโยบายการแทรกแบบไม่ระบุตัวตน
DROP POLICY IF EXISTS "Allow anonymous insert scan_logs" ON public.scan_logs;

-- ลบนโยบายเดิมที่อนุญาต user_id IS NULL
DROP POLICY IF EXISTS "Users can insert own scan_logs" ON public.scan_logs;
DROP POLICY IF EXISTS "Users can read own scan_logs" ON public.scan_logs;

-- INSERT: เฉพาะผู้ใช้ที่ล็อกอินแล้ว และต้องใส่ user_id = ตัวเองเท่านั้น (ไม่มี anonymous)
CREATE POLICY "Authenticated users insert own scan_logs"
  ON public.scan_logs FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- SELECT: ผู้ใช้เห็นเฉพาะแถวของตัวเอง (user_id = ตัวเอง หรือ device ที่ผูกกับตัวเอง); Super_Admin เห็นทั้งหมดสำหรับ compliance/audit
CREATE POLICY "Users read own scan_logs"
  ON public.scan_logs FOR SELECT
  TO authenticated
  USING (
    auth.uid() = user_id
    OR public.is_scan_logs_super_admin()
  );

-- DELETE/UPDATE: ผู้ใช้ทั่วไปไม่สามารถลบ/แก้ไขได้; เฉพาะ Super_Admin ลบได้สำหรับ compliance (เช่น สิทธิ์การลบข้อมูลตามกฎหมาย)
CREATE POLICY "Super_Admin can delete scan_logs for compliance"
  ON public.scan_logs FOR DELETE
  TO authenticated
  USING (public.is_scan_logs_super_admin());

-- ไม่มี UPDATE policy สำหรับ user ทั่วไป – ถ้าอนาคตต้องการให้ user แก้ไขแถวตัวเองค่อยเพิ่ม
-- Super_Admin ไม่จำเป็นต้องแก้ไขแถว scan_log (เป็น log ไม่ควรแก้)
