//
//  ScreenCaptureMaskView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/7/17.
//  开启屏幕共享的蒙层View
//

import Foundation

enum ScreenCaptureMaskViewFrameType {
    case fullScreen
    case small
}

class ScreenCaptureMaskView: UIView {
    private var dotsTimer: Timer = Timer()
    var viewModel: TUIVideoSeatViewModel?
    let frameType: ScreenCaptureMaskViewFrameType
    
    let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    let sharingScreenView: UIView = {
        let view = UIView()
        return view
    }()
    
    let sharingScreenImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "room_sharingScreen", in: tuiRoomKitBundle(), compatibleWith: nil)
        return imageView
    }()
    
    let sharingScreenLabel: UILabel = {
        let label = UILabel()
        label.text = .sharingScreenText
        label.textColor = UIColor(0xB2BBD1)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let stopScreenButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(.shareOffText, for: .normal)
        button.backgroundColor = UIColor(0xCC3D47)
        button.layer.cornerRadius = 6.scale375()
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 12)
        return button
    }()
    
    init(frameType: ScreenCaptureMaskViewFrameType) {
        self.frameType = frameType
        super.init(frame: .zero)
        updateLabelText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    private func constructViewHierarchy() {
        addSubview(contentView)
        contentView.addSubview(sharingScreenView)
        contentView.addSubview(stopScreenButton)
        sharingScreenView.addSubview(sharingScreenImageView)
        sharingScreenView.addSubview(sharingScreenLabel)
    }
    
    private func activateConstraints() {
        contentView.snp.makeConstraints{ make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(128.scale375())
            make.height.equalTo(132.scale375())
        }
        sharingScreenView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(74.scale375())
        }
        stopScreenButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(102.scale375())
            make.height.equalTo(34.scale375())
        }
        sharingScreenImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(48.scale375())
            make.width.equalTo(48.scale375())
        }
        sharingScreenLabel.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(22.scale375())
        }
    }
    
    private func bindInteraction() {
        stopScreenButton.addTarget(self, action: #selector(stopScreenCaptureAction(sender:)), for: .touchUpInside)
        addGesture()
    }
    
    private func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickMask))
        addGestureRecognizer(tap)
    }
    
    @objc func stopScreenCaptureAction(sender: UIButton) {
        RoomRouter.presentAlert(title: .toastTitleText, message: .toastMessageText, sureTitle: .toastStopText, declineTitle: .toastCancelText, sureBlock: { [weak self] in
            guard let self = self else { return }
            self.viewModel?.stopScreenCapture()
        }, declineBlock: nil)
    }
    
    @objc func clickMask() {
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ChangeToolBarHiddenState, param: [:])
        guard RoomRouter.shared.hasChatWindow() else { return }
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_HiddenChatWindow, param: [:])
    }
    
    func updateLabelText() {
        var dots = ""
        dotsTimer = Timer(timeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if dots.count == 3 {
                dots.removeAll()
            }
            dots.append(".")
            self.sharingScreenLabel.text? = .sharingScreenText + dots
        }
        RunLoop.current.add(dotsTimer, forMode: .default)
    }
    
    deinit {
        dotsTimer.invalidate()
        debugPrint("deinit:\(self)")
    }
}

private extension String {
    static var sharingScreenText: String {
        localized("TUIRoom.sharing.screen")
    }
    static var shareOffText: String {
        localized("TUIRoom.share.off")
    }
    static var toastTitleText: String {
        localized("TUIRoom.toast.shareScreen.title")
    }
    static var toastMessageText: String {
        localized("TUIRoom.toast.shareScreen.message")
    }
    static var toastCancelText: String {
        localized("TUIRoom.cancel")
    }
    static var toastStopText: String {
        localized("TUIRoom.toast.shareScreen.stop")
    }
}
