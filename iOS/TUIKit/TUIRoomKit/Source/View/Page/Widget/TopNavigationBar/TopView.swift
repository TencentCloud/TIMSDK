//
//  TopView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2022/12/30.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation

class TopView: UIView {
    // MARK: - store property
    let viewModel: TopViewModel
    private var viewArray: [TopItemView] = []
    let backgroundImageView: UIImageView = {
        let image = UIImage(named: "room_top_background",in: tuiRoomKitBundle(), compatibleWith: nil)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 2.scale375()
        return view
    }()
    
    let meetingTitleView: UIView = {
        let view = UIView()
        return view
    }()
    
    let meetingNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xD5E0F2)
        label.font = UIFont(name: "PingFangSC-Medium", size: 16)
        label.textAlignment = isRTL ? .right : .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let dropDownButton: UIButton = {
        let button = UIButton(type: .custom)
        let normalIcon = UIImage(named: "room_drop_down", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(normalIcon, for: .normal)
        button.isEnabled = true
        return button
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xD1D9EC)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "PingFangSC-Medium", size: 12)
        return label
    }()
    
    let exitView: UIView = {
        let view = UIView()
        return view
    }()
    
    let exitImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "room_exit", in: tuiRoomKitBundle(), compatibleWith: nil)?.checkOverturn()
        return imageView
    }()
    
    let exitLabel: UILabel = {
        let label = UILabel()
        label.text = .exitText
        label.textColor = UIColor(0xED414D)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "PingFangSC-Medium", size: 14)
        return label
    }()
    
    var menuButtons: [UIView] = []
    
    // MARK: - initialized function
    init(viewModel: TopViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - view layout
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        backgroundColor = UIColor(0x0F1014)
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(backgroundImageView)
        addSubview(contentView)
        contentView.addSubview(meetingTitleView)
        contentView.addSubview(stackView)
        contentView.addSubview(exitView)
        meetingTitleView.addSubview(meetingNameLabel)
        meetingTitleView.addSubview(dropDownButton)
        meetingTitleView.addSubview(timeLabel)
        exitView.addSubview(exitImage)
        exitView.addSubview(exitLabel)
        for item in viewModel.viewItems {
            let view = TopItemView(itemData: item)
            menuButtons.append(view)
            stackView.addArrangedSubview(view)
            viewArray.append(view)
            let size = item.size ?? CGSize(width: 35.scale375(), height: 40.scale375Height())
            view.snp.makeConstraints { make in
                make.height.equalTo(size.height)
                make.width.equalTo(size.width)
            }
        }
    }
    
    func activateConstraints() {
        updateRootViewOrientation(isLandscape: isLandscape)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        meetingTitleView.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(180.scale375())
            make.height.equalTo(44.scale375Height())
            make.center.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16.scale375())
            make.top.bottom.equalToSuperview()
        }
        meetingNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(24.scale375())
            make.width.lessThanOrEqualTo(128.scale375())
            make.leading.equalToSuperview()
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(meetingNameLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        exitView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.width.equalTo(51.scale375())
        }
        exitImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(20.scale375())
            make.height.equalTo(20.scale375())
        }
        exitLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(28.scale375())
            make.height.equalTo(20.scale375())
        }
    }
    
    func bindInteraction() {
        let dropTap = UITapGestureRecognizer(target: self, action: #selector(dropDownAction(sender:)))
        let exitTap = UITapGestureRecognizer(target: self, action: #selector(exitAction(sender:)))
        meetingNameLabel.text = viewModel.engineManager.store.roomInfo.name
        meetingTitleView.addGestureRecognizer(dropTap)
        exitView.addGestureRecognizer(exitTap)
        viewModel.viewResponder = self
    }
    
    func updateRootViewOrientation(isLandscape: Bool) {
        contentView.snp.remakeConstraints { make in
            if isLandscape {
                make.top.equalToSuperview()
            } else {
                make.top.equalToSuperview().offset(44.scale375Height())
            }
            make.leading.trailing.bottom.equalToSuperview()
        }
        meetingTitleView.snp.remakeConstraints { make in
            if isLandscape {
                make.width.lessThanOrEqualTo(300.scale375())
                make.height.equalTo(24.scale375Height())
            } else {
                make.width.lessThanOrEqualTo(180.scale375())
                make.height.equalTo(44.scale375Height())
            }
            make.center.equalToSuperview()
        }
        dropDownButton.snp.remakeConstraints { make in
            make.leading.equalTo(meetingNameLabel.snp.trailing).offset(2.scale375())
            make.centerY.equalTo(meetingNameLabel)
            make.width.height.equalTo(16.scale375())
            if !isLandscape {
                make.trailing.equalToSuperview()
            }
        }
        timeLabel.snp.remakeConstraints { make in
            if isLandscape {
                make.centerY.equalTo(dropDownButton)
                make.leading.equalTo(dropDownButton.snp.trailing).offset(15)
                make.trailing.equalToSuperview()
            } else {
                make.top.equalTo(meetingNameLabel.snp.bottom).offset(5)
                make.centerX.equalToSuperview()
            }
        }
    }
    
    @objc func dropDownAction(sender: UIView) {
        viewModel.dropDownAction(sender: sender)
    }
    
    @objc func exitAction(sender: UIView) {
        viewModel.exitAction(sender: sender)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

enum AlertAction {
    case dismissRoomAction
    case transferMasterAction
    case leaveRoomAction
    case cancelAction
}

extension TopView: TopViewModelResponder {
    func updateMeetingNameLabel(_ text: String) {
        meetingNameLabel.text = text
    }
    
    func updateStackView(item: ButtonItemData) {
        guard let view = viewArray.first(where: { $0.itemData.buttonType == item.buttonType }) else { return }
        view.setupViewState(item: item)
    }
    
    func updateTimerLabel(text: String) {
        self.timeLabel.text = text
    }
    
#if RTCube_APPSTORE
    func showReportView() {
        let selector = NSSelectorFromString("showReportAlertWithRoomId:ownerId:")
        if responds(to: selector) {
            let roomInfo = viewModel.store.roomInfo
            perform(selector, with: roomInfo.roomId, with: roomInfo.ownerId)
        }
    }
#endif
}

private extension String {
    static var leaveRoomTitle: String {
        localized("Are you sure you want to leave the conference?")
    }
    static var destroyRoomTitle: String {
        localized("Are you sure you want to end the conference?")
    }
    static var dismissMeetingTitle: String {
        localized("If you don't want to end the conference")
    }
    static var appointNewHostText: String {
        localized("Please appoint a new host before leaving the conference")
    }
    static var leaveMeetingText: String {
        localized("Leave conference")
    }
    static var dismissMeetingText: String {
        localized("End conference")
    }
    static var cancelText: String {
        localized("Cancel")
    }
    static var exitText: String {
        localized("Exit")
    }
}

