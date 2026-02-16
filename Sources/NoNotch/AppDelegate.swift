import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties

    private var statusItem: NSStatusItem!
    private let overlayManager = NotchOverlayManager.shared

    // MARK: - App Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        overlayManager.restoreState()
        updateStatusIcon()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // 앱 종료 시 원래 해상도로 복원
        if overlayManager.isEnabled {
            overlayManager.disable()
        }
    }

    // MARK: - Status Bar Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        guard let button = statusItem.button else { return }
        button.action = #selector(statusItemClicked(_:))
        button.target = self
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            toggleOverlay()
        }
    }

    // MARK: - Actions

    private func toggleOverlay() {
        overlayManager.toggle()
        updateStatusIcon()

        // Buy Me a Coffee 페이지 노출
        if let url = URL(string: "https://buymeacoffee.com/funbox.kr") {
            NSWorkspace.shared.open(url)
        }
    }

    private func updateStatusIcon() {
        guard let button = statusItem.button else { return }

        let iconName = overlayManager.isEnabled
            ? "rectangle.topthird.inset.filled"
            : "rectangle.topthird.inset"

        if let image = NSImage(systemSymbolName: iconName, accessibilityDescription: "NoNotch") {
            image.isTemplate = true
            button.image = image
        } else {
            button.title = overlayManager.isEnabled ? "◼︎" : "◻︎"
        }

        button.toolTip = overlayManager.isEnabled
            ? "NoNotch: 활성화 (클릭하여 비활성화)"
            : "NoNotch: 비활성화 (클릭하여 활성화)"
    }

    // MARK: - Menu

    private func showMenu() {
        let menu = NSMenu()

        // 토글 아이템
        let toggleTitle = overlayManager.isEnabled ? "노치 바 비활성화" : "노치 바 활성화"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(menuToggle), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        // 로그인 시 자동 시작
        let launchItem = NSMenuItem(
            title: "로그인 시 자동 시작",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchItem.target = self
        launchItem.state = LaunchAtLoginManager.isEnabled ? .on : .off
        menu.addItem(launchItem)

        menu.addItem(NSMenuItem.separator())

        // 노치 정보
        let notchInfo = NSMenuItem(title: overlayManager.notchInfoString, action: nil, keyEquivalent: "")
        notchInfo.isEnabled = false
        menu.addItem(notchInfo)

        // 해상도 정보
        let modeInfo = NSMenuItem(title: overlayManager.availableModesInfo, action: nil, keyEquivalent: "")
        modeInfo.isEnabled = false
        menu.addItem(modeInfo)

        menu.addItem(NSMenuItem.separator())

        // 종료
        let quitItem = NSMenuItem(title: "종료", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func menuToggle() {
        toggleOverlay()
    }

    @objc private func toggleLaunchAtLogin() {
        LaunchAtLoginManager.toggle()
    }

    @objc private func quitApp() {
        // 종료 전 원래 해상도로 복원
        if overlayManager.isEnabled {
            overlayManager.disable()
        }
        NSApp.terminate(nil)
    }
}
