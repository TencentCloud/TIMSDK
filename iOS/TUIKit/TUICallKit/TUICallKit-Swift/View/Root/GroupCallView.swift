//
//  GroupCallView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/1/6.
//

class GroupCallView: UIView {
    
    let selfCallStatusObserver = Observer()
    let mediaTypeObserver = Observer()
    private var isViewReady: Bool = false
    
    let backgroundView = {
        return GroupBackgroundView(frame: CGRect.zero)
    }()
    
    let maskedView = {
        let maskedView = UIView(frame: CGRect.zero)
        maskedView.backgroundColor =  UIColor.t_colorWithHexString(color: "#22262E", alpha: 0.85)
        return maskedView
    }()
    
    let layoutView = {
        return GroupCallVideoLayout(frame: CGRect.zero)
    }()
    
    let floatingWindowBtn = {
        return FloatingWindowButton(frame: CGRect.zero)
    }()
    
    let inviteUserButton = {
        return InviteUserButton(frame: CGRect.zero)
    }()
    
    let inviterUserInfoView = {
        return GroupCallerUserInfoView(frame: CGRect.zero)
    }()
    
    lazy var inviteeAvatarListView = {
        return InviteeAvatarListView(frame: CGRect.zero)
    }()
    
    let waitingHintView = {
        return CallWaitingHintView(frame: CGRect.zero)
    }()
    
    let functionView =  {
        let height = groupFunctionViewHeight + 30.scaleWidth()
        return GroupCallerAndCalleeAcceptedView(frame: CGRect(x: 0, y: Screen_Height - height, width: Screen_Width, height: height))
    }()
    
    let inviteeWaitFunctionView = {
        return AudioAndVideoCalleeWaitingView(frame: CGRect.zero)
    }()
    
    let timerView: TimerView = {
        return TimerView(frame: CGRect.zero)
    }()
    
    let callStatusTipLabel: UILabel = {
        let tipLabel = UILabel()
        tipLabel.font = UIFont.systemFont(ofSize: 15.0)
        tipLabel.textColor = UIColor.t_colorWithHexString(color: "#FFFFFF")
        tipLabel.textAlignment = .center
        tipLabel.text = TUICallKitLocalize(key: "TUICallKit.Group.waitAccept") ?? ""
        return tipLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: Screen_Width, height: Screen_Height)
        backgroundColor = UIColor.t_colorWithHexString(color: "#303132")
        functionView.delegate = self
        createGroupCallView()
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callStatus.removeObserver(selfCallStatusObserver)
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
        
        for view in subviews {
            view.removeFromSuperview()
        }
    }
    
    // MARK: UI Specification Processing
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(backgroundView)
        addSubview(maskedView)
        addSubview(layoutView)
        addSubview(floatingWindowBtn)
        addSubview(inviteUserButton)
        addSubview(inviterUserInfoView)
        addSubview(waitingHintView)
        addSubview(functionView)
        addSubview(inviteeWaitFunctionView)
        addSubview(timerView)
        addSubview(callStatusTipLabel)
    }
    
    func activateConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        maskedView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        layoutView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(StatusBar_Height + 48)
            make.centerX.equalTo(self)
            make.width.equalTo(Screen_Width)
            make.bottom.equalTo(functionView.snp.top)
        }
        floatingWindowBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(StatusBar_Height + 12.scaleHeight())
            make.leading.equalToSuperview().offset(12.scaleWidth())
            make.size.equalTo(kFloatWindowButtonSize)
        }
        inviteUserButton.snp.makeConstraints { make in
            make.size.equalTo(kInviteUserButtonSize)
            make.top.equalToSuperview().offset(StatusBar_Height + 12.scaleHeight())
            make.trailing.equalTo(snp.trailing).offset(-12.scaleWidth())
        }
        inviterUserInfoView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(StatusBar_Height + 150.scaleHeight())
            make.leading.equalTo(self).offset(20)
            make.trailing.equalTo(self).offset(-20)
            make.height.equalTo(100.scaleWidth() + 30.scaleHeight() + 50)
        }
        inviteeWaitFunctionView.snp.makeConstraints({ make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.bottom).offset(-Bottom_SafeHeight - 40.scaleHeight())
            make.height.equalTo(60.scaleWidth() + 5.scaleHeight() + 20)
            make.width.equalTo(self.snp.width)
        })
        timerView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(floatingWindowBtn)
            make.width.equalTo(200)
            make.height.equalTo(30)
        }
        callStatusTipLabel.snp.makeConstraints { make in
            make.edges.equalTo(timerView)
        }
        waitingHintView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.height.equalTo(20)
            make.width.equalTo(self)
            make.bottom.equalTo(self.timerView.snp.top)
        }
    }
    
    func addInviteeAvatarListView() {
        maskedView.addSubview(inviteeAvatarListView)
        inviteeAvatarListView.snp.makeConstraints { make in
            make.centerX.equalTo(maskedView)
            make.width.equalTo(maskedView)
            make.height.equalTo(60 + 5.scaleWidth())
            make.top.equalTo(maskedView).offset(Screen_Height * 3 / 5)
        }
    }
    
    func removeInviteeAvatarListView() {
        inviteeAvatarListView.removeFromSuperview()
    }
    
    // MARK: View Create & Manage
    func createGroupCallView() {
        handleFloatingWindowBtn()
        
        if TUICallState.instance.selfUser.value.callStatus.value == .waiting {
            if TUICallState.instance.selfUser.value.callRole.value == .call {
                createCallWaitingView()
            } else if TUICallState.instance.selfUser.value.callRole.value == .called {
                createCalledWaitingView()
            }
        } else if TUICallState.instance.selfUser.value.callStatus.value == .accept {
            createCallingView()
        }
    }
    
    func handleFloatingWindowBtn() {
        if TUICallState.instance.enableFloatWindow {
            floatingWindowBtn.isHidden = false
        } else {
            floatingWindowBtn.isHidden = true
        }
    }
    
    func createCallWaitingView() {
        hiddenChangeSubview()
        layoutView.isHidden = false
        inviteUserButton.isHidden = false
        functionView.isHidden = false
        callStatusTipLabel.isHidden = false
        waitingHintView.isHidden = TUICallState.instance.selfUser.value.callRole.value == .call ? true : false
    }
    
    func createCalledWaitingView() {
        hiddenChangeSubview()
        inviterUserInfoView.isHidden = false
        inviteeWaitFunctionView.isHidden = false
        addInviteeAvatarListView()
    }
    
    func createCallingView() {
        removeInviteeAvatarListView()
        hiddenChangeSubview()
        layoutView.isHidden = false
        inviteUserButton.isHidden = false
        functionView.isHidden = false
        timerView.isHidden = false
    }
    
    func hiddenChangeSubview() {
        layoutView.isHidden = true
        inviteUserButton.isHidden = true
        inviterUserInfoView.isHidden = true
        functionView.isHidden = true
        inviteeWaitFunctionView.isHidden = true
        timerView.isHidden = true
        callStatusTipLabel.isHidden = true
        waitingHintView.isHidden = true
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callStatusChanged()
        mediaTypeChanged()
    }
    
    func callStatusChanged() {
        TUICallState.instance.selfUser.value.callStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.createGroupCallView()
        })
    }
    
    func mediaTypeChanged() {
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver) { [weak self] newValue, _  in
            guard let self = self else { return }
            self.createGroupCallView()
        }
    }
}

extension GroupCallView: GroupCallerAndCalleeAcceptedViewDelegate {
    
    func showAnimation() {
        UIView.animate(withDuration: groupFunctionAnimationDuration) {
            self.functionView.frame = CGRect(x: 0,
                                             y: Screen_Height - groupSmallFunctionViewHeight,
                                             width: Screen_Width,
                                             height: groupSmallFunctionViewHeight)
        }
    }
    
    func restoreExpansion() {
        UIView.animate(withDuration: groupFunctionAnimationDuration) {
            self.functionView.frame = CGRect(x: 0, y: Screen_Height - groupFunctionViewHeight, width: Screen_Width, height: groupFunctionViewHeight)
        }
    }
    
    func handleTransform(animationScale: CGFloat) {
        let height = groupFunctionViewHeight - (groupFunctionViewHeight - groupSmallFunctionViewHeight) * animationScale
        self.functionView.frame = CGRect(x: 0, y: Screen_Height - height, width: Screen_Width, height: height)
    }
    
}
