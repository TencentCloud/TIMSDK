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
        var keyWindow: UIWindow? = UIWindow()
        if #available(iOS 13, *) {
            keyWindow = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })
        } else {
            keyWindow = UIApplication.shared.keyWindow
        }
        return keyWindow
    }
    
    static func getCurrentWindow() -> UIWindow? {
        var currentWindow: UIWindow? {
            if #available(iOS 13.0, *) {
                if let window = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first{
                    return window
                }else if let window = UIApplication.shared.delegate?.window{
                    return window
                }else{
                    return nil
                }
            } else {
                if let window = UIApplication.shared.delegate?.window{
                    return window
                }else{
                    return nil
                }
            }
        }
        
        return currentWindow
    }


}
