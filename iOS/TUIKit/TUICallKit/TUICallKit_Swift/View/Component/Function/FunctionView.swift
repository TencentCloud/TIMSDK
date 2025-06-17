//
//  FunctionView.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/26.
//

import RTCCommon

class FunctionView: UIView {
    private var isViewReady = false
    private let callStatusObserver = Observer()

    private let audioCallerWaitingAndAcceptedFunctionView = {
        return AudioCallerWaitingAndAcceptedView(frame: CGRect.zero)
    }()
    private let videoCallerAndCalleeAcceptedFunctionView =  {
        return VideoCallerAndCalleeAcceptedView(frame: CGRect(x: 0, y: 0, width: CGFloat(Int(375.scale375Width())), height: 220.scale375Height()))
    }()
    private let videoCallerWaitingFunctionView = {
        return VideoCallerWaitingView(frame: CGRect.zero)
    }()
    private let audioAndVideoCalleeWaitingFunctionView = {
        return AudioAndVideoCalleeWaitingView(frame: CGRect.zero)
    }()
    
    
    // MARK: UI Specification Processing
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
    }
    
    private func constructViewHierarchy() {
        addSubview(audioCallerWaitingAndAcceptedFunctionView)
        addSubview(videoCallerAndCalleeAcceptedFunctionView)
        addSubview(videoCallerWaitingFunctionView)
        addSubview(audioAndVideoCalleeWaitingFunctionView)
    }
    
    private func activateConstraints() {
        let functionViewBottomOffset = -Bottom_SafeHeight - 40.scale375Height()
        let baseControlHeight = 60.scale375Width() + 5.scale375Height() + 20.scale375Height()

        audioCallerWaitingAndAcceptedFunctionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioCallerWaitingAndAcceptedFunctionView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            audioCallerWaitingAndAcceptedFunctionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: functionViewBottomOffset),
            audioCallerWaitingAndAcceptedFunctionView.heightAnchor.constraint(equalToConstant: baseControlHeight),
            audioCallerWaitingAndAcceptedFunctionView.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])

        videoCallerWaitingFunctionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoCallerWaitingFunctionView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            videoCallerWaitingFunctionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            videoCallerWaitingFunctionView.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])

        audioAndVideoCalleeWaitingFunctionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioAndVideoCalleeWaitingFunctionView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            audioAndVideoCalleeWaitingFunctionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: functionViewBottomOffset),
            audioAndVideoCalleeWaitingFunctionView.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])
    }
    
    //MARK: init,deinit
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        registerObserver()
    }
    
    deinit {
        unregisterobserver()
    }

    // MARK: Observer
    private func registerObserver() {
        CallManager.shared.userState.selfUser.callStatus.addObserver(callStatusObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.upateFunctionView()
        }
    }
    
    private func unregisterobserver() {
        CallManager.shared.userState.selfUser.callStatus.removeObserver(callStatusObserver)
    }

    // MARK: Config View
    private func initView() {
        upateFunctionView()
    }
    
    private func upateFunctionView() {
        audioCallerWaitingAndAcceptedFunctionView.isHidden = true
        videoCallerAndCalleeAcceptedFunctionView.isHidden = true
        videoCallerWaitingFunctionView.isHidden = true
        audioAndVideoCalleeWaitingFunctionView.isHidden = true
        
        if CallManager.shared.viewState.callingViewType.value == .multi {
            if CallManager.shared.userState.selfUser.callRole.value == .called && CallManager.shared.userState.selfUser.callStatus.value == .waiting {
                audioAndVideoCalleeWaitingFunctionView.isHidden = false
                return
            }
            videoCallerAndCalleeAcceptedFunctionView.isHidden = false
            return
        }
        
        if (CallManager.shared.callState.mediaType.value == .audio && CallManager.shared.userState.selfUser.callRole.value == .call) ||
            (CallManager.shared.callState.mediaType.value == .audio && CallManager.shared.userState.selfUser.callRole.value == .called &&
             CallManager.shared.userState.selfUser.callStatus.value == .accept) {
            audioCallerWaitingAndAcceptedFunctionView.isHidden = false
            return
        }
        
        if CallManager.shared.callState.mediaType.value == .video && CallManager.shared.userState.selfUser.callStatus.value == .accept {
            videoCallerAndCalleeAcceptedFunctionView.isHidden = false
            return
        }
        
        if CallManager.shared.callState.mediaType.value == .video && CallManager.shared.userState.selfUser.callStatus.value == .waiting &&
            CallManager.shared.userState.selfUser.callRole.value == .call {
            videoCallerWaitingFunctionView.isHidden = false
            return
        }
        
        if  CallManager.shared.userState.selfUser.callRole.value == .called && CallManager.shared.userState.selfUser.callStatus.value == .waiting {
            audioAndVideoCalleeWaitingFunctionView.isHidden = false
        }
    }
}
