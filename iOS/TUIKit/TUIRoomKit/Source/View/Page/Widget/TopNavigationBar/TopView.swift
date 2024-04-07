//
//  TopView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2022/12/30.
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
        view.spacing = 24.scale375()
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
        label.textAlignment = isRTL ? .left : .right
        label.adjustsFontSizeToFitWidth = true
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
            let size = item.size ?? CGSize(width: 20.scale375(), height: 20.scale375())
            view.snp.makeConstraints { make in
                make.height.equalTo(size.height)
                make.width.equalTo(size.width)
            }
        }
    }
    
    func activateConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(44.scale375Height())
        }
        meetingTitleView.snp.makeConstraints { make in
            make.width.equalTo(129.scale375())
            make.height.equalTo(44.scale375Height())
            make.centerX.centerY.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16.scale375())
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(meetingTitleView.snp.leading).offset(-16.scale375())
        }
        meetingNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(24.scale375())
            make.width.equalTo(111.scale375())
        }
        dropDownButton.snp.makeConstraints { make in
            make.leading.equalTo(meetingNameLabel.snp.trailing).offset(2.scale375())
            make.centerY.equalTo(meetingNameLabel)
            make.width.height.equalTo(16.scale375())
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
        var namelabel = viewModel.engineManager.store.roomInfo.name + .quickMeetingText
        if namelabel.count > 10 {
            namelabel = namelabel.prefix(9) + "..."
        }
        meetingNameLabel.text = namelabel
        meetingTitleView.addGestureRecognizer(dropTap)
        exitView.addGestureRecognizer(exitTap)
        viewModel.viewResponder = self
        viewModel.updateTimerLabelText()
    }
    
    func updateRootViewOrientation(isLandscape: Bool) {
        if isLandscape { //横屏时，会议时间放在会议名称的右边
            contentView.snp.updateConstraints() { make in
                make.top.equalToSuperview()
            }
            timeLabel.snp.remakeConstraints() { make in
                make.centerY.equalTo(dropDownButton)
                make.leading.equalTo(dropDownButton.snp.trailing).offset(15)
            }
            meetingTitleView.snp.updateConstraints { make in
                make.width.equalTo(150.scale375())
                make.height.equalTo(24.scale375Height())
            }
        } else { //竖屏时，会议时间放在会议名称的下边
            contentView.snp.updateConstraints() { make in
                make.top.equalToSuperview().offset(44.scale375Height())
            }
            timeLabel.snp.remakeConstraints { make in
                make.top.equalTo(meetingNameLabel.snp.bottom).offset(5)
                make.centerX.equalToSuperview()
            }
            meetingTitleView.snp.updateConstraints { make in
                make.width.equalTo(129.scale375())
                make.height.equalTo(44.scale375Height())
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
        localized("TUIRoom.sure.leave.room")
    }
    static var destroyRoomTitle: String {
        localized("TUIRoom.sure.destroy.room")
    }
    static var dismissMeetingTitle: String {
        localized("TUIRoom.dismiss.meeting.Title")
    }
    static var appointNewHostText: String {
        localized("TUIRoom.appoint.new.host")
    }
    static var leaveMeetingText: String {
        localized("TUIRoom.leave.meeting")
    }
    static var dismissMeetingText: String {
        localized("TUIRoom.dismiss.meeting")
    }
    static var cancelText: String {
        localized("TUIRoom.cancel")
    }
    static var exitText: String {
        localized("TUIRoom.exit")
    }
    static var quickMeetingText: String {
        localized("TUIRoom.video.conference")
    }
}

