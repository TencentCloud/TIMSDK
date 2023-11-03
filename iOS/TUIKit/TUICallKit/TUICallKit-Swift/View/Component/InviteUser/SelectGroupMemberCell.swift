//
//  SelectGroupMemberCell.swift
//  Alamofire
//
//  Created by vincepzhang on 2023/5/12.
//

import Foundation

class SelectGroupMemberCell: UITableViewCell {
    let userImageView = {
        let view = UIImageView(frame: CGRect.zero)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    let nameLabel = {
        let view = UILabel(frame: CGRect.zero)
        view.textColor = UIColor.t_colorWithHexString(color: "#242424")
        return view
    }()
    
    let selectImageView = {
        let view = UIImageView(frame: CGRect.zero)
        return view
    }()
    
    var isViewReady = false
    override func didMoveToWindow() {
        if isViewReady {
            return
        }
        constructViewHierarchy()
        activateConstraints()
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(userImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(selectImageView)
    }
    
    func activateConstraints() {
        selectImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(15)
            make.centerY.equalToSuperview()
        }

        userImageView.snp.makeConstraints { make in
            make.leading.equalTo(selectImageView.snp.trailing).offset(20)
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.userImageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
    }
    
    func configCell(user: User, isSelect: Bool) {
        backgroundColor = UIColor.clear
        
        userImageView.sd_setImage(with: URL(string: user.avatar.value), placeholderImage: TUICallKitCommon.getBundleImage(name: "userIcon"))
        
        if isSelect {
            selectImageView.image = TUICallKitCommon.getBundleImage(name: "tuicallkit_check_box_group_selected")
        } else {
            selectImageView.image = TUICallKitCommon.getBundleImage(name: "tuicallkit_check_box_group_unselected")
        }
                
        nameLabel.text = User.getUserDisplayName(user: user)
    }
}
