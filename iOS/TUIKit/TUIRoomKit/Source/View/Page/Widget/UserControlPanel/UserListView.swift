//
//  UserListView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/1/4.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class UserListView: UIView {
    let viewModel: UserListViewModel
    
    let memberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xD5E0F2)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        return label
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = .searchMemberText
        searchBar.setBackgroundImage(UIColor(0x17181F).trans2Image(), for: .top, barMetrics: .default)
        if #available(iOS 13, *) {
            searchBar.searchTextField.textColor = UIColor(0xB2BBD1)
            searchBar.searchTextField.tintColor = UIColor(0xB2BBD1).withAlphaComponent(0.3)
            searchBar.searchTextField.layer.cornerRadius = 6
        } else {
            if let textField = searchBar.value(forKey: "searchField") as? UITextField {
                textField.textColor = UIColor(0xB2BBD1)
                textField.tintColor = UIColor(0xB2BBD1).withAlphaComponent(0.3)
                textField.layer.cornerRadius = 6
            }
        }

        return searchBar
    }()
    
    let searchControl: UIControl = {
        let view = UIControl()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    let inviteButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "room_invite_useInButton", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.setTitle(.inviteText, for: .normal)
        button.setTitleColor(UIColor(0x4791FF), for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
        button.backgroundColor = UIColor(0x17181F)
        button.layer.borderColor = UIColor(0x4791FF).cgColor
        button.layer.borderWidth = 1.scale375()
        button.layer.cornerRadius = 6
        return button
    }()
    
    let listStateView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(0x4F586B).withAlphaComponent(0.3)
        view.layer.cornerRadius = 6
        return view
    }()
    
    let onStageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(0xD5E0F2), for: .normal)
        button.setBackgroundImage(UIColor(0xD5E0F2).withAlphaComponent(0.3).trans2Image(), for: .selected)
        button.setBackgroundImage(UIColor.clear.trans2Image(), for: .normal)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.isSelected = true
        return button
    }()
    
    let offStageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(0xD5E0F2), for: .normal)
        button.setBackgroundImage(UIColor(0xD5E0F2).withAlphaComponent(0.3).trans2Image(), for: .selected)
        button.setBackgroundImage(UIColor.clear.trans2Image(), for: .normal)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.isSelected = false
        return button
    }()
    
    let muteAllAudioButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(.allMuteAudioText, for: .normal)
        button.setTitleColor(UIColor(0xB2BBD1), for: .normal)
        button.setTitle(.allUnMuteAudioText, for: .selected)
        button.setTitleColor(UIColor(0xF2504B), for: .selected)
        button.setTitle(.allUnMuteAudioText, for: [.selected, .highlighted])
        button.setTitleColor(UIColor(0xF2504B), for: [.selected, .highlighted])
        button.backgroundColor = UIColor(0x4F586B, alpha: 0.3)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    let muteAllVideoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(.allMuteVideoText, for: .normal)
        button.setTitleColor(UIColor(0xB2BBD1), for: .normal)
        button.setTitle(.allUnMuteVideoText, for: .selected)
        button.setTitleColor(UIColor(0xF2504B), for: .selected)
        button.setTitle(.allUnMuteVideoText, for: [.selected, .highlighted])
        button.setTitleColor(UIColor(0xF2504B), for: [.selected, .highlighted])
        button.backgroundColor = UIColor(0x4F586B, alpha: 0.3)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    let moreFunctionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(.moreText, for: .normal)
        button.setTitleColor(UIColor(0xB2BBD1), for: .normal)
        button.backgroundColor = UIColor(0x4F586B, alpha: 0.3)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    let bottomControlView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x17181F)
        return view
    }()
    
    lazy var userListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(0x17181F)
        tableView.register(UserListCell.self, forCellReuseIdentifier: "UserListCell")
        return tableView
    }()
    
    lazy var raiseHandNotificationView: RaiseHandApplicationNotificationView = {
        let viewModel = RaiseHandApplicationNotificationViewModel()
        viewModel.delayDisappearanceTime = 0
        let applicationNotificationView = RaiseHandApplicationNotificationView(viewModel: viewModel)
        applicationNotificationView.delegate = self.viewModel
        return applicationNotificationView
    }()
    
    init(viewModel: UserListViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        backgroundColor = UIColor(0x17181F)
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        addSubview(memberLabel)
        addSubview(searchBar)
        addSubview(inviteButton)
        addSubview(listStateView)
        listStateView.addSubview(onStageButton)
        listStateView.addSubview(offStageButton)
        addSubview(raiseHandNotificationView)
        addSubview(userListTableView)
        addSubview(bottomControlView)
        bottomControlView.addSubview(muteAllAudioButton)
        bottomControlView.addSubview(muteAllVideoButton)
        bottomControlView.addSubview(moreFunctionButton)
        addSubview(searchControl)
    }
    
    func activateConstraints() {
        memberLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10.scale375Height())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.height.equalTo(24.scale375Height())
        }
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(memberLabel.snp.bottom).offset(18.scale375Height())
            make.leading.equalToSuperview().offset(16.scale375())
            make.width.equalTo(263.scale375())
            make.height.equalTo(36.scale375Height())
        }
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
                searchField.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        }
        inviteButton.snp.makeConstraints { make in
            make.top.height.equalTo(searchBar)
            make.leading.equalTo(searchBar.snp.trailing).offset(12.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
        }
        listStateView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(15.scale375Height())
            make.leading.equalTo(searchBar)
            make.trailing.equalTo(inviteButton)
            make.height.equalTo(36.scale375Height())
        }
        onStageButton.snp.makeConstraints { make in
            make.leading.top.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        offStageButton.snp.makeConstraints { make in
            make.trailing.top.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        bottomControlView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(84.scale375Height())
        }
        raiseHandNotificationView.snp.makeConstraints { make in
            make.top.equalTo(listStateView.snp.bottom).offset(10.scale375Height())
            make.leading.equalToSuperview().offset(8.scale375())
            make.trailing.equalToSuperview().offset(-8.scale375())
            make.height.equalTo(40.scale375Height())
        }
        setupUserListTableView()
        muteAllAudioButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10.scale375Height())
            make.leading.equalToSuperview().offset(16.scale375())
            make.width.equalTo(108.scale375())
            make.height.equalTo(40.scale375())
        }
        muteAllVideoButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10.scale375Height())
            make.leading.equalToSuperview().offset(133.scale375())
            make.width.equalTo(108.scale375())
            make.height.equalTo(40.scale375())
        }
        moreFunctionButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10.scale375Height())
            make.leading.equalToSuperview().offset(250.scale375())
            make.width.equalTo(108.scale375())
            make.height.equalTo(40.scale375())
        }
        searchControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupUserListTableView() {
        guard userListTableView.superview != nil else { return }
        userListTableView.snp.remakeConstraints { make in
            let aboveView = viewModel.isShownNotificationView ? raiseHandNotificationView : viewModel.isShownListStateView ? listStateView : searchBar
            make.top.equalTo(aboveView.snp.bottom).offset(15.scale375Height())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.bottom.equalTo(bottomControlView.snp.top)
        }
    }
    
    func bindInteraction() {
        viewModel.viewResponder = self
        setupViewState()
        searchBar.delegate = self
        inviteButton.addTarget(self, action: #selector(inviteMemberAction), for: .touchUpInside)
        muteAllAudioButton.addTarget(self, action: #selector(muteAllAudioAction), for: .touchUpInside)
        muteAllVideoButton.addTarget(self, action: #selector(muteAllVideoAction), for: .touchUpInside)
        moreFunctionButton.addTarget(self, action: #selector(moreFunctionAction), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideSearchControl(sender:)))
        searchControl.addGestureRecognizer(tap)
        onStageButton.addTarget(self, action: #selector(selectOnStageAction(sender:)), for: .touchUpInside)
        offStageButton.addTarget(self, action: #selector(selectOffStageAction(sender:)), for: .touchUpInside)
    }
    
    func setupViewState() {
        memberLabel.text = String(format: .memberText, viewModel.allUserCount)
        let roomInfo = viewModel.roomInfo
        muteAllAudioButton.isSelected = roomInfo.isMicrophoneDisableForAllUser
        muteAllVideoButton.isSelected = roomInfo.isCameraDisableForAllUser
        bottomControlView.isHidden = !viewModel.isShownBottomControlView
        listStateView.isHidden = !viewModel.isShownListStateView
        setupListStateView(onStage: viewModel.onStageCount, offStage: viewModel.offStageCount)
    }
    
    private func setupListStateView(onStage: Int, offStage: Int) {
        guard viewModel.isShownListStateView else { return }
        let seatedListText: String = localizedReplace(.onStageNumberText, replace: String(onStage))
        onStageButton.setTitle(seatedListText, for: .normal)
        let offSeatListText: String = localizedReplace(.notOnStageNumberText, replace: String(offStage))
        offStageButton.setTitle(offSeatListText, for: .normal)
    }
    
    @objc func inviteMemberAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .inviteViewType, height: 186)
    }
    
    @objc func muteAllAudioAction(sender: UIButton) {
        viewModel.muteAllAudioAction(sender: sender, view: self)
    }
    
    @objc func muteAllVideoAction(sender: UIButton) {
        viewModel.muteAllVideoAction(sender: sender, view: self)
    }
    
    @objc func moreFunctionAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .inviteViewType, height: 186)
    }
    
    @objc func hideSearchControl(sender: UIView) {
        if #available(iOS 13, *) {
            searchBar.searchTextField.resignFirstResponder()
        } else {
            searchBar.resignFirstResponder()
        }
        searchControl.isHidden = true
    }
    
    @objc func selectOnStageAction(sender: UIButton) {
        guard sender.isSelected != true else { return }
        sender.isSelected = true
        offStageButton.isSelected = false
        viewModel.changeListState(isOnStage: true)
    }
    
    @objc func selectOffStageAction(sender: UIButton) {
        guard sender.isSelected != true else { return }
        sender.isSelected = true
        onStageButton.isSelected = false
        viewModel.changeListState(isOnStage: false)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension UserListView: UISearchBarDelegate {
    func searchBar(_ searchBar:UISearchBar,textDidChange searchText:String){
        let searchContentText = searchText.trimmingCharacters(in: .whitespaces)
        viewModel.searchText = searchContentText
        viewModel.isSearching = searchContentText.count != 0
        viewModel.updateAttendeeList()
        userListTableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchControl.isHidden = false
        return true
    }
}

extension UserListView: UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.attendeeList.count
    }
}

extension UserListView: UITableViewDelegate {
    internal func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attendeeModel = viewModel.attendeeList[indexPath.row]
        let cell = UserListCell(attendeeModel: attendeeModel, viewModel: viewModel)
        cell.selectionStyle = .none
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let attendeeModel = viewModel.attendeeList[indexPath.row]
        viewModel.showUserManageViewAction(userId: attendeeModel.userId, userName: attendeeModel.userName)
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.scale375Height()
    }
}

extension UserListView: UserListViewResponder {
    func updateUserListTableView() {
        setupUserListTableView()
    }
    
    func updateMemberLabel(count: Int) {
        memberLabel.text = String(format: .memberText, viewModel.allUserCount)
    }
    
    func updateListStateView(onStage: Int, offStage: Int) {
        setupListStateView(onStage: onStage, offStage: offStage)
    }
    
    func updateMuteAllAudioButtonState(isSelect: Bool) {
        muteAllAudioButton.isSelected = isSelect
    }
    
    func updateMuteAllVideoButtonState(isSelect: Bool) {
        muteAllVideoButton.isSelected = isSelect
    }
    
    func updateBottomControlView(isHidden: Bool) {
        bottomControlView.isHidden = isHidden
    }
    
    func updateUserManagerViewDisplayStatus(isHidden: Bool) {
        let model = UserListManagerViewModel(selectUserId: viewModel.userId)
        let view = UserListManagerView(viewModel: model)
        view.show(rootView: self)
    }
    
    func makeToast(text: String) {
        RoomRouter.makeToastInCenter(toast: text, duration: 0.5)
    }
    
    func reloadUserListView() {
        userListTableView.reloadData()
    }
    
    func showAlert(title: String?, message: String?, sureTitle: String?, declineTitle: String?, sureBlock: (() -> ())?, declineBlock: (() -> ())?) {
        RoomRouter.presentAlert(title: title, message: message, sureTitle: sureTitle, declineTitle: declineTitle, sureBlock: sureBlock, declineBlock: declineBlock)
    }
}

private extension String {
    static var inviteText: String {
        localized("Invite")
    }
    static var allMuteAudioText: String {
        localized("Mute All")
    }
    static var allMuteVideoText: String {
        localized("Stop all video")
    }
    static var allUnMuteAudioText: String {
        localized("Unmute all")
    }
    static var allUnMuteVideoText: String {
        localized("Enable all video")
    }
    static var moreText: String {
        localized("More")
    }
    static var memberText: String {
        localized("Participants(%lld)")
    }
    static var searchMemberText: String {
        localized("Search for participants")
    }
    static var onStageNumberText: String {
        localized("On stage(xx)")
    }
    static var notOnStageNumberText: String {
        localized("Not on stage(xx)")
    }
}
