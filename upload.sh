#!/bin/bash

# Minimal GoFile Uploader script

set -e

FILE="$1"

# 1. Validate dependencies and input
command -v jq >/dev/null || { echo "❌ Error: 'jq' is required."; exit 1; }
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    echo "❌ Error: File not found."
    echo "Usage: $0 <filename.zip>"
    exit 1
fi

# 2. Upload directly to GoFile's upload fleet (No server lookup needed!)
echo "⏳ Uploading '$FILE' to GoFile..."
RESPONSE=$(curl --progress-bar -F "file=@$FILE" "https://upload.gofile.io/uploadfile" 2>/dev/tty)

# 3. Parse response with fallback
LINK=$(echo "$RESPONSE" | jq -r '.data.downloadPage // empty')
CODE=$(echo "$RESPONSE" | jq -r '.data.code // empty')

if [[ -n "$LINK" ]]; then
    echo -e "\n✅ Success! Download link:\n$LINK"
elif [[ -n "$CODE" ]]; then
    echo -e "\n✅ Success! Download link:\nhttps://gofile.io/d/$CODE"
else
    echo -e "\n❌ Upload failed. Raw response:\n$RESPONSE"
    exit 1
fi
