//
//  ExitRoomView.swift
//  TUIRoomKit
//
//  Created by krabyu on 2023/8/23.
//

import Foundation
import TUIRoomEngine

class ExitRoomView: UIView {
    let viewModel: ExitRoomViewModel
    private var isViewReady: Bool = false
    var viewArray: [UIView] = []
    var currentUser: UserEntity {
        EngineManager.createInstance().store.currentUser
    }
    var roomInfo: TUIRoomInfo {
        EngineManager.createInstance().store.roomInfo
    }
    let dropView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x17181F)
        return view
    }()
    
    let dropImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "room_lineImage",in:tuiRoomKitBundle(),compatibleWith: nil)
        return view
    }()
    
    let headView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x17181F)
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = .leaveRoomTipText
        label.textColor = UIColor(0x7C85A6)
        label.font = UIFont(name: "PingFangSC-Regular", size: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let boundary1View: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x4F586B,alpha: 0.3)
        return view
    }()
    
    let leaveRoomButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(.leaveRoomText, for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 18)
        button.setTitleColor(UIColor(0x006CFF), for: .normal)
        button.backgroundColor = UIColor(0x17181F)
        button.isEnabled = true
        button.addTarget(self, action: #selector(leaveRoomAction), for: .touchUpInside)
        return button
    }()
    
    let boundary2View: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x4F586B,alpha: 0.3)
        return view
    }()
    
    let ExitRoomButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(.exitRoomText, for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 18)
        button.setTitleColor(UIColor(0xE5395C), for: .normal)
        button.backgroundColor = UIColor(0x17181F)
        button.isEnabled = true
        button.addTarget(self, action: #selector(exitRoomAction), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: ExitRoomViewModel) {
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
        boundary2View.isHidden = currentUser.userId != roomInfo.ownerId
        ExitRoomButton.isHidden = currentUser.userId != roomInfo.ownerId
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        roundedRect(rect: bounds,
                    byRoundingCorners: [.topLeft, .topRight],
                    cornerRadii: CGSize(width: 12, height: 12))
    }
    
    func constructViewHierarchy() {
        addSubview(dropView)
        addSubview(headView)
        addSubview(boundary1View)
        addSubview(leaveRoomButton)
        addSubview(boundary2View)
        addSubview(ExitRoomButton)
        dropView.addSubview(dropImageView)
        headView.addSubview(titleLabel)
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
        headView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25.scale375())
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(35.scale375())
        }
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(35.scale375())
        }
        boundary1View.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(68.scale375())
            make.centerX.equalToSuperview()
            make.height.equalTo(1.scale375())
            make.width.equalToSuperview()
        }
        leaveRoomButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(85.scale375())
            make.centerX.equalToSuperview()
            make.height.equalTo(25)
            make.width.equalToSuperview()
        }
        boundary2View.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(126.scale375())
            make.centerX.equalToSuperview()
            make.height.equalTo(1.scale375())
            make.width.equalToSuperview()
        }
        ExitRoomButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(143.scale375())
            make.centerX.equalToSuperview()
            make.height.equalTo(25.scale375())
            make.width.equalToSuperview()
        }
    }
    
    func bindInteraction() {
        backgroundColor = UIColor(0x1B1E26)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dropDownRoomInfoAction(sender:)))
        dropView.addGestureRecognizer(tap)
        dropView.isUserInteractionEnabled = true
    }
    
    @objc func dropDownRoomInfoAction(sender: UIView) {
        viewModel.dropDownAction(sender: sender)
    }
    
    @objc func leaveRoomAction(sender: UIView) {
        viewModel.leaveRoomAction(sender: sender)
    }
    
    @objc func exitRoomAction(sender: UIView) {
        viewModel.exitRoomAction(sender: sender)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var leaveRoomTipText: String {
        localized("TUIRoom.leave.room.tip" )
    }
    static var leaveRoomText: String {
        localized("TUIRoom.leave.room")
    }
    static var exitRoomText: String {
        localized("TUIRoom.dismiss.room")
    }
}
