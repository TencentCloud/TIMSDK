//
//  FeatureButton.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/8.
//

import Foundation
import UIKit

typealias FeatureButtonActionCallback = (_ sender: UIButton) -> Void

class FeatureButton: UIView {
    private var buttonActionCallback: FeatureButtonActionCallback?
    private var imageSize: CGSize
    
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
        
    private init(frame: CGRect, imageSize: CGSize) {
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
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    private func constructViewHierarchy() {
        addSubview(button)
        addSubview(titleLabel)
    }
    
    private func activateConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        if let superview = button.superview {
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: superview.topAnchor),
                button.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                button.widthAnchor.constraint(equalToConstant: imageSize.width),
                button.heightAnchor.constraint(equalToConstant: imageSize.height)
            ])
        }
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        if let superview = titleLabel.superview {
            NSLayoutConstraint.activate([
                titleLabel.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                titleLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 10),
                titleLabel.widthAnchor.constraint(equalToConstant: 100.scale375Width())
            ])
        }
    }
    
    private func bindInteraction() {
        button.addTarget(self, action: #selector(buttonActionEvent(sender: )), for: .touchUpInside)
    }
    
    // MARK: Event Action
    @objc func buttonActionEvent(sender: UIButton) {
        guard let buttonActionCallback = buttonActionCallback else { return }
        buttonActionCallback(sender)
    }
    
    // MARK: Public Interface
    static func create(title: String?, titleColor: UIColor?, image: UIImage?, imageSize: CGSize, buttonAction: @escaping FeatureButtonActionCallback) -> FeatureButton {
        let controlButton = FeatureButton(frame: CGRect.zero, imageSize: imageSize)
        controlButton.titleLabel.text = title
        controlButton.titleLabel.textColor = titleColor
        controlButton.button.setBackgroundImage(image, for: .normal)
        controlButton.buttonActionCallback = buttonAction
        return controlButton
    }

    func updateImage(image: UIImage) {
        button.setBackgroundImage(image, for: .normal)
    }
    
    func updateTitle(title: String) {
        titleLabel.text = title
    }
    
    func updateTitleColor(titleColor: UIColor) {
        titleLabel.textColor = titleColor
    }
}
