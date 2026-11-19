#!/usr/bin/env bash
set -euo pipefail

echo "=== HandleVault OS & Stamp Pack Safety & Structure Check ==="

# 1. Check expected public files
for f in "index.html" "About.html" "Privacy.html" "Terms.html" "manifest.json" ".gitignore"; do
  if [ -f "$f" ]; then
    echo "[OK] Found $f"
  else
    echo "[WARN] Missing $f"
  fi
done

# 2. Check for sensitive patterns in tracked/workspace files (excluding .git and *.zip)
if grep -rnE --exclude-dir=.git --exclude='*.zip' '(AIza[0-9A-Za-z\-_]{35}|sk_live_|sk_test_|rk_live_|rk_test_|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----)' . 2>/dev/null; then
  echo "[FAIL] Potential secret key or private key detected! Clean before committing."
  exit 1
else
  echo "[OK] No obvious API/secret/private keys detected."
fi

# 3. Check if *.zip is covered in .gitignore
if [ -f ".gitignore" ] && grep -qE '^\*\.zip$' ".gitignore"; then
  echo "[OK] *.zip backups are ignored in .gitignore."
else
  echo "[WARN] Add *.zip to .gitignore so local backups stay off public git."
fi

# 4. Validate manifest.json syntax if python3 is available
if command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json; json.load(open("manifest.json", encoding="utf-8"))'
  echo "[OK] manifest.json is valid JSON."
fi

echo "=== Check Complete ==="

