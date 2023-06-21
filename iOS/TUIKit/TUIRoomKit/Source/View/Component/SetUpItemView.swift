//
//  SetUpItemView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class SetUpItemView: UIView {
    let viewModel: SetUpViewModel
    private var viewArray: [ListCellItemView] = []
    let viewType: SetUpViewModel.SetUpItemType
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 0
        view.backgroundColor = UIColor(0x1B1E26)
        return view
    }()
    
    let shareView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    let shareImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "room_share_screen", in: tuiRoomKitBundle(), compatibleWith: nil))
        return imageView
    }()
    
    let shareStartButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(.shareText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 18)
        button.setBackgroundImage(UIColor(0x006EFF).trans2Image(), for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        return button
    }()
    
    init(viewModel: SetUpViewModel, viewType: SetUpViewModel.SetUpItemType) {
        self.viewModel = viewModel
        self.viewType = viewType
        super.init(frame: .zero)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_SomeoneSharing, responder: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        addSubview(stackView)
        addSubview(shareView)
        shareView.addSubview(shareImageView)
        shareView.addSubview(shareStartButton)
        
        var viewItems: [ListCellItemData] = []
        switch viewType {
        case .videoType:
            viewItems = viewModel.videoItems
            stackView.isHidden = false
            shareView.isHidden = true
        case .audioType:
            viewItems = viewModel.audioItems
            stackView.isHidden = false
            shareView.isHidden = true
        case .shareType:
            stackView.isHidden = true
            shareView.isHidden = false
        }
        for item in viewItems {
            let view = ListCellItemView(itemData: item)
            viewArray.append(view)
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.height.equalTo(40.scale375())
                make.width.equalToSuperview()
            }
        }
    }
    
    func activateConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.width.equalToSuperview()
        }
        
        shareView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        shareImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40.scale375())
            make.width.equalTo(84.scale375())
            make.height.equalTo(90.scale375())
        }
        
        shareStartButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(120.scale375())
            make.height.equalTo(40.scale375())
            make.top.equalTo(shareImageView.snp.bottom).offset(20)
        }
    }
    
    func bindInteraction() {
        shareStartButton.addTarget(self, action: #selector(shareStartAction(sender:)), for: .touchUpInside)
        shareStartButton.isEnabled = !viewModel.engineManager.store.isSomeoneSharing
    }
    
    func updateStackView(item: ListCellItemData, index: Int) {
        guard viewArray.count > index else { return }
        viewArray[index].removeFromSuperview()
        let view = ListCellItemView(itemData: item)
        viewArray[index] = view
        stackView.insertArrangedSubview(view, at: index)
        view.snp.makeConstraints { make in
            make.height.equalTo(40.scale375())
            make.width.equalToSuperview()
        }
    }
    
    @objc func shareStartAction(sender: UIButton) {
        viewModel.shareStartAction(sender: sender)
    }
    
    deinit {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_SomeoneSharing, responder: self)
        debugPrint("deinit \(self)")
    }
}

extension SetUpItemView: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        if key == .TUIRoomKitService_SomeoneSharing {
            shareStartButton.isEnabled = viewModel.engineManager.store.isSomeoneSharing
        }
    }
}

private extension String {
    static var shareText: String {
        localized("TUIRoom.share")
    }
}
