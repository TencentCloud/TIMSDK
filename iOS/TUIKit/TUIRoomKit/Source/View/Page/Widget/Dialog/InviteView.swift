//
//  InviteView.swift
//  TUIRoomKit
//
//  Created by jeremiawang on 2024/8/26.
//

import Foundation
import Factory

class InviteView: UIView {
    private var isViewReady: Bool = false
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .fillEqually
        view.spacing = 0
        return view
    }()
    
    private lazy var addUserView: ButtonItemView = {
        let item = ButtonItemData()
        item.normalTitle = .addUserText
        item.normalIcon = "room_add_user"
        item.resourceBundle = tuiRoomKitBundle()
        item.buttonType = .muteAudioItemType
        item.hasLineView = true
        return ButtonItemView(itemData: item)
    }()
    
    private lazy var inviteToJoinView: ButtonItemView = {
        let item = ButtonItemData()
        item.normalTitle = .shareRoomText
        item.normalIcon = "room_invite_to_join"
        item.resourceBundle = tuiRoomKitBundle()
        item.buttonType = .muteVideoItemType
        item.hasLineView = true
        return ButtonItemView(itemData: item)
    }()
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = 16
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    private func constructViewHierarchy() {
        addSubview(stackView)
        stackView.addArrangedSubview(addUserView)
        stackView.addArrangedSubview(inviteToJoinView)
    }
    
    func activateConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.bottom.equalToSuperview().offset(-34.scale375Height())
        }
        addUserView.snp.makeConstraints { make in
                make.height.equalTo(53.scale375())
                make.width.equalToSuperview()
        }
        inviteToJoinView.snp.makeConstraints { make in
                make.height.equalTo(53.scale375())
                make.width.equalToSuperview()
        }
    }
    
    func bindInteraction() {
        addUserView.itemData.action = { sender in
            self.conferenceStore.dispatch(action: InvitationViewActions.showInvitationPopupView())
            RoomRouter.shared.dismissPopupViewController()
        }
        inviteToJoinView.itemData.action = { sender in
            RoomRouter.shared.presentPopUpViewController(viewType: .inviteMemberViewType, height: 290.scale375Height())
        }
    }
    
    @Injected(\.navigation) private var route
    @Injected(\.conferenceStore) var conferenceStore: ConferenceStore
}

private extension String {
    static var addUserText: String {
        localized("Add user")
    }
    static var shareRoomText: String {
        localized("Share room")
    }
}
