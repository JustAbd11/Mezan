-- ====================================
-- Supabase Database Schema
-- نظام تعديل الميزانية الاحترافي
-- ====================================

-- إنشاء جدول المستخدمين (Admins)
CREATE TABLE IF NOT EXISTS admins (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true
);

-- إنشاء جدول الملفات المرفوعة
CREATE TABLE IF NOT EXISTS uploaded_files (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    admin_id UUID REFERENCES admins(id) ON DELETE CASCADE,
    original_filename VARCHAR(255) NOT NULL,
    file_type VARCHAR(10) NOT NULL CHECK (file_type IN ('docx', 'pdf', 'xlsx')),
    file_size INTEGER,
    file_path TEXT NOT NULL,
    upload_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'uploaded' CHECK (status IN ('uploaded', 'processing', 'completed', 'failed')),
    processing_started_at TIMESTAMP WITH TIME ZONE,
    processing_completed_at TIMESTAMP WITH TIME ZONE
);

-- إنشاء جدول الملفات المعالجة
CREATE TABLE IF NOT EXISTS processed_files (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    uploaded_file_id UUID REFERENCES uploaded_files(id) ON DELETE CASCADE,
    processed_filename VARCHAR(255) NOT NULL,
    file_type VARCHAR(10) NOT NULL CHECK (file_type IN ('docx', 'pdf', 'xlsx')),
    file_path TEXT NOT NULL,
    file_size INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء جدول الملاحظات
CREATE TABLE IF NOT EXISTS file_notes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    uploaded_file_id UUID REFERENCES uploaded_files(id) ON DELETE CASCADE,
    page_number VARCHAR(50),
    note_type VARCHAR(50) NOT NULL CHECK (note_type IN ('spelling', 'formatting', 'numbers', 'font', 'margins', 'structure')),
    note_type_ar VARCHAR(50),
    original_text TEXT,
    corrected_text TEXT,
    message TEXT NOT NULL,
    severity VARCHAR(20) DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'error')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء جدول سجل العمليات
CREATE TABLE IF NOT EXISTS activity_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    admin_id UUID REFERENCES admins(id) ON DELETE SET NULL,
    action_type VARCHAR(50) NOT NULL,
    description TEXT,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء جدول إحصائيات النظام
CREATE TABLE IF NOT EXISTS system_statistics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    date DATE DEFAULT CURRENT_DATE,
    total_uploads INTEGER DEFAULT 0,
    total_processed INTEGER DEFAULT 0,
    total_downloads INTEGER DEFAULT 0,
    total_errors INTEGER DEFAULT 0,
    avg_processing_time_seconds DECIMAL(10,2),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ====================================
-- إنشاء Indexes لتحسين الأداء
-- ====================================

CREATE INDEX idx_uploaded_files_admin_id ON uploaded_files(admin_id);
CREATE INDEX idx_uploaded_files_upload_date ON uploaded_files(upload_date);
CREATE INDEX idx_uploaded_files_status ON uploaded_files(status);
CREATE INDEX idx_processed_files_uploaded_file_id ON processed_files(uploaded_file_id);
CREATE INDEX idx_file_notes_uploaded_file_id ON file_notes(uploaded_file_id);
CREATE INDEX idx_activity_logs_admin_id ON activity_logs(admin_id);
CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at);

-- ====================================
-- Row Level Security (RLS) Policies
-- ====================================

-- تفعيل RLS على جميع الجداول
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE uploaded_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE processed_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE file_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_statistics ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان للمسؤولين
CREATE POLICY "Admins can view their own data" ON admins
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Admins can update their own data" ON admins
    FOR UPDATE USING (auth.uid() = id);

-- سياسات الأمان للملفات المرفوعة
CREATE POLICY "Admins can view their uploaded files" ON uploaded_files
    FOR SELECT USING (admin_id = auth.uid());

CREATE POLICY "Admins can insert their files" ON uploaded_files
    FOR INSERT WITH CHECK (admin_id = auth.uid());

CREATE POLICY "Admins can update their files" ON uploaded_files
    FOR UPDATE USING (admin_id = auth.uid());

-- سياسات الأمان للملفات المعالجة
CREATE POLICY "Admins can view processed files" ON processed_files
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM uploaded_files 
            WHERE uploaded_files.id = processed_files.uploaded_file_id 
            AND uploaded_files.admin_id = auth.uid()
        )
    );

CREATE POLICY "Admins can insert processed files" ON processed_files
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM uploaded_files 
            WHERE uploaded_files.id = processed_files.uploaded_file_id 
            AND uploaded_files.admin_id = auth.uid()
        )
    );

-- سياسات الأمان للملاحظات
CREATE POLICY "Admins can view notes" ON file_notes
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM uploaded_files 
            WHERE uploaded_files.id = file_notes.uploaded_file_id 
            AND uploaded_files.admin_id = auth.uid()
        )
    );

CREATE POLICY "Admins can insert notes" ON file_notes
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM uploaded_files 
            WHERE uploaded_files.id = file_notes.uploaded_file_id 
            AND uploaded_files.admin_id = auth.uid()
        )
    );

-- ====================================
-- Functions & Triggers
-- ====================================

-- دالة لتحديث آخر تسجيل دخول
CREATE OR REPLACE FUNCTION update_last_login()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_login = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- دالة لحساب وقت المعالجة
CREATE OR REPLACE FUNCTION calculate_processing_time()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND OLD.status = 'processing' THEN
        NEW.processing_completed_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_processing_time
    BEFORE UPDATE ON uploaded_files
    FOR EACH ROW
    EXECUTE FUNCTION calculate_processing_time();

-- دالة لتحديث الإحصائيات
CREATE OR REPLACE FUNCTION update_statistics()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO system_statistics (date, total_uploads, updated_at)
    VALUES (CURRENT_DATE, 1, NOW())
    ON CONFLICT (date) 
    DO UPDATE SET 
        total_uploads = system_statistics.total_uploads + 1,
        updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_statistics
    AFTER INSERT ON uploaded_files
    FOR EACH ROW
    EXECUTE FUNCTION update_statistics();

-- ====================================
-- إدراج بيانات تجريبية
-- ====================================

-- إدراج مستخدم Admin افتراضي
-- ملاحظة: يجب تغيير password_hash إلى hash حقيقي في الإنتاج
INSERT INTO admins (username, password_hash, full_name, email, is_active)
VALUES (
    'Admin',
    '$2a$10$YourHashedPasswordHere', -- سيتم استبداله بـ hash حقيقي
    'مدير النظام',
    'admin@budget-system.com',
    true
) ON CONFLICT (username) DO NOTHING;

-- ====================================
-- Views للتقارير
-- ====================================

-- عرض ملخص الملفات
CREATE OR REPLACE VIEW files_summary AS
SELECT 
    uf.id,
    uf.original_filename,
    uf.file_type,
    uf.upload_date,
    uf.status,
    a.username as uploaded_by,
    COUNT(DISTINCT pf.id) as processed_versions,
    COUNT(DISTINCT fn.id) as total_notes,
    EXTRACT(EPOCH FROM (uf.processing_completed_at - uf.processing_started_at)) as processing_time_seconds
FROM uploaded_files uf
LEFT JOIN admins a ON uf.admin_id = a.id
LEFT JOIN processed_files pf ON uf.id = pf.uploaded_file_id
LEFT JOIN file_notes fn ON uf.id = fn.uploaded_file_id
GROUP BY uf.id, a.username;

-- عرض الإحصائيات اليومية
CREATE OR REPLACE VIEW daily_statistics AS
SELECT 
    date,
    total_uploads,
    total_processed,
    total_downloads,
    total_errors,
    avg_processing_time_seconds,
    updated_at
FROM system_statistics
ORDER BY date DESC;

-- ====================================
-- Storage Bucket Configuration
-- ====================================

-- يجب إنشاء Buckets في Supabase Dashboard:
-- 1. original-files (للملفات الأصلية)
-- 2. processed-files (للملفات المعالجة)
-- 3. notes-files (لملفات الملاحظات)

-- Storage Policies (يتم تطبيقها من Dashboard)
-- Bucket: original-files
--   - Allow authenticated uploads
--   - Allow authenticated reads for own files
-- Bucket: processed-files
--   - Allow authenticated reads for own files
-- Bucket: notes-files
--   - Allow authenticated reads for own files

COMMENT ON TABLE admins IS 'جدول المستخدمين المسؤولين عن النظام';
COMMENT ON TABLE uploaded_files IS 'جدول الملفات المرفوعة من قبل المستخدمين';
COMMENT ON TABLE processed_files IS 'جدول الملفات المعالجة والمعدلة';
COMMENT ON TABLE file_notes IS 'جدول الملاحظات والتعديلات على الملفات';
COMMENT ON TABLE activity_logs IS 'سجل جميع الأنشطة في النظام';
COMMENT ON TABLE system_statistics IS 'إحصائيات استخدام النظام';
