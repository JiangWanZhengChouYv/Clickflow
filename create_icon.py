#!/usr/bin/env python3
"""
简单的图标生成脚本
创建一个基础的 .icns 图标
"""

import os
import sys

def create_placeholder_icon():
    """创建占位符图标（使用简单的图形库创建）"""
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        print("请先安装 Pillow: pip install Pillow")
        return False
    
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    
    os.makedirs('assets', exist_ok=True)
    
    icon_dir = 'assets/icon.iconset'
    os.makedirs(icon_dir, exist_ok=True)
    
    for size in sizes:
        img = Image.new('RGBA', (size, size), (50, 150, 250, 255))
        draw = ImageDraw.Draw(img)
        
        center = size // 2
        
        draw.ellipse(
            [center - size * 0.35, center - size * 0.35,
             center + size * 0.35, center + size * 0.35],
            fill=(255, 255, 255, 255),
            outline=(30, 100, 200, 255),
            width=max(2, size // 64)
        )
        
        draw.ellipse(
            [center - size * 0.15, center - size * 0.2,
             center + size * 0.15, center + size * 0.1],
            fill=(30, 100, 200, 255)
        )
        
        filename = f'icon_{size}x{size}.png'
        img.save(os.path.join(icon_dir, filename))
        
        if size * 2 in sizes:
            filename = f'icon_{size}x{size}@2x.png'
            img.save(os.path.join(icon_dir, filename))
    
    print(f"图标已生成在 {icon_dir}")
    return True

def convert_to_icns():
    """将 .iconset 转换为 .icns"""
    if os.path.exists('assets/icon.iconset'):
        os.system('iconutil -c icns assets/icon.iconset -o assets/icon.icns')
        print("已转换为 assets/icon.icns")
        return True
    return False

if __name__ == '__main__':
    if create_placeholder_icon():
        if sys.platform == 'darwin':
            convert_to_icns()
        else:
            print("在非 macOS 平台上，请使用 iconutil 命令生成 .icns 文件")
