#!/bin/bash
# macOS 鼠标连点器构建脚本

set -e

APP_NAME="macOS 鼠标连点器"
VERSION="1.0.0"
BUILD_DIR="build"
DIST_DIR="dist"

echo "========================================="
echo "  macOS 鼠标连点器 - 构建脚本"
echo "========================================="
echo ""

clean() {
    echo "[1/6] 清理旧的构建文件..."
    rm -rf "$BUILD_DIR" "$DIST_DIR"
    echo "✅ 清理完成"
    echo ""
}

create_icon() {
    echo "[2/6] 创建应用图标..."
    if [ ! -f "assets/icon.icns" ]; then
        python3 create_icon.py
    fi
    echo "✅ 图标准备完成"
    echo ""
}

install_deps() {
    echo "[3/6] 检查并安装依赖..."
    if [ ! -d "venv" ]; then
        echo "创建虚拟环境..."
        python3 -m venv venv
    fi
    source venv/bin/activate
    pip install -q -U pip
    pip install -q -r requirements.txt
    echo "✅ 依赖安装完成"
    echo ""
}

build_app() {
    echo "[4/6] 构建 .app 应用包..."
    source venv/bin/activate
    pyinstaller --clean mouse_clicker.spec
    echo "✅ .app 应用包构建完成"
    echo ""
}

create_dmg() {
    echo "[5/6] 创建 DMG 安装包..."
    
    if [ ! -d "$DIST_DIR/$APP_NAME.app" ]; then
        echo "错误: 找不到 $DIST_DIR/$APP_NAME.app"
        exit 1
    fi
    
    DMG_NAME="${APP_NAME}-${VERSION}.dmg"
    DMG_PATH="$DIST_DIR/$DMG_NAME"
    
    if command -v create-dmg &> /dev/null; then
        create-dmg \
            --volname "$APP_NAME" \
            --window-pos 200 120 \
            --window-size 800 400 \
            --icon-size 100 \
            --icon "$APP_NAME.app" 200 190 \
            --hide-extension "$APP_NAME.app" \
            --app-drop-link 600 185 \
            "$DMG_PATH" \
            "$DIST_DIR/"
    else
        echo "create-dmg 工具未安装，使用基础 DMG 创建方式"
        hdiutil create -volname "$APP_NAME" -srcfolder "$DIST_DIR/$APP_NAME.app" -ov -format UDZO "$DMG_PATH"
    fi
    
    echo "✅ DMG 安装包创建完成: $DMG_PATH"
    echo ""
}

show_summary() {
    echo "[6/6] 构建成功！"
    echo "========================================="
    echo ""
    echo "构建产物:"
    if [ -d "$DIST_DIR/$APP_NAME.app" ]; then
        APP_SIZE=$(du -sh "$DIST_DIR/$APP_NAME.app" | cut -f1)
        echo "  - $DIST_DIR/$APP_NAME.app ($APP_SIZE)"
    fi
    if [ -f "$DMG_PATH" ]; then
        DMG_SIZE=$(du -sh "$DMG_PATH" | cut -f1)
        echo "  - $DMG_PATH ($DMG_SIZE)"
    fi
    echo ""
    echo "========================================="
}

usage() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --clean    仅清理构建文件"
    echo "  --app      仅构建 .app 应用包"
    echo "  --dmg      构建 .app 和 DMG 安装包"
    echo "  -h, --help 显示帮助信息"
    echo ""
}

case "${1:-}" in
    --clean)
        clean
        exit 0
        ;;
    --app)
        clean
        create_icon
        install_deps
        build_app
        show_summary
        exit 0
        ;;
    --dmg)
        clean
        create_icon
        install_deps
        build_app
        create_dmg
        show_summary
        exit 0
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        clean
        create_icon
        install_deps
        build_app
        create_dmg
        show_summary
        exit 0
        ;;
esac
