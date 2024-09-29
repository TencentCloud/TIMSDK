//
//  ConferenceInvitationViewController.swift
//  TUIRoomKit
//
//  Created by jeremiawang on 2024/8/6.
//

import Foundation
import RTCRoomEngine
import UIKit
import Combine
import Factory

class ConferenceInvitationViewController: UIViewController {
    private var cancellableSet = Set<AnyCancellable>()
    var roomInfo: TUIRoomInfo
    var invitation: TUIInvitation
    
    init(roomInfo: TUIRoomInfo, invitation: TUIInvitation) {
        self.roomInfo = roomInfo
        self.invitation = invitation
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var shouldAutorotate: Bool {
        return false
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.alpha = 0.2
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        return avatarImageView
    }()
    
    private let inviteLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "PingFangSC-Regular", size: 14)
        return label
    }()
    
    private let conferenceNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "PingFangSC-Regular", size: 14)
        return label
    }()
    
    private let joinSliderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 39.scale375()
        return view
    }()
    
    private let joinLabel: UILabel = {
        let label = UILabel()
        label.text = .joinNowText
        label.textColor = .white.withAlphaComponent(0.8)
        label.font = UIFont(name: "PingFangSC-Medium", size: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let sliderThumbView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.tui_color(withHex: "1C66E5")
        view.layer.cornerRadius = 32
        return view
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "room_rightlink_arrow", in: tuiRoomKitBundle(), compatibleWith: nil)
        imageView.tintColor = .white
        return imageView
    }()
    
    private let declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(.notEnterText, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.8), for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 16)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        initState()
        initializeData()
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        operation.select(ViewSelectors.getDismissInvitationFlag)
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] shouldDismissInvitation in
                guard let self = self else { return }
                if shouldDismissInvitation {
                    InvitationObserverService.shared.dismissInvitationWindow()
                }
            }
            .store(in: &cancellableSet)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    private func initState() {
        self.operation.dispatch(action: InvitationViewActions.resetInvitationFlag())
    }
    
    private func constructViewHierarchy() {
        view.addSubview(backgroundImageView)
        view.addSubview(avatarImageView)
        view.addSubview(inviteLabel)
        view.addSubview(conferenceNameLabel)
        view.addSubview(detailsLabel)
        view.addSubview(joinSliderView)
        joinSliderView.addSubview(joinLabel)
        joinSliderView.addSubview(sliderThumbView)
        sliderThumbView.addSubview(arrowImageView)
        view.addSubview(declineButton)
    }
    
    private func activateConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.width.equalTo(50.scale375())
            make.top.equalToSuperview().offset(150.scale375Height())
        }
        inviteLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
        }
        conferenceNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(300.scale375())
            make.top.equalTo(inviteLabel.snp.bottom).offset(30)
        }
        detailsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(conferenceNameLabel.snp.bottom).offset(10)
        }
        declineButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-94.scale375Height())
        }
        joinSliderView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(200.scale375())
            make.height.equalTo(78.scale375())
            make.bottom.equalTo(declineButton.snp.top).offset(-30)
        }
        joinLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(32.scale375())
        }
        sliderThumbView.snp.makeConstraints { make in
            make.left.equalTo(joinSliderView.snp.left).offset(5)
            make.centerY.equalTo(joinSliderView.snp.centerY)
            make.width.height.equalTo(64.scale375())
        }
        arrowImageView.snp.makeConstraints { make in
            make.center.equalTo(sliderThumbView)
            make.width.height.equalTo(20.scale375())
        }
    }
    
    private func bindInteraction() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        sliderThumbView.addGestureRecognizer(panGesture)
        declineButton.addTarget(self, action: #selector(rejectAction), for: .touchUpInside)
    }
    
    private func initializeData() {
        inviteLabel.text = invitation.inviter.userName + .inviteJoinConferenceText
        conferenceNameLabel.text = roomInfo.name
        detailsLabel.text = .hostText + roomInfo.ownerName + " | " + .participantText + String(roomInfo.memberCount)
        
        let placeholder = UIImage(named: "room_default_user", in: tuiRoomKitBundle(), compatibleWith: nil)
        if let url = URL(string: invitation.inviter.avatarUrl) {
            avatarImageView.sd_setImage(with: url, placeholderImage: placeholder)
            backgroundImageView.sd_setImage(with: url, placeholderImage: placeholder)
        } else {
            avatarImageView.image = placeholder
            backgroundImageView.image = placeholder
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: joinSliderView)
        let maxTranslation = joinSliderView.frame.width - sliderThumbView.frame.width - 10

        switch gesture.state {
            case .changed:
                if translation.x >= 0 && translation.x <= maxTranslation {
                    sliderThumbView.snp.updateConstraints { make in
                        make.left.equalTo(joinSliderView.snp.left).offset(5 + translation.x)
                    }
                }
            case .ended:
                if translation.x >= maxTranslation {
                    sliderThumbView.snp.updateConstraints { make in
                        make.left.equalTo(joinSliderView.snp.left).offset(5 + maxTranslation)
                    }
                    gesture.isEnabled = false
                    self.acceptAction()
                } else {
                    sliderThumbView.snp.updateConstraints { make in
                        make.left.equalTo(joinSliderView.snp.left).offset(5)
                    }
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                    }
                }
            default:
                break
        }
    }
    
    private func acceptAction() {
        operation.dispatch(action: ConferenceInvitationActions.accept(payload: roomInfo.roomId))
    }
    
    @objc func rejectAction() {
        operation.dispatch(action: InvitationViewActions.dismissInvitationView())
        operation.dispatch(action: ConferenceInvitationActions.reject(payload: (roomInfo.roomId, .rejectToEnter)))
    }
    
    @Injected(\.navigation) var route
    @Injected(\.conferenceStore) var operation
}

private extension String {
    static var inviteJoinConferenceText: String {
        localized(" invite you to join the conference")
    }
    static var hostText: String {
        localized("Conference Host")
    }
    static var participantText: String {
        localized("Participant")
    }
    static var peopleText: String {
        localized("People")
    }
    static var joinNowText: String {
        localized("Join now")
    }
    static var notEnterText: String {
        localized("Do not enter for now")
    }
}
