<div align="center">

[![banner](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/SCI.png?raw=true "banner")](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/SCI.png?raw=true "banner")


Automatic Installation and Configuration of WARP, ShadowTLS, WebSocket, gRPC, Reality, Naive, TUIC, Hysteria2



![GitHub Repo stars](https://img.shields.io/github/stars/TheyCallMeSecond/config-examples?style=for-the-badge&color=cba6f7) ![GitHub last commit](https://img.shields.io/github/last-commit/TheyCallMeSecond/config-examples?style=for-the-badge&color=b4befe) ![GitHub forks](https://img.shields.io/github/forks/TheyCallMeSecond/config-examples?style=for-the-badge&color=cba6f7)
<br/>
</div>

------------

#### Installation:


 You need Curl to run this script. If it's not installed on your server, install it with the following command:

>sudo apt install curl 


Run the following command on your server:


```bash
bash <(curl -fsSL https://bit.ly/config-installer)
```

 [After the initial use, you can access the latest version of the script by simply typing "sci" on your server]

 
 
[![bash screen](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/29.png?raw=true "bash screen")](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/29.png?raw=true "bash screen")

[![bash screen](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/30.png?raw=true "bash screen")](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/30.png?raw=true "bash screen")

[![bash screen](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/31.png?raw=true "bash screen")](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/31.png?raw=true "bash screen")

[![bash screen](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/32.png?raw=true "bash screen")](https://github.com/TheyCallMeSecond/config-examples/blob/main/img/32.png?raw=true "bash screen")

------------

#### Notes:

- Tested on Ubuntu, Debian, and CentOS servers.

- Optimize your server before installing protocols (actions include: server update and upgrade, installing the latest ZEN kernel, necessary package installation, enabling IPv6, enabling BBR, optimizing SSH connection, setting limits, enabling firewall).

- To activate WARP: first obtain the WARP+ code through the script, create a WireGuard configuration for WARP, then enable it for the desired protocol.

- WARP connects via WireGuard's kernel, utilizing minimal server resources and offering minimal latency compared to the primary WARP client.

- You can use the script to obtain WARP+ codes.

- Deleting WARP will automatically deactivate it for the protocols you had enabled.

- Ability to update the Singbox core used to run protocols.

- Regenerates Reality Keys.

- Automatic certificate retrieval for your domain.

- User management: capability to add or remove users for all protocols.

- Displays configuration output as links and QR codes separately for IPv6 and IPv4 (provides separate output models for Shadow TLS compatible with NekoRay and NekoBox, where you need to create custom configurations and copy relevant configurations into them).

- Additionally, for Shadow TLS, you can use the official SingBox client on Android and iOS (use the dedicated output configuration for NekoBox).



------------

#### Clients
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


  - [hawshemi](https://github.com/hawshemi/Linux-Optimizer) - *For server optimizer*

  - [misaka](https://replit.com/@misaka-blog/warpgo-profile-generator) - *For warp config and key generator*
