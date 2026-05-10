
# Lazy-Flash V1

**Lazy-Flash** is a set of Bash scripts designed for fast and automated server setup with 3X-UI, IPv6 management, and system diagnostics.

The project is created to save time during initial VPS setup and simplify basic server configuration.

---

# 📦 Main Installation Script

File:

```
Fullin-ersr.sh
```

This is the main installation script that performs:

* full installation of 3X-UI;
* dependency installation;
* system checks and validation;
* panel port selection;
* optional IPv6 disabling;
* basic server setup.

---

# 🚀 Installation (Online Server)

## Ubuntu / Debian

### Ubuntu:

```bash
wget -O install.sh https://raw.githubusercontent.com/d0ct0rvrach/Lazy-Flash/refs/heads/main/Fullin-erscr.sh && chmod +x install.sh && sudo ./install.sh
```

### Debian:

```bash
wget -O install.sh https://raw.githubusercontent.com/d0ct0rvrach/Lazy-Flash/refs/heads/main/Fullin-erscr.sh && chmod +x install.sh && ./install.sh
```

---

# 💾 Installation (Offline Server)

If the server has no internet access:

### Ubuntu / Debian

1. Download the `Fullin-ersr.sh` file manually on your local machine
2. Transfer it to the server (for example via SCP or USB):

```bash
scp Fullin-ersr.sh user@server:/root/
```

3. On the server run:

```bash
chmod +x Fullin-ersr.sh
sudo ./Fullin-ersr.sh
```

---

# 🌐 IPv6 Manager

File:

```
Off-onipv6.sh
```

A separate script for managing IPv6:

* disable IPv6
* enable IPv6
* check current IPv6 status

---

## IPv6 Manager Installation

### Ubuntu:

```bash
wget -O install.sh https://raw.githubusercontent.com/d0ct0rvrach/Lazy-Flash/refs/heads/main/Off-onipv6.sh && chmod +x install.sh && sudo ./install.sh
```

### Debian:

```bash
wget -O install.sh https://raw.githubusercontent.com/d0ct0rvrach/Lazy-Flash/refs/heads/main/Off-onipv6.sh && chmod +x install.sh && ./install.sh
```

---

# 📊 Panel Dashboard

File:

```
checkpanel.sh
```

A separate monitoring script for server and panel diagnostics:

* 3X-UI status check;
* port monitoring;
* CPU / RAM usage;
* log viewer;
* network diagnostics;
* quick actions (restart / logs / status).

---

## Dashboard Installation

### Ubuntu:

```bash
wget -O install.sh https://raw.githubusercontent.com/d0ct0rvrach/Lazy-Flash/refs/heads/main/checkpanel.sh && chmod +x install.sh && sudo ./install.sh
```

### Debian:

```bash
wget -O install.sh https://raw.githubusercontent.com/d0ct0rvrach/Lazy-Flash/refs/heads/main/checkpanel.sh && chmod +x install.sh && ./install.sh
```

---

# ⚠️ Notes

* Scripts are tested on clean Ubuntu and Debian systems.
* A minimal VPS installation is recommended.
* Root privileges are required.
* systemd is required for proper operation.

---

# 🔥 Summary

This toolset is designed for:

* fast server setup;
* automation of panel installation;
* simplified server management;
* time-saving deployment workflow.

---
