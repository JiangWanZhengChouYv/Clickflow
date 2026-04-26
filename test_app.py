import sys
import os

# 在无头环境中配置 Qt 使用 offscreen 平台
os.environ["QT_QPA_PLATFORM"] = "offscreen"

from PyQt5.QtWidgets import QApplication

# 测试导入和基本初始化
try:
    from src.main import MainWindow
    print("✓ 成功导入 MainWindow 类")
    
    # 创建应用实例（不显示窗口，因为是无头环境）
    app = QApplication.instance()
    if app is None:
        app = QApplication(sys.argv)
    print("✓ QApplication 创建成功")
    
    # 创建主窗口
    window = MainWindow()
    print("✓ MainWindow 初始化成功")
    print("✓ 项目结构验证完成！")
    
except Exception as e:
    print(f"✗ 错误: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
