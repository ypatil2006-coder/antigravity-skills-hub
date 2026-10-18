#!/usr/bin/env bash
# ==============================================================================
# Google Antigravity Skills Hub & Manager Installer
# ==============================================================================
# Repository: https://github.com/ypatil2006-coder/antigravity-skills-hub
# ==============================================================================

set -e

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${BLUE}======================================================${RESET}"
echo -e "${GREEN}    ⚡ Google Antigravity Skills Hub & Manager Setup   ${RESET}"
echo -e "${BLUE}======================================================${RESET}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
SKILLS_DIR="$HOME/.agents/skills"
GEMINI_SKILLS_DIR="$HOME/.gemini/config/skills"
PROFILES_DIR="$HOME/.config/Antigravity-Profiles"

mkdir -p "$BIN_DIR" "$SKILLS_DIR" "$GEMINI_SKILLS_DIR"

echo -e "${YELLOW}[1/4] Installing CLI binary (~/.local/bin/manage-skills)...${RESET}"
cat << EOF > "$BIN_DIR/manage-skills"
#!/usr/bin/env bash
exec /usr/bin/python3 "$SCRIPT_DIR/manage_skills.py" "\$@"
EOF
chmod +x "$BIN_DIR/manage-skills"
chmod +x "$SCRIPT_DIR/manage_skills.py"

echo -e "${YELLOW}[2/4] Installing /skills-manager agent skill...${RESET}"
mkdir -p "$SKILLS_DIR/skills-manager"
cp "$SCRIPT_DIR/skills/skills-manager/SKILL.md" "$SKILLS_DIR/skills-manager/SKILL.md"

# Symlink into global discovery
ln -sf "$SKILLS_DIR/skills-manager" "$GEMINI_SKILLS_DIR/skills-manager"

# Symlink into Antigravity profiles
if [ -d "$PROFILES_DIR" ]; then
    find "$PROFILES_DIR" -maxdepth 1 -type d -name "Account-*" | while read -r prof; do
        mkdir -p "$prof/HOME/.agents/skills"
        ln -sf "$SKILLS_DIR/skills-manager" "$prof/HOME/.agents/skills/skills-manager"
    done
fi

echo -e "${YELLOW}[3/4] Scanning installed skills & building catalog...${RESET}"
python3 "$SCRIPT_DIR/manage_skills.py" sync

echo -e "${YELLOW}[4/4] Checking Electron patcher status...${RESET}"
if command -v npx &>/dev/null && [ -f "/opt/Antigravity/resources/app.asar" ]; then
    echo -e "${BLUE}Patching app.asar with integrated Skills Hub drawer...${RESET}"
    python3 "$SCRIPT_DIR/patch_app_asar.py" || true
else
    echo -e "${YELLOW}Note: app.asar patch skipped. Skills Hub can be injected via CDP or by running 'python3 patch_app_asar.py' when npx is available.${RESET}"
fi

echo -e "\n${GREEN}✓ Installation Complete!${RESET}"
echo -e "${BLUE}• Use CLI:       'manage-skills scan' | 'manage-skills sync' | 'manage-skills import <url>'${RESET}"
echo -e "${BLUE}• Use Agent:     Tell your agent: '/skills-manager' or 'import skill <url>'${RESET}"
echo -e "${BLUE}• In App:        Click 'Skills Hub [/cmd]' in the sidebar to browse all skills!${RESET}\n"
