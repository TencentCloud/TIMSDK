//
//  AudioAndVideoCalleeWaitingView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import TUICallEngine

class AudioAndVideoCalleeWaitingView: UIView {
    
    let viewModel = FunctionViewModel()
    let mediaTypeObserver = Observer()
    
    lazy var acceptBtn: BaseControlButton = {
        weak var weakSelf = self
        let acceptBtn = BaseControlButton.create(frame: CGRect.zero,
                                                 title: TUICallKitLocalize(key: "Demo.TRTC.Calling.answer") ?? "",
                                                 imageSize: CGSize(width: 64, height: 64)) { sender in
            weakSelf?.acceptTouchEvent(sender: sender)
        }
        if let image = TUICallKitCommon.getBundleImage(name: "trtccalling_ic_dialing") {
            acceptBtn.updateImage(image: image)
        }
        if viewModel.mediaType.value ==  TUICallMediaType.audio {
            acceptBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#242424"))
        } else if viewModel.mediaType.value == .video {
            acceptBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#F2F2F2"))
        }
        return acceptBtn
    }()
    
    lazy var rejectBtn: BaseControlButton = {
        weak var weakSelf = self
        let rejectBtn = BaseControlButton.create(frame: CGRect.zero,
                                                 title: TUICallKitLocalize(key: "Demo.TRTC.Calling.decline") ?? "",
                                                 imageSize: CGSize(width: 64, height: 64)) { sender in
            weakSelf?.rejectTouchEvent(sender: sender)
        }
        if let image = TUICallKitCommon.getBundleImage(name: "ic_hangup") {
            rejectBtn.updateImage(image: image)
        }
        if viewModel.mediaType.value == .audio {
            rejectBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#242424"))
        } else if viewModel.mediaType.value == .video {
            rejectBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#F2F2F2"))
        }
        return rejectBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.mediaType.removeObserver(mediaTypeObserver)
    }
    
    //MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(rejectBtn)
        addSubview(acceptBtn)
    }
    
    func activateConstraints() {
        rejectBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? 80 : -80)
            make.bottom.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(94)
        }
        
        acceptBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? -80 : 80)
            make.bottom.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(94)
        }
    }
    
    //MARK:   Event Action
    func rejectTouchEvent(sender: UIButton) {
        viewModel.reject()
    }
    
    func acceptTouchEvent(sender: UIButton) {
        viewModel.accept()
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        mediaTypeChange()
    }
    
    func mediaTypeChange() {
        viewModel.mediaType.addObserver(mediaTypeObserver) {  [weak self] newValue, _  in
            guard let self = self else { return }
            DispatchCallKitMainAsyncSafe {
                if newValue == .audio {
                    self.acceptBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#242424"))
                } else if newValue == .video {
                    self.acceptBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#F2F2F2"))
                }
                
                if newValue == .audio {
                    self.rejectBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#242424"))
                } else if newValue == .video {
                    self.rejectBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#F2F2F2"))
                }
            }
        }
    }
}
