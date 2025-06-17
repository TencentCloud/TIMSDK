//
//  IncomingBannerViewController.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/25.
//

import RTCCommon

class IncomingBannerViewController: UIViewController {
    private var isViewReady: Bool = false

    private let userHeadImageView: UIImageView = {
        let userHeadImageView = UIImageView(frame: CGRect.zero)
        userHeadImageView.layer.masksToBounds = true
        userHeadImageView.layer.cornerRadius = 7.0
        if let remoteUser = CallManager.shared.userState.remoteUserList.value.first {
            userHeadImageView.sd_setImage(with: URL(string: remoteUser.avatar.value), placeholderImage: CallKitBundle.getBundleImage(name: "default_user_icon"))
        }
        return userHeadImageView
    }()
    private let userNameLabel: UILabel = {
        let userNameLabel = UILabel(frame: CGRect.zero)
        userNameLabel.textColor = Color_OweWhite
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        userNameLabel.backgroundColor = UIColor.clear
        userNameLabel.textAlignment = .center
        if let remoteUser = CallManager.shared.userState.remoteUserList.value.first {
            userNameLabel.text = UserManager.getUserDisplayName(user: remoteUser)
        }
        return userNameLabel
    }()
    private lazy var callStatusTipView: UILabel = {
        let callStatusTipLabel = UILabel(frame: CGRect.zero)
        callStatusTipLabel.textColor = UIColor(hex: "#C5CCDB")
        callStatusTipLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        callStatusTipLabel.textAlignment = .left
        callStatusTipLabel.text = self.getCallStatusTipText()
        return callStatusTipLabel
    }()
    private let rejectBtn: UIButton = {
        let btn = UIButton(type: .system)
        if let image = CallKitBundle.getBundleImage(name: "icon_hangup") {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(rejectTouchEvent(sender: )), for: .touchUpInside)
        return btn
    }()
    private let acceptBtn: UIButton = {
        let btn = UIButton(type: .system)
        let imageStr = CallManager.shared.callState.mediaType.value == .video ? "icon_video_dialing" : "icon_dialing"
        if let image = CallKitBundle.getBundleImage(name: imageStr) {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(acceptTouchEvent(sender: )), for: .touchUpInside)
        return btn
    }()
    
    // MARK: init
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super .init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        view.layer.cornerRadius = 10.0
        view.backgroundColor = UIColor(hex: "#22262E")
        let tap = UITapGestureRecognizer(target: self, action: #selector(showCallView(sender:)))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: UI Specification Processing
    override func viewDidLoad() {
        super.viewDidLoad()
        if isViewReady { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
    }
    
    private func constructViewHierarchy() {
        view.addSubview(userHeadImageView)
        view.addSubview(userNameLabel)
        view.addSubview(callStatusTipView)
        view.addSubview(rejectBtn)
        view.addSubview(acceptBtn)
    }
    
    private func activateConstraints() {
        userHeadImageView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = userHeadImageView.superview, let parentView = self.view {
            NSLayoutConstraint.activate([
                userHeadImageView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 16.scale375Width()),
                userHeadImageView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
                userHeadImageView.widthAnchor.constraint(equalToConstant: 60.scale375Width()),
                userHeadImageView.heightAnchor.constraint(equalToConstant: 60.scale375Width())
            ])
        }
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        if let superview = userNameLabel.superview {
            NSLayoutConstraint.activate([
                userNameLabel.topAnchor.constraint(equalTo: userHeadImageView.topAnchor, constant: 10.scale375Width()),
                userNameLabel.leadingAnchor.constraint(equalTo: userHeadImageView.trailingAnchor, constant: 12.scale375Width())
            ])
        }
        
        callStatusTipView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = callStatusTipView.superview {
            NSLayoutConstraint.activate([
                callStatusTipView.leadingAnchor.constraint(equalTo: userHeadImageView.trailingAnchor, constant: 12.scale375Width()),
                callStatusTipView.bottomAnchor.constraint(equalTo: userHeadImageView.bottomAnchor, constant: -10.scale375Width())
            ])
        }
        
        rejectBtn.translatesAutoresizingMaskIntoConstraints = false
        if let superview = rejectBtn.superview, let parentView = self.view {
            NSLayoutConstraint.activate([
                rejectBtn.trailingAnchor.constraint(equalTo: acceptBtn.leadingAnchor, constant: -22.scale375Width()),
                rejectBtn.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
                rejectBtn.widthAnchor.constraint(equalToConstant: 36.scale375Width()),
                rejectBtn.heightAnchor.constraint(equalToConstant: 36.scale375Width())
            ])
        }
        
        acceptBtn.translatesAutoresizingMaskIntoConstraints = false
        if let superview = acceptBtn.superview, let parentView = self.view {
            NSLayoutConstraint.activate([
                acceptBtn.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -16.scale375Width()),
                acceptBtn.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
                acceptBtn.widthAnchor.constraint(equalToConstant: 36.scale375Width()),
                acceptBtn.heightAnchor.constraint(equalToConstant: 36.scale375Width())
            ])
        }
    }
    
    // MARK: Event Action
    @objc func showCallView(sender: UIButton) {
        view.removeFromSuperview()
        WindowManager.shared.showCallingWindow()
    }
    
    @objc func rejectTouchEvent(sender: UIButton) {
        view.removeFromSuperview()
        CallManager.shared.reject() { } fail: { code, message in }
        WindowManager.shared.closeWindow()
    }
    
    @objc func acceptTouchEvent(sender: UIButton) {
        view.removeFromSuperview()
        CallManager.shared.accept() { } fail: { code, message in }
        WindowManager.shared.showCallingWindow()
    }
    
    // MARK: other private
    private func getCallStatusTipText() -> String {
        if CallManager.shared.viewState.callingViewType.value == .multi {
            return TUICallKitLocalize(key: "TUICallKit.Group.inviteToGroupCall") ?? ""
        }
        
        var tipLabelText = String()
        switch CallManager.shared.callState.mediaType.value {
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
