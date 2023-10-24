# آموزش نصب و کانفیگ Hysteria 2 + WARP
[![](https://hysteria.network/assets/banner_dark.svg)](https://hysteria.network/assets/banner_dark.svg)

مزیت این روش نسبت به روش‌های دیگر برای کانفیگ هیستریا ۲ امنیت بسیار بالا، غیرقابل شناسایی بودن آی‌پی (و بلاک شدن و فیلترشدن آن) و امکان دسترسی به سایت‌های ایرانی بدون نگرانی از شناسایی آی‌پی اصلی سرور است. 
------------
### نصب اتوماتیک 


(به همراه وارپ) :

از طریق [این بات تلگرام](https://t.me/generatewarpplusbot "این بات تلگرام") یک کلید WARP+ تهیه کنید و بعد از اتصال دامنه ی خود بهIP سرور, کد زیر را بر روی سرور اجرا کنید
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/HY2-warp-installer.sh)"
```
------------

(بدون وارپ) :

(برای امنیت بیشتر دامنه ها و IP های ایرانی بلاک هستند)

بعد از اتصال دامنه ی خود بهIP سرور, کد زیر را بر روی سرور اجرا کنید
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/HY2-installer.sh)"
```
------------
------------
### نصب و کانفیگ دستی (+WARP)
# سرور
۱. 	برنامه را (linux-amd64) دانلود کنید.
```
curl -Lo /root/hysteria2 https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64 && chmod +x /root/hysteria2 && mv -f /root/hysteria2 /usr/bin
```
۲. 	کانفیگ را دانلود کنید.
```
mkdir /etc/hysteria2 && curl -Lo /etc/hysteria2/server.yaml raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/server.yaml
```
۳. 	کانفیگ مربوط به systemctl را دانلود کنید.
```
curl -Lo /etc/systemd/system/hysteria2.service raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/hysteria2.service && systemctl daemon-reload
```
۴. 	به سایت کلاودفلر بروید و پس از ورود به بخش DNS یک رکورد جدید ثبت کنید(Add record). 
(برای ipv4 رکورد A و برای ipv6 رکورد AAAA ایجاد کنید)
(تنظیمات بخش Proxy status در حالت DNS only باشد)
 
[![](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/1.png)](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/1.png)


۵. 	به قسمت SSL/TLS بروید و گزینه‌ی Origin Server را انتخاب کنید. در صفحه‌ی باز‌شده گزینه‌ی Create Certificate را انتخاب کنید. در مرحله‌ی بعد هم Create را بزنید. 

[![](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/2.png)](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/2.png)


سپس دو مقدار Origin Certificate و Private Key را به شکل جداگانه در جایی ذخیره کنید (در مراحل آتی به آن‌ها نیاز خواهید داشت)

[![](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/3.png)](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/3.png)

۶. 	حالا در سرور فایل server.crt را به‌کمک دستور زیر بسازید.
```
sudo nano /etc/hysteria2/server.crt
```
در صفحه‌ی باز شده مقدار Origin Certificate که در مرحله‌ی ۵ ذخیره کرده بودید را قرار دهید(CTRL+SHIFT+V).

در آخر به کمک CTRL+X و فشردن Y و سپس اینتر فایل را ذخیره کنید.

در ویندوز نوت‌پد را باز کرده و محتوای Origin Certificate را در آن پیست کنید. سپس این فایل را با نام ca.crt در جایی ذخیره کنید(در قسمت کلاینت به این فایل نیاز خواهید داشت).

سپس فایل server.key را به‌کمک دستور زیر بسازید
```
sudo nano /etc/hysteria2/server.key
```
در صفحه‌ی باز شده مقدار Private Key که در مرحله‌ی ۵ ذخیره کرده بودید را قرار دهید(CTRL+SHIFT+V).

در آخر به کمک CTRL+X و فشردن Y و سپس ENTER فایل را ذخیره کنید.

به کمک دستور زیر SHA256 سرتیفیکیت را دریافت و در جایی ذخیره کنید(در بخش کلاینت به آن نیاز خواهیم داشت).


```
openssl x509 -noout -fingerprint -sha256 -in /etc/hysteria2/server.crt

```
۷. 	فایل کانفیگ را با دستور زیر باز کرده و مطابق با عکس ادیت کنید.
```
sudo nano /etc/hysteria2/server.yaml

``` 

[![](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/4.png)](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/4.png)

۸.	از طریق [این بات تلگرام](https://t.me/generatewarpplusbot "این بات تلگرام") یک کلید WARP+ تهیه کنید  و سپس به[ این آدرس](https://replit.com/@TheyCallMeSecon/warpgo-sing-box-config-generator-english " این آدرس") رفته و روی گزینه‌ی Run کلیک کنید.

سپس در اولین مرحله با وارد کردن عدد ۲ گزینه‌ی WARP+ را انتخاب کنید.  در صفحه‌ی بعد کلید WARP+ که از بات دریافت کرده بودید را وارد کنید. در صفحه‌ی بعد یک Device Name دلخواه انتخاب کنید. 
سپس کانفیگ را در جایی ذخیره کنید.

[![](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/5.png)](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/5.png)

حالا دستور زیر را در سرور خود وارد کنید.
```
mkdir singbox-warp && nano /root/singbox-warp/config.json
```
در صفحه‌ی باز شده کانفیگ ذخیره شده در قسمت قبل را پیست کنید(CTRL+SHIFT+V). سپس به کمک CTRL+X و فشردن Y و سپس ENTER فایل را ذخیره کنید.

حالا دستورات زیر را به‌ترتیب اجرا کنید
```
curl -Lo /root/sb https://github.com/SagerNet/sing-box/releases/download/v1.5.0-beta.3/sing-box-1.5.0-beta.3-linux-amd64.tar.gz && tar -xzf /root/sb && cp -f /root/sing-box-*/sing-box /root/singbox-warp/ && rm -r /root/sb /root/sing-box-* && chown root:root /root/singbox-warp/sing-box && chmod +x /root/singbox-warp/sing-box
```

```
curl -Lo /etc/systemd/system/SBW.service raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/SBW.service && systemctl daemon-reload
```

```
systemctl enable --now SBW

```
در نهایت با دستور `systemctl status SBW` از فعا‌ل‌بودن پروکسی در سمت سرور مطمئن شوید.

۹. به‌کمک دستور زیر سرویس هیستریا را اجرا کنید.
```
systemctl enable --now hysteria2
```
با دستور `systemctl status hysteria2` از فعال‌بودن سرویس هیستریا مطمئن شوید.

------------



# کلاینت

### ویندوز

#### برنامه V2rayN

۱. آخرین نسخه‌ی v2rayN را از [اینجا](https://github.com/2dust/v2rayN/releases "اینجا") دانلود کنید.

۲. هسته‌ی Hysteria 2 را دانلود کنید. 

[https://github.com/apernet/hysteria/releases/latest/download/hysteria-windows-amd64.exe](https://github.com/apernet/hysteria/releases/latest/download/hysteria-windows-amd64.exe "https://github.com/apernet/hysteria/releases/latest/download/hysteria-windows-amd64.exe")

۳. سپس فایل .exe دانلود شده را در فولدر `v2rayN/bin/hysteria` جایگزین کنید.

۴. کانفیگ را از اینجا کپی کنید.

[https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/client.yaml](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/client.yaml "raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/client.yaml")

فایلی با نام `config.yaml` در نوت‌پد بسازید و کانفیگ کپی شده را در آن پیست کنید. سپس مانند تصویر زیر ان‌را ادیت کنید.

[![](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/6.png)](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/6.png)

۵. برنامه‌ی v2rayN را باز کنید. از قسمت Server بر روی Add a custom configuration server کلیک کنید. سپس با انتخاب گزینه‌ی Browse، فایل `config.yaml` که ساخته بودید را انتخاب کنید. مطمئن شوید Core Type روی گزینه‌ی Hysteria قرار دارد و پورت 10810 است. 

[![](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/7.png)](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/7.png)

کانفیگ شما ساخته شده و بر روی برنامه v2rayN روی ویندوز قابل اجراست.

------------

#### برنامه Nekoray


آخرین نسخه‌ی Nekoray را از [اینجا](https://github.com/MatsuriDayo/nekoray/releases "اینجا") دانلود کنید.

برنامه را باز کرده, به قسمت server بروید و new profile را انتخاب کنید و type را بر روی hysteria2 بذارید

مطابق تصویر اطلاعاته کانفیگتون رو وارد کنید


[![](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/13.png)](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/13.png)


بر روی certificate کلیک کرده و محتوای فایل ca.crt رو داخلش paste کنید

[![](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/14.png)](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/14.png)

 تمام

------------



### اندروید

#### نکوباکس :
از آخرین نسخه‌ی نکوباکس استفاده کنید
[https://github.com/MatsuriDayo/NekoBoxForAndroid/releases](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases "https://github.com/MatsuriDayo/NekoBoxForAndroid/releases")

#### سینگ باکس :

۱. آخرین نسخه‌ی برنامه‌ی SFA را از [اینجا ](https://github.com/SagerNet/sing-box/releases "اینجا ")دانلود کنید.

۲. کانفیگ را از لینک زیر کپی کنید.

[https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/SFA/hysteria2-insecure.json](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/SFA/hysteria2-insecure.json "raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/SFA/hysteria2-insecure.json")

بخش outbounds کانفیگ را مطابق تصویر زیر ادیت کنید.

[![](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/8.png)](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/8.png)
 
۳. وارد برنامه‌ی sing-box شوید و از منوی پایین روی Profile کلیک کرده و New Profile را انتخاب کنید. 

برای کانفیگ نامی انتخاب کرده و روی گزینه‌ی Create بزنید. 

[![](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/10.jpg)](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/10.jpg)

سپس در قسمت Profiles روی نام کانفیگ جدید خود بزنید و Edit Content را انتخاب کنید. 

[![](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/9.jpg)](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/9.jpg)

محتوای کانفیگ پیشفرض را به‌طور کامل پاک کرده و کانفیگ خود را Paste کنید.


[![](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/11.jpg)](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/11.jpg)

 سپس بازگردید و از قسمت Dashboard پس از انتخاب کانفیگ آنرا اجرا کنید. 

[![](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/12.jpg)](https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/img/12.jpg)
