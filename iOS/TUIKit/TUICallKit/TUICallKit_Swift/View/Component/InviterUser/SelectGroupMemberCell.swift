//
//  SelectGroupMemberCell.swift
//  Pods
//
//  Created by vincepzhang on 2025/3/3.
//


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
        selectImageView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = selectImageView.superview {
            NSLayoutConstraint.activate([
                selectImageView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 12),
                selectImageView.widthAnchor.constraint(equalToConstant: 20),
                selectImageView.heightAnchor.constraint(equalToConstant: 20),
                selectImageView.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
            ])
        }
        
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = userImageView.superview {
            NSLayoutConstraint.activate([
                userImageView.leadingAnchor.constraint(equalTo: selectImageView.trailingAnchor, constant: 12),
                userImageView.widthAnchor.constraint(equalToConstant: 30),
                userImageView.heightAnchor.constraint(equalToConstant: 30),
                userImageView.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
            ])
        }
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        if let superview = nameLabel.superview {
            NSLayoutConstraint.activate([
                nameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 12),
                nameLabel.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -12),
                nameLabel.heightAnchor.constraint(equalToConstant: 40),
                nameLabel.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
            ])
        }
    }
    
    func configCell(user: User, isSelect: Bool) {
        backgroundColor = UIColor.clear
        userImageView.sd_setImage(with: URL(string: user.avatar.value), placeholderImage: CallKitBundle.getBundleImage(name: "default_user_icon"))
        
        if isSelect {
            selectImageView.image = CallKitBundle.getBundleImage(name: "icon_check_box_group_selected")
        } else {
            selectImageView.image = CallKitBundle.getBundleImage(name: "icon_check_box_group_unselected")
        }
        
        nameLabel.text = UserManager.getUserDisplayName(user: user)
    }
}
