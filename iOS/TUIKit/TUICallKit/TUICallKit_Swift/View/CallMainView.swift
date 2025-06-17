//
//  CallMainView.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/21.
//

import RTCCommon

class CallMainView: UIView {
    
    private var isViewReady = false
    private let callStatusObserver = Observer()
    private let isScreenCleanedObserver = Observer()
    private let chatGroupIdObserver = Observer()

    private let videoLayout: UIView = CallVideoLayout(frame: .zero)
    private let functionView = FunctionView(frame: CGRect(x: 0, y: Screen_Height - 220.scale375Height(), width: CGFloat(Int(375.scale375Width())), height: 220.scale375Height()))
    
    private let floatWindowButton: UIButton = {
        let floatButton = UIButton(type: .system)
        if let image = CallKitBundle.getBundleImage(name: "icon_min_window") {
            floatButton.setBackgroundImage(image, for: .normal)
        }
        floatButton.addTarget(self, action: #selector(touchFloatWindowEvent(sender:)), for: .touchUpInside)
        floatButton.isHidden = !CallManager.shared.globalState.enableFloatWindow
        return floatButton
    }()
    private let inviterUserButton: UIButton = {
        let inviteUserButton = UIButton(type: .system)
        if let image = CallKitBundle.getBundleImage(name: "icon_add_user") {
            inviteUserButton.setBackgroundImage(image, for: .normal)
        }
        inviteUserButton.addTarget(self, action: #selector(touchInviterUserEvent(sender:)), for: .touchUpInside)
        inviteUserButton.isHidden = !(CallManager.shared.viewState.callingViewType.value == .multi && !CallManager.shared.callState.chatGroupId.value.isEmpty)
        return inviteUserButton
    }()
    
    private let timerView = CallTimerView(frame: .zero)
    private let hintView = CallHintView(frame: .zero)
    
    //MARK: init,deinit
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "#242424")
        registerObserver()
    }
    
    deinit {
        unregisterObserver()
    }
    
    // MARK: UI Specification Processing
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
    }
    
    private func constructViewHierarchy() {
        addSubview(videoLayout)
        addSubview(functionView)
        addSubview(floatWindowButton)
        addSubview(inviterUserButton)
        addSubview(timerView)
        addSubview(hintView)
    }
    
    private func activateConstraints() {
        videoLayout.translatesAutoresizingMaskIntoConstraints = false
        if let superview = videoLayout.superview {
            NSLayoutConstraint.activate([
                videoLayout.widthAnchor.constraint(equalTo: superview.widthAnchor),
                videoLayout.heightAnchor.constraint(equalTo: superview.heightAnchor)
            ])
        }
        
        floatWindowButton.translatesAutoresizingMaskIntoConstraints = false
        if let superview = floatWindowButton.superview {
            NSLayoutConstraint.activate([
                floatWindowButton.topAnchor.constraint(equalTo: superview.topAnchor, constant: StatusBar_Height + 12.scale375Height()),
                floatWindowButton.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 12.scale375Width()),
                floatWindowButton.heightAnchor.constraint(equalToConstant: 24.scale375Width()),
                floatWindowButton.widthAnchor.constraint(equalToConstant: 24.scale375Width())
            ])
        }
        
        inviterUserButton.translatesAutoresizingMaskIntoConstraints = false
        if let superview = inviterUserButton.superview {
            NSLayoutConstraint.activate([
                inviterUserButton.topAnchor.constraint(equalTo: superview.topAnchor, constant: StatusBar_Height + 12.scale375Height()),
                inviterUserButton.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -12.scale375Width()),
                inviterUserButton.heightAnchor.constraint(equalToConstant: 24.scale375Width()),
                inviterUserButton.widthAnchor.constraint(equalToConstant: 24.scale375Width())
            ])
        }
        
        timerView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = timerView.superview {
            NSLayoutConstraint.activate([
                timerView.topAnchor.constraint(equalTo: superview.topAnchor, constant: StatusBar_Height + 12.scale375Height()),
                timerView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                timerView.heightAnchor.constraint(equalToConstant: 24.scale375Width())
            ])
        }
        
        hintView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = hintView.superview {
            NSLayoutConstraint.activate([
                hintView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                hintView.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -220.scale375Height() - 10.scale375Height()),
                hintView.heightAnchor.constraint(equalToConstant: 24.scale375Width())
            ])
        }
    }
    
    // MARK: Action Event
    @objc func touchFloatWindowEvent(sender: UIButton) {
        WindowManager.shared.showFloatingWindow()
    }
    
    @objc func touchInviterUserEvent(sender: UIButton) {
        let selectGroupMemberVC = SelectGroupMemberViewController()
        selectGroupMemberVC.modalPresentationStyle = .fullScreen
        UIWindow.getKeyWindow()?.rootViewController?.present(selectGroupMemberVC, animated: false)
    }
    
    func registerObserver() {
        CallManager.shared.viewState.isScreenCleaned.addObserver(isScreenCleanedObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateScreenCleaned()
        }
        
        CallManager.shared.callState.chatGroupId.addObserver(chatGroupIdObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateInviterUserButton()
        }
    }
    
    func unregisterObserver() {
        CallManager.shared.viewState.isScreenCleaned.removeObserver(isScreenCleanedObserver)
        CallManager.shared.callState.chatGroupId.removeObserver(chatGroupIdObserver)
    }
    
    func updateScreenCleaned() {
        guard CallManager.shared.callState.mediaType.value == .video else { return }
        
        if CallManager.shared.viewState.isScreenCleaned.value {
            self.functionView.isHidden = true
            self.floatWindowButton.isHidden = true
            self.timerView.isHidden = true
        } else {
            self.functionView.isHidden = false
            self.floatWindowButton.isHidden = false
            self.timerView.isHidden = false
        }
    }
    
    func updateInviterUserButton() {
        if CallManager.shared.callState.chatGroupId.value.isEmpty {
            inviterUserButton.isHidden = true
            return
        }
        inviterUserButton.isHidden = false
    }
}
