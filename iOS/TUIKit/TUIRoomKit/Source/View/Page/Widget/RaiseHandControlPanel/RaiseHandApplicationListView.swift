//
//  RaiseHandApplicationListView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class RaiseHandApplicationListView: UIView {
    let viewModel: RaiseHandApplicationListViewModel
    private var isSearching: Bool = false
    
    let backButton: UIButton = {
        let button = UIButton()
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = isRTL ? .right : .left
        button.setTitleColor(UIColor(0xADB6CC), for: .normal)
        let image = UIImage(named: "room_back_white", in: tuiRoomKitBundle(), compatibleWith: nil)?.checkOverturn()
        button.setImage(image, for: .normal)
        button.setTitle(.videoConferenceTitle, for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 18)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        return button
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = .searchMemberText
        searchBar.setBackgroundImage(UIColor(0x1B1E26).trans2Image(), for: .top, barMetrics: .default)
        searchBar.searchTextField.textColor = UIColor(0xB2BBD1)
        searchBar.searchTextField.tintColor = UIColor(0xB2BBD1).withAlphaComponent(0.3)
        searchBar.searchTextField.layer.cornerRadius = 6
        return searchBar
    }()
    
    let searchControl: UIControl = {
        let view = UIControl()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    let allAgreeButton : UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(.agreeAllText, for: .normal)
        button.setTitleColor(UIColor(0xADB6CC), for: .normal)
        button.backgroundColor = UIColor(0x292D38)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    let inviteMemberButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(.inviteMembersText, for: .normal)
        button.setTitleColor(UIColor(0xADB6CC), for: .normal)
        button.backgroundColor = UIColor(0x292D38)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    lazy var applyTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(0x1B1E26)
        tableView.register(UserListCell.self, forCellReuseIdentifier: "RaiseHandCell")
        return tableView
    }()
    
    init(viewModel: RaiseHandApplicationListViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = UIColor(0x1B1E26)
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(backButton)
        addSubview(searchBar)
        addSubview(applyTableView)
        addSubview(allAgreeButton)
        addSubview(inviteMemberButton)
        addSubview(searchControl)
    }
    
    func activateConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.height.equalTo(20)
            make.width.equalTo(200)
        }
        searchBar.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.height.equalTo(34.scale375Height())
            make.top.equalTo(backButton.snp.bottom).offset(23.scale375Height())
        }
        applyTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.top.equalTo(searchBar.snp.bottom).offset(10.scale375Height())
            make.bottom.equalToSuperview()
        }
        allAgreeButton.snp.makeConstraints { make in
            make.trailing.equalTo(snp.centerX).offset(-10)
            make.bottom.equalToSuperview().offset(-40 - kDeviceSafeBottomHeight)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(30)
        }
        inviteMemberButton.snp.remakeConstraints { make in
            make.leading.equalTo(snp.centerX).offset(10)
            make.bottom.equalTo(allAgreeButton)
            make.height.equalTo(50)
            make.trailing.equalToSuperview().offset(-30)
        }
        searchControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bindInteraction() {
        viewModel.viewResponder = self
        searchBar.delegate = self
        setupViewState()
        backButton.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        allAgreeButton.addTarget(self, action: #selector(allAgreeStageAction(sender:)), for: .touchUpInside)
        inviteMemberButton.addTarget(self, action: #selector(inviteMemberAction(sender:)), for: .touchUpInside)
        searchBar.setBackgroundImage(UIColor(0x1B1E26).trans2Image(), for: .top, barMetrics: .default)
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideSearchControl(sender:)))
        searchControl.addGestureRecognizer(tap)
    }
    
    @objc func backAction(sender: UIButton) {
        searchBar.endEditing(true)
        searchBar.searchTextField.resignFirstResponder()
        viewModel.backAction()
    }
    
    @objc func allAgreeStageAction(sender: UIButton) {
        viewModel.allAgreeStageAction(sender: sender, view: self)
    }
    
    @objc func inviteMemberAction(sender: UIButton) {
        viewModel.inviteMemberAction(sender: sender, view: self)
    }
    
    @objc func hideSearchControl(sender: UIView) {
        searchBar.searchTextField.resignFirstResponder()
        searchControl.isHidden = true
    }
    
    private func setupViewState() {
        let currentUser = viewModel.engineManager.store.currentUser
        let roomInfo = viewModel.engineManager.store.roomInfo
        allAgreeButton.isSelected = roomInfo.isMicrophoneDisableForAllUser
        inviteMemberButton.isSelected = roomInfo.isCameraDisableForAllUser
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension RaiseHandApplicationListView: UISearchBarDelegate {
    func searchBar(_ searchBar:UISearchBar,textDidChange searchText:String){
        let searchContentText = searchText.trimmingCharacters(in: .whitespaces)
        if searchContentText.count == 0 {
            viewModel.inviteSeatList = viewModel.engineManager.store.inviteSeatList
            applyTableView.reloadData()
            isSearching = false
        } else {
            let searchArray = viewModel.engineManager.store.inviteSeatList.filter({ model -> Bool in
                return model.userName.contains(searchContentText)
            })
            viewModel.inviteSeatList = searchArray
            applyTableView.reloadData()
            isSearching = true
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchControl.isHidden = false
        return true
    }
}

extension RaiseHandApplicationListView: UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.inviteSeatList.count
    }
}

extension RaiseHandApplicationListView: UITableViewDelegate {
    internal func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attendeeModel = viewModel.inviteSeatList[indexPath.row]
        let cell = ApplyTableCell(attendeeModel: attendeeModel, viewModel: viewModel)
        cell.selectionStyle = .none
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.endEditing(true)
        searchBar.searchTextField.resignFirstResponder()
    }
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.scale375()
    }
}

extension RaiseHandApplicationListView: RaiseHandApplicationListViewResponder {
    func searchControllerChangeActive(isActive: Bool) {
        searchBar.endEditing(!isActive)
        searchBar.searchTextField.resignFirstResponder()
    }
    
    func reloadApplyListView() {
        guard !isSearching else { return }
        applyTableView.reloadData()
    }
    
    func makeToast(text: String) {
        RoomRouter.makeToastInCenter(toast: text, duration: 1)
    }
}

class ApplyTableCell: UITableViewCell {
    let attendeeModel: UserEntity
    let viewModel: RaiseHandApplicationListViewModel
    
    let avatarImageView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = 20
        img.layer.masksToBounds = true
        return img
    }()
    
    let userLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xD1D9EC)
        label.backgroundColor = UIColor.clear
        label.textAlignment = isRTL ? .right : .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    let muteAudioButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "room_mic_on", in: tuiRoomKitBundle(), compatibleWith: nil)?.checkOverturn(), for: .normal)
        button.setImage(UIImage(named: "room_mic_off", in: tuiRoomKitBundle(), compatibleWith: nil)?.checkOverturn(), for: .selected)
        return button
    }()
    
    let muteVideoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "room_camera_on", in: tuiRoomKitBundle(), compatibleWith: nil)?.checkOverturn(), for: .normal)
        button.setImage(UIImage(named: "room_camera_off", in: tuiRoomKitBundle(), compatibleWith: nil)?.checkOverturn(), for: .selected)
        return button
    }()
    
    let agreeStageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(0x0565FA)
        button.setTitle(.agreeSeatText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        return button
    }()
    
    let disagreeStageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .red
        button.setTitle(.disagreeSeatText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        return button
    }()
    
    let downLineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x2A2D38)
        return view
    }()
    
    init(attendeeModel: UserEntity ,viewModel: RaiseHandApplicationListViewModel) {
        self.attendeeModel = attendeeModel
        self.viewModel = viewModel
        super.init(style: .default, reuseIdentifier: "UserListCell")
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
        contentView.addSubview(muteAudioButton)
        contentView.addSubview(muteVideoButton)
        contentView.addSubview(agreeStageButton)
        contentView.addSubview(disagreeStageButton)
        contentView.addSubview(downLineView)
    }
    
    func activateConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        muteVideoButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalTo(self.avatarImageView)
        }
        muteAudioButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.trailing.equalTo(self.muteVideoButton.snp.leading).offset(-12)
            make.centerY.equalTo(self.avatarImageView)
        }
        disagreeStageButton.snp.makeConstraints { make in
            make.width.equalTo(62.scale375())
            make.height.equalTo(24.scale375Height())
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.avatarImageView)
        }
        agreeStageButton.snp.makeConstraints { make in
            make.trailing.equalTo(disagreeStageButton.snp.leading).offset(-10)
            make.centerY.equalTo(disagreeStageButton)
            make.width.height.equalTo(64.scale375())
            make.height.equalTo(24.scale375Height())
        }
        userLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12.scale375())
            make.width.equalTo(150.scale375())
            make.height.equalTo(22.scale375())
        }
        downLineView.snp.makeConstraints { make in
            make.leading.equalTo(userLabel)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1.scale375())
        }
    }
    
    func bindInteraction() {
        backgroundColor = UIColor(0x1B1E26)
        setupViewState(item: attendeeModel)
        agreeStageButton.addTarget(self, action: #selector(agreeStageAction(sender:)), for: .touchUpInside)
        disagreeStageButton.addTarget(self, action: #selector(disagreeStageAction(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: UserEntity) {
        let placeholder = UIImage(named: "room_default_user", in: tuiRoomKitBundle(), compatibleWith: nil)
        if let url = URL(string: item.avatarUrl) {
            avatarImageView.sd_setImage(with: url, placeholderImage: placeholder)
        } else {
            avatarImageView.image = placeholder
        }
        if item.userId == viewModel.roomInfo.ownerId {
            userLabel.text = item.userName + "(" + .meText + ")"
        } else {
            userLabel.text = item.userName
        }
        muteAudioButton.isSelected = !item.hasAudioStream
        muteVideoButton.isSelected = !item.hasVideoStream
        if item.isOnSeat {
            agreeStageButton.isHidden = true
            disagreeStageButton.isHidden = true
            muteAudioButton.isHidden = false
            muteVideoButton.isHidden = false
        } else {
            agreeStageButton.isHidden = false
            disagreeStageButton.isHidden = false
            muteAudioButton.isHidden = true
            muteVideoButton.isHidden = true
        }
    }
    
    @objc func agreeStageAction(sender: UIButton) {
        viewModel.agreeStageAction(sender: sender, isAgree: true, userId: attendeeModel.userId)
    }
    
    @objc func disagreeStageAction(sender: UIButton) {
        viewModel.agreeStageAction(sender: sender, isAgree: false, userId: attendeeModel.userId)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var searchMemberText: String {
        localized("TUIRoom.search.meeting.member")
    }
    static var agreeAllText: String {
        localized("TUIRoom.agree.all")
    }
    static var inviteMembersText: String {
        localized("TUIRoom.invite.members")
    }
    static var agreeSeatText: String {
        localized("TUIRoom.agree.seat")
    }
    static var disagreeSeatText: String {
        localized("TUIRoom.disagree.seat")
    }
    static var meText: String {
        localized("TUIRoom.me")
    }
    static var videoConferenceTitle: String {
        localized("TUIRoom.video.conference.title")
    }
}
