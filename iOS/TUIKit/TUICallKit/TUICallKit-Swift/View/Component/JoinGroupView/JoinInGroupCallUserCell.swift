//
//  JoinInGroupCallUserCell.swift
//  TUICallKit-Swift
//
//  Created by noah on 2024/2/27.
//

import Foundation

class JoinInGroupCallUserCell: UICollectionViewCell {
    
    private var user: User = User()
    
    private let userIcon = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4.0
        if let image = TUICallKitCommon.getBundleImage(name: "default_user_icon") {
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
    
    // MARK: UI Specification Processing
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
    
    func setModel(user: User) {
        self.user = user
        setUserIcon()
    }
    
    private func setUserIcon() {
        let userImage: UIImage? = TUICallKitCommon.getBundleImage(name: "default_user_icon")
        
        if user.avatar.value == "" {
            guard let image = userImage else { return }
            userIcon.image = image
        } else {
            userIcon.sd_setImage(with: URL(string: user.avatar.value), placeholderImage: userImage)
        }
    }
}
