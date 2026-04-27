# -*- mode: python ; coding: utf-8 -*-

import os

block_cipher = None

# 获取当前目录
current_dir = os.path.dirname(os.path.abspath(SPEC))

# 检查图标文件是否存在
icon_path = os.path.join(current_dir, 'assets', 'icon.icns')
if not os.path.exists(icon_path):
    icon_path = None

a = Analysis(['src/main.py'],
             pathex=[current_dir],
             binaries=[],
             datas=[],
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

options = [
    ('u', None, 'OPTION'),
]

exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          [],
          name='Clickflow',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          upx_exclude=[],
          runtime_tmpdir=None,
          console=False,
          disable_windowed_traceback=False,
          target_arch=None,
          codesign_identity=None,
          entitlements_file=None)

app = BUNDLE(exe,
             name='Clickflow.app',
             icon=icon_path,
             bundle_identifier=None,
             info_plist={
                 'CFBundleName': 'Clickflow',
                 'CFBundleDisplayName': 'Clickflow',
                 'CFBundleVersion': '1.0.0',
                 'CFBundleShortVersionString': '1.0.0',
                 'NSHumanReadableCopyright': 'Copyright © 2026, All Rights Reserved'
             }
            )
