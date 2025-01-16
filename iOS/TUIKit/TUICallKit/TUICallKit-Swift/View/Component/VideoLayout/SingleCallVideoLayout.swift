//
//  SingleLayoutView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//

import Foundation

private let kCallKitSingleSmallVideoViewWidth = 100.0
private let kCallKitSingleSmallVideoViewFrame = CGRect(x: ScreenSize.width - kCallKitSingleSmallVideoViewWidth,
                                                       y: StatusBar_Height + 40,
                                                       width: kCallKitSingleSmallVideoViewWidth,
                                                       height: kCallKitSingleSmallVideoViewWidth / 9.0 * 16.0)
private let kCallKitSingleLargeVideoViewFrame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)

class SingleCallVideoLayout: UIView {
    
    let selfCallStatusObserver = Observer()
    let isCameraOpenObserver = Observer()
    let enableBlurBackgroundObserver = Observer()
    let remoteUserListObserver = Observer()

    var remoteHadInit = false
    var isLocalPreViewLarge: Bool = true
    
    var localPreView: VideoView {
        if VideoFactory.instance.viewMap[TUICallState.instance.selfUser.value.id.value] == nil {
            let _ = VideoFactory.instance.createVideoView(userId: TUICallState.instance.selfUser.value.id.value, frame: CGRect.zero)
        }
        return VideoFactory.instance.viewMap[TUICallState.instance.selfUser.value.id.value]?.videoView ?? VideoView(frame: CGRect.zero)
    }
    
    var remotePreView: VideoView {
        guard let remoteUser = TUICallState.instance.remoteUserList.value.first else { return VideoView(frame: CGRect.zero) }
        if VideoFactory.instance.viewMap[remoteUser.id.value] == nil {
            let _ = VideoFactory.instance.createVideoView(userId: remoteUser.id.value, frame: CGRect.zero)
        }
        return VideoFactory.instance.viewMap[remoteUser.id.value]?.videoView ?? VideoView(frame: CGRect.zero)
    }
    var remoteUser: User?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.t_colorWithHexString(color: "#242424")
        
        if TUICallState.instance.mediaType.value != .video {
            return
        }
        
        initPreView()
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callStatus.removeObserver(selfCallStatusObserver)
        TUICallState.instance.isCameraOpen.removeObserver(isCameraOpenObserver)
        TUICallState.instance.enableBlurBackground.removeObserver(enableBlurBackgroundObserver)
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callStatusChanged()
        cameraStateChanged()
        enableBlurBackgroundStateChange()
        remoteUserListChange()
    }
    
    func callStatusChanged() {
        TUICallState.instance.selfUser.value.callStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            if TUICallState.instance.mediaType.value == .video &&
                TUICallState.instance.selfUser.value.callStatus.value == .accept {
                self.initRemotePreView()
                self.setBeginAcceptPreview()
            }
            
            if TUICallState.instance.mediaType.value == .unknown &&
                TUICallState.instance.selfUser.value.callStatus.value == .none {
                self.setEndPreview()
                self.deinitPreView()
            }
        })
    }
    
    func cameraStateChanged() {
        TUICallState.instance.isCameraOpen.addObserver(isCameraOpenObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue == false && self.isLocalPreViewLarge == false {
                self.localPreView.isHidden = true
            } else {
                self.localPreView.isHidden = false
            }
        }
    }
    
    
    func enableBlurBackgroundStateChange() {
        TUICallState.instance.enableBlurBackground.addObserver(enableBlurBackgroundObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue == true && self.isLocalPreViewLarge == false {
                switchPreview()
            }
        }
    }
    
    func remoteUserListChange() {
        TUICallState.instance.remoteUserList.addObserver(remoteUserListObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if !remoteHadInit && TUICallState.instance.selfUser.value.callStatus.value == .accept {
                self.initRemotePreView()
                self.setBeginAcceptPreview()}
        }
    }
    
    // MARK: update UI
    func switchPreview() {
        if isLocalPreViewLarge {
            UIView.animate(withDuration: 0.3) {
                self.localPreView.frame = kCallKitSingleSmallVideoViewFrame
                self.remotePreView.frame = kCallKitSingleLargeVideoViewFrame
            } completion: { finished in
                self.sendSubviewToBack(self.remotePreView)
            }
            isLocalPreViewLarge = false
        } else {
            UIView.animate(withDuration: 0.3) {
                self.localPreView.frame = kCallKitSingleLargeVideoViewFrame
                self.remotePreView.frame = kCallKitSingleSmallVideoViewFrame
            } completion: { finished in
                self.sendSubviewToBack(self.localPreView)
            }
            isLocalPreViewLarge = true
        }
    }
    
    func setBeginAcceptPreview() {
        remotePreView.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.localPreView.frame = kCallKitSingleSmallVideoViewFrame
            self.remotePreView.frame = kCallKitSingleLargeVideoViewFrame
            self.localPreView.isHidden = TUICallState.instance.isCameraOpen.value ? false : true
        } completion: { finished in
            self.sendSubviewToBack(self.remotePreView)
        }
        isLocalPreViewLarge = false
    }
    
    func setEndPreview() {
        CallEngineManager.instance.closeCamera()
        CallEngineManager.instance.stopRemoteView(user: self.remoteUser ?? User())
        
        self.remoteUser = nil
        isLocalPreViewLarge = true
    }
    
    func initPreView() {
        if TUICallState.instance.selfUser.value.callStatus.value == .waiting {
            initLocalPreView()
        } else if TUICallState.instance.selfUser.value.callStatus.value == .accept {
            initLocalPreView()
            initRemotePreView()
            setBeginAcceptPreview()
        }
    }
    
    func initLocalPreView() {
        localPreView.frame = kCallKitSingleLargeVideoViewFrame
        localPreView.delegate = self
        localPreView.isUserInteractionEnabled = true
        localPreView.isHidden = false
        addSubview(localPreView)
        
        if TUICallState.instance.selfUser.value.callStatus.value == .waiting {
            CallEngineManager.instance.openCamera(videoView: localPreView)
        } else if TUICallState.instance.selfUser.value.callStatus.value == .accept && TUICallState.instance.isCameraOpen.value == true {
            CallEngineManager.instance.openCamera(videoView: localPreView)
        }
        
        if TUICallState.instance.isCameraOpen.value == false {
            localPreView.isHidden = true
        } else {
            localPreView.isHidden = false
        }
    }
    
    func initRemotePreView() {
        guard let remoteUser = TUICallState.instance.remoteUserList.value.first else { return }
        self.remoteUser = remoteUser
        remotePreView.frame = kCallKitSingleSmallVideoViewFrame
        remotePreView.isUserInteractionEnabled = true
        remotePreView.delegate = self
        remotePreView.isHidden = true
        addSubview(self.remotePreView)
        remoteHadInit = true
        
        CallEngineManager.instance.startRemoteView(user: remoteUser, videoView: remotePreView)
    }
    
    func deinitPreView() {
        localPreView.removeFromSuperview()
        remotePreView.removeFromSuperview()
        VideoFactory.instance.viewMap.removeAll()
    }
}

extension SingleCallVideoLayout: VideoViewDelegate {
    func tapGestureAction(tapGesture: UITapGestureRecognizer) {
        if  tapGesture.view?.frame.size.width == CGFloat(kCallKitSingleSmallVideoViewWidth) {
            switchPreview()
        } else {
            self.clickFullScreen()
        }
        
        if TUICallState.instance.isCameraOpen.value == false && self.isLocalPreViewLarge == false {
            self.localPreView.isHidden = true
        } else {
            self.localPreView.isHidden = false
        }
    }
    
    func clickFullScreen() {
        if (TUICallState.instance.selfUser.value.callStatus.value == .accept) {
            TUICallState.instance.isShowFullScreen.value = !TUICallState.instance.isShowFullScreen.value
        }
    }
    
    func panGestureAction(panGesture: UIPanGestureRecognizer) {
        if panGesture.view?.frame.size.width != CGFloat(kCallKitSingleSmallVideoViewWidth) { return }
        
        let smallView = panGesture.view?.superview
        if panGesture.state == .changed {
            let translation = panGesture.translation(in: self)
            let newCenterX = translation.x + (smallView?.center.x ?? 0.0)
            let newCenterY = translation.y + (smallView?.center.y ?? 0.0)
            
            if newCenterX < ((smallView?.bounds.size.width ?? 0.0) / 2.0) ||
                newCenterX > self.bounds.size.width - (smallView?.bounds.size.width ?? 0.0) / 2.0 {
                return
            }
            
            if newCenterY < ((smallView?.bounds.size.height ?? 0.0) / 2.0) ||
                newCenterY > self.bounds.size.height - (smallView?.bounds.size.height ?? 0.0) / 2.0 {
                return
            }
            
            UIView.animate(withDuration: 0.1) {
                smallView?.center = CGPoint(x: newCenterX, y: newCenterY)
            }
            panGesture.setTranslation(CGPointZero, in: self)
        }
    }
}
