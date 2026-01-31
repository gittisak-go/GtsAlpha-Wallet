-- GtsAlpha Wallet – initial schema
-- Run in Supabase SQL Editor or via Supabase CLI

-- scan_logs: บันทึกการสแกน QR/NFC
CREATE TABLE IF NOT EXISTS public.scan_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text NOT NULL CHECK (type IN ('QR', 'NFC')),
  value text NOT NULL,
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  device_id text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_scan_logs_user_id ON public.scan_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_scan_logs_created_at ON public.scan_logs(created_at DESC);

ALTER TABLE public.scan_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own scan_logs"
  ON public.scan_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can read own scan_logs"
  ON public.scan_logs FOR SELECT
  USING (auth.uid() = user_id OR user_id IS NULL);

-- user_profiles: โปรไฟล์ผู้ใช้
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text,
  display_name text,
  avatar_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON public.user_profiles(email);

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own profile"
  ON public.user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.user_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.user_profiles FOR UPDATE
  USING (auth.uid() = id);

-- digital_cards: นามบัตรดิจิทัล
CREATE TABLE IF NOT EXISTS public.digital_cards (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  title text,
  company text,
  phone text,
  email text,
  website text,
  address text,
  social_links jsonb,
  qr_code_url text,
  nfc_tag_id text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_digital_cards_user_id ON public.digital_cards(user_id);
CREATE INDEX IF NOT EXISTS idx_digital_cards_updated_at ON public.digital_cards(updated_at DESC);

ALTER TABLE public.digital_cards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own digital_cards"
  ON public.digital_cards FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own digital_cards"
  ON public.digital_cards FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own digital_cards"
  ON public.digital_cards FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own digital_cards"
  ON public.digital_cards FOR DELETE
  USING (auth.uid() = user_id);

-- Allow anonymous insert for scan_logs when user_id is null (e.g. not logged in)
CREATE POLICY "Allow anonymous insert scan_logs"
  ON public.scan_logs FOR INSERT
  WITH CHECK (user_id IS NULL);
