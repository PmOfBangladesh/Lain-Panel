# Lain Panel — Interface the Wired

<div align="center">

```
██╗      █████╗ ██╗███╗   ██╗    ██████╗  █████╗ ███╗   ██╗███████╗██╗
██║     ██╔══██╗██║████╗  ██║    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║
██║     ███████║██║██╔██╗ ██║    ██████╔╝███████║██╔██╗ ██║█████╗  ██║
██║     ██╔══██║██║██║╚██╗██║    ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║
███████╗██║  ██║██║██║ ╚████║    ██║     ██║  ██║██║ ╚████║███████╗███████╗
╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝
```

**"Present day, present time." — Serial Experiments Lain**
*Automated VPS Bootstrap Tool — by SML The Unknown*

[![Telegram](https://img.shields.io/badge/Telegram-@codeninjaxd-blue?logo=telegram)](https://t.me/codeninjaxd)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-CentOS%20%7C%20AlmaLinux%20%7C%20Ubuntu-orange)](#)
[![Python](https://img.shields.io/badge/Python-3.10-blue?logo=python)](#)
[![Shell](https://img.shields.io/badge/Shell-Bash-lightgrey?logo=gnu-bash)](#)

</div>

---

## Overview

**Lain Panel** is a fully automated VPS bootstrap script that connects your server to "the Wired" — setting up a Python environment from scratch on a fresh server. It handles everything from system updates to systemd service registration — all in one command.

On first run, it installs and configures everything automatically. On every boot or login after that, it displays a cyberpunk-style system info panel with speedtest and welcome animation — no manual steps needed.

> *"And you, who are you?" — Lain Iwakura*

---

## Features

| Feature | Description |
|---|---|
| System Update | Auto-updates packages on first run |
| Python 3.10 | Installs if not already present |
| Virtual Environment | Creates isolated venv at `~/.venv/lainbot` |
| Speedtest-cli | Installs speedtest module inside venv |
| Auto Venv Activate | Activates venv on every SSH login |
| Systemd Service | Registers Lain Panel as a system service, auto-runs on every boot |
| Welcome Animation | Typewriter welcome message + loading bar |
| System Info Panel | OS, CPU, RAM, Disk, IP, Uptime — cyberpunk style |

---

## Requirements

- CentOS 7/8, AlmaLinux 8/9, or Ubuntu 20.04+
- Root or `sudo` access
- `bash` shell

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/PmOfBangladesh/Lain-Panel.git
cd Lain-Panel

# Give execute permission
chmod +x setup.sh fix.sh

# Run Lain Panel
bash setup.sh
```

> First run installs everything and registers systemd service. Every boot after that runs automatically.

---

## File Structure

```
Lain-Panel/
├── setup.sh          # Main Lain Panel script
├── fix.sh            # Fix venv auto-activate if not working
├── README.md
└── LICENSE
```

---

## Systemd Service

After setup, Lain Panel runs as a systemd service and auto-starts on every reboot — no manual action needed.

```bash
# Check status
sudo systemctl status lain-panel

# Restart
sudo systemctl restart lain-panel

# Live logs
journalctl -u lain-panel -f

# Stop
sudo systemctl stop lain-panel
```

---

## Venv Not Activating on Login?

```bash
bash fix.sh
```

Then logout and login again.

---

## Re-Run Full Setup

```bash
rm ~/.lain_setup_done
bash setup.sh
```

---

## View Setup Logs

```bash
cat ~/.lain_setup.log
```

---

## License

MIT License — see [LICENSE](LICENSE)

---

<div align="center">
Made with ❤️ by <a href="https://t.me/codeninjaxd">SML The Unknown</a>
<br>
<sub>✦ Interface the Wired ✦</sub>
</div>
