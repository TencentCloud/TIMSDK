//
//  FloatChatMessageView.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/5/10.
//

import SnapKit
import UIKit

class FloatChatMessageView: UIView {
    private let messageHorizonSpacing: CGFloat = 8
    private let messageVerticalSpacing: CGFloat = 5
    init(floatMessage: FloatChatMessage? = nil) {
        self.floatMessage = floatMessage
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 14.0)
        label.numberOfLines = 0
        label.text = " "
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        return label
    }()
    
    var floatMessage: FloatChatMessage? {
        didSet {
            guard let floatMessage = floatMessage else {
                return
            }
            updateMessage(with: floatMessage)
        }
    }
    
    var height: CGFloat {
        return messageLabel.frame.height + 2 * messageVerticalSpacing
    }
    
    func setupUI() {
        backgroundColor = UIColor.tui_color(withHex: "#22262E", alpha: 0.4)
        layer.cornerRadius = 13.0
        constructViewHierarchy()
        activateConstraints()
        updateMessage(with: floatMessage)
    }
    
    private func constructViewHierarchy() {
        addSubview(messageLabel)
    }
    
    private func activateConstraints() {
        messageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(messageHorizonSpacing)
            make.top.equalToSuperview().offset(messageVerticalSpacing)
        }
        self.snp.makeConstraints { make in
            make.width.equalTo(messageLabel).offset(2 * messageHorizonSpacing)
            make.height.equalTo(messageLabel).offset(2 * messageVerticalSpacing)
        }
    }
    
    private func updateMessage(with message: FloatChatMessage?) {
        guard let message = message else {
            messageLabel.attributedText = nil
            return
        }
        messageLabel.attributedText = getAttributedText(from: message)
     }
     
     private func getAttributedText(from message: FloatChatMessage) -> NSMutableAttributedString {
         var userName = message.user.userName.isEmpty ? message.user.userId : message.user.userName
         userName = userName + ": "
         let userNameAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12),
                                                                  .foregroundColor: UIColor.tui_color(withHex: "B2BBD1")]
         let userNameAttributedText = NSMutableAttributedString(string: userName,
                                                                attributes: userNameAttributes)

         let contentAttributedText: NSMutableAttributedString = getFullContentAttributedText(content: message.content)
         userNameAttributedText.append(contentAttributedText)
         return userNameAttributedText
     }
    
    private func getFullContentAttributedText(content: String) -> NSMutableAttributedString {
        return EmotionHelper.shared.obtainImagesAttributedString(byText: content,
                                                                   font: UIFont(name: "PingFangSC-Regular", size: 12) ??
                                                                   UIFont.systemFont(ofSize: 12))
    }
}

