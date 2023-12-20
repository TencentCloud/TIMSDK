//
//  MemberInviteView.swift
//  TUIRoomKit
//
//  Created by 于西巍 on 2023/8/21.
//  邀请页面
//

import Foundation

import TUIRoomEngine

class MemberInviteView: UIView {
    let viewModel: MemberInviteViewModel
    private var isViewReady: Bool = false
    var viewArray: [UIView] = []
    
    let headView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x1B1E26)
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = .inviteMemberText
        label.textColor = UIColor(0xD5E0F2)
        label.font = UIFont(name: "PingFangSC-Regular", size: 18)
        label.textAlignment = .left
        return label
    }()
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 0
        view.backgroundColor = UIColor(0x1B1E26)
        return view
    }()
    
    init(viewModel: MemberInviteViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = 12
    }
    
    func constructViewHierarchy() {
        addSubview(stackView)
        addSubview(headView)
        headView.addSubview(titleLabel)
    }
    
    func activateConstraints() {
        headView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(35.scale375())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.height.equalTo(25.scale375())
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(25.scale375())
            make.width.equalTo(182.scale375())
        }
        stackView.snp.makeConstraints { make in
            make.top.equalTo(headView.snp.bottom).offset(20.scale375())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.height.equalTo(56.scale375())
        }
        
        for item in viewModel.messageItems {
            let view = ListCellItemView(itemData: item)
            viewArray.append(view)
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.height.equalTo(20.scale375())
                make.width.equalToSuperview()
            }
        }
    }
    
    func bindInteraction() {
        backgroundColor = UIColor(0x1B1E26)
        viewModel.viewResponder = self
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension MemberInviteView: MemberInviteResponder {
    func showCopyToast(copyType: CopyType) {
        RoomRouter.makeToastInCenter(toast: copyType == .copyRoomIdType ?
            .copyRoomIdSuccess : .copyRoomLinkSuccess,duration: 0.5)
    }
}

private extension String {
    static var copyRoomIdSuccess: String {
        localized("TUIRoom.copy.roomId.success")
    }
    static var copyRoomLinkSuccess: String {
        localized("TUIRoom.copy.roomLink.success")
    }
    static var inviteMemberText: String {
        localized("TUIRoom.inviteMember")
    }
}
