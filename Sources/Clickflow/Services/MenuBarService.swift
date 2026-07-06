import AppKit
import Combine
import SwiftUI

@MainActor
class MenuBarService: NSObject {
    private var statusItem: NSStatusItem!
    private var viewModel: ClickViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    func setup(with viewModel: ClickViewModel) {
        self.viewModel = viewModel
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "cursorarrow.click", accessibilityDescription: "Clickflow")
            button.image?.isTemplate = true
        }
        
        setupMenu()
        setupObservers()
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        let toggleItem = NSMenuItem(
            title: toggleTitle(for: viewModel.runStatus),
            action: #selector(toggleClicked),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let showWindowItem = NSMenuItem(
            title: "显示主窗口",
            action: #selector(showWindowClicked),
            keyEquivalent: ""
        )
        showWindowItem.target = self
        menu.addItem(showWindowItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(
            title: "退出",
            action: #selector(quitClicked),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    private func setupObservers() {
        viewModel.$runStatus
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                self?.updateToggleMenuItem(for: status)
            }
            .store(in: &cancellables)
    }
    
    private func toggleTitle(for status: RunStatus) -> String {
        switch status {
        case .ready:
            return "开始"
        case .running:
            return "暂停"
        case .paused:
            return "继续"
        }
    }
    
    private func updateToggleMenuItem(for status: RunStatus) {
        guard let menu = statusItem.menu, let toggleItem = menu.items.first else { return }
        toggleItem.title = toggleTitle(for: status)
    }
    
    @objc private func toggleClicked() {
        switch viewModel.runStatus {
        case .ready:
            viewModel.start()
        case .running:
            viewModel.pause()
        case .paused:
            viewModel.resume()
        }
    }
    
    @objc private func showWindowClicked() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.title == "Clickflow" }) {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    @objc private func quitClicked() {
        NSApp.terminate(nil)
    }
}
