//
//  CallHintView.swift
//  Pods
//
//  Created by vincepzhang on 2025/3/3.
//

import RTCCommon

class CallHintView: UIView {
    private let selfCallStatusObserver = Observer()
    private let networkQualityObserver = Observer()
    private var needShowAcceptHit: Bool
    
    let callStatusLabel: UILabel = {
        let callStatusLabel = UILabel(frame: CGRect.zero)
        callStatusLabel.textColor = UIColor(hex: "#FFFFFF")
        callStatusLabel.font = UIFont.systemFont(ofSize: 15.0)
        callStatusLabel.backgroundColor = UIColor.clear
        callStatusLabel.textAlignment = .center
        return callStatusLabel
    }()
    
    override init(frame: CGRect) {
        needShowAcceptHit = (CallManager.shared.userState.selfUser.callStatus.value == .accept) ? false : true
        super.init(frame: frame)

        updateStatusText()
        updateHintView()
        registerObserve()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterObserve()
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
        self.callStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.callStatusLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.callStatusLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.callStatusLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.callStatusLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserve() {
        CallManager.shared.userState.selfUser.callStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateStatusText()
            self.updateHintView()
        })
        CallManager.shared.callState.networkQualityReminder.addObserver(networkQualityObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateNetworkQualityText()
        })
    }
    func unregisterObserve() {
        CallManager.shared.userState.selfUser.callStatus.removeObserver(selfCallStatusObserver)
        CallManager.shared.callState.networkQualityReminder.removeObserver(networkQualityObserver)
    }
       
    // MARK: update view
    func updateHintView() {
        if CallManager.shared.viewState.callingViewType.value == .one2one {
            callStatusLabel.isHidden = false
        } else if CallManager.shared.viewState.callingViewType.value == .multi &&
                    CallManager.shared.userState.selfUser.callRole.value == .called &&
                    CallManager.shared.userState.selfUser.callStatus.value == .waiting {
            callStatusLabel.isHidden = false
        } else {
            callStatusLabel.isHidden = true
        }
    }

    func updateNetworkQualityText() {
        switch CallManager.shared.callState.networkQualityReminder.value {
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
        switch CallManager.shared.userState.selfUser.callStatus.value {
        case .waiting:
            self.callStatusLabel.text = self.getCurrentWaitingText()
            break
        case .accept:
            if needShowAcceptHit {
                self.callStatusLabel.text = TUICallKitLocalize(key: "TUICallKit.accept") ?? ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let self = self else { return }
                    self.needShowAcceptHit = false
                    self.updateStatusText()
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
        if CallManager.shared.viewState.callingViewType.value == .multi {
            return  TUICallKitLocalize(key: "TUICallKit.Group.inviteToGroupCall") ?? ""
        }
        
        var waitingText = String()
        switch CallManager.shared.callState.mediaType.value {
        case .audio:
            if CallManager.shared.userState.selfUser.callRole.value == .call {
                waitingText = TUICallKitLocalize(key: "TUICallKit.waitAccept") ?? ""
            } else {
                waitingText = TUICallKitLocalize(key: "TUICallKit.inviteToAudioCall") ?? ""
            }
        case .video:
            if CallManager.shared.userState.selfUser.callRole.value == .call {
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
