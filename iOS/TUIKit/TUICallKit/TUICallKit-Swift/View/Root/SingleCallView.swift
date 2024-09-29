//
//  SingleCallView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2022/12/30.
//

import SnapKit

protocol SingleCallViewDelegate: AnyObject {
    func handleStatusBarHidden(isHidden: Bool)
}

class SingleCallView: UIView {
    
    weak var delegate: SingleCallViewDelegate?
    
    let selfCallStatusObserver = Observer()
    let mediaTypeObserver = Observer()
    let isShowFullScreenObserver = Observer()
    private var isViewReady: Bool = false
    
    let userInfoView = {
        return CallUserInfoView(frame: CGRect.zero)
    }()
    
    let callStatusTipView = {
        return CallStatusTipView(frame: CGRect.zero)
    }()
    
    let backgroundView = {
        return BackgroundView(frame: CGRect.zero)
    }()
    
    let maskedView = {
        let maskedView = UIView(frame: CGRect.zero)
        maskedView.backgroundColor =  UIColor.t_colorWithHexString(color: "#22262E", alpha: 0.85)
        return maskedView
    }()
    
    let audioFunctionView = {
        return AudioCallerWaitingAndAcceptedView(frame: CGRect.zero)
    }()
    
    let videoFunctionView =  {
        return VideoCallerAndCalleeAcceptedView(frame: CGRect.zero)
    }()
    
    let videoInviteFunctionView = {
        return VideoCallerWaitingView(frame: CGRect.zero)
    }()
    
    let inviteeWaitFunctionView = {
        return AudioAndVideoCalleeWaitingView(frame: CGRect.zero)
    }()
    
    let renderBackgroundView = {
        return SingleCallVideoLayout(frame: CGRect.zero)
    }()
    
    let timerView = {
        return TimerView(frame: CGRect.zero)
    }()
    
    let floatingWindowBtn = {
        return FloatingWindowButton(frame: CGRect.zero)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let screenSize = UIScreen.main.bounds.size
        self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        backgroundColor = UIColor.t_colorWithHexString(color: "#303132")
        
        createView()
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callStatus.removeObserver(selfCallStatusObserver)
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
        TUICallState.instance.isShowFullScreen.removeObserver(isShowFullScreenObserver)
        
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
        addSubview(renderBackgroundView)
        addSubview(userInfoView)
        addSubview(callStatusTipView)
        addSubview(audioFunctionView)
        addSubview(videoFunctionView)
        addSubview(videoInviteFunctionView)
        addSubview(inviteeWaitFunctionView)
        addSubview(floatingWindowBtn)
        addSubview(timerView)
    }
    
    func activateConstraints() {
        let baseControlHeight = 60.scaleWidth() + 5.scaleHeight() + 20
        let functionViewBottomOffset = -Bottom_SafeHeight - 40.scaleHeight()
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        maskedView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        renderBackgroundView.snp.makeConstraints { make in
            make.size.equalTo(self)
        }
        userInfoView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(StatusBar_Height + 150.scaleHeight())
            make.centerX.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(100.scaleWidth() + 10.scaleHeight() + 30)
        }
        callStatusTipView.snp.makeConstraints { make in
            make.top.equalTo(userInfoView.snp.bottom).offset((TUICallState.instance.showVirtualBackgroundButton ? 120 : 180).scaleHeight())
            make.centerX.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(20)
        }
        audioFunctionView.snp.makeConstraints({ make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.bottom).offset(functionViewBottomOffset)
            make.height.equalTo(baseControlHeight)
            make.width.equalTo(self.snp.width)
        })
        videoFunctionView.snp.makeConstraints({ make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.bottom).offset(functionViewBottomOffset)
            make.height.equalTo(baseControlHeight + 60.scaleWidth() + 20.scaleHeight())
            make.width.equalTo(self.snp.width)
        })
        videoInviteFunctionView.snp.makeConstraints({ make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.bottom).offset(functionViewBottomOffset)
            make.width.equalTo(self.snp.width)
        })
        inviteeWaitFunctionView.snp.makeConstraints({ make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.bottom).offset(functionViewBottomOffset)
            make.width.equalTo(self.snp.width)
        })
        floatingWindowBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(StatusBar_Height + 12.scaleHeight())
            make.leading.equalToSuperview().offset(12.scaleWidth())
            make.size.equalTo(kFloatWindowButtonSize)
        }
        timerView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(floatingWindowBtn)
            make.width.equalTo(100)
        }
    }
    
    // MARK: View Create & Manage
    
    func createView() {
        cleanView()
        handleFloatingWindowBtn()
        
        if TUICallState.instance.selfUser.value.callStatus.value == .waiting {
            createWaitingView()
        } else if TUICallState.instance.selfUser.value.callStatus.value == .accept {
            createAcceptView()
        }
    }
    
    func handleFloatingWindowBtn() {
        if TUICallState.instance.enableFloatWindow {
            floatingWindowBtn.isHidden = TUICallState.instance.isShowFullScreen.value
        } else {
            floatingWindowBtn.isHidden = true
        }
    }
    
    func createWaitingView() {
        switch TUICallState.instance.mediaType.value {
        case .audio:
            createAudioWaitingView()
        case .video:
            createVideoWaitingView()
        case .unknown:
            break
        default:
            break
        }
    }
    
    func createAudioWaitingView() {
        userInfoView.isHidden = false
        callStatusTipView.isHidden = false
        if TUICallState.instance.selfUser.value.callRole.value == .call {
            audioFunctionView.isHidden = false
        } else {
            inviteeWaitFunctionView.isHidden = false
        }
    }
    
    func createVideoWaitingView() {
        renderBackgroundView.isHidden = false
        userInfoView.isHidden = false
        callStatusTipView.isHidden = false
        if TUICallState.instance.selfUser.value.callRole.value == .call {
            videoInviteFunctionView.isHidden = false
        } else {
            inviteeWaitFunctionView.isHidden = false
        }
    }
    
    func createAcceptView() {
        switch TUICallState.instance.mediaType.value {
        case .audio:
            createAudioAcceptView()
        case .video:
            createVideoAcceptView()
        case .unknown:
            break
        default:
            break
        }
        
        createCallStatusTipView()
    }
    
    func createCallStatusTipView() {
        callStatusTipView.isHidden = false
    }
    
    func createAudioAcceptView() {
        userInfoView.isHidden = false
        timerView.isHidden = false
        audioFunctionView.isHidden = false
    }
    
    func createVideoAcceptView() {
        renderBackgroundView.isHidden = false
        timerView.isHidden = false
        videoFunctionView.isHidden = false
    }
    
    func cleanView() {
        timerView.isHidden = true
        callStatusTipView.isHidden = true
        userInfoView.isHidden = true
        audioFunctionView.isHidden = true
        videoFunctionView.isHidden = true
        videoInviteFunctionView.isHidden = true
        inviteeWaitFunctionView.isHidden = true
        renderBackgroundView.isHidden = true
    }
    
    // MARK: Register TUICallState Observer && Update UI
    
    func registerObserveState() {
        callStatusChanged()
        mediaTypeChanged()
        isShowFullScreenChanged()
    }
    
    func callStatusChanged() {
        TUICallState.instance.selfUser.value.callStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.createView()
        })
    }
    
    func mediaTypeChanged() {
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver) { [weak self] newValue, _  in
            guard let self = self else { return }
            self.createView()
        }
    }
    
    func isShowFullScreenChanged() {
        TUICallState.instance.isShowFullScreen.addObserver(isShowFullScreenObserver) { [weak self] newValue, _  in
            guard let self = self else { return }
            self.videoFunctionView.isHidden = newValue
            self.timerView.isHidden = newValue
            self.delegate?.handleStatusBarHidden(isHidden: newValue)
            
            if TUICallState.instance.enableFloatWindow {
                self.floatingWindowBtn.isHidden = newValue
            }
        }
    }
}
