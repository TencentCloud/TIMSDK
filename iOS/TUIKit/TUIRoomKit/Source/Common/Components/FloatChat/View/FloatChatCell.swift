//
//  FloatChatCell.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/5/10.
//

import SnapKit
import UIKit

class FloatChatDefaultCell: UITableViewCell {
    static let identifier = "FloatChatDefaultCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let messageView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 13.0
        view.backgroundColor = UIColor.tui_color(withHex: "#22262E", alpha: 0.4)
        return view
    }()
    
    private let messageLabel: UILabel = {
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
    
    func setupUI() {
        backgroundColor = .clear
        constructViewHierarchy()
        activateConstraints()
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(messageView)
        messageView.addSubview(messageLabel)
    }
    
    private func activateConstraints() {
        messageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.height.equalTo(contentView.snp.height).offset(-8)
            make.leading.equalTo(contentView.snp.leading).offset(8)
            make.width.lessThanOrEqualTo(contentView).offset(-8 * 2)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateMessage(with: nil)
    }
    
    private func updateMessage(with message: FloatChatMessage?) {
        guard let message = message else {
            messageLabel.attributedText = nil
            return
        }
        messageLabel.attributedText = getAttributedText(from: message)
     }
     
     private func getAttributedText(from message: FloatChatMessage) -> NSMutableAttributedString {
         let userName = message.user.userName + ": "
         let userNameAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12)]
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

