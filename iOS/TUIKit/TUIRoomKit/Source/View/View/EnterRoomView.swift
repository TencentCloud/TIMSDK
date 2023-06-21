//
//  EnterRoomView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

import UIKit

class EnterRoomView: UIView {
    let loading = UIActivityIndicatorView(style: .gray)
    let viewModel: EnterRoomViewModel
    private var inputViewArray: [ListCellItemView] = []
    private var switchViewArray: [ListCellItemView] = []
    
    let inputStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 0
        return view
    }()
    
    let switchStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 0
        return view
    }()
    
    let enterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIColor(0x0062E3).trans2Image(), for: .normal)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        button.setTitleColor(.white, for: .normal)
        button.setTitle(.enterRoomText, for: .normal)
        return button
    }()
    
    private var isViewReady: Bool = false
    
    init(viewModel: EnterRoomViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        inputStackView.roundedRect(rect: inputStackView.bounds,
                                   byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
                                   cornerRadii: CGSize(width: 12, height: 12))
        switchStackView.roundedRect(rect: switchStackView.bounds,
                                    byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: 12, height: 12))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ResignFirstResponder, param: [:])
    }
    
    func constructViewHierarchy() {
        backgroundColor = UIColor(0x17181F)
        addSubview(inputStackView)
        addSubview(switchStackView)
        addSubview(enterButton)
        addSubview(loading)
        for item in viewModel.inputViewItems {
            let view = ListCellItemView(itemData: item)
            inputStackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.height.equalTo(52.scale375())
                make.width.equalToSuperview()
            }
            view.backgroundColor = item.backgroundColor ?? UIColor(0x2A2D38)
        }
        
        for item in viewModel.switchViewItems {
            let view = ListCellItemView(itemData: item)
            switchStackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.height.equalTo(52.scale375())
                make.width.equalToSuperview()
            }
            view.backgroundColor = item.backgroundColor ?? UIColor(0x2A2D38)
        }
    }
    
    func activateConstraints() {
        inputStackView.snp.makeConstraints { make in
            make.top.equalTo(snp.topMargin).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        switchStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(inputStackView.snp.bottom).offset(12)
        }
        
        enterButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40 - kDeviceSafeBottomHeight)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(50)
        }
        
        loading.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    func bindInteraction() {
        enterButton.addTarget(self, action: #selector(enterButtonClick(sender:)), for: .touchUpInside)
    }
    
    @objc func backButtonClick(sender: UIButton) {
        viewModel.backButtonClick(sender: sender)
    }
    
    @objc func enterButtonClick(sender: UIButton) {
        viewModel.enterButtonClick(sender: sender, view: self)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var enterRoomText: String {
        localized("TUIRoom.join.room")
    }
}
