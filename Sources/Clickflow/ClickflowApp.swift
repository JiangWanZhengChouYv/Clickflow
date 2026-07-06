import SwiftUI
import AppKit

@main
struct ClickflowApp: App {
    @StateObject private var viewModel = ClickViewModel()
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup("Clickflow") {
            ContentView()
                .environmentObject(viewModel)
                .onAppear {
                    appDelegate.setupServices(with: viewModel)
                }
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private let menuBarService = MenuBarService()
    private let hotKeyService = HotKeyService()
    private var viewModel: ClickViewModel?
    
    func setupServices(with viewModel: ClickViewModel) {
        guard self.viewModel == nil else { return }
        self.viewModel = viewModel
        menuBarService.setup(with: viewModel)
        hotKeyService.setup(with: viewModel)
    }
}
