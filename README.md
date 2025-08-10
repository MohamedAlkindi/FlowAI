## FlowAI

<details>
<summary><strong>English</strong></summary>

### What is FlowAI?
FlowAI makes AI text generation available in any Android text field. Type `/ai` then your prompt and FlowAI will replace your text in-place with AI-generated content.

### Why this project? (Problem → Solution)
- Problem: Switching apps and copy/pasting to use AI breaks your flow.
- Solution: A lightweight Accessibility Service that listens for a trigger (`/ai`) and streams AI output directly back into the focused input.

### Key Features
- Works system‑wide in any text field
- Inline generation with `/ai` trigger
- Fast streaming output (Gemini)
- Modern Flutter UI with i18n (English/Arabic)

### Download
- Grab the latest APK from the Releases page: [Releases](https://github.com/yourusername/flow-ai/releases)

### Getting Started
1) Download and install the APK from Releases
2) Open the app and complete onboarding
3) Enable the accessibility service when prompted
4) Start typing `/ai Your prompt here /` in any text field

### Development Setup
```bash
git clone https://github.com/yourusername/flow-ai.git
cd flow-ai
flutter pub get
flutter run
```

### First‑time configuration
- Enable the accessibility service from the app or system settings
- Optional: configure trigger prefix in settings (default: `/ai`)

### Troubleshooting
- If nothing happens, ensure the accessibility service is enabled
- For API/rate‑limit errors the app now shows descriptive messages

### License & Contributing
PRs are welcome. See LICENSE for details.

</details>

<details>
<summary><strong>العربية</strong></summary>

### ما هو FlowAI؟
يوفّر FlowAI توليد النصوص بالذكاء الاصطناعي داخل أي مربع نص على أندرويد. اكتب `/ai` ثم اكتب طلبك، وسيستبدل FlowAI النص مباشرة بالناتج.

### لماذا هذا المشروع؟ (المشكلة → الحل)
- المشكلة: الاعتماد على النسخ/اللصق والتنقل بين التطبيقات لاستخدام الذكاء الاصطناعي يعطّل سير العمل.
- الحل: خدمة وصول خفيفة تلتقط المُحفّز (`/ai`) وتبث الناتج مباشرة إلى حقل الإدخال النشط.

### المزايا الرئيسية
- يعمل في أي مربع نص على مستوى النظام
- توليد داخل الحقل باستخدام المُحفّز `/ai`
- بث سريع للناتج (Gemini)
- واجهة حديثة مع دعم للغات (العربية/الإنجليزية)

### التحميل
- قم بتنزيل ملف الـAPK من صفحة الإصدارات: [الإصدارات](https://github.com/yourusername/flow-ai/releases)

### البدء
1) قم بتثبيت التطبيق من صفحة الإصدارات
2) افتح التطبيق وأكمل الإعداد الأولي
3) فعّل خدمة تسهيلات الاستخدام عند الطلب
4) ابدأ بالكتابة: `/ai طلبك هنا/` في أي مربع نص

### إعداد التطوير
```bash
git clone https://github.com/yourusername/flow-ai.git
cd flow-ai
flutter pub get
flutter run
```

### الإعداد لأول مرة
- فعّل خدمة تسهيلات الاستخدام من داخل التطبيق أو من الإعدادات
- اختياري: عدّل مُحفّز الكتابة من الإعدادات (الافتراضي: `/ai`)

### استكشاف الأخطاء وإصلاحها
- إن لم يحدث شيء، تأكد من تفعيل خدمة تسهيلات الاستخدام
- عند أخطاء الشبكة أو الحدّ اليومي ستظهر الآن رسائل وصفية واضحة

### الترخيص والمساهمة
نرحّب بالمساهمات. راجع ملف الترخيص.

</details>

---

Note: FlowAI requires the Accessibility Service permission to function. The app does not collect or store your personal data; it only processes the text you explicitly send to generate AI output.
