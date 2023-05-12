//
//  GroupCallView.swift
//  Pods
//
//  Created by vincepzhang on 2023/1/6.
//

class GroupCallView: UIView {
    
    let viewModel = GroupCallViewModel()
    let selfCallStatusObserver = Observer()
    let mediaTypeObserver = Observer()
    private var isViewReady: Bool = false
    
    let layoutView = {
        return GroupCallVideoLayout(frame: CGRectZero)
    }()
    
    let floatingWindowBtn = {
        return FloatingWindowButton(frame: CGRectZero)
    }()
    
    let inviteUserBUtton = {
        return InviteUserButton(frame: CGRectZero)
    }()
    
    let inviterUserInfoView = {
        return GroupCallerUserInfoView(frame: CGRectZero)
    }()
    
    let inviteeAvatarListView = {
        return InviteeAvatarListView(frame: CGRectZero)
    }()
    
    let waitingHintView = {
        return CallWaitingHintView(frame: CGRectZero)
    }()
    
    let audioFunctionView = {
        return AudioCallerWaitingAndAcceptedView(frame: CGRectZero)
    }()
    
    let videoFunctionView =  {
        return VideoCallerAndCalleeAcceptedView(frame: CGRectZero)
    }()
        
    let inviteeWaitFunctionView = {
        return AudioAndVideoCalleeWaitingView(frame: CGRectZero)
    }()
        
    let timerView: TimerView = {
        return TimerView(frame: CGRectZero)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRectMake(0, 0, Screen_Width, Screen_Height)
        createGroupCallView()
        registerObserveState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.selfCallStatus.removeObserver(selfCallStatusObserver)
        viewModel.mediaType.removeObserver(mediaTypeObserver)
        
        for view in subviews {
            view.removeFromSuperview()
        }
    }
    
    //MARK: UI Specification Processing
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }

    func constructViewHierarchy() {
        addSubview(layoutView)
        addSubview(floatingWindowBtn)
        addSubview(inviteUserBUtton)
        addSubview(inviterUserInfoView)
        addSubview(inviteeAvatarListView)
        addSubview(waitingHintView)
        addSubview(audioFunctionView)
        addSubview(videoFunctionView)
        addSubview(inviteeWaitFunctionView)
        addSubview(timerView)
    }
    
    func activateConstraints() {
        layoutView.snp.makeConstraints { make in
            make.size.equalTo(self)
        }
        
        floatingWindowBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.top.equalTo(snp.top).offset(20)
            make.left.equalTo(snp.left).offset(20)
        }

        inviteUserBUtton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.top.equalTo(snp.top).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }

        inviterUserInfoView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(StatusBar_Height + 75.0)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(180)
        }
        
        inviteeAvatarListView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(40)
            make.top.equalTo(inviterUserInfoView.snp.bottom).offset(10)
        }
        
        audioFunctionView.snp.makeConstraints({ make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.top).offset(self.frame.size.height - Bottom_SafeHeight - 20)
            make.height.equalTo(100.0)
            make.width.equalTo(self.snp.width)
        })
        
        videoFunctionView.snp.makeConstraints({ make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.top).offset(self.frame.size.height - Bottom_SafeHeight - 20)
            make.height.equalTo(200.0)
            make.width.equalTo(self)
        })

        inviteeWaitFunctionView.snp.makeConstraints({ make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.top).offset(self.frame.size.height - Bottom_SafeHeight - 20)
            make.height.equalTo(100.0)
            make.width.equalTo(self.snp.width)
        })

        timerView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.height.equalTo(20)
            make.width.equalTo(self)
            make.bottom.equalTo(self.videoFunctionView.snp.top).offset(10)
        }
        
        waitingHintView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.height.equalTo(20)
            make.width.equalTo(self)
            make.bottom.equalTo(self.timerView.snp.top)
        }
    }

    //MARK: View Create & Manage
    func createGroupCallView() {
        
        if viewModel.enableFloatWindow {
            floatingWindowBtn.isHidden = false
        } else {
            floatingWindowBtn.isHidden = true
        }

        if viewModel.selfCallRole.value == .call {
            if viewModel.mediaType.value == .audio {
                if viewModel.selfCallStatus.value == .waiting {
                    createAudioCallWaitingView()
                } else if viewModel.selfCallStatus.value == .accept {
                    createAudioCallingView()
                }
            } else if viewModel.mediaType.value == .video {
                if viewModel.selfCallStatus.value == .waiting {
                    createVideoCallWaitingView()
                } else if viewModel.selfCallStatus.value == .accept {
                    createVideoCallingView()
                }
            }
        } else if viewModel.selfCallRole.value == .called {
            if viewModel.mediaType.value == .audio {
                if viewModel.selfCallStatus.value == .waiting {
                    createAudioCalledWaitingView()
                } else if viewModel.selfCallStatus.value == .accept {
                    createAudioCallingView()
                }
            } else if viewModel.mediaType.value == .video {
                if viewModel.selfCallStatus.value == .waiting {
                    createVideoCalledWaitingView()
                } else if viewModel.selfCallStatus.value == .accept {
                    createVideoCallingView()
                }
            }
        }
    }
    
    func createVideoCallWaitingView() {
        hiddencChangeSubview()
        layoutView.backgroundColor = UIColor.t_colorWithHexString(color: "#242424")
        layoutView.isHidden = false
        inviteUserBUtton.isHidden = false
        videoFunctionView.isHidden = false
        waitingHintView.isHidden = false
    }
    
    func createVideoCallingView() {
        hiddencChangeSubview()
        layoutView.backgroundColor = UIColor.t_colorWithHexString(color: "#242424")
        layoutView.isHidden = false
        inviteUserBUtton.isHidden = false
        videoFunctionView.isHidden = false
        timerView.isHidden = false
    }

    func createAudioCallWaitingView() {
        hiddencChangeSubview()
        layoutView.backgroundColor = UIColor.t_colorWithHexString(color: "#F2F2F2")
        layoutView.isHidden = false
        inviteUserBUtton.isHidden = false
        audioFunctionView.isHidden = false
        waitingHintView.isHidden = false
    }
    
    func createAudioCallingView() {
        hiddencChangeSubview()
        layoutView.backgroundColor = UIColor.t_colorWithHexString(color: "#F2F2F2")
        layoutView.isHidden = false
        inviteUserBUtton.isHidden = false
        audioFunctionView.isHidden = false
        timerView.isHidden = false
    }
    
    func createVideoCalledWaitingView() {
        hiddencChangeSubview()
        backgroundColor = UIColor.t_colorWithHexString(color: "#242424")
        inviterUserInfoView.isHidden = false
        inviteeAvatarListView.isHidden = false
        inviteeWaitFunctionView.isHidden = false
    }
    
    func createAudioCalledWaitingView() {
        hiddencChangeSubview()
        backgroundColor = UIColor.t_colorWithHexString(color: "#F2F2F2")
        inviterUserInfoView.isHidden = false
        inviteeAvatarListView.isHidden = false
        inviteeWaitFunctionView.isHidden = false
    }
    
    func hiddencChangeSubview() {
        layoutView.isHidden = true
        inviteUserBUtton.isHidden = true
        inviterUserInfoView.isHidden = true
        inviteeAvatarListView.isHidden = true
        audioFunctionView.isHidden = true
        videoFunctionView.isHidden = true
        inviteeWaitFunctionView.isHidden = true
        timerView.isHidden = true
        waitingHintView.isHidden = true
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callStatusChanged()
        mediaTypeChanged()
    }
    
    func callStatusChanged() {
        viewModel.selfCallStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.createGroupCallView()
        })
    }
    
    func mediaTypeChanged() {
        viewModel.mediaType.addObserver(mediaTypeObserver) { [weak self] newValue, _  in
            guard let self = self else { return }
            self.createGroupCallView()
        }
    }
}
