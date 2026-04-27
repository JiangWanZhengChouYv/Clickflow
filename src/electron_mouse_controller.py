#!/usr/bin/env python3
import sys
import json
from Quartz import (
    CGEventCreateMouseEvent,
    CGEventPost,
    kCGEventLeftMouseDown,
    kCGEventLeftMouseUp,
    kCGEventRightMouseDown,
    kCGEventRightMouseUp,
    kCGHIDEventTap,
    kCGMouseButtonLeft,
    kCGMouseButtonRight,
    CGEventSourceCreate,
    kCGEventSourceStateHIDSystemState,
    CGGetEventSourceLocation
)


def move_to(x, y):
    event = CGEventCreateMouseEvent(None, kCGEventLeftMouseDown, (x, y), kCGMouseButtonLeft)
    CGEventPost(kCGHIDEventTap, event)


def left_click(x, y):
    event_down = CGEventCreateMouseEvent(None, kCGEventLeftMouseDown, (x, y), kCGMouseButtonLeft)
    CGEventPost(kCGHIDEventTap, event_down)
    
    event_up = CGEventCreateMouseEvent(None, kCGEventLeftMouseUp, (x, y), kCGMouseButtonLeft)
    CGEventPost(kCGHIDEventTap, event_up)


def right_click(x, y):
    event_down = CGEventCreateMouseEvent(None, kCGEventRightMouseDown, (x, y), kCGMouseButtonRight)
    CGEventPost(kCGHIDEventTap, event_down)
    
    event_up = CGEventCreateMouseEvent(None, kCGEventRightMouseUp, (x, y), kCGMouseButtonRight)
    CGEventPost(kCGHIDEventTap, event_up)


def click(x, y, button='left'):
    if button == 'left':
        left_click(x, y)
    else:
        right_click(x, y)


def get_position():
    try:
        loc = CGGetEventSourceLocation(CGEventSourceCreate(kCGEventSourceStateHIDSystemState))
        return {'x': int(loc.x), 'y': int(loc.y)}
    except Exception:
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
        x = int(sys.argv[2])
        y = int(sys.argv[3])
        button = sys.argv[4]
        click(x, y, button)
        print(json.dumps({'success': True}))
    elif command == 'get_position':
        pos = get_position()
        print(json.dumps(pos))
    else:
        print(json.dumps({'error': 'Unknown command'}))


if __name__ == '__main__':
    main()
