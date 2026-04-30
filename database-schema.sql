-- ====================================
-- جدول المدراء (مرتبط بـ Supabase Auth)
-- ====================================
CREATE TABLE IF NOT EXISTS admins (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID UNIQUE, -- يربط مع auth.uid()
    username VARCHAR(50) UNIQUE,
    full_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true
);

-- ====================================
-- جدول الملفات
-- ====================================
CREATE TABLE IF NOT EXISTS uploaded_files (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID, -- بدل admin_id
    original_filename VARCHAR(255) NOT NULL,
    file_type VARCHAR(10) CHECK (file_type IN ('docx', 'pdf', 'xlsx')),
    file_size INTEGER,
    file_path TEXT NOT NULL,
    upload_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'uploaded',
    processing_started_at TIMESTAMP,
    processing_completed_at TIMESTAMP
);

-- ====================================
-- تفعيل RLS
-- ====================================
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE uploaded_files ENABLE ROW LEVEL SECURITY;

-- ====================================
-- Policies (الأهم 🔥)
-- ====================================

-- admins
DROP POLICY IF EXISTS "Admins can view their own data" ON admins;

CREATE POLICY "Admins access"
ON admins
FOR SELECT
USING (auth.uid() = user_id);

-- uploaded_files
DROP POLICY IF EXISTS "Admins can view their uploaded files" ON uploaded_files;

CREATE POLICY "Users can view their files"
ON uploaded_files
FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert files"
ON uploaded_files
FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update files"
ON uploaded_files
FOR UPDATE
USING (auth.uid() = user_id);
