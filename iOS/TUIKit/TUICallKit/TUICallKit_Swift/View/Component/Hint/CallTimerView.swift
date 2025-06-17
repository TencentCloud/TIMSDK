//
//  CallTimerView.swift
//  Pods
//
//  Created by vincepzhang on 2025/3/3.
//

import RTCCommon

class CallTimerView: UIView {
    private let timeCountObserver = Observer()
    private let callStatusObserver = Observer()
    private let timerLabel: UILabel = {
        let timerLabel = UILabel(frame: CGRect.zero)
        timerLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        timerLabel.backgroundColor = UIColor.clear
        timerLabel.textAlignment = .center
        timerLabel.textColor = UIColor(hex: "#D5E0F2")
        return timerLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        if let superview = timerLabel.superview {
            NSLayoutConstraint.activate([
                timerLabel.topAnchor.constraint(equalTo: superview.topAnchor),
                timerLabel.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                timerLabel.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                timerLabel.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        
        updateTimerView()
        registerObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterObserver()
    }
    
    // MARK: Observer
    private func registerObserver() {
        CallManager.shared.callState.callDurationCount.addObserver(timeCountObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            CallKitDispatchQueue.mainAsyncSafe {
                self.updateTimerView()
            }
        })
        
        CallManager.shared.userState.selfUser.callStatus.addObserver(callStatusObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            CallKitDispatchQueue.mainAsyncSafe {
                self.updateTimerView()
            }
        }
    }
    
    private func unregisterObserver() {
        CallManager.shared.userState.selfUser.callStatus.removeObserver(callStatusObserver)
        CallManager.shared.callState.callDurationCount.removeObserver(timeCountObserver)
    }
    
    // MARK: Config View
    private func updateTimerView() {
        timerLabel.text = CallManager.shared.userState.selfUser.callStatus.value == .accept ?
        GCDTimer.secondToHMSString(second: CallManager.shared.callState.callDurationCount.value) : TUICallKitLocalize(key: "TUICallKit.Group.waitAccept")

        if CallManager.shared.viewState.callingViewType.value == .one2one {
            if CallManager.shared.userState.selfUser.callStatus.value == .accept {
                timerLabel.isHidden = false
            } else {
                timerLabel.isHidden = true
            }
            return
        }
        
        if CallManager.shared.viewState.callingViewType.value == .multi {
           
            if CallManager.shared.userState.selfUser.callStatus.value == .waiting && CallManager.shared.userState.selfUser.callRole.value == .called {
                timerLabel.isHidden = true
            } else {
                timerLabel.isHidden = false
            }
            return
        }
    }
}
