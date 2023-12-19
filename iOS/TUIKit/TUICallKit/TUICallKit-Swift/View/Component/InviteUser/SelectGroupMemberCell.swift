//
//  SelectGroupMemberCell.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/5/12.
//

import Foundation

class SelectGroupMemberCell: UITableViewCell {
    
    let userImageView = {
        let view = UIImageView(frame: CGRect.zero)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    let nameLabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_select_group_member_name_color",
                                                                         defaultHex: "#242424")
        return label
    }()
    
    let selectImageView = {
        let view = UIImageView(frame: CGRect.zero)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_select_group_member_cell_bg_color",
                                                                                     defaultHex: "#FFFFFF")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        userImageView.snp.makeConstraints { make in
            make.leading.equalTo(selectImageView.snp.trailing).offset(12)
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.userImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
    }
    
    func configCell(user: User, isSelect: Bool) {
        backgroundColor = UIColor.clear
        userImageView.sd_setImage(with: URL(string: user.avatar.value), placeholderImage: TUICallKitCommon.getBundleImage(name: "default_user_icon"))
        
        if isSelect {
            selectImageView.image = TUICallKitCommon.getBundleImage(name: "icon_check_box_group_selected")
        } else {
            selectImageView.image = TUICallKitCommon.getBundleImage(name: "icon_check_box_group_unselected")
        }
        
        nameLabel.text = User.getUserDisplayName(user: user)
    }
    
}
