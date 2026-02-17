import AppKit
import CoreGraphics

/// 디스플레이 해상도를 노치 아래 영역에 맞게 변경하여
/// 메뉴바를 노치 아래로 밀어내는 매니저
final class NotchOverlayManager {

    // MARK: - Properties

    private(set) var isEnabled: Bool = false
    private var originalModes: [CGDirectDisplayID: CGDisplayMode] = [:]
    private var isChangingMode: Bool = false

    // MARK: - Singleton

    static let shared = NotchOverlayManager()
    private init() {
        setupScreenChangeObserver()
    }

    // MARK: - Public Methods

    func toggle() {
        if isEnabled { disable() } else { enable() }
    }

    func enable() {
        guard !isEnabled else { return }
        isEnabled = true
        applyBelowNotchModes()
        saveState()
    }

    func disable() {
        guard isEnabled else { return }
        isEnabled = false
        restoreOriginalModes()
        saveState()
    }

    func restoreState() {
        if UserDefaults.standard.bool(forKey: stateKey) {
            enable()
        }
    }

    /// 노치 정보 문자열
    var notchInfoString: String {
        guard let screen = NSScreen.main else { return L10n.noScreenInfo }
        let notchHeight = screen.safeAreaInsets.top
        if notchHeight > 0 {
            return L10n.notchDetected(height: Int(notchHeight))
        }
        return L10n.noNotchDetected
    }

    /// 사용 가능한 해상도 정보
    var availableModesInfo: String {
        guard let screen = NSScreen.main,
              let displayID = displayID(for: screen) else {
            return L10n.noDisplayInfo
        }

        guard let currentMode = CGDisplayCopyDisplayMode(displayID) else {
            return L10n.noCurrentModeInfo
        }

        var info = L10n.currentResolution(width: currentMode.width, height: currentMode.height)

        if let belowMode = findBelowNotchMode(displayID: displayID, screen: screen, currentMode: currentMode) {
            info += L10n.changeResolution(width: belowMode.width, height: belowMode.height)
        } else {
            info += L10n.noBelowNotchMode
        }

        return info
    }

    // MARK: - Display Mode Management

    private func applyBelowNotchModes() {
        isChangingMode = true
        defer { isChangingMode = false }

        for screen in NSScreen.screens {
            guard screen.safeAreaInsets.top > 0,
                  let displayID = displayID(for: screen) else { continue }

            guard let currentMode = CGDisplayCopyDisplayMode(displayID) else { continue }

            // 현재 모드 저장 (복원용)
            originalModes[displayID] = currentMode

            // 노치 아래 모드 찾기
            if let belowNotchMode = findBelowNotchMode(
                displayID: displayID,
                screen: screen,
                currentMode: currentMode
            ) {
                let result = CGDisplaySetDisplayMode(displayID, belowNotchMode, nil)
                if result == .success {
                    print("[NoNotch] 디스플레이 모드 변경 성공: \(currentMode.width)×\(currentMode.height) → \(belowNotchMode.width)×\(belowNotchMode.height)")
                } else {
                    print("[NoNotch] 디스플레이 모드 변경 실패: CGError \(result.rawValue)")
                }
            } else {
                print("[NoNotch] 적합한 노치 아래 모드를 찾지 못했습니다.")
                printAvailableModes(displayID: displayID)
            }
        }
    }

    private func restoreOriginalModes() {
        isChangingMode = true
        defer { isChangingMode = false }

        for (displayID, mode) in originalModes {
            let result = CGDisplaySetDisplayMode(displayID, mode, nil)
            if result == .success {
                print("[NoNotch] 원래 모드로 복원: \(mode.width)×\(mode.height)")
            } else {
                print("[NoNotch] 모드 복원 실패: CGError \(result.rawValue)")
            }
        }
        originalModes.removeAll()
    }

    // MARK: - Mode Finding

    /// 노치 아래에 맞는 최적의 디스플레이 모드를 찾습니다.
    ///
    /// 전략:
    /// 1. 현재 해상도와 같은 너비 + 높이가 (현재 높이 - 노치 높이)인 모드 → 정확히 일치
    /// 2. 정확히 일치하지 않으면 같은 너비, 더 낮은 높이 중 가장 가까운 모드
    /// 3. 같은 너비도 없으면, 유사한 너비의 가장 가까운 작은 모드
    private func findBelowNotchMode(
        displayID: CGDirectDisplayID,
        screen: NSScreen,
        currentMode: CGDisplayMode
    ) -> CGDisplayMode? {
        let notchHeight = screen.safeAreaInsets.top
        guard notchHeight > 0 else { return nil }

        let options = [kCGDisplayShowDuplicateLowResolutionModes: true] as CFDictionary
        guard let allModes = CGDisplayCopyAllDisplayModes(displayID, options) as? [CGDisplayMode] else {
            return nil
        }

        let currentWidth = currentMode.width
        let currentHeight = currentMode.height
        let targetHeight = currentHeight - Int(notchHeight)

        // 사용 가능한 모드만 필터링 (데스크탑 GUI 가능 + 현재보다 작은 높이)
        let usableModes = allModes.filter {
            $0.isUsableForDesktopGUI() &&
            $0.height < currentHeight &&
            $0 !== currentMode
        }

        // 전략 1: 같은 너비, 정확한 높이 일치
        if let exactMatch = usableModes.first(where: {
            $0.width == currentWidth && $0.height == targetHeight
        }) {
            return exactMatch
        }

        // 전략 2: 같은 너비, 가장 가까운 높이 (targetHeight 이하)
        let sameWidthModes = usableModes
            .filter { $0.width == currentWidth && $0.height <= targetHeight }
            .sorted { $0.height > $1.height } // 높이 내림차순 (가장 큰 것부터)

        if let closest = sameWidthModes.first {
            return closest
        }

        // 전략 3: 같은 너비, targetHeight보다 크지만 현재보다는 작은 모드
        let sameWidthLarger = usableModes
            .filter { $0.width == currentWidth && $0.height > targetHeight }
            .sorted { $0.height < $1.height } // 높이 오름차순 (가장 작은 것부터)

        if let closest = sameWidthLarger.first {
            return closest
        }

        // 전략 4: 비슷한 너비 (±100), 가장 큰 해상도
        let similarWidthModes = usableModes
            .filter { abs($0.width - currentWidth) <= 100 && $0.height <= targetHeight }
            .sorted { ($0.width * $0.height) > ($1.width * $1.height) }

        return similarWidthModes.first
    }

    // MARK: - Helpers

    private func displayID(for screen: NSScreen) -> CGDirectDisplayID? {
        return screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
    }

    /// 디버깅용: 사용 가능한 모든 모드 출력
    private func printAvailableModes(displayID: CGDirectDisplayID) {
        let options = [kCGDisplayShowDuplicateLowResolutionModes: true] as CFDictionary
        guard let allModes = CGDisplayCopyAllDisplayModes(displayID, options) as? [CGDisplayMode] else { return }

        print("[NoNotch] 사용 가능한 디스플레이 모드:")
        let usableModes = allModes
            .filter { $0.isUsableForDesktopGUI() }
            .sorted { ($0.width * $0.height) > ($1.width * $1.height) }

        for mode in usableModes {
            print("  \(mode.width)×\(mode.height) (\(mode.pixelWidth)×\(mode.pixelHeight)px, \(mode.refreshRate)Hz)")
        }
    }

    // MARK: - Screen Change Observer

    private func setupScreenChangeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    @objc private func screenDidChange() {
        // 자기 자신이 모드를 변경하는 중에는 무시 (무한 루프 방지)
        guard !isChangingMode else { return }

        if isEnabled {
            // 화면 구성이 바뀌면 다시 적용
            applyBelowNotchModes()
        }
    }

    // MARK: - State Persistence

    private let stateKey = "NoNotch_isEnabled"

    private func saveState() {
        UserDefaults.standard.set(isEnabled, forKey: stateKey)
    }
}
