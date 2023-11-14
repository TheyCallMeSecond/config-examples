<div align="center">
نصب و کانفیگ اتوماتیک WARP, ShadowTLS, Reality, TUIC, Hysteria2



![GitHub Repo stars](https://img.shields.io/github/stars/TheyCallMeSecond/config-examples?style=for-the-badge&color=cba6f7) ![GitHub last commit](https://img.shields.io/github/last-commit/TheyCallMeSecond/config-examples?style=for-the-badge&color=b4befe) ![GitHub forks](https://img.shields.io/github/forks/TheyCallMeSecond/config-examples?style=for-the-badge&color=cba6f7)


<br/>
</div>

------------

#### نصب :


 برای اجرای این اسکریپت نیاز به کرل دارید.اگر روی سرورتون نصب نیست با دستور زیر نصبش کنید

>sudo apt install curl 


 اسکریپت زیر رو روی سرورتون اجرا کنید : 


```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box_Config_Installer/Menu-Selector.sh)"
```
[![bash screen](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/29.png?raw=true "bash screen")](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/29.png?raw=true "bash screen")

[![bash screen](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/30.png?raw=true "bash screen")](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/30.png?raw=true "bash screen")

[![bash screen](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/31.png?raw=true "bash screen")](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/31.png?raw=true "bash screen")

[![bash screen](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/32.png?raw=true "bash screen")](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/32.png?raw=true "bash screen")

------------

#### نکات :

 بر روی سرور‌های اوبونتو دبین و سنت او اس تست شده

 حتما قبل از نصب پروتکل ها سرورتون رو اپتیمایز کنید (کارایی که انجام میشه : آپدیت و آپگرید سرور...نصب آخرین ورژن کرنل زن-مود...نصب پکیج های مورد نیاز...فعال کردن آیپی ورژن 6...فعال   کردن بی بی آر...اپتیمایز کردن کانکشن اس اس اچ...اپتیمایز کردن لیمیت ها...فعال کردن فایروال)
 

 برای فعال کردن وارپ : ابتدا کد وارپ پلاس رو از طریق اسکریپت دریافت کنید.کانفیگ وایرگارد برای وارپ بسازید بعد روی هر پروتکلی که خواستید فعالش کنید

 وارپ از طریق وایرگارد توسط هسته سینگ باکس کانکت میشه در نتیجه از حداقل منابع سرور استفاده میکنه و کمترین تاخیر رو داره (نسبت به کلاینت اصلی وارپ)

 میتونین از اسکریپت برای دریافت کد وارپ پلاس  استفاده کنید

 با پاک کردن وارپ به صورت اتوماتیک وارپ روی پروتکل هایی که فعال کرده بودین غیرفعال میشه

 قابلیت آپدیت هسته سینگ باکس استفاده شده برای اجرای پروتکل ها

 مدیریت کاربران : قابلیت حذف و اضافه کردن کاربر برای همه ی پروتکل ها

 نمایش خروجی کانفیگ به صورت لینک و کیو‌آر کد برای آیپی ورژن 6 و 4 جداگونه (برای شدو تی ال اس دو مدل خروجی برای نکوری و نکوباکس داده میشه که باید داخل این دو نرم افزار کاستم کانفیگ     بسازید و کانفیگ مرتبط رو داخلش کپی کنید)

 همچنین برای شدو تی ال اس  بر روی اندروید و آی او اس می تونین از کلاینت رسمی سینگ باکس هم استفاده کنید (از کانفیگ خروجیه مخصوص نکوباکس استفاده کنید)



------------
برای نصب هیستریا2 به صورت دستی داخل فولدر [Hysteria](https://github.com/TheyCallMeSecond/config-examples/tree/main/Hysteria "Hysteria") برید


------------


#### کلاینت
- Android
  - [v2rayNG](https://github.com/2dust/v2rayNg/releases)
  - [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases)
  - [sing-box (SFA)](https://github.com/SagerNet/sing-box/releases)
- Windows
  - [v2rayN](https://github.com/2dust/v2rayN/releases)
- Windows, Linux, macOS
  - [NekoRay](https://github.com/MatsuriDayo/nekoray/releases)
  - [Furious](https://github.com/LorenEteval/Furious/releases)
- iOS
  - [FoXray](https://apps.apple.com/app/foxray/id6448898396)
  - [Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118)
  - [sing-box (SFM)](https://github.com/SagerNet/sing-box/releases)
  - [Stash](https://apps.apple.com/app/stash/id1596063349)

  ------------
 
  ## Special Thanks

<br>

   **[hawshemi]** - *For server optimizer*

   **[misaka]** - *For warp config and key generator*

<!----------------------------------{ Thanks }--------------------------------->

[hawshemi]: https://github.com/hawshemi/Linux-Optimizer
[misaka]: https://replit.com/@misaka-blog/warpgo-profile-generator



