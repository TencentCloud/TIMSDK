//
//  CallStatusView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//

import Foundation

class CallStatusTipView: UIView {
    
    let selfCallStatusObserver = Observer()
    let networkQualityObserver = Observer()
    private var isFirstShowAccept: Bool = true
    
    let callStatusLabel: UILabel = {
        let callStatusLabel = UILabel(frame: CGRect.zero)
        callStatusLabel.textColor = UIColor.t_colorWithHexString(color: "#FFFFFF")
        callStatusLabel.font = UIFont.systemFont(ofSize: 15.0)
        callStatusLabel.backgroundColor = UIColor.clear
        callStatusLabel.textAlignment = .center
        return callStatusLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isFirstShowAccept = (TUICallState.instance.selfUser.value.callStatus.value == .accept) ? false : true
        updateStatusText()
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callStatus.removeObserver(selfCallStatusObserver)
        TUICallState.instance.networkQualityReminder.removeObserver(networkQualityObserver)
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
        addSubview(callStatusLabel)
    }
    
    func activateConstraints() {
        self.callStatusLabel.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callStatusChange()
        networkQualityChange()
    }
    
    func callStatusChange() {
        TUICallState.instance.selfUser.value.callStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateStatusText()
        })
    }
    
    func networkQualityChange() {
        TUICallState.instance.networkQualityReminder.addObserver(networkQualityObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateNetworkQualityText()
        })
    }
    
    func updateNetworkQualityText() {
        switch TUICallState.instance.networkQualityReminder.value {
        case .Local:
            self.callStatusLabel.text = TUICallKitLocalize(key: "TUICallKit.Self.NetworkLowQuality") ?? ""
            break
        case .Remote:
            self.callStatusLabel.text = TUICallKitLocalize(key: "TUICallKit.OtherParty.NetworkLowQuality") ?? ""
            break
        case .None:
            updateStatusText()
            break
        }
    }
    
    func updateStatusText() {
        switch TUICallState.instance.selfUser.value.callStatus.value {
        case .waiting:
            self.callStatusLabel.text = self.getCurrentWaitingText()
            break
        case .accept:
            if isFirstShowAccept {
                self.callStatusLabel.text = TUICallKitLocalize(key: "TUICallKit.accept") ?? ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isFirstShowAccept = false
                }
            } else {
                self.callStatusLabel.text = ""
            }
            break
        case .none:
            break
        default:
            break
        }
    }
    
    func getCurrentWaitingText() -> String {
        var waitingText = String()
        switch TUICallState.instance.mediaType.value {
        case .audio:
            if TUICallState.instance.selfUser.value.callRole.value == .call {
                waitingText = TUICallKitLocalize(key: "TUICallKit.waitAccept") ?? ""
            } else {
                waitingText = TUICallKitLocalize(key: "TUICallKit.inviteToAudioCall") ?? ""
            }
        case .video:
            if TUICallState.instance.selfUser.value.callRole.value == .call {
                waitingText = TUICallKitLocalize(key: "TUICallKit.waitAccept") ?? ""
            } else {
                waitingText = TUICallKitLocalize(key: "TUICallKit.inviteToVideoCall") ?? ""
            }
        case .unknown:
            break
        default:
            break
        }
        return waitingText
    }
}
