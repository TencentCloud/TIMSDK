//
//  ExitRoomView.swift
//  TUIRoomKit
//
//  Created by krabyu on 2023/8/23.
//

import Foundation
import TUIRoomEngine

class ExitRoomView: UIView {
    private let viewModel: ExitRoomViewModel
    private var isViewReady: Bool = false
    var currentUser: UserEntity {
        EngineManager.createInstance().store.currentUser
    }
    var roomInfo: TUIRoomInfo {
        EngineManager.createInstance().store.roomInfo
    }
    
    let panelControl : UIControl = {
        let control = UIControl()
        control.backgroundColor = .clear
        return control
    }()
    
    let contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(0x17181F)
        view.layer.cornerRadius = 12
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0x7C85A6)
        label.font = UIFont(name: "PingFangSC-Regular", size: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = viewModel.isShownDestroyRoomButton() && viewModel.isShownLeaveRoomButton() ? .appointOwnerText : .leaveRoomTipText
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
        return button
    }()
    
    let boundary2View: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x4F586B,alpha: 0.3)
        return view
    }()
    
    let destroyRoomButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(.exitRoomText, for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 18)
        button.setTitleColor(UIColor(0xE5395C), for: .normal)
        button.backgroundColor = UIColor(0x17181F)
        button.isEnabled = true
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
    }
    
    func constructViewHierarchy() {
        addSubview(panelControl)
        addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(boundary1View)
        contentView.addSubview(leaveRoomButton)
        contentView.addSubview(boundary2View)
        contentView.addSubview(destroyRoomButton)
    }
    
    func activateConstraints() {
        let titleLabelHeight = 67.scale375Height()
        let leaveRoomButtonHeight = viewModel.isShownLeaveRoomButton() ? 57.scale375Height() : 0
        let destroyRoomButtonHeight = currentUser.userId == roomInfo.ownerId ? 57.scale375Height() : 0
        let space = 20.scale375Height()
        let contentViewHeight = titleLabelHeight + leaveRoomButtonHeight + destroyRoomButtonHeight + space
        panelControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.height.equalTo(contentViewHeight)
            make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
            make.leading.equalTo(safeAreaLayoutGuide.snp.leading)
            make.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(titleLabelHeight)
        }
        boundary1View.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(1.scale375Height())
            make.leading.trailing.equalToSuperview()
        }
        leaveRoomButton.snp.makeConstraints { make in
            make.top.equalTo(boundary1View.snp.bottom)
            make.height.equalTo(leaveRoomButtonHeight)
            make.leading.trailing.equalToSuperview()
        }
        boundary2View.snp.makeConstraints { make in
            make.top.equalTo(leaveRoomButton.snp.bottom)
            make.height.equalTo(1.scale375Height())
            make.leading.trailing.equalToSuperview()
        }
        destroyRoomButton.snp.makeConstraints { make in
            make.top.equalTo(boundary2View.snp.bottom)
            make.height.equalTo(destroyRoomButtonHeight)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func bindInteraction() {
        setupViewState()
        viewModel.viewResponder = self
        leaveRoomButton.addTarget(self, action: #selector(leaveRoomAction), for: .touchUpInside)
        destroyRoomButton.addTarget(self, action: #selector(destroyRoomAction), for: .touchUpInside)
        contentView.transform = CGAffineTransform(translationX: 0, y: kScreenHeight)
        panelControl.addTarget(self, action: #selector(clickBackgroundView), for: .touchUpInside)
    }
    
    private func setupViewState() {
        destroyRoomButton.isHidden = !viewModel.isShownDestroyRoomButton()
        leaveRoomButton.isHidden = !viewModel.isShownLeaveRoomButton()
        boundary2View.isHidden = !viewModel.isShownDestroyRoomButton() || !viewModel.isShownLeaveRoomButton()
    }
    
    @objc func clickBackgroundView() {
        dismiss()
    }
    
    @objc func leaveRoomAction(sender: UIView) {
        viewModel.leaveRoomAction()
    }
    
    @objc func destroyRoomAction(sender: UIView) {
        viewModel.destroyRoom()
    }
    
    func show(rootView: UIView) {
        rootView.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.alpha = 1
            self.contentView.transform = .identity
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.alpha = 0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: kScreenHeight)
        } completion: { [weak self]  _ in
            guard let self = self else { return }
            self.removeFromSuperview()
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension ExitRoomView: ExitRoomViewModelResponder {
    func makeToast(message: String) {
        makeToast(message)
    }
    
    func dismissView() {
        dismiss()
    }
}

private extension String {
    static var leaveRoomTipText: String {
        localized("TUIRoom.leave.room.tip" )
    }
    static var appointOwnerText: String {
        localized("TUIRoom.appoint.owner" )
    }
    static var leaveRoomText: String {
        localized("TUIRoom.leave.room")
    }
    static var exitRoomText: String {
        localized("TUIRoom.dismiss.room")
    }
}
