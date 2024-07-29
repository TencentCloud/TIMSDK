import UIKit

extension UIWindow {
    public func t_makeKeyAndVisible() {
        if #available(iOS 13.0, *) {
            for windowScene in UIApplication.shared.connectedScenes {
                if windowScene.activationState == UIScene.ActivationState.foregroundActive ||
                    windowScene.activationState == UIScene.ActivationState.background {
                    self.windowScene = windowScene as? UIWindowScene
                    break
                }
            }
        }
        self.makeKeyAndVisible()
    }
    
    static func getKeyWindow() -> UIWindow? {
        var keyWindow: UIWindow?
        if #available(iOS 13, *) {
            keyWindow = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })
        } else {
            keyWindow = UIApplication.shared.keyWindow
        }
        return keyWindow
    }
    
    static func getTopFullscreenWindow() -> UIWindow? {
        let topWindow = UIApplication.shared.windows
            .filter { !$0.isHidden && $0.bounds.equalTo(UIScreen.main.bounds) }
            .max(by: { $0.windowLevel.rawValue < $1.windowLevel.rawValue })
        
        return topWindow
    }
    
}
