//
//  SingleLayoutView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//

import Foundation

private let kCallKitSingleSmallVideoViewWidth = 100.0
private let kCallKitSingleSmallVideoViewFrame = CGRectMake(ScreenSize.width - kCallKitSingleSmallVideoViewWidth - 18,
StatusBar_Height + 20, kCallKitSingleSmallVideoViewWidth, kCallKitSingleSmallVideoViewWidth / 9.0 * 16.0)
private let kCallKitSingleLargeVideoViewFrame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)

class SingleCallVideoLayout: UIView {
    
    let viewModel = SingleCallVideoLayoutModel()
    let selfCallStatusObserver = Observer()
    let isCameraOpenObserver = Observer()
    var isLocalPreViewLargr: Bool = true

    var localPreView: VideoView {
        if VideoFactory.instance.viewMap[viewModel.selfUser.value.id.value] == nil {
            let _ = VideoFactory.instance.createVideoView(userId: viewModel.selfUser.value.id.value, frame: CGRectZero)
        }
        return VideoFactory.instance.viewMap[viewModel.selfUser.value.id.value]?.videoView ?? VideoView(frame: CGRectZero)
    }
    
    var remotePreView: VideoView {
        guard let remoteUser = self.viewModel.remoteUserList.value.first else { return VideoView(frame: CGRectZero) }
        if VideoFactory.instance.viewMap[remoteUser.id.value] == nil {
            let _ = VideoFactory.instance.createVideoView(userId: remoteUser.id.value, frame: CGRectZero)
        }
        return  VideoFactory.instance.viewMap[remoteUser.id.value]?.videoView ?? VideoView(frame: CGRectZero)
    }
    var remoteUser: User?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.t_colorWithHexString(color: "#242424")
        
        initPreView()
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.selfCallStatus.removeObserver(selfCallStatusObserver)
        viewModel.isCameraOpen.removeObserver(isCameraOpenObserver)
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callStatusChanged()
        cameraStateChanged()
    }
        
    func callStatusChanged() {
        viewModel.selfCallStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            if self.viewModel.mediaType.value == .video &&
                self.viewModel.selfCallStatus.value == .accept {
                self.initRemotePreView()
                self.setBeginAcceptPreview()
            }
            
            if self.viewModel.mediaType.value == .unknown &&
                self.viewModel.selfCallStatus.value == .none {
                self.setEndPreview()
                self.deinitPreView()
            }
        })
    }
    
    func cameraStateChanged() {
        viewModel.isCameraOpen.addObserver(isCameraOpenObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue == false && self.isLocalPreViewLargr == false {
                self.localPreView.isHidden = true
            } else {
                self.localPreView.isHidden = false
            }
        }
    }
    
    //MARK: update UI
    func switchPreview() {
        if isLocalPreViewLargr {
            UIView.animate(withDuration: 0.3) {
                self.localPreView.frame = kCallKitSingleSmallVideoViewFrame
                self.remotePreView.frame = kCallKitSingleLargeVideoViewFrame
            } completion: { finished in
                self.sendSubviewToBack(self.remotePreView)
                
                self.localPreView.isUserInteractionEnabled = true
                self.remotePreView.isUserInteractionEnabled = false
            }
            isLocalPreViewLargr = false
        } else {
            UIView.animate(withDuration: 0.3) {
                self.localPreView.frame = kCallKitSingleLargeVideoViewFrame
                self.remotePreView.frame = kCallKitSingleSmallVideoViewFrame
            } completion: { finished in
                self.sendSubviewToBack(self.localPreView)

                self.localPreView.isUserInteractionEnabled = false
                self.remotePreView.isUserInteractionEnabled = true
            }
            isLocalPreViewLargr = true
        }
    }

    func setBeginAcceptPreview() {
        remotePreView.isHidden = false

        UIView.animate(withDuration: 0.3) {
            self.localPreView.frame = kCallKitSingleSmallVideoViewFrame
            self.remotePreView.frame = kCallKitSingleLargeVideoViewFrame
        } completion: { finished in
            self.sendSubviewToBack(self.remotePreView)
            
            self.localPreView.isUserInteractionEnabled = true
            self.remotePreView.isUserInteractionEnabled = false
        }
        isLocalPreViewLargr = false
    }
    
    func setEndPreview() {
        self.viewModel.closeCamera()
        self.viewModel.stopRemoteView(user: self.remoteUser ?? User())
        
        self.remoteUser = nil
        isLocalPreViewLargr = true
    }
    
    func initPreView() {
        if viewModel.selfCallStatus.value == .waiting {
            initLocalPreView()
        } else if viewModel.selfCallStatus.value == .accept {
            initLocalPreView()
            initRemotePreView()
            setBeginAcceptPreview()
        }
    }
    
    func initLocalPreView() {
        localPreView.frame = kCallKitSingleLargeVideoViewFrame
        localPreView.delegate = self
        localPreView.isUserInteractionEnabled = false
        localPreView.isHidden = false
        addSubview(localPreView)
        
        if viewModel.selfCallStatus.value == .waiting {
            viewModel.openCamera(videoView: localPreView)
        } else if viewModel.selfCallStatus.value == .accept && viewModel.isCameraOpen.value == true {
            viewModel.openCamera(videoView: localPreView)
        }
        
        if viewModel.isCameraOpen.value == false {
            localPreView.isHidden = true
        } else {
            localPreView.isHidden = false
        }
    }
    
    func initRemotePreView() {
        guard let remoteUser = self.viewModel.remoteUserList.value.first else { return }
        self.remoteUser = remoteUser
        remotePreView.frame = kCallKitSingleSmallVideoViewFrame
        remotePreView.delegate = self
        remotePreView.isHidden = true
        addSubview(self.remotePreView)
        
        viewModel.startRemoteView(user: remoteUser, videoView: remotePreView)
    }
    
    func deinitPreView() {
        localPreView.removeFromSuperview()
        remotePreView.removeFromSuperview()
        VideoFactory.instance.viewMap.removeAll()
    }
}

extension  SingleCallVideoLayout: VideoViewDelegate {
    func tapGestureAction(tapGesture: UITapGestureRecognizer) {
        if  tapGesture.view?.frame.size.width == CGFloat(kCallKitSingleSmallVideoViewWidth) {
            switchPreview()
        }
        if viewModel.isCameraOpen.value == false && self.isLocalPreViewLargr == false {
            self.localPreView.isHidden = true
        } else {
            self.localPreView.isHidden = false
        }
    }
    
    func panGestureAction(panGesture: UIPanGestureRecognizer) {
        if  panGesture.view?.frame.size.width != CGFloat(kCallKitSingleSmallVideoViewWidth) { return }
        
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
