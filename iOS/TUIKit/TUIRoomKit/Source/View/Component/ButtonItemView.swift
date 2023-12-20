//
//  ButtonItemView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class ButtonItemView: UIView {    
    var itemData: ButtonItemData
    
    lazy var controlButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = itemData.backgroundColor
        if let cornerRadius = itemData.cornerRadius {
            button.layer.cornerRadius = cornerRadius
        }
        return button
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = isRTL ? .right : .left
        label.font = itemData.titleFont ?? UIFont(name: "PingFangSC-Regular", size: 14)
        label.textColor = itemData.titleColor ?? UIColor(0xD5E0F2)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x4F586B,alpha: 0.1)
        view.isHidden = itemData.hasLineView ? false : true
        return view
    }()
    // MARK: - initialized function
    init(itemData: ButtonItemData) {
        self.itemData = itemData
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - view layout
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(lineView)
        addSubview(controlButton)
        controlButton.addSubview(imageView)
        controlButton.addSubview(label)
    }
    
    func activateConstraints() {
        controlButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            if let size = itemData.imageSize {
                make.size.equalTo(size)
            } else {
                make.width.height.equalTo(20)
            }
            if itemData.orientation == .left {
                make.leading.equalToSuperview()
            } else {
                make.trailing.equalToSuperview()
            }
            make.centerY.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            if itemData.orientation == .left {
                make.leading.equalTo(imageView.snp.trailing).offset(10)
            } else {
                make.trailing.equalTo(imageView.snp.leading).offset(-10)
            }
        }
        lineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1.scale375())
        }
    }
    
    func bindInteraction() {
        setupViewState(item: itemData)
        controlButton.addTarget(self, action: #selector(clickMenuButton(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: ButtonItemData) {
        itemData = item
        controlButton.isSelected = item.isSelect
        controlButton.isEnabled = item.isEnabled
        imageView.image = item.isSelect ? itemData.selectedImage : itemData.normalImage
        label.text = item.isSelect ? itemData.selectedTitle : itemData.normalTitle
    }
    
    @objc func clickMenuButton(sender: UIButton) {
        itemData.action?(sender)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
