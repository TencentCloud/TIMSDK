//
//  BaseControlButton.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import UIKit
import SnapKit

typealias ButtonActionBlock = (_ sender: UIButton) -> Void

class BaseControlButton: UIView {
    
    var buttonActionBlock: ButtonActionBlock?
    var imageSize: CGSize
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        return titleLabel
    }()
    
    let button: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    static func create(frame: CGRect, title: String, imageSize: CGSize, buttonAction: @escaping ButtonActionBlock) -> BaseControlButton {
        let controlButton = BaseControlButton(frame: frame, imageSize: imageSize)
        controlButton.titleLabel.text = title
        controlButton.buttonActionBlock = buttonAction
        return controlButton
    }
    
    init(frame: CGRect, imageSize: CGSize) {
        self.imageSize = imageSize
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(button)
        addSubview(titleLabel)
    }
    
    func activateConstraints() {
        button.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.centerX.equalTo(self)
            make.size.equalTo(imageSize)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(button.snp.bottom).offset(10)
            make.width.equalTo(100.scaleWidth())
        }
    }
    
    func bindInteraction() {
        button.addTarget(self, action: #selector(buttonActionEvent(sender: )), for: .touchUpInside)
    }
    
    // MARK: Update Info
    func updateImage(image: UIImage) {
        button.setBackgroundImage(image, for: .normal)
    }
    
    func updateTitle(title: String) {
        titleLabel.text = title
    }
    
    func updateTitleColor(titleColor: UIColor) {
        titleLabel.textColor = titleColor
    }
    
    // MARK: Event Action
    @objc func buttonActionEvent(sender: UIButton) {
        guard let buttonActionBlock = buttonActionBlock else { return }
        buttonActionBlock(sender)
    }
}
