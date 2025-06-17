//
//  AISubtitle.swift
//  Pods
//
//  Created by vincepzhang on 2025/4/22.
//

#if canImport(TXLiteAVSDK_TRTC)
import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
import TXLiteAVSDK_Professional
#endif

class AISubtitle: UIView {
    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.isHidden = true
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        label.attributedText = NSAttributedString(string: "", attributes: [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.white
        ])
        return label
    }()
    
    private var messages: [(sender: String, text: String)] = []
    private var hideTimer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        CallManager.shared.getTRTCCloudInstance().addDelegate(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            textLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
    }
    
    private func updateSubtitle(sender: String, text: String) {
        self.messages.append((sender: sender, text: text))
        if self.messages.count > 2 {
            self.messages.removeFirst()
        }
        
        guard let user = getUser(userId: sender) else { return }
        let displayName = UserManager.getUserDisplayName(user: user)
        let formattedText = self.messages.map { " \(displayName): \($0.text)" }.joined(separator: "\n")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            let attributedText = NSAttributedString(string: formattedText, attributes: [
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.white
            ])
            self.textLabel.attributedText = attributedText
            
            self.textLabel.isHidden = false
            self.hideTimer?.invalidate()
            self.hideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                self?.textLabel.isHidden = true
                self?.textLabel.attributedText = NSAttributedString(string: "")
            }
        }
    }
    
    private func getUser(userId: String) -> User? {
        if userId == CallManager.shared.userState.selfUser.id.value {
            return CallManager.shared.userState.selfUser
        }
        
        for user in CallManager.shared.userState.remoteUserList.value {
            if userId == user.id.value {
                return user
            }
        }
        return nil
    }
    
    deinit {
        hideTimer?.invalidate()
    }
}

extension AISubtitle: TRTCCloudDelegate {
    func onRecvCustomCmdMsgUserId(_ userId: String, cmdID: Int, seq: UInt32, message: Data) {
        if let string = String(data: message, encoding: .utf8) {
            if let data = string.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let type = json["type"] as? Int,
               type == 10000,
               let sender = json["sender"] as? String,
               let payload = json["payload"] as? [String: Any],
               let translationText = payload["translation_text"] as? String {
                updateSubtitle(sender: sender, text: translationText)
            }
        }
    }
}
