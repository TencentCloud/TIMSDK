//
//  IncomingFloatView.swift
//  TUICallKit-Swift
//
//  Created by noah on 2024/3/15.
//

import UIKit
import SnapKit

class IncomingFloatView: UIView {
    
    let remoteUserListObserver = Observer()
    let mediaTypeObserver = Observer()
    
    let userHeadImageView: UIImageView = {
        let userHeadImageView = UIImageView(frame: CGRect.zero)
        userHeadImageView.layer.masksToBounds = true
        userHeadImageView.layer.cornerRadius = 7.0
        if let image = TUICallKitCommon.getBundleImage(name: "default_user_icon") {
            userHeadImageView.image = image
        }
        return userHeadImageView
    }()
    
    let userNameLabel: UILabel = {
        let userNameLabel = UILabel(frame: CGRect.zero)
        userNameLabel.textColor = UIColor.t_colorWithHexString(color: "#D5E0F2")
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        userNameLabel.backgroundColor = UIColor.clear
        userNameLabel.textAlignment = .center
        return userNameLabel
    }()
    
    let callStatusTipView: UILabel = {
        let callStatusTipLabel = UILabel(frame: CGRect.zero)
        callStatusTipLabel.textColor = UIColor.t_colorWithHexString(color: "#C5CCDB")
        callStatusTipLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        callStatusTipLabel.textAlignment = .left
        return callStatusTipLabel
    }()
    
    lazy var rejectBtn: UIButton = {
        let btn = UIButton(type: .system)
        if let image = TUICallKitCommon.getBundleImage(name: "icon_hangup") {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(rejectTouchEvent(sender: )), for: .touchUpInside)
        return btn
    }()
    
    lazy var acceptBtn: UIButton = {
        let btn = UIButton(type: .system)
        let imageStr = TUICallState.instance.mediaType.value == .video ? "icon_video_dialing" : "icon_dialing"
        if let image = TUICallKitCommon.getBundleImage(name: imageStr) {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(acceptTouchEvent(sender: )), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        userHeadImageView.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        backgroundColor = UIColor.t_colorWithHexString(color: "#22262E")
        let tap = UITapGestureRecognizer(target: self, action: #selector(showCallView(sender:)))
        self.addGestureRecognizer(tap)
        callStatusTipView.text = getCallStatusTipText()
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
    }
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(userHeadImageView)
        addSubview(userNameLabel)
        addSubview(callStatusTipView)
        addSubview(rejectBtn)
        addSubview(acceptBtn)
    }
    
    func activateConstraints() {
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        userHeadImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16.scaleWidth())
            make.centerY.equalTo(self)
            make.width.height.equalTo(60.scaleWidth())
        }
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(userHeadImageView).offset(10.scaleWidth())
            make.leading.equalTo(userHeadImageView.snp.trailing).offset(12.scaleWidth())
        }
        callStatusTipView.snp.makeConstraints { make in
            make.leading.equalTo(userHeadImageView.snp.trailing).offset(12.scaleWidth())
            make.bottom.equalTo(userHeadImageView).offset(-10.scaleWidth())
        }
        rejectBtn.snp.makeConstraints { make in
            make.trailing.equalTo(acceptBtn.snp.leading).offset(-22.scaleWidth())
            make.centerY.equalTo(self)
            make.width.height.equalTo(36.scaleWidth())
        }
        acceptBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16.scaleWidth())
            make.centerY.equalTo(self)
            make.width.height.equalTo(36.scaleWidth())
        }
    }
    
    // MARK: Event Action
    @objc func showCallView(sender: UIButton) {
        self.removeFromSuperview()
        WindowManager.instance.showCallWindow(false)
    }
    
    @objc func rejectTouchEvent(sender: UIButton) {
        self.removeFromSuperview()
        CallEngineManager.instance.reject()
    }
    
    @objc func acceptTouchEvent(sender: UIButton) {
        self.removeFromSuperview()
        CallEngineManager.instance.accept()
        WindowManager.instance.showCallWindow(false)
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        remoteUserListChanged()
        mediaTypeChanged()
    }
    
    func remoteUserListChanged() {
        TUICallState.instance.remoteUserList.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.setUserImageAndName()
        })
    }
    
    func mediaTypeChanged() {
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.callStatusTipView.text = self.getCallStatusTipText()
        })
    }
    
    func setUserImageAndName() {
        let remoteUser = TUICallState.instance.remoteUserList.value.first ?? User()
        userNameLabel.text = User.getUserDisplayName(user: remoteUser)
        
        if let url = URL(string: remoteUser.avatar.value) {
            userHeadImageView.sd_setImage(with: url)
        }
    }
    
    func getCallStatusTipText() -> String {
        if TUICallState.instance.scene.value == .group {
            return TUICallKitLocalize(key: "TUICallKit.Group.inviteToGroupCall") ?? ""
        }
        
        var tipLabelText = String()
        switch TUICallState.instance.mediaType.value {
        case .audio:
            tipLabelText = TUICallKitLocalize(key: "TUICallKit.inviteToAudioCall") ?? ""
        case .video:
            tipLabelText = TUICallKitLocalize(key: "TUICallKit.inviteToVideoCall") ?? ""
        case .unknown:
            break
        default:
            break
        }
        return tipLabelText
    }
}
