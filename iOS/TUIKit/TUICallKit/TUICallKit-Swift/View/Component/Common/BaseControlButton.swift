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
        let titleLable = UILabel(frame: CGRectZero)
        titleLable.font = UIFont.systemFont(ofSize: 12.0)
        titleLable.textAlignment = .center
        return titleLable
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
    
    //MARK: UI Specification Processing
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
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.centerX.bottom.equalTo(self)
        }
        
        button.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.size.equalTo(imageSize)
            make.bottom.equalTo(titleLabel.snp.top).offset(-10)
        }
    }
    
    func bindInteraction() {
        button.addTarget(self, action: #selector(buttonActionEvent(sender: )), for: .touchUpInside)
    }

    // MARK: Update Info
    func updateImage(image: UIImage) {
        button.setBackgroundImage(image, for: .normal)
    }
    
    func updateTitleColor(titleColor: UIColor) {
        titleLabel.textColor = titleColor
    }
    
    //MARK: Event Action
    @objc func buttonActionEvent(sender: UIButton) {
        guard let buttonActionBlock = buttonActionBlock else { return }
        buttonActionBlock(sender)
    }
}


