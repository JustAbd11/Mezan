// ====================================
// Supabase Configuration File
// ملف إعداد الاتصال بقاعدة بيانات Supabase
// ====================================

// ملاحظة مهمة: 
// يجب إنشاء مشروع جديد في Supabase على الرابط: https://supabase.com
// ثم استبدال القيم التالية بالقيم الخاصة بمشروعك

const SUPABASE_CONFIG = {
    // URL الخاص بمشروع Supabase
    // يمكن الحصول عليه من: Project Settings > API > Project URL
    SUPABASE_URL: 'https://ddrnvybfvdxozmmurzpu.supabase.co',
    
    // المفتاح العام (anon key)
    // يمكن الحصول عليه من: Project Settings > API > Project API keys > anon public
    SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRkcm52eWJmdmR4b3ptbXVyenB1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc1NTA3NDIsImV4cCI6MjA5MzEyNjc0Mn0.n-sJCNg5BBty-BF-20HHXFfBN_PttbZr6YzXJo12ZeA',
    
    // Storage Buckets Names
    BUCKETS: {
        ORIGINAL_FILES: 'original-files',
        PROCESSED_FILES: 'processed-files',
        NOTES_FILES: 'notes-files'
    },
    
    // جداول قاعدة البيانات
    TABLES: {
        ADMINS: 'admins',
        UPLOADED_FILES: 'uploaded_files',
        PROCESSED_FILES: 'processed_files',
        FILE_NOTES: 'file_notes',
        ACTIVITY_LOGS: 'activity_logs',
        SYSTEM_STATISTICS: 'system_statistics'
    }
};

// تصدير الإعدادات
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SUPABASE_CONFIG;
}

// ====================================
// خطوات الإعداد:
// ====================================

/*
1. إنشاء مشروع جديد في Supabase:
   - اذهب إلى: https://supabase.com/dashboard
   - انقر على "New Project"
   - اختر اسم المشروع وكلمة المرور لقاعدة البيانات
   - اختر المنطقة الجغرافية (اختر الأقرب لك)

2. تنفيذ سكريبت قاعدة البيانات:
   - اذهب إلى: SQL Editor في لوحة تحكم Supabase
   - افتح ملف database-schema.sql
   - انسخ المحتوى بالكامل والصقه في SQL Editor
   - اضغط على "RUN" لتنفيذ السكريبت

3. إنشاء Storage Buckets:
   - اذهب إلى: Storage في لوحة التحكم
   - أنشئ 3 buckets:
     a) original-files (للملفات الأصلية)
     b) processed-files (للملفات المعالجة)
     c) notes-files (لملفات الملاحظات)
   
   - لكل bucket، اضبط الإعدادات التالية:
     * Public: No (خاص)
     * Allowed MIME types: 
       - original-files: .docx, .pdf, .xlsx
       - processed-files: .docx, .pdf, .xlsx
       - notes-files: .txt
     * File size limit: 10 MB (أو حسب الحاجة)

4. إعداد Storage Policies:
   - لكل bucket، أضف Policy التالية:
   
   Policy Name: "Allow authenticated uploads"
   Policy Definition:
   ```sql
   (bucket_id = 'bucket-name'::text) AND (auth.role() = 'authenticated'::text)
   ```
   Operations: INSERT
   
   Policy Name: "Allow authenticated to read own files"
   Policy Definition:
   ```sql
   (bucket_id = 'bucket-name'::text) AND 
   ((storage.foldername(name))[1] = (auth.uid())::text)
   ```
   Operations: SELECT

5. تكوين Authentication:
   - اذهب إلى: Authentication > Providers
   - فعّل "Email" provider
   - اختياري: فعّل 2FA للأمان الإضافي

6. إنشاء مستخدم Admin:
   - يمكن إنشاؤه من خلال Supabase Dashboard
   - أو استخدام API من النظام نفسه
   - تأكد من تشفير كلمة المرور باستخدام bcrypt

7. الحصول على API Keys:
   - اذهب إلى: Project Settings > API
   - انسخ:
     * Project URL
     * anon public key
   - الصقها في ملف supabase-config.js

8. اختبار الاتصال:
   - افتح ملف budget-system.html
   - سجل الدخول باستخدام حساب Admin
   - جرب رفع ملف للتأكد من عمل الاتصال

9. الأمان (مهم جداً):
   - لا تشارك SUPABASE_ANON_KEY علناً
   - استخدم Environment Variables في الإنتاج
   - فعّل RLS (Row Level Security) على جميع الجداول
   - راجع Policies بانتظام

10. النسخ الاحتياطي:
    - فعّل Automatic Backups من لوحة التحكم
    - احفظ نسخة من database-schema.sql
*/

// ====================================
// معلومات إضافية مفيدة:
// ====================================

/*
الحد الأقصى للملفات في الخطة المجانية:
- Storage: 1 GB
- Database: 500 MB
- Bandwidth: 5 GB

للترقية إلى خطة Pro:
- $25/شهر
- Storage: 100 GB
- Database: 8 GB
- Bandwidth: 250 GB

روابط مفيدة:
- Documentation: https://supabase.com/docs
- Storage Guide: https://supabase.com/docs/guides/storage
- Row Level Security: https://supabase.com/docs/guides/auth/row-level-security
- JavaScript Client: https://supabase.com/docs/reference/javascript
*/