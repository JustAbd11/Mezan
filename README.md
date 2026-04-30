# 🏦 نظام تعديل الميزانية الاحترافي
## دليل الإعداد والتشغيل الكامل

---

## 📋 المحتويات

1. [نظرة عامة](#نظرة-عامة)
2. [المتطلبات](#المتطلبات)
3. [إعداد قاعدة بيانات Supabase](#إعداد-قاعدة-بيانات-supabase)
4. [إعداد النظام](#إعداد-النظام)
5. [هيكل قاعدة البيانات](#هيكل-قاعدة-البيانات)
6. [الأمان](#الأمان)
7. [استكشاف الأخطاء](#استكشاف-الأخطاء)
8. [الأسئلة الشائعة](#الأسئلة-الشائعة)

---

## 🎯 نظرة عامة

نظام متكامل وآمن لتعديل ومعالجة ملفات الميزانية تلقائياً مع المميزات التالية:

### ✨ المميزات الرئيسية:
- ✅ رفع ومعالجة ملفات Word, PDF, Excel
- ✅ تعديل تلقائي للتنسيق (Arial حجم 11)
- ✅ تطبيق Bold على العناوين
- ✅ توسيع الهوامش اليمنى
- ✅ تصحيح الأخطاء الإملائية
- ✅ تنسيق الأرقام حسب المعايير الدولية
- ✅ إنشاء ملف ملاحظات تفصيلي
- ✅ تحميل النتائج بصيغ متعددة (Word, PDF, Excel)
- ✅ نظام أمان متقدم مع Supabase
- ✅ تسجيل جميع الأنشطة
- ✅ واجهة مستخدم احترافية

---

## 🔧 المتطلبات

### 1. حساب Supabase (مجاني)
- قم بالتسجيل على: https://supabase.com
- الخطة المجانية كافية للبدء

### 2. متصفح حديث
- Chrome, Firefox, Safari, Edge (آخر إصدار)

### 3. الملفات المطلوبة:
```
project/
├── index.html              (الملف الرئيسي)
├── supabase-config.js      (ملف الإعدادات)
├── database-schema.sql     (سكريبت قاعدة البيانات)
└── README.md              (هذا الملف)
```

---

## 🗄️ إعداد قاعدة بيانات Supabase

### الخطوة 1: إنشاء مشروع جديد

1. اذهب إلى: https://supabase.com/dashboard
2. انقر على **"New Project"**
3. املأ البيانات:
   - **Name**: نظام الميزانية
   - **Database Password**: اختر كلمة مرور قوية (احفظها!)
   - **Region**: اختر المنطقة الأقرب لك (مثل: Middle East)
   - **Pricing Plan**: Free (للبداية)
4. انقر **"Create new project"**
5. انتظر 2-3 دقائق حتى يتم إنشاء المشروع

### الخطوة 2: تنفيذ سكريبت قاعدة البيانات

1. في لوحة تحكم Supabase، اذهب إلى **"SQL Editor"** من القائمة الجانبية
2. انقر على **"New Query"**
3. افتح ملف `database-schema.sql`
4. انسخ **المحتوى بالكامل**
5. الصقه في SQL Editor
6. انقر على **"RUN"** أو اضغط `Ctrl + Enter`
7. انتظر حتى ترى رسالة **"Success"**

### الخطوة 3: إنشاء Storage Buckets

1. اذهب إلى **"Storage"** من القائمة الجانبية
2. انقر على **"Create a new bucket"**
3. أنشئ 3 buckets بالأسماء التالية:

#### Bucket 1: original-files
```
Name: original-files
Public: ❌ No
Allowed MIME types: application/vnd.openxmlformats-officedocument.wordprocessingml.document, application/pdf, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
File size limit: 10 MB
```

#### Bucket 2: processed-files
```
Name: processed-files
Public: ❌ No
Allowed MIME types: application/vnd.openxmlformats-officedocument.wordprocessingml.document, application/pdf, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
File size limit: 10 MB
```

#### Bucket 3: notes-files
```
Name: notes-files
Public: ❌ No
Allowed MIME types: text/plain
File size limit: 1 MB
```

### الخطوة 4: إعداد Storage Policies

لكل bucket، قم بإضافة Policies التالية:

1. اذهب إلى **Storage** > اختر bucket > **Policies**
2. انقر **"New Policy"**

#### Policy للرفع (Upload):
```
Policy Name: Allow authenticated uploads
Target roles: authenticated
Policy definition: SELECT THE TEMPLATE "Enable insert for authenticated users only"
```

#### Policy للقراءة (Read):
```
Policy Name: Allow users to read own files
Target roles: authenticated
Policy definition: SELECT THE TEMPLATE "Enable read access for authenticated users only"
```

### الخطوة 5: الحصول على API Keys

1. اذهب إلى **"Project Settings"** (أيقونة الترس في الأسفل)
2. اذهب إلى **"API"**
3. ستجد:
   - **Project URL**: انسخه (مثل: https://xxxxx.supabase.co)
   - **anon public**: انسخ المفتاح

---

## ⚙️ إعداد النظام

### الخطوة 1: تحديث ملف supabase-config.js

افتح ملف `supabase-config.js` وحدّث القيم التالية:

```javascript
const SUPABASE_CONFIG = {
    SUPABASE_URL: 'https://your-project-id.supabase.co', // ضع Project URL هنا
    SUPABASE_ANON_KEY: 'your-anon-key-here', // ضع anon public key هنا
    
    // باقي الإعدادات لا تتغير
    BUCKETS: {
        ORIGINAL_FILES: 'original-files',
        PROCESSED_FILES: 'processed-files',
        NOTES_FILES: 'notes-files'
    },
    // ...
};
```

### الخطوة 2: إنشاء مستخدم Admin

هناك طريقتان:

#### الطريقة الأولى: عبر SQL Editor
```sql
-- قم بتشغيل هذا الأمر في SQL Editor
INSERT INTO admins (username, password_hash, full_name, email, is_active)
VALUES (
    'Admin',
    '$2a$10$YnwE7Z8VH3KqGvN4xQXMxOLQZKlN0vYrN6pXmB5hXXXXXXXXXXXX', -- استخدم bcrypt لتشفير 'Pass1122'
    'مدير النظام',
    'admin@example.com',
    true
);
```

#### الطريقة الثانية: استخدام bcrypt online
1. اذهب إلى: https://bcrypt-generator.com/
2. أدخل كلمة المرور: `Pass1122`
3. Rounds: 10
4. انسخ الـ hash الناتج
5. استخدمه في SQL بدلاً من الـ hash أعلاه

### الخطوة 3: تشغيل النظام

1. افتح ملف `index.html` في متصفحك
2. سجل الدخول باستخدام:
   - Username: `Admin`
   - Password: `Pass1122`

---

## 📊 هيكل قاعدة البيانات

### الجداول الرئيسية:

#### 1. admins (المستخدمين)
```sql
- id (UUID)
- username (VARCHAR)
- password_hash (TEXT)
- full_name (VARCHAR)
- email (VARCHAR)
- created_at (TIMESTAMP)
- last_login (TIMESTAMP)
- is_active (BOOLEAN)
```

#### 2. uploaded_files (الملفات المرفوعة)
```sql
- id (UUID)
- admin_id (UUID)
- original_filename (VARCHAR)
- file_type (VARCHAR)
- file_size (INTEGER)
- file_path (TEXT)
- upload_date (TIMESTAMP)
- status (VARCHAR)
- processing_started_at (TIMESTAMP)
- processing_completed_at (TIMESTAMP)
```

#### 3. processed_files (الملفات المعالجة)
```sql
- id (UUID)
- uploaded_file_id (UUID)
- processed_filename (VARCHAR)
- file_type (VARCHAR)
- file_path (TEXT)
- file_size (INTEGER)
- created_at (TIMESTAMP)
```

#### 4. file_notes (الملاحظات)
```sql
- id (UUID)
- uploaded_file_id (UUID)
- page_number (VARCHAR)
- note_type (VARCHAR)
- note_type_ar (VARCHAR)
- original_text (TEXT)
- corrected_text (TEXT)
- message (TEXT)
- severity (VARCHAR)
- created_at (TIMESTAMP)
```

#### 5. activity_logs (سجل الأنشطة)
```sql
- id (UUID)
- admin_id (UUID)
- action_type (VARCHAR)
- description (TEXT)
- ip_address (INET)
- user_agent (TEXT)
- created_at (TIMESTAMP)
```

#### 6. system_statistics (الإحصائيات)
```sql
- id (UUID)
- date (DATE)
- total_uploads (INTEGER)
- total_processed (INTEGER)
- total_downloads (INTEGER)
- total_errors (INTEGER)
- avg_processing_time_seconds (DECIMAL)
- updated_at (TIMESTAMP)
```

---

## 🔐 الأمان

### مميزات الأمان المطبقة:

1. **Row Level Security (RLS)**: مفعّل على جميع الجداول
2. **تشفير كلمات المرور**: باستخدام bcrypt
3. **Storage Policies**: التحكم في الوصول للملفات
4. **Session Management**: إدارة الجلسات بشكل آمن
5. **Activity Logging**: تسجيل جميع الأنشطة
6. **Input Validation**: التحقق من المدخلات
7. **File Type Validation**: قبول صيغ محددة فقط

### نصائح أمنية:

- ✅ غيّر كلمة المرور الافتراضية فوراً
- ✅ استخدم HTTPS دائماً في الإنتاج
- ✅ لا تشارك API Keys علناً
- ✅ فعّل 2FA للمستخدمين المهمين
- ✅ راجع Activity Logs بانتظام
- ✅ حافظ على نسخ احتياطية دورية

---

## 🐛 استكشاف الأخطاء

### المشكلة: لا يتم الاتصال بـ Supabase
**الحل:**
1. تأكد من صحة SUPABASE_URL و SUPABASE_ANON_KEY
2. افتح Console في المتصفح (F12) وتحقق من الأخطاء
3. تأكد من تفعيل JavaScript في المتصفح

### المشكلة: فشل تسجيل الدخول
**الحل:**
1. تأكد من إنشاء مستخدم Admin في قاعدة البيانات
2. تحقق من صحة password_hash
3. تأكد من أن is_active = true

### المشكلة: فشل رفع الملفات
**الحل:**
1. تأكد من إنشاء Storage Buckets
2. تحقق من Storage Policies
3. تأكد من حجم الملف أقل من الحد المسموح (10MB)

### المشكلة: لا تظهر الملاحظات
**الحل:**
1. تحقق من جدول file_notes في قاعدة البيانات
2. افتح Console وتحقق من الأخطاء
3. تأكد من اكتمال معالجة الملف

---

## ❓ الأسئلة الشائعة

### س: هل يمكن إضافة مستخدمين أكثر؟
ج: نعم، يمكنك إضافة مستخدمين عبر SQL أو بناء صفحة إدارة

### س: ما هو الحد الأقصى لحجم الملف؟
ج: افتراضياً 10MB، يمكن تغييره من إعدادات Storage Bucket

### س: هل البيانات آمنة؟
ج: نعم، النظام يستخدم RLS، تشفير، و Storage Policies

### س: كم عدد الملفات التي يمكن رفعها؟
ج: الخطة المجانية: 1GB تخزين، للترقية اختر Pro Plan

### س: هل يمكن استخدامه في الإنتاج؟
ج: نعم، لكن يُنصح بـ:
- استخدام Environment Variables
- تفعيل HTTPS
- مراجعة Security Policies
- عمل نسخ احتياطية دورية

### س: كيف أحصل على الإحصائيات؟
ج: استخدم View في قاعدة البيانات:
```sql
SELECT * FROM daily_statistics;
SELECT * FROM files_summary;
```

---

## 📞 الدعم والمساعدة

### موارد Supabase:
- 📖 Documentation: https://supabase.com/docs
- 💬 Discord: https://discord.supabase.com
- 🐛 GitHub Issues: https://github.com/supabase/supabase

### نصائح إضافية:
1. راجع Supabase Logs للأخطاء
2. استخدم Postman لاختبار API
3. فعّل Database Backups من Settings

---

## 📝 ملاحظات مهمة

1. **النسخ الاحتياطي**: احفظ نسخة من database-schema.sql دائماً
2. **التحديثات**: راجع Supabase Updates بانتظام
3. **الأداء**: مراقبة استخدام Database في Dashboard
4. **التكاليف**: راقب استهلاك Storage و Bandwidth
5. **الترقية**: للمشاريع الكبيرة، فكر في Pro Plan ($25/شهر)

---

## ✅ قائمة التحقق النهائية

قبل الاستخدام، تأكد من:

- [ ] إنشاء مشروع Supabase
- [ ] تنفيذ database-schema.sql
- [ ] إنشاء 3 Storage Buckets
- [ ] إضافة Storage Policies
- [ ] نسخ API Keys إلى supabase-config.js
- [ ] إنشاء مستخدم Admin
- [ ] اختبار تسجيل الدخول
- [ ] اختبار رفع ملف
- [ ] اختبار التحميل
- [ ] مراجعة Activity Logs

---

## 🎉 تم بنجاح!

إذا أكملت جميع الخطوات، نظامك جاهز الآن للاستخدام!

**استمتع بنظام تعديل الميزانية الاحترافي!** 🚀