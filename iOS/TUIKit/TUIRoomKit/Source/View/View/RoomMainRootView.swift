//
//  RoomMainRootView.swift
//  TUIRoomKit
//
//  Created by aby on 2022/12/27.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation

protocol RoomMainViewFactory {
    func makeBottomView() -> UIView
    func makeTopView() -> UIView
    func makeVideoSeatView() -> UIView
    func makeBeautyView() -> UIView?
    func makeRaiseHandNoticeView() -> UIView
}

class RoomMainRootView: UIView {
    let viewModel: RoomMainViewModel
    let viewFactory: RoomMainViewFactory
    init(viewModel: RoomMainViewModel,
         viewFactory: RoomMainViewFactory) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var topView: UIView = {
        return viewFactory.makeTopView()
    }()
    
    lazy var videoSeatView: UIView = {
        return viewFactory.makeVideoSeatView()
    }()
    
    lazy var bottomView: UIView = {
        return viewFactory.makeBottomView()
    }()
    
    lazy var beautyView: UIView? = {
        return viewFactory.makeBeautyView()
    }()
    
    lazy var raiseHandNoticeView: UIView = {
        return viewFactory.makeRaiseHandNoticeView()
    }()
    
    // MARK: - view layout
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        backgroundColor = UIColor(0x1B1E26)
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(videoSeatView)
        addSubview(topView)
        addSubview(bottomView)
        if let beautyView = beautyView {
            addSubview(beautyView)
        }
        addSubview(raiseHandNoticeView)
    }
    
    func activateConstraints() {
        topView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
            make.height.equalTo(53.scale375())
        }
        bottomView.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            make.leading.equalTo(safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
            make.height.equalTo(52.scale375())
        }
        videoSeatView.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(bottomView.snp.top).offset(-5)
        }
        beautyView?.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
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
    }
    
    func updateRootViewOrientation(isLandscape: Bool) {
        if isLandscape { //横屏时，videoSeat扩展到整个页面
            videoSeatView.snp.remakeConstraints { make in
                make.leading.equalTo(safeAreaLayoutGuide.snp.leading)
                make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
                make.top.bottom.equalToSuperview()
            }
        } else {
            videoSeatView.snp.remakeConstraints { make in
                make.leading.equalTo(safeAreaLayoutGuide.snp.leading)
                make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
                make.top.equalTo(topView.snp.bottom)
                make.bottom.equalTo(bottomView.snp.top).offset(-5)
            }
        }
    }
    
    deinit {
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
    
    func showBeautyView() {
        beautyView?.isHidden = false
    }
    
    func makeToast(text: String) {
        RoomRouter.makeToast(toast: text)
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
