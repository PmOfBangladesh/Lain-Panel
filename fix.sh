#!/bin/bash
# ============================================================
#   fix.sh —
#   
# ============================================================

VENV_DIR="$HOME/.venv/smlbot"
MARKER="# SML_VENV_HOOK"

echo ""
echo -e "\033[1;36m  ▶ Fixing venv auto-activate on login...\033[0m"
echo ""

add_hook() {
    local FILE=$1
    grep -q "$MARKER" "$FILE" 2>/dev/null && { echo -e "\033[2m  ✔ Already in $FILE\033[0m"; return; }
    cat >> "$FILE" << EOF

$MARKER
[ -f "$VENV_DIR/bin/activate" ] && source "$VENV_DIR/bin/activate"
EOF
    echo -e "\033[0;32m  ✔ Added to $FILE\033[0m"
}

[ -f "$HOME/.bashrc" ]       && add_hook "$HOME/.bashrc"
[ -f "$HOME/.bash_profile" ] && add_hook "$HOME/.bash_profile"
[ -f "$HOME/.profile" ]      && add_hook "$HOME/.profile"
[ -f "$HOME/.zshrc" ]        && add_hook "$HOME/.zshrc"

if [ ! -f "$HOME/.bash_profile" ]; then
    cat > "$HOME/.bash_profile" << EOF
[ -f ~/.bashrc ] && source ~/.bashrc

$MARKER
[ -f "$VENV_DIR/bin/activate" ] && source "$VENV_DIR/bin/activate"
EOF
    echo -e "\033[0;32m  ✔ Created ~/.bash_profile\033[0m"
fi

echo ""
echo -e "\033[1;32m  Done! Logout & login to apply.\033[0m"
echo -e "\033[2m  Or run: source ~/.bash_profile\033[0m"
echo ""
