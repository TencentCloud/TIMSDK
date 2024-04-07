//
//  RoomMainView.swift
//  TUIRoomKit
//
//  Created by aby on 2022/12/27.
//  Copyright © 2022 Tencent. All rights reserved.
//  会议主界面，负责布置并管理顶部栏、底部栏以及视频界面等
//

import Foundation

protocol RoomMainViewFactory {
    func makeBottomView() -> BottomView
    func makeTopView() -> TopView
    func makeVideoSeatView() -> UIView
    func makeRaiseHandNoticeView() -> UIView
    func makeLocalAudioView() -> UIView
}

struct RoomMainViewLayout { //横竖屏切换时的布局变化
    let bottomViewLandscapeSpace: Float = 0
    let bottomViewPortraitSpace: Float = 34.0
    let topViewLandscapeHight: Float = 75.0
    let topViewPortraitHight: Float = 105.0
    let videoSeatViewPortraitSpace: Float = 73.0
    let videoSeatViewLandscapeSpace: Float = 82.0
}

class RoomMainView: UIView {
    let viewModel: RoomMainViewModel
    let viewFactory: RoomMainViewFactory
    let layout: RoomMainViewLayout = RoomMainViewLayout()
    init(viewModel: RoomMainViewModel,
         viewFactory: RoomMainViewFactory) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory
        super.init(frame: .zero)
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
        addSubview(topView)
        addSubview(bottomView)
        addSubview(localAudioView)
        addSubview(raiseHandNoticeView)
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
    }
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        debugPrint("deinit \(self)")
    }
}

extension RoomMainView: RoomMainViewResponder {
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
