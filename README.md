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

في الحالتين: اكتب اسماً للنسخة الجديدة (مثل `Work` أو `Account2`)، فتُفتح فوراً ويظهر اختصار
**«Claude - الاسم»** على سطح المكتب وفي قائمة Start. سجّل الدخول فيها بحسابك الثاني.
كرّر العملية لأي عدد من الحسابات.

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
انقر مرتين على **`Uninstall.cmd`** واكتب اسم النسخة. تُحذف الاختصارات فقط، ولا تُحذف البيانات إلا إذا أجبت `y`.

أو من PowerShell:

```powershell
.\Install-ClaudeInstance.ps1 -Name Work -Uninstall              # يحذف الاختصارات ويُبقي البيانات
.\Install-ClaudeInstance.ps1 -Name Work -Uninstall -RemoveData  # يحذف البيانات أيضاً
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

Either way, enter a name for the new instance (e.g. `Work`). It opens right away, and a **"Claude - Name"**
shortcut is added to the Desktop and Start menu. Sign in with your second account. Repeat for as many accounts as you need.

Parameters: `-Name <name>` · `-Uninstall` · `-RemoveData` · `-NoLaunch`

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
Double-click **`Uninstall.cmd`** and enter the instance name. Shortcuts are removed; data is deleted only if you answer `y`.

---

## License
[MIT](LICENSE) © Mohammad Al-Masri
