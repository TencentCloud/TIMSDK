//
//  ScheduleTabCell.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/5.
//

import Foundation
import Combine

class ScheduleTabCell: ScheduleBaseCell {
    static let identifier = "ScheduleTabCell"
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = UIColor(0x2B2E38)
        view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        view.textAlignment = isRTL ? .right : .left
        return view
    }()
    
    let messageLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = UIColor(0x2B2E38).withAlphaComponent(0.7)
        view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        view.textAlignment = isRTL ? .left : .right
        return view
    }()
    
    let button: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "room_down_arrow1", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(image, for: .normal)
        return button
    }()
    
    let avatarsView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = isRTL ? .leading : .trailing
        view.spacing = 5
        return view
    }()
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        setupViewStyle()
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(button)
        contentView.addSubview(messageLabel)
        contentView.addSubview(avatarsView)
    }
    
    private func activateConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20.scale375())
            make.width.lessThanOrEqualTo(100.scale375())
            make.centerY.equalToSuperview()
        }
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20.scale375())
            make.width.height.equalTo(16.scale375())
            make.centerY.equalToSuperview()
        }
        messageLabel.snp.makeConstraints() { make in
            make.trailing.equalTo(button.snp.leading).offset(-5.scale375())
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(170.scale375())
        }
        avatarsView.snp.makeConstraints { make in
            make.trailing.equalTo(messageLabel.snp.leading).offset(-5.scale375())
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(120.scale375())
        }
    }
    
    private func setupViewStyle() {
        // TODO: - @janejntang use color theme define from design graph.
        backgroundColor = UIColor(0xFFFFFF)
    }
        
    func updateView(item: CellConfigItem) {
        guard let listItem  = item as? ListItem else { return }
        titleLabel.text = listItem.title
        messageLabel.text = listItem.content
        button.setImage(UIImage(named: listItem.buttonIcon, in:  tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        updateButton(isShown: listItem.showButton)
        updateStackView(iconList: listItem.iconList)
    }
    
    func updateStackView(iconList: [String]) {
        avatarsView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
        let placeHolderImage = UIImage(named: "room_default_avatar_rect", in: tuiRoomKitBundle(), compatibleWith: nil)
        for iconString in iconList {
            let imageView = UIImageView(image: placeHolderImage)
            if let url = URL(string: iconString ) {
                imageView.sd_setImage(with: url, placeholderImage: placeHolderImage)
            }
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(32.scale375())
            }
            avatarsView.addArrangedSubview(imageView)
        }
        titleLabel.snp.updateConstraints { make in
            let maxWidth = iconList.count > 0 ? 80.scale375() : 100.scale375()
            make.width.lessThanOrEqualTo(maxWidth)
        }
    }
    
    func updateButton(isShown: Bool) {
        let buttonWidth = isShown ? 16.scale375() : 0
        button.snp.updateConstraints { make in
            make.width.equalTo(buttonWidth)
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
