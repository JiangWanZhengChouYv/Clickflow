#!/usr/bin/env python3
import sys
import json
import ctypes
from ctypes import cdll, Structure, c_int, c_double, c_void_p

class CGPoint(Structure):
    _fields_ = [("x", c_double), ("y", c_double)]

CoreGraphics = cdll.LoadLibrary('/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics')

CGEventCreateMouseEvent = CoreGraphics.CGEventCreateMouseEvent
CGEventCreateMouseEvent.argtypes = [c_void_p, c_int, CGPoint, c_int]
CGEventCreateMouseEvent.restype = c_void_p

CGEventPost = CoreGraphics.CGEventPost
CGEventPost.argtypes = [c_int, c_void_p]
CGEventPost.restype = None

kCGEventLeftMouseDown = 1
kCGEventLeftMouseUp = 2
kCGEventRightMouseDown = 3
kCGEventRightMouseUp = 4
kCGHIDEventTap = 0
kCGMouseButtonLeft = 0
kCGMouseButtonRight = 1

def click(x, y, button_type='left'):
    point = CGPoint(x, y)
    if button_type == 'left':
        event_down = CGEventCreateMouseEvent(None, kCGEventLeftMouseDown, point, kCGMouseButtonLeft)
        CGEventPost(kCGHIDEventTap, event_down)
        event_up = CGEventCreateMouseEvent(None, kCGEventLeftMouseUp, point, kCGMouseButtonLeft)
        CGEventPost(kCGHIDEventTap, event_up)
    elif button_type == 'right':
        event_down = CGEventCreateMouseEvent(None, kCGEventRightMouseDown, point, kCGMouseButtonRight)
        CGEventPost(kCGHIDEventTap, event_down)
        event_up = CGEventCreateMouseEvent(None, kCGEventRightMouseUp, point, kCGMouseButtonRight)
        CGEventPost(kCGHIDEventTap, event_up)

def main():
    if len(sys.argv) < 2:
        print(json.dumps({'error': 'No command'}))
        return
    
    command = sys.argv[1]
    
    if command == 'click':
        if len(sys.argv) < 5:
            print(json.dumps({'error': 'Invalid args'}))
            return
        x = float(sys.argv[2])
        y = float(sys.argv[3])
        button_type = sys.argv[4]
        click(x, y, button_type)
        print(json.dumps({'success': True}))
    elif command == 'get_position':
        print(json.dumps({'x': 0, 'y': 0}))

if __name__ == '__main__':
    main()
