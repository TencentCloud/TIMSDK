//
//  InviteeAvatarCell.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/2.
//

import Foundation

class InviteeAvatarCell: UICollectionViewCell {
    
    private var user: User = User()
    private let userIcon = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        if let image = TUICallKitCommon.getBundleImage(name: "userIcon") {
            imageView.image = image
        }
        return imageView
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

    private func constructViewHierarchy() {
        contentView.addSubview(userIcon)
    }
    
    private func activateConstraints() {
        userIcon.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
    }

    func initCell(user: User) {
        self.user = user
        setUserIcon()
    }
    
    private func setUserIcon() {
        if user.avatar.value == "" {
            if let image = TUICallKitCommon.getBundleImage(name: "userIcon") {
                userIcon.image = image
            }
        } else {
            if let image = TUICallKitCommon.getUrlImage(url: user.avatar.value) {
                userIcon.image = image
            }
        }
    }
}
