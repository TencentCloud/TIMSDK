//
//  IntroduceRoomView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/3.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class RoomInfoView: UIView {
    let viewModel: RoomInfoViewModel
    private var isViewReady: Bool = false
    var viewArray: [UIView] = []
    
    let headView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x1B1E26)
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xD1D9EC)
        label.font = UIFont(name: "PingFangSC-Regular", size: 25)
        label.textAlignment = .left
        return label
    }()
    
    let codeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "room_message_code", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.isHidden = true
        return button
    }()
    
    let footerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x1B1E26)
        return view
    }()
    
    let inviteLabel: UILabel = {
        let label = UILabel()
        label.text = .inviteJoinRoomText
        label.textColor = UIColor(0x7C85A6)
        label.font = UIFont(name: "PingFangSC-Regular", size: 17)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
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
    
    init(viewModel: RoomInfoViewModel) {
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
        roundedRect(rect: bounds,
                    byRoundingCorners: [.topLeft, .topRight],
                    cornerRadii: CGSize(width: 12, height: 12))
    }
    
    func constructViewHierarchy() {
        addSubview(footerView)
        addSubview(stackView)
        addSubview(headView)
        headView.addSubview(nameLabel)
        headView.addSubview(codeButton)
        footerView.addSubview(inviteLabel)
    }
    
    func activateConstraints() {
        footerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(80.scale375())
            make.width.equalToSuperview()
        }
        inviteLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10.scale375())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.height.equalTo(20)
        }
        stackView.snp.makeConstraints { make in
            make.bottom.equalTo(footerView.snp.top)
            make.width.equalToSuperview()
        }
        headView.snp.makeConstraints { make in
            make.bottom.equalTo(stackView.snp.top)
            make.height.equalTo(50)
            make.width.equalToSuperview()
        }
        codeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.width.height.equalTo(24.scale375())
            make.centerY.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16.scale375())
            make.height.equalTo(30.scale375())
            make.right.equalTo(codeButton.snp.left).offset(-10.scale375())
        }
        for item in viewModel.messageItems {
            let view = ListCellItemView(itemData: item)
            viewArray.append(view)
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.height.equalTo(40.scale375())
                make.width.equalToSuperview()
            }
        }
    }
    
    func bindInteraction() {
        backgroundColor = UIColor(0x1B1E26)
        setupViewState(item: viewModel)
        codeButton.addTarget(self, action: #selector(codeAction(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: RoomInfoViewModel) {
        nameLabel.text = EngineManager.shared.store.roomInfo.name
    }
    
    @objc func codeAction(sender: UIButton) {
        viewModel.codeAction(sender: sender)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var inviteJoinRoomText: String {
        localized("TUIRoom.invite.join")
    }
}

