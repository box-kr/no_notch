import AppKit
import WebKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties

    private var statusItem: NSStatusItem!
    private let overlayManager = NotchOverlayManager.shared
    private var toggleCount: Int = 0
    private let coffeeShowInterval: Int = 3

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

        // 토글 횟수 카운트 → 3회마다 Buy Me a Coffee 다이얼로그 표시
        toggleCount += 1
        if toggleCount % coffeeShowInterval == 0 {
            showBuyMeACoffeeDialog()
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
            ? L10n.tooltipEnabled
            : L10n.tooltipDisabled
    }

    // MARK: - Menu

    private func showMenu() {
        let menu = NSMenu()

        // About NoNotch
        let aboutItem = NSMenuItem(
            title: "About NoNotch",
            action: #selector(showAboutWindow),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem.separator())

        // 토글 아이템
        let toggleTitle = overlayManager.isEnabled ? L10n.disableNotchBar : L10n.enableNotchBar
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(menuToggle), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        // 로그인 시 자동 시작
        let launchItem = NSMenuItem(
            title: L10n.launchAtLogin,
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchItem.target = self
        launchItem.state = LaunchAtLoginManager.isEnabled ? .on : .off
        menu.addItem(launchItem)

        menu.addItem(NSMenuItem.separator())

        let coffeeItem = NSMenuItem(
            title: L10n.buyMeACoffee,
            action: #selector(openBuyMeACoffee),
            keyEquivalent: ""
        )
        coffeeItem.target = self
        menu.addItem(coffeeItem)

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
        let quitItem = NSMenuItem(title: L10n.quit, action: #selector(quitApp), keyEquivalent: "q")
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

    @objc private func openBuyMeACoffee() {
        showBuyMeACoffeeDialog()
    }

    @objc private func showAboutWindow() {
        NSApp.activate(ignoringOtherApps: true)
        
        var options: [NSApplication.AboutPanelOptionKey: Any] = [
            .applicationName: "NoNotch"
        ]
        
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            // macOS About 윈도우에서는 .applicationVersion(굵은글씨)과 .version(괄호 안)을 사용합니다.
            options[.applicationVersion] = version
        }
        
        // 아이콘을 명시적으로 로드합니다.
        if let icon = NSImage(named: "AppIcon.png") ?? NSImage(named: "AppIcon") {
            options[.applicationIcon] = icon
        } else if let iconPath = Bundle.main.path(forResource: "AppIcon", ofType: "png"),
                  let iconImage = NSImage(contentsOfFile: iconPath) {
            options[.applicationIcon] = iconImage
        }
        
        NSApp.orderFrontStandardAboutPanel(options: options)
    }

    @objc private func quitApp() {
        // 종료 전 원래 해상도로 복원
        if overlayManager.isEnabled {
            overlayManager.disable()
        }
        NSApp.terminate(nil)
    }

    // MARK: - Buy Me a Coffee Dialog

    private var coffeeWindow: NSWindow?

    private func showBuyMeACoffeeDialog() {
        // 기존 창이 있으면 앞으로 가져오기
        if let existingWindow = coffeeWindow, existingWindow.isVisible {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let windowWidth: CGFloat = 480
        let windowHeight: CGFloat = 700

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "☕ Buy Me a Coffee"
        window.center()
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 400, height: 500)

        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight))
        webView.autoresizingMask = [.width, .height]

        if let url = URL(string: "https://buymeacoffee.com/funbox.kr") {
            webView.load(URLRequest(url: url))
        }

        window.contentView = webView
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        coffeeWindow = window
    }
}
