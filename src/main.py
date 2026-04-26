import sys
import time
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QGridLayout, QLabel, QLineEdit, QPushButton, QRadioButton,
    QButtonGroup, QCheckBox, QListWidget, QGroupBox, QSplitter,
    QFrame, QSpinBox, QMessageBox
)
from PyQt5.QtCore import Qt, QThread, pyqtSignal
from PyQt5.QtGui import QFont, QColor, QPalette
from mouse_controller import MouseController
from hotkey_manager import HotkeyManager


class ClickerThread(QThread):
    status_updated = pyqtSignal(str)
    count_updated = pyqtSignal(int)
    finished = pyqtSignal()
    error_occurred = pyqtSignal(str)

    def __init__(self):
        super().__init__()
        self.mouse = MouseController()
        self._running = False
        self._paused = False
        self._stopped = False
        self.x = 0
        self.y = 0
        self.interval = 100
        self.click_count = 100
        self.infinite = False
        self.button = 'left'
        self.points = []
        self.is_multi_mode = False

    def setup(self, x, y, interval, click_count, infinite, button, points=None, is_multi_mode=False):
        self.x = x
        self.y = y
        self.interval = interval
        self.click_count = click_count
        self.infinite = infinite
        self.button = button
        self.points = points if points is not None else []
        self.is_multi_mode = is_multi_mode
        self._running = False
        self._paused = False
        self._stopped = False

    def run(self):
        self._running = True
        self.status_updated.emit("运行中")
        count = 0
        current_point_index = 0

        while self._running:
            if self._stopped:
                break

            if self._paused:
                time.sleep(0.1)
                continue

            try:
                if self.is_multi_mode and self.points:
                    x, y = self.points[current_point_index]
                    current_point_index = (current_point_index + 1) % len(self.points)
                else:
                    x, y = self.x, self.y

                self.mouse.click(x, y, self.button)
                count += 1
                self.count_updated.emit(count)

                if not self.infinite and count >= self.click_count:
                    break

                time.sleep(self.interval / 1000.0)
            except Exception as e:
                self.error_occurred.emit(str(e))
                break

        self._running = False
        self.status_updated.emit("就绪")
        self.finished.emit()

    def pause(self):
        self._paused = True
        self.status_updated.emit("暂停")

    def resume(self):
        self._paused = False
        self.status_updated.emit("运行中")

    def stop(self):
        self._stopped = True
        self._running = False

    def is_running(self):
        return self._running and not self._stopped

    def is_paused(self):
        return self._paused


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        
        self.setWindowTitle("macOS 鼠标连点器")
        self.setGeometry(100, 100, 500, 750)
        self.setMinimumSize(450, 700)
        
        self.points = []
        self.clicker_thread = ClickerThread()
        self.hotkey_manager = HotkeyManager(callback=self.toggle_clicker)
        
        self.init_ui()
        self.connect_signals()
        self.hotkey_manager.start()
        
    def init_ui(self):
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        main_layout = QVBoxLayout()
        main_layout.setSpacing(15)
        main_layout.setContentsMargins(20, 20, 20, 20)
        central_widget.setLayout(main_layout)
        
        self.create_mode_section(main_layout)
        self.create_point_config_section(main_layout)
        self.create_time_settings_section(main_layout)
        self.create_mouse_button_section(main_layout)
        self.create_control_section(main_layout)
        self.create_hotkey_section(main_layout)
        self.create_status_section(main_layout)
        
    def create_mode_section(self, parent_layout):
        group = QGroupBox("模式选择")
        layout = QHBoxLayout()
        
        self.mode_group = QButtonGroup()
        self.single_point_radio = QRadioButton("固定单点")
        self.single_point_radio.setChecked(True)
        self.multi_point_radio = QRadioButton("多点循环")
        
        self.mode_group.addButton(self.single_point_radio, 1)
        self.mode_group.addButton(self.multi_point_radio, 2)
        
        layout.addWidget(self.single_point_radio)
        layout.addWidget(self.multi_point_radio)
        
        group.setLayout(layout)
        parent_layout.addWidget(group)
        
    def create_point_config_section(self, parent_layout):
        group = QGroupBox("点位配置")
        layout = QVBoxLayout()
        
        coord_layout = QHBoxLayout()
        coord_layout.addWidget(QLabel("X:"))
        self.x_input = QLineEdit()
        self.x_input.setPlaceholderText("0")
        coord_layout.addWidget(self.x_input)
        
        coord_layout.addWidget(QLabel("Y:"))
        self.y_input = QLineEdit()
        self.y_input.setPlaceholderText("0")
        coord_layout.addWidget(self.y_input)
        
        self.pick_button = QPushButton("拾取坐标")
        coord_layout.addWidget(self.pick_button)
        
        layout.addLayout(coord_layout)
        
        point_action_layout = QHBoxLayout()
        self.add_point_button = QPushButton("添加点位")
        self.edit_point_button = QPushButton("编辑点位")
        self.delete_point_button = QPushButton("删除点位")
        self.clear_points_button = QPushButton("清空点位")
        
        point_action_layout.addWidget(self.add_point_button)
        point_action_layout.addWidget(self.edit_point_button)
        point_action_layout.addWidget(self.delete_point_button)
        point_action_layout.addWidget(self.clear_points_button)
        
        layout.addLayout(point_action_layout)
        
        self.point_list = QListWidget()
        self.point_list.setMaximumHeight(120)
        layout.addWidget(self.point_list)
        
        group.setLayout(layout)
        parent_layout.addWidget(group)
        
    def create_time_settings_section(self, parent_layout):
        group = QGroupBox("时间设置")
        layout = QGridLayout()
        
        layout.addWidget(QLabel("间隔时间(毫秒):"), 0, 0)
        self.interval_spin = QSpinBox()
        self.interval_spin.setRange(1, 60000)
        self.interval_spin.setValue(100)
        layout.addWidget(self.interval_spin, 0, 1, 1, 2)
        
        layout.addWidget(QLabel("点击次数:"), 1, 0)
        self.click_count_spin = QSpinBox()
        self.click_count_spin.setRange(1, 999999)
        self.click_count_spin.setValue(100)
        layout.addWidget(self.click_count_spin, 1, 1, 1, 2)
        
        self.infinite_checkbox = QCheckBox("无限循环")
        layout.addWidget(self.infinite_checkbox, 2, 0, 1, 3)
        
        group.setLayout(layout)
        parent_layout.addWidget(group)
        
    def create_mouse_button_section(self, parent_layout):
        group = QGroupBox("鼠标按键")
        layout = QHBoxLayout()
        
        self.button_group = QButtonGroup()
        self.left_button_radio = QRadioButton("左键")
        self.left_button_radio.setChecked(True)
        self.right_button_radio = QRadioButton("右键")
        
        self.button_group.addButton(self.left_button_radio, 1)
        self.button_group.addButton(self.right_button_radio, 2)
        
        layout.addWidget(self.left_button_radio)
        layout.addWidget(self.right_button_radio)
        
        group.setLayout(layout)
        parent_layout.addWidget(group)
        
    def create_control_section(self, parent_layout):
        group = QGroupBox("操作控制")
        layout = QHBoxLayout()
        
        self.start_button = QPushButton("开始")
        self.pause_button = QPushButton("暂停")
        self.pause_button.setEnabled(False)
        self.stop_button = QPushButton("停止")
        self.stop_button.setEnabled(False)
        
        layout.addWidget(self.start_button)
        layout.addWidget(self.pause_button)
        layout.addWidget(self.stop_button)
        
        group.setLayout(layout)
        parent_layout.addWidget(group)
        
    def create_hotkey_section(self, parent_layout):
        group = QGroupBox("全局快捷键")
        layout = QVBoxLayout()
        
        hotkey_label = QLabel("开始/停止: Cmd + Shift + S")
        hotkey_label.setAlignment(Qt.AlignCenter)
        hotkey_label.setFont(QFont("Arial", 11))
        
        layout.addWidget(hotkey_label)
        
        group.setLayout(layout)
        parent_layout.addWidget(group)

    def create_status_section(self, parent_layout):
        group = QGroupBox("运行状态")
        layout = QVBoxLayout()
        
        self.status_label = QLabel("就绪")
        self.status_label.setAlignment(Qt.AlignCenter)
        self.status_label.setFont(QFont("Arial", 12, QFont.Bold))
        
        palette = QPalette()
        palette.setColor(QPalette.WindowText, QColor(0, 128, 0))
        self.status_label.setPalette(palette)
        
        layout.addWidget(self.status_label)
        
        group.setLayout(layout)
        parent_layout.addWidget(group)
    
    def toggle_clicker(self):
        if self.clicker_thread.is_running():
            self.on_stop()
        else:
            if not self.clicker_thread.is_paused():
                self.on_start()
            else:
                self.on_pause()
    
    def closeEvent(self, event):
        if self.clicker_thread.is_running():
            self.clicker_thread.stop()
            self.clicker_thread.wait()
        
        self.hotkey_manager.stop()
        event.accept()
    
    def connect_signals(self):
        self.start_button.clicked.connect(self.on_start)
        self.pause_button.clicked.connect(self.on_pause)
        self.stop_button.clicked.connect(self.on_stop)
        self.pick_button.clicked.connect(self.on_pick_coordinate)
        self.add_point_button.clicked.connect(self.on_add_point)
        self.edit_point_button.clicked.connect(self.on_edit_point)
        self.delete_point_button.clicked.connect(self.on_delete_point)
        self.clear_points_button.clicked.connect(self.on_clear_points)
        
        self.clicker_thread.status_updated.connect(self.update_status)
        self.clicker_thread.finished.connect(self.on_clicker_finished)
        self.clicker_thread.error_occurred.connect(self.show_error)
    
    def update_status(self, status_text):
        self.status_label.setText(status_text)
        
        palette = QPalette()
        if status_text == "运行中":
            palette.setColor(QPalette.WindowText, QColor(0, 128, 0))
        elif status_text == "暂停":
            palette.setColor(QPalette.WindowText, QColor(255, 165, 0))
        elif status_text == "就绪":
            palette.setColor(QPalette.WindowText, QColor(0, 0, 128))
        else:
            palette.setColor(QPalette.WindowText, QColor(0, 0, 0))
        
        self.status_label.setPalette(palette)
    
    def on_clicker_finished(self):
        self.start_button.setEnabled(True)
        self.pause_button.setEnabled(False)
        self.pause_button.setText("暂停")
        self.stop_button.setEnabled(False)
    
    def show_error(self, error_msg):
        QMessageBox.critical(self, "错误", f"发生错误: {error_msg}")
        self.on_clicker_finished()
    
    def on_pick_coordinate(self):
        try:
            from Quartz import CGEventSourceCreate, kCGEventSourceStateHIDSystemState, CGGetEventSourceLocation
            loc = CGGetEventSourceLocation(CGEventSourceCreate(kCGEventSourceStateHIDSystemState))
            x = int(loc.x)
            y = int(loc.y)
            self.x_input.setText(str(x))
            self.y_input.setText(str(y))
        except Exception as e:
            QMessageBox.warning(self, "提示", "拾取坐标功能需要额外实现，当前请手动输入坐标")
    
    def on_add_point(self):
        try:
            if len(self.points) >= 3:
                QMessageBox.warning(self, "限制提示", "最多只能添加3个点位")
                return
            
            x = int(self.x_input.text()) if self.x_input.text() else 0
            y = int(self.y_input.text()) if self.y_input.text() else 0
            
            self.points.append((x, y))
            point_num = len(self.points)
            self.point_list.addItem(f"点位 {point_num}: ({x}, {y})")
            
        except ValueError as e:
            QMessageBox.warning(self, "输入错误", "请输入有效的坐标值")
    
    def on_edit_point(self):
        try:
            current_row = self.point_list.currentRow()
            if current_row < 0:
                QMessageBox.warning(self, "提示", "请先选择要编辑的点位")
                return
            
            x = int(self.x_input.text()) if self.x_input.text() else 0
            y = int(self.y_input.text()) if self.y_input.text() else 0
            
            self.points[current_row] = (x, y)
            self.point_list.item(current_row).setText(f"点位 {current_row + 1}: ({x}, {y})")
            
        except ValueError as e:
            QMessageBox.warning(self, "输入错误", "请输入有效的坐标值")
    
    def on_delete_point(self):
        current_row = self.point_list.currentRow()
        if current_row < 0:
            QMessageBox.warning(self, "提示", "请先选择要删除的点位")
            return
        
        del self.points[current_row]
        self.point_list.takeItem(current_row)
        
        for i in range(current_row, len(self.points)):
            x, y = self.points[i]
            self.point_list.item(i).setText(f"点位 {i + 1}: ({x}, {y})")
    
    def on_clear_points(self):
        self.points.clear()
        self.point_list.clear()
    
    def on_start(self):
        try:
            x = int(self.x_input.text()) if self.x_input.text() else 0
            y = int(self.y_input.text()) if self.y_input.text() else 0
            interval = self.interval_spin.value()
            click_count = self.click_count_spin.value()
            infinite = self.infinite_checkbox.isChecked()
            button = 'left' if self.left_button_radio.isChecked() else 'right'
            
            is_multi_mode = self.multi_point_radio.isChecked()
            
            if is_multi_mode:
                if not self.points:
                    QMessageBox.warning(self, "提示", "多点模式下请先添加至少1个点位")
                    return
                
                self.clicker_thread.setup(x, y, interval, click_count, infinite, button, self.points, is_multi_mode=True)
            else:
                self.clicker_thread.setup(x, y, interval, click_count, infinite, button)
            
            self.clicker_thread.start()
            
            self.start_button.setEnabled(False)
            self.pause_button.setEnabled(True)
            self.stop_button.setEnabled(True)
        except ValueError as e:
            QMessageBox.warning(self, "输入错误", "请输入有效的坐标值")
    
    def on_pause(self):
        if self.clicker_thread.is_paused():
            self.clicker_thread.resume()
            self.pause_button.setText("暂停")
        else:
            self.clicker_thread.pause()
            self.pause_button.setText("继续")
    
    def on_stop(self):
        self.clicker_thread.stop()


def main():
    app = QApplication(sys.argv)
    app.setStyle('Fusion')
    
    window = MainWindow()
    window.show()
    
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
