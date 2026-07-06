import AppKit
import Carbon

@MainActor
class HotKeyService {
    private var hotKeyRef: EventHotKeyRef?
    private var viewModel: ClickViewModel?
    
    private let hotKeyID = EventHotKeyID(signature: OSType(0x434C464C), id: 1)
    
    func setup(with viewModel: ClickViewModel) {
        self.viewModel = viewModel
        registerHotKey()
    }
    
    private func registerHotKey() {
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)
        
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, eventRef, userData) -> OSStatus in
                guard let userData = userData, let eventRef = eventRef else {
                    return noErr
                }
                
                let hotKeyService = Unmanaged<HotKeyService>.fromOpaque(userData).takeUnretainedValue()
                
                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    eventRef,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                
                if hotKeyID.id == hotKeyService.hotKeyID.id {
                    Task { @MainActor in
                        hotKeyService.handleHotKey()
                    }
                }
                
                return noErr
            },
            1,
            &eventType,
            selfPtr,
            nil
        )
        
        let keyCode = UInt32(kVK_ANSI_S)
        let modifiers = UInt32(cmdKey | shiftKey)
        
        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }
    
    private func handleHotKey() {
        guard let viewModel = viewModel else { return }
        
        switch viewModel.runStatus {
        case .ready:
            viewModel.start()
        case .running:
            viewModel.pause()
        case .paused:
            viewModel.resume()
        }
    }
    
    deinit {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }
}
