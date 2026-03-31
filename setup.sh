#!/bin/bash
# ============================================================
#   Lain Panel — VPS Auto Setup & Status Script
#   "Present day, present time." — Serial Experiments Lain
#   By SML The Unknown — @codeninjaxd
#   GitHub: https://github.com/PmOfBangladesh/Lain-Panel
# ============================================================

# ── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Config ────────────────────────────────────────────────────
PYTHON_VERSION="3.10"
VENV_DIR="$HOME/.venv/lainbot"
SERVICE_NAME="lain-panel"
SCRIPT_PATH="$(realpath "$0")"
SETUP_DONE_FLAG="$HOME/.lain_setup_done"
LOG_FILE="$HOME/.lain_setup.log"

# ── Welcome Animation ─────────────────────────────────────────
welcome_animation() {
    clear
    echo ""
    sleep 0.2

    local msg="  Connecting to the Wired"
    local dots="........"
    echo -ne "${BOLD}${CYAN}"
    for (( i=0; i<${#msg}; i++ )); do
        echo -ne "${msg:$i:1}"
        sleep 0.05
    done
    echo -ne "${MAGENTA}"
    for (( i=0; i<${#dots}; i++ )); do
        echo -ne "${dots:$i:1}"
        sleep 0.15
    done
    echo -e "${RESET}"
    echo ""

    echo -ne "  ${DIM}Loading Lain Panel${RESET}  ${CYAN}["
    for i in {1..25}; do
        echo -ne "${MAGENTA}█${RESET}"
        sleep 0.03
    done
    echo -e "${CYAN}]${RESET}  ${BOLD}${GREEN}Connected${RESET}"
    echo ""
    sleep 0.5
    clear
}

# ── Banner (mobile-friendly small ASCII) ─────────────────────
print_banner() {
    echo ""
    echo -e "${BOLD}${MAGENTA}"
    echo ' ██╗      █████╗ ██╗███╗  ██╗'
    echo ' ██║     ██╔══██╗██║████╗ ██║'
    echo ' ██║     ███████║██║██╔██╗██║'
    echo ' ██║     ██╔══██║██║██║╚████║'
    echo ' ███████╗██║  ██║██║██║ ╚███║'
    echo ' ╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚══╝'
    echo -e "${RESET}"
    echo -e "${BOLD}${CYAN}  ██████╗  █████╗ ███╗  ██╗███████╗██╗${RESET}"
    echo -e "${BOLD}${CYAN}  ██╔══██╗██╔══██╗████╗ ██║██╔════╝██║${RESET}"
    echo -e "${BOLD}${CYAN}  ██████╔╝███████║██╔██╗██║█████╗  ██║${RESET}"
    echo -e "${BOLD}${CYAN}  ██╔═══╝ ██╔══██║██║╚████║██╔══╝  ██║${RESET}"
    echo -e "${BOLD}${CYAN}  ██║     ██║  ██║██║ ╚███║███████╗███████╗${RESET}"
    echo -e "${BOLD}${CYAN}  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚══╝╚══════╝╚══════╝${RESET}"
    echo ""
    echo -e "${BOLD}${MAGENTA}  ✦  Interface the Wired  ✦${RESET}"
    echo -e "${DIM}  By SML The Unknown · @codeninjaxd${RESET}"
    echo -e "${MAGENTA}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

# ── Speedtest ─────────────────────────────────────────────────
run_speedtest() {
    echo -e "${BOLD}${CYAN}  ╔══════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}  ║      Speed Test — Wired Speed        ║${RESET}"
    echo -e "${BOLD}${CYAN}  ╚══════════════════════════════════════╝${RESET}"
    echo ""
    echo -ne "  ${DIM}Measuring connection to the Wired${RESET}  ${CYAN}["

    local tmpfile=$(mktemp)
    (source "$VENV_DIR/bin/activate" 2>/dev/null
     python -m speedtest --simple 2>/dev/null > "$tmpfile"
     deactivate 2>/dev/null) &
    local pid=$!

    local spin=0
    while kill -0 $pid 2>/dev/null; do
        echo -ne "${MAGENTA}█${RESET}"
        sleep 0.15
        spin=$((spin+1))
        if [ $spin -ge 20 ]; then break; fi
    done
    wait $pid 2>/dev/null

    for (( r=spin; r<20; r++ )); do echo -ne "${MAGENTA}█${RESET}"; done
    echo -e "${CYAN}]${RESET}  ${BOLD}${GREEN}Connected${RESET}"
    echo ""

    if [ -s "$tmpfile" ]; then
        local ping=$(grep Ping "$tmpfile" | awk '{print $2, $3}')
        local down=$(grep Download "$tmpfile" | awk '{print $2, $3}')
        local up=$(grep Upload "$tmpfile" | awk '{print $2, $3}')
        echo -e "  ${YELLOW}  Latency   ${CYAN}➜${RESET}  ${WHITE}${ping:-N/A}${RESET}"
        echo -e "  ${YELLOW}  Download  ${CYAN}➜${RESET}  ${GREEN}${down:-N/A}${RESET}"
        echo -e "  ${YELLOW}  Upload    ${CYAN}➜${RESET}  ${MAGENTA}${up:-N/A}${RESET}"
    else
        echo -e "  ${YELLOW}  ⚠ Connection to the Wired failed.${RESET}"
    fi
    rm -f "$tmpfile"
    echo ""
}

# ── System Info ───────────────────────────────────────────────
print_sysinfo() {
    local os kernel hostname ip cpu cores ram_total ram_used disk_total disk_used uptime_str boot_time

    os=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || echo "Unknown")
    kernel=$(uname -r)
    hostname=$(hostname)
    ip=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "N/A")
    cpu=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs || echo "Unknown")
    cores=$(nproc 2>/dev/null || echo "?")
    ram_total=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}' || echo "?")
    ram_used=$(free -m 2>/dev/null | awk '/^Mem:/{print $3}' || echo "?")
    disk_total=$(df -h / 2>/dev/null | awk 'NR==2{print $2}' || echo "?")
    disk_used=$(df -h / 2>/dev/null | awk 'NR==2{print $3}' || echo "?")
    uptime_str=$(uptime -p 2>/dev/null || echo "unknown")
    boot_time=$(who -b 2>/dev/null | awk '{print $3, $4}' || echo "unknown")

    echo -e "${BOLD}${CYAN}  ╔══════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}  ║     System Information — Node        ║${RESET}"
    echo -e "${BOLD}${CYAN}  ╚══════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${YELLOW}  Hostname   ${CYAN}➜${RESET}  ${WHITE}$hostname${RESET}"
    echo -e "  ${YELLOW}  IP Address ${CYAN}➜${RESET}  ${WHITE}$ip${RESET}"
    echo -e "  ${YELLOW}  OS         ${CYAN}➜${RESET}  ${WHITE}$os${RESET}"
    echo -e "  ${YELLOW}  Kernel     ${CYAN}➜${RESET}  ${WHITE}$kernel${RESET}"
    echo -e "  ${YELLOW}  CPU        ${CYAN}➜${RESET}  ${WHITE}$cpu${RESET}"
    echo -e "  ${YELLOW}  Cores      ${CYAN}➜${RESET}  ${WHITE}$cores cores${RESET}"
    echo -e "  ${YELLOW}  RAM Usage  ${CYAN}➜${RESET}  ${WHITE}${ram_used} MB / ${ram_total} MB${RESET}"
    echo -e "  ${YELLOW}  Disk Usage ${CYAN}➜${RESET}  ${WHITE}${disk_used} / ${disk_total}${RESET}"
    echo -e "  ${YELLOW}  Uptime     ${CYAN}➜${RESET}  ${WHITE}$uptime_str${RESET}"
    echo -e "  ${YELLOW}  Boot Time  ${CYAN}➜${RESET}  ${WHITE}$boot_time${RESET}"
    echo ""
    echo -e "${DIM}  \"And you, who are you?\" — Lain Iwakura${RESET}"
    echo ""
}

# ── Helpers ───────────────────────────────────────────────────
log()  { echo -e "$1" | tee -a "$LOG_FILE"; }
step() { log "${BOLD}${CYAN}\n  ▶ $1${RESET}"; }
ok()   { log "${GREEN}  ✔ $1${RESET}"; }
warn() { log "${YELLOW}  ⚠ $1${RESET}"; }

is_first_run() { [ ! -f "$SETUP_DONE_FLAG" ]; }

# ── 1. System Update ──────────────────────────────────────────
do_system_update() {
    step "Updating system nodes..."
    if command -v dnf &>/dev/null; then
        sudo dnf update -y >> "$LOG_FILE" 2>&1
    elif command -v apt &>/dev/null; then
        sudo apt update -y && sudo apt upgrade -y >> "$LOG_FILE" 2>&1
    elif command -v yum &>/dev/null; then
        sudo yum update -y >> "$LOG_FILE" 2>&1
    else
        warn "Package manager not found, skipping."; return
    fi
    ok "System updated."
}

# ── 2. Python 3.10 ───────────────────────────────────────────
do_python_install() {
    step "Checking Python ${PYTHON_VERSION}..."
    if python3.10 --version &>/dev/null; then
        ok "Python 3.10 already installed: $(python3.10 --version)"; return
    fi
    log "  Installing Python ${PYTHON_VERSION}..."
    if command -v dnf &>/dev/null; then
        sudo dnf install -y python3.10 python3.10-devel python3.10-pip >> "$LOG_FILE" 2>&1 || \
        (sudo dnf install -y gcc openssl-devel bzip2-devel libffi-devel zlib-devel wget >> "$LOG_FILE" 2>&1 && \
         cd /tmp && wget -q https://www.python.org/ftp/python/3.10.14/Python-3.10.14.tgz && \
         tar xzf Python-3.10.14.tgz && cd Python-3.10.14 && \
         ./configure --enable-optimizations >> "$LOG_FILE" 2>&1 && \
         sudo make altinstall >> "$LOG_FILE" 2>&1)
    elif command -v apt &>/dev/null; then
        sudo apt install -y python3.10 python3.10-venv python3.10-dev >> "$LOG_FILE" 2>&1
    fi
    ok "Python 3.10 installed."
}

# ── 3. Virtualenv ─────────────────────────────────────────────
do_venv_setup() {
    step "Creating virtual environment at $VENV_DIR..."
    mkdir -p "$(dirname "$VENV_DIR")"
    if [ ! -d "$VENV_DIR" ]; then
        python3.10 -m venv "$VENV_DIR" >> "$LOG_FILE" 2>&1
        ok "Virtual environment created."
    else
        ok "Virtual environment already exists."
    fi
    source "$VENV_DIR/bin/activate"
    pip install --upgrade pip >> "$LOG_FILE" 2>&1
    ok "pip upgraded."
    deactivate
}

# ── 4. Speedtest ──────────────────────────────────────────────
do_speedtest_install() {
    step "Installing speedtest-cli..."
    source "$VENV_DIR/bin/activate"
    if python -c "import speedtest" &>/dev/null; then
        ok "speedtest-cli already installed."
    else
        pip install speedtest-cli >> "$LOG_FILE" 2>&1
        ok "speedtest-cli installed."
    fi
    deactivate
}

# ── 5. Shell Hook ─────────────────────────────────────────────
do_shell_hook() {
    step "Adding venv + auto-status to shell profiles..."
    local VENV_MARKER="# LAIN_VENV_HOOK"
    local STATUS_MARKER="# LAIN_STATUS_HOOK"

    add_venv_hook() {
        local f=$1
        grep -q "$VENV_MARKER" "$f" 2>/dev/null && { ok "Venv hook already in $f"; return; }
        cat >> "$f" << EOF

$VENV_MARKER
[ -f "$VENV_DIR/bin/activate" ] && source "$VENV_DIR/bin/activate"
EOF
        ok "Venv hook added to $f"
    }

    add_status_hook() {
        local f=$1
        grep -q "$STATUS_MARKER" "$f" 2>/dev/null && { ok "Status hook already in $f"; return; }
        cat >> "$f" << EOF

$STATUS_MARKER
[ -f "$SCRIPT_PATH" ] && bash "$SCRIPT_PATH" --status
EOF
        ok "Status hook added to $f"
    }

    # Add venv hook to all profiles
    [ -f "$HOME/.bashrc" ]  && add_venv_hook "$HOME/.bashrc"
    [ -f "$HOME/.zshrc" ]   && add_venv_hook "$HOME/.zshrc"
    [ -f "$HOME/.profile" ] && add_venv_hook "$HOME/.profile"

    # .bash_profile — SSH login shell (CentOS/Ubuntu)
    if [ ! -f "$HOME/.bash_profile" ]; then
        cat > "$HOME/.bash_profile" << EOF
[ -f ~/.bashrc ] && source ~/.bashrc

# LAIN_VENV_HOOK
[ -f "$VENV_DIR/bin/activate" ] && source "$VENV_DIR/bin/activate"

# LAIN_STATUS_HOOK
[ -f "$SCRIPT_PATH" ] && bash "$SCRIPT_PATH" --status
EOF
        ok "Created ~/.bash_profile with hooks."
    else
        add_venv_hook "$HOME/.bash_profile"
        add_status_hook "$HOME/.bash_profile"
    fi

    # Also add status to .bashrc for interactive logins
    add_status_hook "$HOME/.bashrc"
}

# ── 6. Systemd Service ────────────────────────────────────────
do_systemd_service() {
    step "Registering Lain Panel as systemd service..."
    chmod +x "$SCRIPT_PATH"

    sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null << EOF
[Unit]
Description=Lain Panel — Interface the Wired
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
User=$USER
ExecStart=/bin/bash $SCRIPT_PATH --status
StandardOutput=journal
StandardError=journal
Environment=TERM=xterm-256color

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload >> "$LOG_FILE" 2>&1
    sudo systemctl enable "$SERVICE_NAME" >> "$LOG_FILE" 2>&1
    ok "Systemd service registered & enabled."
}

# ── 7. Mark Done ─────────────────────────────────────────────
mark_done() {
    echo "$(date)" > "$SETUP_DONE_FLAG"
    ok "Lain Panel setup complete."
}

# ── Status Mode ───────────────────────────────────────────────
run_status_mode() {
    welcome_animation
    print_banner
    run_speedtest
    print_sysinfo
}

# ── Main ──────────────────────────────────────────────────────
main() {
    if [ "$1" = "--status" ]; then
        run_status_mode
        exit 0
    fi

    if is_first_run; then
        welcome_animation
        print_banner

        log "${BOLD}${MAGENTA}  ━━ First Time Setup — Entering the Wired ━━━━━━━━━━━${RESET}"
        do_system_update
        do_python_install
        do_venv_setup
        do_speedtest_install
        do_shell_hook
        do_systemd_service
        mark_done

        echo ""
        echo -e "${BOLD}${GREEN}  ╔══════════════════════════════════════╗${RESET}"
        echo -e "${BOLD}${GREEN}  ║  ✅  Connected to the Wired!         ║${RESET}"
        echo -e "${BOLD}${GREEN}  ╚══════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "  ${DIM}Present day, present time.${RESET}"
        echo -e "  ${DIM}Log: $LOG_FILE${RESET}"
        echo ""

        run_status_mode
    else
        run_status_mode
    fi
}

main "$@"
