//
//  InviteEnterRoomView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/7/5.
//

import Foundation
import Factory
import TUICore
import Combine

enum InviteEnterRoomViewStyle {
    case normal
    case inviteWhenSuccess
}

class InviteEnterRoomView: UIView {
    private var cancellableSet = Set<AnyCancellable>()
    var style: InviteEnterRoomViewStyle = .normal
    var title: String {
        if self.style == .normal {
            return .inviteMember
        } else {
            return .inviteWhenSuccess
        }
    }
    let conferenceInfo: ConferenceInfo
    lazy var menus = {
        InviteEnterRoomDataHelper.generateInviteEnterRoomHelperData(conferenceInfo: conferenceInfo, operation: operation)
    }()
    
    private let dropArrowButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "room_drop_arrow", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 10.scale375Height(), left: 20.scale375(), bottom: 20.scale375Height(), right: 20.scale375())
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.textColor = UIColor(0x4F586B)
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = isRTL ? .right : .left
        return label
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 10
        view.backgroundColor = .clear
        return view
    }()
    
    private let copyButton: UIButton = {
        let button = UIButton()
        button.setTitle(.copyRoomInformation, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(0x1C66E5), for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(0x1C66E5).cgColor
        return button
    }()
    
    init(conferenceInfo: ConferenceInfo, style: InviteEnterRoomViewStyle = .normal) {
        self.conferenceInfo = conferenceInfo
        self.style = style
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
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        backgroundColor = UIColor(0xFFFFFF)
        layer.cornerRadius = 14
    }
    
    private func constructViewHierarchy() {
        addSubview(dropArrowButton)
        addSubview(titleLabel)
        addSubview(stackView)
        addSubview(copyButton)
    }
    
    private func activateConstraints() {
        dropArrowButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dropArrowButton.snp.bottom)
            make.leading.equalToSuperview().offset(16.scale375())
        }
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20.scale375Height())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
        }
        copyButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.height.equalTo(44.scale375Height())
            make.top.equalTo(stackView.snp.bottom).offset(20.scale375Height())
            make.bottom.equalToSuperview().offset(-34.scale375Height())
        }
        
        for item in menus {
            let view = ListCellItemView(itemData: item)
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.height.equalTo(20.scale375Height())
                make.width.equalToSuperview()
            }
        }
    }
    
    private func bindInteraction() {
        subscribeToast()
        dropArrowButton.addTarget(self, action: #selector(dropAction(sender: )), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyAction(sender: )), for: .touchUpInside)
    }
    
    @objc func dropAction(sender: UIButton) {
        route.dismiss(animated: true)
    }
    
    @objc func copyAction(sender: UIButton) {
        var conferenceDetails = title
        menus.forEach { item in
            conferenceDetails = conferenceDetails +  "\n\(item.titleText) : \(item.messageText)"
        }
        UIPasteboard.general.string = conferenceDetails
        operation.dispatch(action: ViewActions.showToast(payload: ToastInfo(message: .roomInformationCopiedSuccessfully)))
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    @Injected(\.navigation) private var route
    @Injected(\.conferenceStore) private var operation
}


extension InviteEnterRoomView {
    private func subscribeToast() {
        operation.toastSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] toast in
                guard let self = self else { return }
                var position = TUICSToastPositionBottom
                switch toast.position {
                    case .center:
                        position = TUICSToastPositionCenter
                    default:
                        break
                }
                self.makeToast(toast.message, duration: toast.duration, position: position)
            }
            .store(in: &cancellableSet)
    }}

private extension String {
    static let inviteMember = localized("Invite members to join")
    static let inviteWhenSuccess = localized("Booking successful, invite members to join")
    static let copyRoomInformation = localized("Copy room information")
    static let roomInformationCopiedSuccessfully = localized("Room information copied successfully")
}
