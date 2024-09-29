//
//  UserListView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/1/4.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import Factory
import Combine
import RTCRoomEngine

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
            searchBar.searchTextField.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        } else {
            if let textField = searchBar.value(forKey: "searchField") as? UITextField {
                textField.textColor = UIColor(0xB2BBD1)
                textField.tintColor = UIColor(0xB2BBD1).withAlphaComponent(0.3)
                textField.layer.cornerRadius = 6
                textField.font = UIFont.systemFont(ofSize: 14, weight: .medium)
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
    
    let listStateView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(0x4F586B).withAlphaComponent(0.3)
        view.layer.cornerRadius = 6
        return view
    }()
    
    let haveEnteredButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(0xD5E0F2), for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
        button.setBackgroundImage(UIColor(0xD5E0F2).withAlphaComponent(0.3).trans2Image(), for: .selected)
        button.setBackgroundImage(UIColor.clear.trans2Image(), for: .normal)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.isSelected = true
        return button
    }()
    
    let onStageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(0xD5E0F2), for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
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
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
        button.setBackgroundImage(UIColor(0xD5E0F2).withAlphaComponent(0.3).trans2Image(), for: .selected)
        button.setBackgroundImage(UIColor.clear.trans2Image(), for: .normal)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.isSelected = false
        return button
    }()
    
    let invatationListButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(0xD5E0F2), for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
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
    
    let callEveryoneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(.callEveryoneText, for: .normal)
        button.setTitleColor(UIColor(0xB2BBD1), for: .normal)
        button.backgroundColor = UIColor(0x4F586B)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.isHidden = true
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
    
    private lazy var invitationListPublisher = {
        conferenceStore.select(ConferenceInvitationSelectors.getInvitationList)
    }()
    
    var cancellableSet = Set<AnyCancellable>()
    
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
        addSubview(listStateView)
        listStateView.addSubview(haveEnteredButton)
        listStateView.addSubview(onStageButton)
        listStateView.addSubview(offStageButton)
        listStateView.addSubview(invatationListButton)
        addSubview(raiseHandNotificationView)
        addSubview(userListTableView)
        addSubview(bottomControlView)
        bottomControlView.addSubview(muteAllAudioButton)
        bottomControlView.addSubview(muteAllVideoButton)
        bottomControlView.addSubview(moreFunctionButton)
        addSubview(callEveryoneButton)
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
            make.trailing.equalToSuperview().offset(-16.scale375())
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
        listStateView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(15.scale375Height())
            make.leading.trailing.equalTo(searchBar)
            make.height.equalTo(36.scale375Height())
        }
        setupListStateView()
        bottomControlView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(84.scale375Height())
        }
        callEveryoneButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.bottom.equalToSuperview().offset(-34.scale375())
            make.height.equalTo(40.scale375Height())
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
            let aboveView = viewModel.isShownNotificationView ? raiseHandNotificationView : listStateView
            let bottomView = viewModel.userListType == .notInRoomUsers ? callEveryoneButton : bottomControlView
            make.top.equalTo(aboveView.snp.bottom).offset(15.scale375Height())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.bottom.equalTo(bottomView.snp.top)
        }
    }
    
    private func setupListStateView() {
        if viewModel.isSeatEnabled {
            onStageButton.snp.remakeConstraints { make in
                make.left.centerY.equalToSuperview()
                make.height.equalTo(32.scale375Height())
                make.width.equalToSuperview().multipliedBy(1.0 / 3.0)
            }
            offStageButton.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(onStageButton.snp.trailing)
                make.height.equalTo(32.scale375Height())
                make.width.equalToSuperview().multipliedBy(1.0 / 3.0)
            }
            invatationListButton.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(offStageButton.snp.trailing)
                make.height.equalTo(32.scale375Height())
                make.width.equalToSuperview().multipliedBy(1.0 / 3.0)
            }
        } else {
            haveEnteredButton.snp.remakeConstraints { make in
                make.left.centerY.equalToSuperview()
                make.height.equalTo(32.scale375Height())
                make.width.equalToSuperview().multipliedBy(0.5)
            }
            invatationListButton.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(haveEnteredButton.snp.trailing)
                make.height.equalTo(32.scale375Height())
                make.width.equalToSuperview().multipliedBy(0.5)
            }
        }
    }
    
    func bindInteraction() {
        viewModel.viewResponder = self
        setupViewState()
        searchBar.delegate = self
        muteAllAudioButton.addTarget(self, action: #selector(muteAllAudioAction), for: .touchUpInside)
        muteAllVideoButton.addTarget(self, action: #selector(muteAllVideoAction), for: .touchUpInside)
        moreFunctionButton.addTarget(self, action: #selector(moreFunctionAction), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideSearchControl(sender:)))
        searchControl.addGestureRecognizer(tap)
        haveEnteredButton.addTarget(self, action: #selector(selectAllUserAction(sender:)), for: .touchUpInside)
        onStageButton.addTarget(self, action: #selector(selectOnStageAction(sender:)), for: .touchUpInside)
        offStageButton.addTarget(self, action: #selector(selectOffStageAction(sender:)), for: .touchUpInside)
        invatationListButton.addTarget(self, action: #selector(selectInvitationListAction(sender:)), for: .touchUpInside)
        callEveryoneButton.addTarget(self, action: #selector(callEveryoneAction(sender:)), for: .touchUpInside)
        invitationListPublisher
            .receive(on: DispatchQueue.mainQueue)
            .sink { [weak self] invitationList in
                guard let self = self else { return }
                let oldList = viewModel.invitationList
                viewModel.invitationList = invitationList
                if viewModel.userListType == .notInRoomUsers {
                    self.updateInvitationTableView(oldList: oldList, newList: invitationList)
                    self.updateBottomControlView()
                }
                self.updateListStateView()
            }
            .store(in: &cancellableSet)
    }
    
    func setupViewState() {
        memberLabel.text = String(format: .memberText, viewModel.allUserCount)
        let roomInfo = viewModel.roomInfo
        muteAllAudioButton.isSelected = roomInfo.isMicrophoneDisableForAllUser
        muteAllVideoButton.isSelected = roomInfo.isCameraDisableForAllUser
        bottomControlView.isHidden = !viewModel.isShownBottomControlView
        setupListStateViewText()
    }
    
    private func setupListStateViewText() {
        if viewModel.isSeatEnabled {
            let seatedListText: String = localizedReplace(.onStageNumberText, replace: String(viewModel.onStageCount))
            onStageButton.setTitle(seatedListText, for: .normal)
            let offSeatListText: String = localizedReplace(.notOnStageNumberText, replace: String(viewModel.offStageCount))
            offStageButton.setTitle(offSeatListText, for: .normal)
        } else {
            let haveEnteredListText: String = localizedReplace(.haveEnterenRoomText, replace: String(viewModel.allUserCount))
            haveEnteredButton.setTitle(haveEnteredListText, for: .normal)
        }
        let invitationListText: String = localizedReplace(.notEnteredRoomText, replace: String(viewModel.invitationUserList.count))
        invatationListButton.setTitle(invitationListText, for: .normal)
    }
    
    private func updateBottomControlView() {
        if viewModel.userListType == .notInRoomUsers {
            bottomControlView.isHidden = true
            callEveryoneButton.isHidden = viewModel.invitationList.isEmpty
        } else {
            callEveryoneButton.isHidden = true
            bottomControlView.isHidden = !viewModel.isShownBottomControlView
        }
        setupUserListTableView()
    }
    
    @objc func muteAllAudioAction(sender: UIButton) {
        viewModel.muteAllAudioAction(sender: sender, view: self)
    }
    
    @objc func muteAllVideoAction(sender: UIButton) {
        viewModel.muteAllVideoAction(sender: sender, view: self)
    }
    
    @objc func moreFunctionAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .inviteViewType, height: 158.scale375Height())
    }
    
    @objc func hideSearchControl(sender: UIView) {
        if #available(iOS 13, *) {
            searchBar.searchTextField.resignFirstResponder()
        } else {
            searchBar.resignFirstResponder()
        }
        searchControl.isHidden = true
    }
    
    @objc func selectAllUserAction(sender: UIButton) {
        guard sender.isSelected != true else { return }
        sender.isSelected = true
        invatationListButton.isSelected = false
        viewModel.changeListState(type: .allUsers)
        updateBottomControlView()
    }
    
    @objc func selectOnStageAction(sender: UIButton) {
        guard sender.isSelected != true else { return }
        sender.isSelected = true
        offStageButton.isSelected = false
        invatationListButton.isSelected = false
        viewModel.changeListState(type: .onStageUsers)
        updateBottomControlView()
    }
    
    @objc func selectOffStageAction(sender: UIButton) {
        guard sender.isSelected != true else { return }
        sender.isSelected = true
        onStageButton.isSelected = false
        invatationListButton.isSelected = false
        viewModel.changeListState(type: .offStageUsers)
        updateBottomControlView()
    }
    
    @objc func selectInvitationListAction(sender: UIButton) {
        guard sender.isSelected != true else { return }
        sender.isSelected = true
        haveEnteredButton.isSelected = false
        onStageButton.isSelected = false
        offStageButton.isSelected = false
        viewModel.changeListState(type: .notInRoomUsers)
        updateBottomControlView()
    }
    
    @objc func callEveryoneAction(sender: UIButton) {
        let userIdsNeedtoCall = viewModel.invitationList
            .filter { $0.status != .pending }
            .map { $0.invitee.userId }
        conferenceStore.dispatch(action: ConferenceInvitationActions.inviteUsers(payload: (viewModel.roomInfo.roomId, userIdsNeedtoCall)))
    }
    
    func updateInvitationTableView(oldList: [TUIInvitation], newList: [TUIInvitation]) {
        let result = viewModel.compareLists(oldList: oldList, newList: newList)
        
        userListTableView.beginUpdates()
        for invitation in result.removed {
            if let index = oldList.firstIndex(where: { $0.invitee.userId == invitation.invitee.userId }) {
                userListTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                viewModel.attendeeList.remove(at: index)
            }
        }
        for invitation in result.added {
            viewModel.attendeeList.insert(UserEntity(invitation: invitation), at: 0)
            userListTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        for invitation in result.changed {
            if let index = oldList.firstIndex(where: { $0.invitee.userId == invitation.invitee.userId }) {
                if invitation.status == .rejected {
                    DispatchQueue.main.async {
                        if let cell = self.userListTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? UserListCell {
                            cell.showNotJoiningLabel()
                        }
                    }
                }
                userListTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
        userListTableView.endUpdates()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    @Injected(\.conferenceStore) private var conferenceStore
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
    
    func updateListStateView() {
        setupListStateViewText()
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
        localized("Users(%lld)")
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
    static var notEnteredRoomText: String {
        localized("Not Entered(xx)")
    }
    static var haveEnterenRoomText: String {
        localized("Entered(xx)")
    }
    static var callEveryoneText: String {
        localized("Call all")
    }
}
