#!/bin/bash
cd /Users/markzhang/Desktop/GithubClone/Clickflow

# Remove temp files
rm -f build_icon.py create_assets.py create_icon_direct.py create_simple_icon.py do_icon.py final_icon.py generate_icon.py icon_creator.py make_assets.py make_icon.py make_png_icon.py quick_icon.py run_icon.py simple_icon.py

# Add files
git add main.js package.json src/renderer/script.js src/electron_mouse_controller.py .trae/specs/clickflow-fixes/

# Commit
git commit -m "fix: resolve clicker issues and add real mouse click functionality

- Implement real mouse click using Python Quartz API
- Restrict single point mode to only one point
- Disable click count input when infinite loop is selected
- Update UI interaction logic
- Add Python mouse controller script"

echo "Commit complete!"
