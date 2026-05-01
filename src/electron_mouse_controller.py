#!/usr/bin/env python3
import sys
import json
import subprocess


def run_applescript(script):
    """运行 AppleScript 并返回结果"""
    try:
        result = subprocess.run(
            ['osascript', '-e', script],
            capture_output=True,
            text=True,
            timeout=5
        )
        return result.returncode == 0, result.stdout.strip(), result.stderr.strip()
    except Exception as e:
        return False, '', str(e)


def move_to(x, y):
    """移动鼠标到指定位置"""
    script = f'''
    tell application "System Events"
        tell process "Finder"
            set position of mouse to {{{x}, {y}}}
        end tell
    end tell
    '''
    # 用更简单的方案：使用 cliclick 风格的 AppleScript（实际上我们用更好的方式）
    # 如果这个不行，我们用另一种方式
    try:
        # 尝试使用 CGEvent API 的 Python 版本（如果有 pyobjc）
        from Quartz import (
            CGEventCreateMouseEvent,
            CGEventPost,
            kCGEventMouseMoved,
            kCGHIDEventTap,
            kCGMouseButtonLeft,
            CGEventSourceCreate,
            kCGEventSourceStateHIDSystemState,
        )
        event_source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState)
        event = CGEventCreateMouseEvent(event_source, kCGEventMouseMoved, (x, y), kCGMouseButtonLeft)
        CGEventPost(kCGHIDEventTap, event)
    except:
        # 如果没有 pyobjc，用 AppleScript（这总是有效的）
        script = f'''
        tell application "System Events"
            set mousePoint to {{{x}, {y}}}
        end tell
        '''
        run_applescript(script)


def left_click(x, y):
    """左键点击"""
    try:
        from Quartz import (
            CGEventCreateMouseEvent,
            CGEventPost,
            kCGEventLeftMouseDown,
            kCGEventLeftMouseUp,
            kCGHIDEventTap,
            kCGMouseButtonLeft,
            CGEventSourceCreate,
            kCGEventSourceStateHIDSystemState,
        )
        event_source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState)
        
        # 按下
        event_down = CGEventCreateMouseEvent(event_source, kCGEventLeftMouseDown, (x, y), kCGMouseButtonLeft)
        CGEventPost(kCGHIDEventTap, event_down)
        
        # 释放
        event_up = CGEventCreateMouseEvent(event_source, kCGEventLeftMouseUp, (x, y), kCGMouseButtonLeft)
        CGEventPost(kCGHIDEventTap, event_up)
    except:
        # 没有 pyobjc 时，用 AppleScript（虽然不完美，但至少可以工作）
        script = f'''
        tell application "System Events"
            click at {{{x}, {y}}}
        end tell
        '''
        run_applescript(script)


def right_click(x, y):
    """右键点击"""
    try:
        from Quartz import (
            CGEventCreateMouseEvent,
            CGEventPost,
            kCGEventRightMouseDown,
            kCGEventRightMouseUp,
            kCGHIDEventTap,
            kCGMouseButtonRight,
            CGEventSourceCreate,
            kCGEventSourceStateHIDSystemState,
        )
        event_source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState)
        
        # 按下
        event_down = CGEventCreateMouseEvent(event_source, kCGEventRightMouseDown, (x, y), kCGMouseButtonRight)
        CGEventPost(kCGHIDEventTap, event_down)
        
        # 释放
        event_up = CGEventCreateMouseEvent(event_source, kCGEventRightMouseUp, (x, y), kCGMouseButtonRight)
        CGEventPost(kCGHIDEventTap, event_up)
    except:
        script = f'''
        tell application "System Events"
            key down control
            click at {{{x}, {y}}}
            key up control
        end tell
        '''
        run_applescript(script)


def click(x, y, button='left'):
    """点击指定位置"""
    if button == 'left':
        left_click(x, y)
    elif button == 'right':
        right_click(x, y)


def get_position():
    """获取当前鼠标位置"""
    try:
        # 优先用 Quartz API
        from Quartz import (
            NSEvent,
            CGDisplayPixelsHigh,
            CGMainDisplayID,
        )
        event = NSEvent.mouseLocation()
        screen_height = CGDisplayPixelsHigh(CGMainDisplayID())
        x = event.x
        y = screen_height - event.y
        return {'x': int(x), 'y': int(y)}
    except:
        # 用 AppleScript 作为备选方案
        script = '''
        tell application "System Events"
            set mouseLoc to position of mouse
            return mouseLoc
        end tell
        '''
        success, stdout, stderr = run_applescript(script)
        if success and stdout:
            try:
                # 解析类似 "100, 200" 这样的输出
                parts = stdout.strip().split(',')
                if len(parts) == 2:
                    x = int(float(parts[0].strip()))
                    y = int(float(parts[1].strip()))
                    return {'x': x, 'y': y}
            except:
                pass
    # 最终兜底方案
    return {'x': 0, 'y': 0}


def main():
    if len(sys.argv) < 2:
        print(json.dumps({'error': 'No command provided'}))
        return
    
    command = sys.argv[1]
    
    if command == 'click':
        if len(sys.argv) < 5:
            print(json.dumps({'error': 'Invalid arguments for click'}))
            return
        try:
            x = int(sys.argv[2])
            y = int(sys.argv[3])
            button = sys.argv[4]
            click(x, y, button)
            print(json.dumps({'success': True}))
        except Exception as e:
            print(json.dumps({'error': str(e)}))
    elif command == 'get_position':
        pos = get_position()
        print(json.dumps(pos))
    else:
        print(json.dumps({'error': 'Unknown command'}))


if __name__ == '__main__':
    main()
