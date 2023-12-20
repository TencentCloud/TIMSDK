//
//  PopUpViewController.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/12.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUICore

protocol PopUpViewResponder: AnyObject {
    func updateAlertTransitionPosition(position: AlertTransitionAnimator.AlertTransitionPosition)
}

class PopUpView: UIView {
    let viewModel: PopUpViewModel
    var rootView: UIView?
    weak var responder: PopUpViewResponder?
    private let arrowViewHeight: CGFloat = 35.0
    private var currentLandscape: Bool = isLandscape
    
    private let panelControl : UIControl = {
        let control = UIControl()
        control.backgroundColor = .clear
        return control
    }()
    
    private let dropArrowView : UIView = {
        let view = UIView()
        return view
    }()
    
    private let dropArrowImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "room_drop_arrow",in:tuiRoomKitBundle(),compatibleWith: nil)
        return view
    }()
    
    private let rightArrowView : UIView = {
        let view = UIView()
        return view
    }()
    
    private let rightArrowImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "room_right_arrow",in:tuiRoomKitBundle(),compatibleWith: nil)
        return view
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        return view
    }()
    
    init(viewModel: PopUpViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        addSubview(panelControl)
        addSubview(backgroundView)
        backgroundView.addSubview(dropArrowView)
        backgroundView.addSubview(rightArrowView)
        dropArrowView.addSubview(dropArrowImageView)
        rightArrowView.addSubview(rightArrowImageView)
        setupViewState()
        guard let rootView = rootView else { return }
        backgroundView.addSubview(rootView)
        backgroundView.layer.cornerRadius = 15
    }
    
    func activateConstraints() {
        panelControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupViewOrientation(isLandscape: isLandscape)
        dropArrowView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(arrowViewHeight)
        }
        dropArrowImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(24.scale375())
            make.height.equalTo(3.scale375())
        }
        rightArrowView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(arrowViewHeight)
        }
        rightArrowImageView.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.width.equalTo(3.scale375())
            make.height.equalTo(24.scale375())
        }
    }
    
    func bindInteraction() {
        backgroundView.backgroundColor = viewModel.backgroundColor
        let dropArrowTap = UITapGestureRecognizer(target: self, action: #selector(dropDownPopUpViewAction(sender:)))
        dropArrowView.addGestureRecognizer(dropArrowTap)
        dropArrowView.isUserInteractionEnabled = true
        let rightArrowTap = UITapGestureRecognizer(target: self, action: #selector(dropDownPopUpViewAction(sender:)))
        rightArrowView.addGestureRecognizer(rightArrowTap)
        rightArrowView.isUserInteractionEnabled = true
        panelControl.addTarget(self, action: #selector(panelControlAction), for: .touchUpInside)
    }
    
    func setupViewState() {
        switch viewModel.viewType {
        case .roomInfoViewType:
            let model = RoomInfoViewModel()
            rootView = RoomInfoView(viewModel: model)
        case .mediaSettingViewType:
            let model = MediaSettingViewModel()
            let view = MediaSettingView(viewModel: model)
            rootView = view
        case .userListViewType:
            let model = UserListViewModel()
            rootView = UserListView(viewModel: model)
        case .raiseHandApplicationListViewType:
            let model = RaiseHandApplicationListViewModel()
            viewModel.viewResponder = model
            rootView = RaiseHandApplicationListView(viewModel: model)
        case .transferMasterViewType:
            let model = TransferMasterViewModel()
            viewModel.viewResponder = model
            rootView = TransferMasterView(viewModel: model)
        case .QRCodeViewType:
            let model = QRCodeViewModel(urlString: "https://web.sdk.qcloud.com/component/tuiroom/index.html#/" + "#/room?roomId=" +
                                        EngineManager.createInstance().store.roomInfo.roomId)
            rootView = QRCodeView(viewModel: model)
        case .inviteViewType:
            let model = MemberInviteViewModel()
            rootView = MemberInviteView(viewModel: model)
        default: break
        }
    }
    
    @objc func dropDownPopUpViewAction(sender: UIView) {
        RoomRouter.shared.dismissPopupViewController(viewType: viewModel.viewType, animated: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard currentLandscape != isLandscape else { return }
        setupViewOrientation(isLandscape: isLandscape)
        responder?.updateAlertTransitionPosition(position: isLandscape ? .right : .bottom)
        currentLandscape = isLandscape
    }
    
    func setupViewOrientation(isLandscape: Bool) {
        let width = min(kScreenHeight, kScreenWidth)
        let height = max(kScreenHeight, kScreenWidth)
        if isLandscape { //横屏
            backgroundView.snp.remakeConstraints { make in
                make.width.equalTo(width + arrowViewHeight)
                make.top.equalToSuperview()
                make.height.equalToSuperview()
                make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
            }
        } else { //竖屏
            let currentHeight = min(viewModel.height + arrowViewHeight, height - arrowViewHeight)
            backgroundView.snp.remakeConstraints { make in
                make.width.bottom.equalToSuperview()
                make.height.equalTo(currentHeight)
            }
        }
        rootView?.snp.remakeConstraints { make in
            if isLandscape {
                make.leading.equalToSuperview().offset(arrowViewHeight)
                make.trailing.top.bottom.equalToSuperview()
            } else {
                let currentHeight = min(viewModel.height, height - 2*arrowViewHeight)
                make.height.equalTo(currentHeight)
                make.trailing.leading.bottom.equalToSuperview()
            }
        }
        rightArrowView.isHidden = !isLandscape
        dropArrowView.isHidden = isLandscape
    }
    
    
    @objc func panelControlAction() {
        viewModel.panelControlAction()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
