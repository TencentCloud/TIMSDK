//
//  InviteUserButton.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//

import Foundation
import TUICore

class InviteUserButton: UIView {
    
    let mediaTypeObserver = Observer()
    
    let inviteUserButton: InviteUserCustomButton = {
        let inviteUserButton = InviteUserCustomButton(type: .system)
        return inviteUserButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateImage()
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
    }
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(inviteUserButton)
    }
    
    func activateConstraints() {
        inviteUserButton.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.width.height.equalTo(24)
        }
    }
    
    func bindInteraction() {
        inviteUserButton.addTarget(self, action: #selector(clickButton(sender: )), for: .touchUpInside)
    }
    
    // MARK:  Action Event
    @objc func clickButton(sender: UIButton) {
        let selectGroupMemberVC = SelectGroupMemberViewController()
        selectGroupMemberVC.modalPresentationStyle = .fullScreen
        UIWindow.getKeyWindow()?.rootViewController?.present(selectGroupMemberVC, animated: false)
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateImage()
        }
    }
    
    func updateImage() {
        if let image = TUICallKitCommon.getBundleImage(name: "icon_add_user") {
            inviteUserButton.setBackgroundImage(image, for: .normal)
        }
    }
    
    func tui_valueCallback(param: [AnyHashable: Any]) {
        guard let selectUserList = param[TUICore_TUIContactObjectFactory_SelectGroupMemberVC_ResultUserList] as? [TUIUserModel] else { return }
        if selectUserList.count > 0 {
            return
        }
        
        var userIds: [String] = []
        for user in selectUserList {
            userIds.append(user.userId)
        }
        
        CallEngineManager.instance.inviteUser(userIds: userIds)
    }
}

class InviteUserCustomButton: UIButton {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let expandedBounds = bounds.insetBy(dx: -6, dy: -6)
        return expandedBounds.contains(point) ? self : nil
    }
}
