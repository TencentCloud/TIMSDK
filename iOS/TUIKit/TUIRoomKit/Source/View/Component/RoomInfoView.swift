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
    
    let dropView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x1B1E26)
        return view
    }()
    
    let dropImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "room_lineImage",in:tuiRoomKitBundle(),compatibleWith: nil)
        return view
    }()
    
    let headView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x1B1E26)
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xD5E0F2)
        label.font = UIFont(name: "PingFangSC-Regular", size: 18)
        label.textAlignment = isRTL ? .right : .left
        return label
    }()
    
    let codeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "room_message_code", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.isHidden = true
        return button
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
        backgroundColor = UIColor(0x1B1E26)
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
        addSubview(dropView)
        addSubview(stackView)
        addSubview(headView)
        dropView.addSubview(dropImageView)
        headView.addSubview(nameLabel)
        headView.addSubview(codeButton)
    }
    
    func activateConstraints() {
        dropView.snp.makeConstraints{ make in
            make.top.equalToSuperview()
            make.height.equalTo(15.scale375())
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
        }
        dropImageView.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12.scale375())
            make.width.equalTo(24.scale375())
            make.height.equalTo(3.scale375())
        }
        stackView.snp.makeConstraints { make in
            make.top.equalTo(headView.snp.bottom).offset(20.scale375())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.height.equalTo(128.scale375())
        }
        headView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(35.scale375())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.height.equalTo(25.scale375())
        }
        codeButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(25.scale375())
            make.width.equalTo(68.scale375())
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(25.scale375())
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
        setupViewState(item: viewModel)
        codeButton.addTarget(self, action: #selector(codeAction(sender:)), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dropDownRoomInfoAction(sender:)))
        dropView.addGestureRecognizer(tap)
        dropView.isUserInteractionEnabled = true
        viewModel.viewResponder = self
    }
    
    func setupViewState(item: RoomInfoViewModel) {
        nameLabel.text = EngineManager.createInstance().store.roomInfo.name + .quickMeetingText
    }
    
    @objc func dropDownRoomInfoAction(sender: UIView) {
        viewModel.dropDownAction(sender: sender)
    }
    
    @objc func codeAction(sender: UIButton) {
        viewModel.codeAction(sender: sender)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension RoomInfoView: RoomInfoResponder {
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
    static var quickMeetingText: String {
        localized("TUIRoom.video.conference")
    }
}

