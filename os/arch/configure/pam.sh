#!/usr/bin/env bash
set -euo pipefail

pam_file="/etc/pam.d/quickshell"

if [[ -f "$pam_file" ]]; then
  echo "PAM config '$pam_file' already exists, skipping."
else
  echo "Creating PAM config '$pam_file'..."
  sudo tee "$pam_file" > /dev/null << 'EOF'
#%PAM-1.0
auth include system-auth
account include system-auth
EOF
  echo "Created '$pam_file'."
fi
