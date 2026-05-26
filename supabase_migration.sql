-- ============================================================
-- JobGo: Realtime Chat & Notifications Schema Migration (Dùng Bảng Gốc)
-- Chạy file này trong Supabase Dashboard > SQL Editor
-- ============================================================

-- 1. Thêm cột related_id và related_type cho bảng notifications nếu chưa có
ALTER TABLE notifications
  ADD COLUMN IF NOT EXISTS related_id   TEXT,
  ADD COLUMN IF NOT EXISTS related_type TEXT;

-- 2. Bật Realtime cho các bảng gốc
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'messages'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE messages;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'notifications'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
  END IF;
END $$;

-- 3. Tạo helper function lấy u_id của user hiện tại từ auth.uid()
CREATE OR REPLACE FUNCTION get_my_user_id()
RETURNS INT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT u_id FROM users WHERE auth_uid = auth.uid() LIMIT 1;
$$;

-- 4. Bật Row Level Security (RLS) cho messages và notifications
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- 5. Thiết lập RLS Policies cho bảng messages (dùng u_id nguyên bản)
DROP POLICY IF EXISTS "Users read own messages" ON messages;
CREATE POLICY "Users read own messages" ON messages
  FOR SELECT USING (
    sender_id = get_my_user_id() OR receiver_id = get_my_user_id()
  );

DROP POLICY IF EXISTS "Users insert own messages" ON messages;
CREATE POLICY "Users insert own messages" ON messages
  FOR INSERT WITH CHECK (
    sender_id = get_my_user_id()
  );

DROP POLICY IF EXISTS "Users update own messages" ON messages;
CREATE POLICY "Users update own messages" ON messages
  FOR UPDATE USING (
    receiver_id = get_my_user_id()
  ) WITH CHECK (
    receiver_id = get_my_user_id()
  );

-- 6. Thiết lập RLS Policies cho bảng notifications
DROP POLICY IF EXISTS "Users read own notifications" ON notifications;
CREATE POLICY "Users read own notifications" ON notifications
  FOR SELECT USING (
    u_id = get_my_user_id()
  );

DROP POLICY IF EXISTS "Users update own notifications" ON notifications;
CREATE POLICY "Users update own notifications" ON notifications
  FOR UPDATE USING (
    u_id = get_my_user_id()
  ) WITH CHECK (
    u_id = get_my_user_id()
  );
