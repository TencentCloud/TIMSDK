//
//  CallWaitingHintView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/7.
//

import Foundation

class CallWaitingHintView: UIView {
 
    
    let label: UILabel = {
        let waitingInviteLabel = UILabel(frame: CGRect.zero)
        waitingInviteLabel.textColor = UIColor.t_colorWithHexString(color: "#999999")
        waitingInviteLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        waitingInviteLabel.backgroundColor = UIColor.clear
        waitingInviteLabel.textAlignment = .center
        waitingInviteLabel.text = TUICallKitLocalize(key: "Demo.TRTC.Calling.calleeTip")
        return waitingInviteLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        addSubview(label)
    }

    func activateConstraints() {
        self.label.snp.makeConstraints { make in
            make.centerX.size.equalTo(self)
        }
    }
}
