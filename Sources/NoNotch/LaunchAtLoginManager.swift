import ServiceManagement

/// 로그인 시 자동 시작 관리
enum LaunchAtLoginManager {

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "NoNotch_launchAtLogin")
    }

    static func toggle() {
        let newState = !isEnabled
        UserDefaults.standard.set(newState, forKey: "NoNotch_launchAtLogin")

        if #available(macOS 13.0, *) {
            do {
                if newState {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("\(L10n.launchAtLoginError): \(error)")
            }
        } else {
            // macOS 12 이하: SMLoginItemSetEnabled 사용
            // 이 경우 별도의 Helper App이 필요하므로 간단히 UserDefaults만 저장
            print(L10n.launchAtLoginNotSupported)
        }
    }
}
