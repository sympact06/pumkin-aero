# 🎃 Pumpkin Rust Server – AERO Edition

> Lightning-fast, lightweight Minecraft server written in Rust — rebuilt & packaged by [AERO Company](https://aero.nu)

---

## 🚀 What is this?

This is a custom build of [Pumpkin](https://github.com/Pumpkin-MC/Pumpkin), a blazing-fast Minecraft server written in Rust.  
This version is maintained by **AERO Company**, optimized for performance, and packaged to work seamlessly with [Pterodactyl](https://pterodactyl.io).

### 🛠 Features
- ⚡ Ultra-fast Rust performance
- 📦 Full Pterodactyl egg & Docker image support
- 🔧 Auto-generated config with environment injection
- 🎨 Custom AERO ASCII banner at startup
- 🧱 Minecraft Java Edition compatibility (vanilla clients)
- 🔒 Open source with mandatory attribution

---

## 📦 Installation (Docker)

```bash
docker run -d \
  -p 25565:25565 \
  -e CONFIG_FILE="config/pumpkin.toml" \
  -e MOTD="Welcome to my AERO server!" \
  aero/pumpkin-server:latest