# -*- mode: python ; coding: utf-8 -*-

block_cipher = None


a = Analysis(['src/main.py'],
             pathex=['/Users/markzhang/Desktop/GithubClone/Clickflow'],
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
          name='macOS 鼠标连点器',
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
             name='macOS 鼠标连点器.app',
             icon='assets/icon.icns',
             bundle_identifier=None,
             info_plist={
                 'CFBundleName': 'macOS 鼠标连点器',
                 'CFBundleDisplayName': 'macOS 鼠标连点器',
                 'CFBundleVersion': '1.0.0',
                 'CFBundleShortVersionString': '1.0.0',
                 'NSHumanReadableCopyright': 'Copyright © 2026, All Rights Reserved'
             }
            )
