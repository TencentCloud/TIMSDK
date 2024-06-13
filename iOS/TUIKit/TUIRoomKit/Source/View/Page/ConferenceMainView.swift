//
//  ConferenceMainView.swift
//  TUIRoomKit
//
//  Created by aby on 2022/12/27.
//  Copyright © 2022 Tencent. All rights reserved.
//  The main conference interface is responsible for arranging and managing the top bar, bottom bar, video interface, etc.
//

import Foundation

protocol ConferenceMainViewFactory {
    func makeBottomView() -> BottomView
    func makeTopView() -> TopView
    func makeVideoSeatView() -> UIView
    func makeRaiseHandNoticeView() -> UIView
    func makeLocalAudioView() -> UIView
    func makeWaterMarkLayer() -> WaterMarkLayer
    func makeFloatChatButton() -> FloatChatButton
    func makeFloatChatDisplayView() -> FloatChatDisplayView
    func makeRaiseHandApplicationNotificationView() -> RaiseHandApplicationNotificationView
}

struct ConferenceMainViewLayout { //Layout changes when switching between horizontal and vertical screens
    let bottomViewLandscapeSpace: Float = 0
    let bottomViewPortraitSpace: Float = 34.0
    let topViewLandscapeHight: Float = 75.0
    let topViewPortraitHight: Float = 105.0
    let videoSeatViewPortraitSpace: Float = 73.0
    let videoSeatViewLandscapeSpace: Float = 82.0
}

class ConferenceMainView: UIView {
    let viewModel: ConferenceMainViewModel
    let viewFactory: ConferenceMainViewFactory
    let layout: ConferenceMainViewLayout = ConferenceMainViewLayout()
    init(viewModel: ConferenceMainViewModel,
         viewFactory: ConferenceMainViewFactory) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory
        super.init(frame: .zero)
        subscribeUIEvent()
    }
    private var currentLandscape: Bool = isLandscape
    private let firstDelayDisappearanceTime = 6.0
    private let delayDisappearanceTime = 3.0

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var topView: TopView = {
        return viewFactory.makeTopView()
    }()
    
    lazy var videoSeatView: UIView = {
        return viewFactory.makeVideoSeatView()
    }()
    
    lazy var bottomView: BottomView = {
        return viewFactory.makeBottomView()
    }()
    
    lazy var raiseHandNoticeView: UIView = {
        return viewFactory.makeRaiseHandNoticeView()
    }()
    
    lazy var localAudioView: UIView = {
        return viewFactory.makeLocalAudioView()
    }()
    
    lazy var waterMarkLayer: CALayer = {
        return viewFactory.makeWaterMarkLayer()
    }()
    
    lazy var floatChatDisplayView: FloatChatDisplayView = {
        return viewFactory.makeFloatChatDisplayView()
    }()
    
    lazy var floatChatButton: FloatChatButton = {
        return viewFactory.makeFloatChatButton()
    }()
    
    lazy var raiseHandApplicationNotificationView: RaiseHandApplicationNotificationView = {
        let applicationNotificationView = viewFactory.makeRaiseHandApplicationNotificationView()
        return applicationNotificationView
    }()
    
    // MARK: - view layout
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        backgroundColor = UIColor(0x0F1014)
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard currentLandscape != isLandscape else { return }
        setupRootViewOrientation(isLandscape: isLandscape)
        currentLandscape = isLandscape
    }
    
    func constructViewHierarchy() {
        addSubview(videoSeatView)
        if viewModel.isShownWaterMark {
            layer.addSublayer(waterMarkLayer)
        }
        addSubview(topView)
        addSubview(floatChatDisplayView)
        addSubview(floatChatButton)
        addSubview(bottomView)
        addSubview(localAudioView)
        addSubview(raiseHandNoticeView)
        addSubview(raiseHandApplicationNotificationView)
    }
    
    func activateConstraints() {
        setupRootViewOrientation(isLandscape: isLandscape)
        raiseHandNoticeView.snp.makeConstraints { make in
            make.bottom.equalTo(bottomView.snp.top).offset(-15)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(300)
        }
        localAudioView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(40.scale375())
            make.bottom.equalToSuperview().offset(-40.scale375Height())
        }
        floatChatButton.snp.makeConstraints { make in
            make.bottom.equalTo(localAudioView.snp.top).offset(-18)
            make.height.equalTo(30)
            make.leading.equalToSuperview()
            make.width.equalTo(100)
        }
        floatChatDisplayView.snp.makeConstraints { make in
            make.bottom.equalTo(floatChatButton.snp.top).offset(-8)
            make.height.equalTo(128)
            make.leading.equalToSuperview()
            make.width.equalTo(313)
        }
        raiseHandApplicationNotificationView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.width.equalTo(359.scale375())
            make.centerX.equalToSuperview()
            make.height.equalTo(40.scale375Height())
        }
    }
    
    private func bindInteraction() {
        viewModel.viewResponder = self
        viewModel.applyConfigs()
        perform(#selector(hideToolBar),with: nil,afterDelay: firstDelayDisappearanceTime)
    }
    
    func setupRootViewOrientation(isLandscape: Bool) {
        videoSeatView.snp.remakeConstraints { make in
            if isLandscape {
                make.leading.equalTo(layout.videoSeatViewLandscapeSpace)
                make.trailing.equalTo(-layout.videoSeatViewLandscapeSpace)
                make.top.bottom.equalToSuperview()
            } else {
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(layout.videoSeatViewPortraitSpace)
                make.bottom.equalTo(-layout.videoSeatViewPortraitSpace)
            }
        }
        topView.snp.remakeConstraints() { make in
            make.top.equalToSuperview()
            make.leading.equalTo(safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
            if isLandscape {
                make.height.equalTo(layout.topViewLandscapeHight)
            } else {
                make.height.equalTo(layout.topViewPortraitHight)
            }
        }
        bottomView.snp.remakeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
            make.height.equalTo(bottomView.isUnfold ? bottomView.unfoldHeight : bottomView.packUpHeight)
            if isLandscape {
                make.bottom.equalToSuperview().offset(-layout.bottomViewLandscapeSpace)
            } else {
                make.bottom.equalToSuperview().offset(-layout.bottomViewPortraitSpace)
            }
        }
        topView.updateRootViewOrientation(isLandscape: isLandscape)
        setupWaterMarkLayerOrientation(isLandscape: isLandscape)
    }
    
    private func setupWaterMarkLayerOrientation(isLandscape: Bool) {
        guard viewModel.isShownWaterMark else { return }
        let widthSpace = isLandscape ? CGFloat(layout.videoSeatViewLandscapeSpace) : 0
        let heightSpace = isLandscape ? 0 : CGFloat(layout.videoSeatViewPortraitSpace)
        waterMarkLayer.frame = CGRect(x: widthSpace, y: heightSpace, width: kScreenWidth - widthSpace * 2, height: kScreenHeight - heightSpace * 2)
        waterMarkLayer.setNeedsDisplay()
    }
    
    private func subscribeUIEvent() {
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_ShowFloatChatView, responder: self)
    }
    
    private func unsubscribeEvent() {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_ShowFloatChatView, responder: self)
    }
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        unsubscribeEvent()
        debugPrint("deinit \(self)")
    }
}

extension ConferenceMainView: ConferenceMainViewResponder {
    func showExitRoomView() {
        let view = ExitRoomView(viewModel: ExitRoomViewModel())
        view.show(rootView: self)
    }
    
    func showAlert(title: String?, message: String?, sureTitle:String?, declineTitle: String?, sureBlock: (() -> ())?, declineBlock: (() -> ())?) {
        RoomRouter.presentAlert(title: title, message: message, sureTitle: sureTitle, declineTitle: declineTitle, sureBlock: sureBlock, declineBlock: declineBlock)
    }
    
    func makeToast(text: String) {
        RoomRouter.makeToastInCenter(toast: text, duration: 1)
    }
    
    private func showToolBar() {
        topView.alpha = 1
        bottomView.alpha = 1
        topView.isHidden = false
        bottomView.isHidden = false
        viewModel.hideLocalAudioView()
    }
    
    @objc private func hideToolBar() {
        topView.alpha = 0
        bottomView.alpha = 0
        topView.isHidden = true
        bottomView.isHidden = true
        viewModel.showLocalAudioView()
    }
    
    func changeToolBarHiddenState() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideToolBar), object: nil)
        if topView.isHidden {
            showToolBar()
            perform(#selector(hideToolBar),with: nil,afterDelay: delayDisappearanceTime)
        } else if !bottomView.isUnfold {
            hideToolBar()
        }
    }
    
    func setToolBarDelayHidden(isDelay: Bool) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideToolBar), object: nil)
        guard !bottomView.isUnfold, isDelay else { return }
        perform(#selector(hideToolBar),with: nil,afterDelay: delayDisappearanceTime)
    }
}

extension ConferenceMainView: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key {
        case .TUIRoomKitService_ShowFloatChatView:
            guard let shouldShow = info?["shouldShow"] as? Bool else { return }
            floatChatButton.isHidden = !shouldShow
            floatChatDisplayView.isHidden = !shouldShow
        default: break
        }
    }
}
