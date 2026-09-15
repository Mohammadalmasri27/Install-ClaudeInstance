# Install-ClaudeInstance

**شغّل أكثر من حساب Claude Desktop في نفس الوقت على نفس مستخدم Windows — بنقرة واحدة، بدون VM.**
**Run multiple Claude Desktop accounts side by side on one Windows user — one click, no VM.**

[العربية](#العربية) · [English](#english)

---

## العربية

### ما المشكلة التي يحلها؟
تطبيق Claude Desktop على Windows يسمح بحساب واحد فقط في كل مرة. إن كان لديك حساب شخصي وحساب عمل،
أو حسابان لمشروعين مختلفين، فعليك تسجيل الخروج والدخول في كل مرة.

هذا السكربت ينشئ **نسخاً معزولة** من Claude Desktop تعمل معاً في نفس الوقت، ولكل نسخة:

- تسجيل دخول مستقل (حساب مختلف)
- إعدادات مستقلة
- خوادم MCP مستقلة
- جلسات ومحادثات مستقلة
- إعدادات وذاكرة مستقلة لتبويب **Code**

```
┌──────────────────────┐   ┌──────────────────────┐
│ Claude (الأصلية)     │   │ Claude - Work        │
│ الحساب الأول          │   │ الحساب الثاني         │
└──────────────────────┘   └──────────────────────┘
```

### المتطلبات
- Windows 10 أو 11
- Claude Desktop مثبت من https://claude.ai/download

### التثبيت

**الطريقة 1 — أمر واحد في PowerShell:**

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Mohammadalmasri27/Install-ClaudeInstance/main/Install-ClaudeInstance.ps1)))
```

**الطريقة 2 — نقرة مزدوجة:**
1. حمّل المستودع: **Code ← Download ZIP** وفك الضغط.
2. انقر مرتين على **`Install.cmd`**.

في الحالتين يسألك السكربت:
1. **كم نسخة تريد؟** — اضغط Enter مباشرة لإنشاء **نسخة واحدة**، أو اكتب العدد (حتى 20).
2. **اسم كل نسخة** — يقترح اسماً تلقائياً (`Account2`، `Account3`…)؛ اضغط Enter لقبوله أو اكتب اسماً مثل `Work`.

تُفتح النسخ فوراً، ويظهر لكل منها اختصار **«Claude - الاسم»** على سطح المكتب وفي قائمة Start.
سجّل الدخول في كل نافذة بالحساب الذي تريده.

**خيارات متقدمة في PowerShell:**

```powershell
.\Install-ClaudeInstance.ps1 -Count 3              # ثلاث نسخ بأسماء تلقائية
.\Install-ClaudeInstance.ps1 -Name Work,Personal   # نسخ بأسماء محددة
.\Install-ClaudeInstance.ps1 -List                 # عرض النسخ الموجودة
```

الأسماء التلقائية تتجاوز الأسماء المستخدمة، وإعادة إنشاء نسخة موجودة تحدّث اختصاراتها فقط دون المساس بتسجيل الدخول.
مع أمر التثبيت الواحد، أضف الخيارات في آخره: `... ))) -Count 3`

### كيف يعمل؟
Claude Desktop مبني على Electron، الذي يدعم المفتاح القياسي `--user-data-dir`.
يعطي السكربت كل نسخة مجلد بيانات خاصاً بها في:

```
%LOCALAPPDATA%\ClaudeInstances\<الاسم>
```

ويضبط `CLAUDE_CONFIG_DIR` لتبويب Code داخل نفس المجلد. **نسختك الأصلية لا تُمسّ إطلاقاً.**
لا يوجد برنامج يعمل في الخلفية، والاستهلاك هو فقط استهلاك نافذة Claude إضافية.
ويبحث الاختصار عن مسار Claude عند كل تشغيل، فلا يتعطل عند تحديث التطبيق.

### ملاحظات مهمة
- **تسجيل الدخول:** يُفضَّل الدخول برمز البريد الإلكتروني داخل النافذة الجديدة. إن فتح المتصفح وأعادك عبر رابط `claude://`
  فقد يصل الرابط إلى النسخة الأصلية بدلاً من الجديدة؛ تحقّق بعدها أي نافذة سجّلت الدخول.
- روابط `claude://` تفتح دائماً النسخة الأصلية.
- كل النسخ تظهر بأيقونة واحدة في شريط المهام.
- **هذه ليست ميزة رسمية من Anthropic.** قد يوقفها تحديث مستقبلي، لكن بياناتك تبقى سليمة في مجلداتها.

### الإزالة
انقر مرتين على **`Uninstall.cmd`**؛ يعرض النسخ الموجودة، ثم اكتب اسماً أو عدة أسماء مفصولة بفواصل.
تُحذف الاختصارات فقط، ولا تُحذف البيانات إلا إذا أجبت `y`.

أو من PowerShell:

```powershell
.\Install-ClaudeInstance.ps1 -Name Work -Uninstall                     # يحذف الاختصارات ويُبقي البيانات
.\Install-ClaudeInstance.ps1 -Name Work,Personal -Uninstall -RemoveData # يحذف البيانات أيضاً
```

---

## English

### What it solves
Claude Desktop on Windows signs in to one account at a time. With a personal and a work account,
you have to sign out and back in every time you switch.

This script creates **isolated Claude Desktop instances** that run at the same time, each with its own:

- sign-in (a different account)
- settings
- MCP servers
- sessions and chats
- **Code** tab settings and memory

### Requirements
- Windows 10 or 11
- Claude Desktop installed from https://claude.ai/download

### Install

**Option 1 — one PowerShell command:**

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Mohammadalmasri27/Install-ClaudeInstance/main/Install-ClaudeInstance.ps1)))
```

**Option 2 — double-click:**
1. Download the repo: **Code → Download ZIP**, then extract it.
2. Double-click **`Install.cmd`**.

Either way, the script asks:
1. **How many instances?** Press Enter to create **one**, or type a number (up to 20).
2. **A name for each.** It suggests one (`Account2`, `Account3`…); press Enter to accept or type your own, e.g. `Work`.

The instances open right away, each with a **"Claude - Name"** shortcut on the Desktop and in the Start menu.
Sign in to each window with the account you want.

**Advanced (PowerShell):**

```powershell
.\Install-ClaudeInstance.ps1 -Count 3              # three instances, automatic names
.\Install-ClaudeInstance.ps1 -Name Work,Personal   # named instances
.\Install-ClaudeInstance.ps1 -List                 # show existing instances
```

Automatic names skip ones already in use, and re-creating an existing instance only refreshes its shortcuts — its sign-in is kept.
With the one-line installer, append options at the end: `... ))) -Count 3`

All parameters: `-Name` · `-Count` · `-List` · `-Uninstall` · `-RemoveData` · `-NoLaunch`

### How it works
Claude Desktop is an Electron app, and Electron honours the standard `--user-data-dir` switch.
Each instance gets its own folder at `%LOCALAPPDATA%\ClaudeInstances\<Name>`, and `CLAUDE_CONFIG_DIR`
for the Code tab points inside it. **Your default install is never touched.** Nothing runs in the background,
and the shortcut resolves Claude's install path on every launch, so app updates don't break it.

### Caveats
- **Sign in with an email code.** A browser sign-in that returns through a `claude://` link may be delivered to your default instance instead.
- `claude://` deep links always open the default instance.
- All instances share one taskbar icon.
- **Unofficial — not an Anthropic feature.** A future Claude update could stop honouring the switch; your data stays in its folders either way.

### Uninstall
Double-click **`Uninstall.cmd`**: it lists your instances, then enter one name or several separated by commas.
Shortcuts are removed; data is deleted only if you answer `y`.

---

## License
[MIT](LICENSE) © Mohammad Al-Masri
