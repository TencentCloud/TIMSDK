//
//  MainCollectionViewCell.swift
//  TRTCScene
//
//  Created by adams on 2021/5/11.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "MainCollectionViewCell_Reuse_Identifier"
    
    private let containerView: UIView = {
        let view = UIView.init(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = UIFont.init(name: "PingFangSC-Medium", size: 18)
        label.textColor = UIColor.init("333333")
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = UIFont.init(name: "PingFangSC-Regular", size: 14)
        label.textColor = UIColor.init("666666")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupViewConstraints()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        roundedRect(rect: containerView.frame, byRoundingCorners: .allCorners, cornerRadii: CGSize.init(width: 10, height: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MainCollectionViewCell {
    
    private func setupViewHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descLabel)
    }
    
    private func setupViewConstraints() {
        containerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(iconImageView.snp.height).multipliedBy(170.0/136.0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.right.lessThanOrEqualToSuperview().offset(-20)
            make.top.equalTo(36)
            make.bottom.equalTo(descLabel.snp.top).offset(-4)
        }
        
        descLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.left)
            make.right.lessThanOrEqualToSuperview().offset(-20)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
    }
    
}

extension MainCollectionViewCell {
    
    public func config(_ model: MainMenuItemModel) {
        if model.imageName.hasPrefix("http") {
            if let imageURL = URL.init(string: model.imageName) {
                iconImageView.kf.setImage(with: .network(imageURL))
            }
        }
        else {
            iconImageView.image = model.iconImage
        }
        titleLabel.text = model.title
        descLabel.text = model.content
    }
    
}
