//
//  BottomItemView.swift
//  Alamofire
//
//  Created by aby on 2022/12/23.
//  Copyright © 2023 Tencent. All rights reserved.
//

import UIKit

class BottomItemView: UIView {
    
    var itemData: ButtonItemData
    
    var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    
    let button: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10.0)
        label.textColor = UIColor(0xD1D9EC)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    let noticeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0xED414D)
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor(0x2A2D38).cgColor
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    let noticeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xFFFFFF)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.backgroundColor = .clear
        return label
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
        self.layer.cornerRadius = 10
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(button)
        button.addSubview(imageView)
        button.addSubview(label)
        button.addSubview(noticeView)
        noticeView.addSubview(noticeLabel)
    }
    
    func activateConstraints() {
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            if itemData.normalTitle.isEmpty, itemData.selectedTitle.isEmpty {
                make.centerY.equalToSuperview()
            } else {
                make.top.equalToSuperview().offset(7)
            }
            make.width.height.equalTo(24)
            make.centerX.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            if itemData.normalIcon.isEmpty, itemData.selectedIcon.isEmpty {
                make.centerY.equalToSuperview()
            } else {
                make.top.equalTo(imageView.snp.bottom).offset(2)
            }
            make.width.equalToSuperview()
            make.height.equalTo(14)
        }
        noticeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(button).offset(-7)
            make.top.equalToSuperview().offset(4)
            make.width.height.greaterThanOrEqualTo(16)
        }
        noticeView.snp.makeConstraints { make in
            make.leading.top.equalTo(noticeLabel).offset(-4)
            make.trailing.bottom.equalTo(noticeLabel).offset(4)
            make.width.lessThanOrEqualTo(button)
        }
    }
    
    func bindInteraction() {
        setupViewState(item: itemData)
        button.addTarget(self, action: #selector(clickMenuButton(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: ButtonItemData) {
        itemData = item
        button.isSelected = item.isSelect
        button.isEnabled = item.isEnabled
        imageView.image = item.isSelect ? itemData.selectedImage : itemData.normalImage
        label.text = item.isSelect ? itemData.selectedTitle : itemData.normalTitle
        button.alpha = item.alpha
        noticeView.isHidden = !item.hasNotice
        noticeLabel.text = item.noticeText
    }
    
    @objc
    func clickMenuButton(sender: UIView) {
        itemData.action?(sender)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
