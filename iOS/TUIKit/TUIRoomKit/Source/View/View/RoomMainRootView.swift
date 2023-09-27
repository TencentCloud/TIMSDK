//
//  RoomMainRootView.swift
//  TUIRoomKit
//
//  Created by aby on 2022/12/27.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation

protocol RoomMainViewFactory {
    func makeBottomView() -> BottomView
    func makeTopView() -> TopView
    func makeVideoSeatView() -> UIView
    func makeRaiseHandNoticeView() -> UIView
}

struct RoomMainRootViewLayout { //横竖屏切换时的布局变化
    let bottomViewLandscapeSpace: Float = 0
    let bottomViewPortraitSpace: Float = 15.0
    let topViewLandscapeHight: Float = 36.0
    let topViewPortraitHight: Float = 53.0
    let videoSeatViewPortraitSpace: Float = 73.0
    let videoSeatViewLandscapeSpace: Float = 82.0
}

class RoomMainRootView: UIView {
    let viewModel: RoomMainViewModel
    let viewFactory: RoomMainViewFactory
    let layout: RoomMainRootViewLayout = RoomMainRootViewLayout()
    init(viewModel: RoomMainViewModel,
         viewFactory: RoomMainViewFactory) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory
        super.init(frame: .zero)
    }
    
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
    
    func constructViewHierarchy() {
        addSubview(videoSeatView)
        addSubview(topView)
        addSubview(bottomView)
        addSubview(raiseHandNoticeView)
    }
    
    func activateConstraints() {
        topView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
            make.height.equalTo(layout.topViewPortraitHight)
        }
        bottomView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-layout.bottomViewPortraitSpace)
            make.leading.equalTo(safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
            make.height.equalTo(60.scale375())
        }
        videoSeatView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(layout.videoSeatViewPortraitSpace)
            make.bottom.equalTo(-layout.videoSeatViewPortraitSpace)
        }
        raiseHandNoticeView.snp.makeConstraints { make in
            make.bottom.equalTo(bottomView.snp.top).offset(-15)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(300)
        }
    }
    
    private func bindInteraction() {
        viewModel.viewResponder = self
        viewModel.applyConfigs()
        perform(#selector(hideToolBarWithAnimation),with: nil,afterDelay: 3.0)
    }
    
    func updateRootViewOrientation(isLandscape: Bool) {
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
        topView.snp.updateConstraints() { make in
            if isLandscape {
                make.height.equalTo(layout.topViewLandscapeHight)
            } else {
                make.height.equalTo(layout.topViewPortraitHight)
            }
        }
        bottomView.snp.updateConstraints { make in
            if isLandscape {
                make.bottom.equalToSuperview().offset(layout.bottomViewLandscapeSpace)
            } else {
                make.bottom.equalToSuperview().offset(-layout.bottomViewPortraitSpace)
            }
        }
        topView.updateRootViewOrientation(isLandscape: isLandscape)
    }
    
    @objc func hideToolBarWithAnimation() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else {return}
            self.topView.alpha = 0
            self.bottomView.alpha = 0
        } completion: { [weak self] _ in
            guard let self = self else {return}
            self.topView.isHidden = true
            self.bottomView.isHidden = true
        }
    }
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        debugPrint("deinit \(self)")
    }
}

extension RoomMainRootView: RoomMainViewResponder {
    func showSelfBecomeRoomOwnerAlert() {
        let alertVC = UIAlertController(title: .haveBecomeMasterText,
                                        message: nil,
                                        preferredStyle: .alert)
        let sureAction = UIAlertAction(title: .alertOkText, style: .cancel) { _ in
        }
        alertVC.addAction(sureAction)
        RoomRouter.shared.presentAlert(alertVC)
    }
    
    func makeToast(text: String) {
        RoomRouter.makeToastInCenter(toast: text, duration: 1)
    }
    
    private func showToolBar() {
        topView.alpha = 1
        bottomView.alpha = 1
        topView.isHidden = false
        bottomView.isHidden = false
    }
    
    private func hideToolBar() {
        topView.alpha = 0
        bottomView.alpha = 0
        topView.isHidden = true
        bottomView.isHidden = true
    }
    
    func changeToolBarHiddenState() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideToolBarWithAnimation), object: nil)
        if topView.isHidden {
            showToolBar()
            perform(#selector(hideToolBarWithAnimation),with: nil,afterDelay: 3.0)
        } else {
            hideToolBar()
        }
    }
    
    func setToolBarDelayHidden(isDelay: Bool) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideToolBarWithAnimation), object: nil)
        guard isDelay else { return }
        perform(#selector(hideToolBarWithAnimation),with: nil,afterDelay: 3.0)
    }
}

private extension String {
    static var alertOkText: String {
        localized("TUIRoom.ok")
    }
    static var haveBecomeMasterText: String {
        localized("TUIRoom.have.become.master")
    }
}
