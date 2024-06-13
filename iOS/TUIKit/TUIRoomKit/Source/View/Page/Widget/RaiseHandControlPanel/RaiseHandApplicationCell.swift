//
//  RaiseHandApplicationCell.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/5/7.
//

import Foundation

class RaiseHandApplicationCell: UITableViewCell {
    let attendeeModel: RequestEntity
    let viewModel: RaiseHandApplicationListViewModel
    
    let avatarImageView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = 20
        img.layer.masksToBounds = true
        return img
    }()
    
    let userLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xD5E0F2)
        label.backgroundColor = UIColor.clear
        label.textAlignment = isRTL ? .right : .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    let applyLabel: UILabel = {
        let label = UILabel()
        label.text = .applyText
        label.textColor = UIColor(0x8F9AB2)
        label.backgroundColor = UIColor.clear
        label.textAlignment = isRTL ? .right : .left
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let disagreeStageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(0x6B758A).withAlphaComponent(0.3)
        button.setTitle(.disagreeSeatText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(UIColor(0xB2BBD1), for: .normal)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        return button
    }()
    
    let agreeStageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(0x1C66E5)
        button.setTitle(.agreeSeatText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        return button
    }()
    
    let downLineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x4F586B).withAlphaComponent(0.3)
        return view
    }()
    
    init(attendeeModel: RequestEntity ,viewModel: RaiseHandApplicationListViewModel) {
        self.attendeeModel = attendeeModel
        self.viewModel = viewModel
        super.init(style: .default, reuseIdentifier: "RaiseHandCell")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(userLabel)
        contentView.addSubview(applyLabel)
        contentView.addSubview(agreeStageButton)
        contentView.addSubview(disagreeStageButton)
        contentView.addSubview(downLineView)
    }
    
    func activateConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40.scale375())
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(10.scale375Height())
        }
        agreeStageButton.snp.makeConstraints { make in
            make.width.equalTo(48.scale375())
            make.height.equalTo(28.scale375Height())
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        disagreeStageButton.snp.makeConstraints { make in
            make.trailing.equalTo(agreeStageButton.snp.leading).offset(-10)
            make.centerY.equalTo(agreeStageButton)
            make.width.height.equalTo(agreeStageButton)
        }
        userLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14.scale375Height())
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12.scale375())
            make.width.equalTo(150.scale375())
            make.height.equalTo(22.scale375())
        }
        applyLabel.snp.makeConstraints { make in
            make.top.equalTo(userLabel.snp.bottom).offset(2.scale375Height())
            make.leading.equalTo(userLabel)
        }
        downLineView.snp.makeConstraints { make in
            make.leading.equalTo(userLabel)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1.scale375())
        }
    }
    
    func bindInteraction() {
        setupViewState(item: attendeeModel)
        agreeStageButton.addTarget(self, action: #selector(agreeStageAction(sender:)), for: .touchUpInside)
        disagreeStageButton.addTarget(self, action: #selector(disagreeStageAction(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: RequestEntity) {
        let placeholder = UIImage(named: "room_default_user", in: tuiRoomKitBundle(), compatibleWith: nil)
        if let url = URL(string: item.avatarUrl) {
            avatarImageView.sd_setImage(with: url, placeholderImage: placeholder)
        } else {
            avatarImageView.image = placeholder
        }
        userLabel.text = item.userName
        backgroundColor = .clear
    }
    
    @objc func agreeStageAction(sender: UIButton) {
        viewModel.respondRequest(isAgree: true, request: attendeeModel)
    }
    
    @objc func disagreeStageAction(sender: UIButton) {
        viewModel.respondRequest(isAgree: false, request: attendeeModel)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var applyText: String {
        localized("Apply to be on stage")
    }
    static var disagreeSeatText: String {
        localized("Reject")
    }
    static var agreeSeatText: String {
        localized("Agree")
    }
}
