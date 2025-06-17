//
//  Untitled.swift
//  Pods
//
//  Created by vincepzhang on 2025/3/3.
//

import Foundation

class JoinCallUserCell: UICollectionViewCell {
    
    private var user: User = User()
    
    private let userIcon = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4.0
        if let image = CallKitBundle.getBundleImage(name: "default_user_icon") {
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
        userIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userIcon.topAnchor.constraint(equalTo: contentView.topAnchor),
            userIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            userIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            userIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func setModel(user: User) {
        self.user = user
        setUserIcon()
    }
    
    private func setUserIcon() {
        let userImage: UIImage? = CallKitBundle.getBundleImage(name: "default_user_icon")
        
        if user.avatar.value == "" {
            guard let image = userImage else { return }
            userIcon.image = image
        } else {
            userIcon.sd_setImage(with: URL(string: user.avatar.value), placeholderImage: userImage)
        }
    }
}
