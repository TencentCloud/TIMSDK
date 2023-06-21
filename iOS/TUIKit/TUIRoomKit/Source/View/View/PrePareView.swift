//
//  PrePareView.swift
//
//  Created by aby on 2022/12/26.
//  Copyright © 2022 Tencent. All rights reserved.
//

import UIKit

class PrePareView: UIView {
    
    let viewModel: PrePareViewModel
    
    let topViewContainer: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    let backButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "room_back", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(image, for: .normal)
        return button
    }()
    
    let avatarButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 16.0)
        return label
    }()
    
    let switchLanguageButton: UIButton = {
        let button = UIButton(type: .custom)
        let normalIcon = UIImage(named: "room_language", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(normalIcon, for: .normal)
        return button
    }()
    
    let tencentBigView: UIView = {
        let view = UIView(frame: .zero)
        let iconImageView = UIImageView(frame: .zero)
        iconImageView.image = UIImage(named: "room_tencent", in: tuiRoomKitBundle(), compatibleWith: nil)
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(136)
            make.height.equalTo(36)
        }
        let textImageView = UIImageView(frame: .zero)
        textImageView.image = UIImage(named: "room_tencent_text", in: tuiRoomKitBundle(), compatibleWith: nil)
        view.addSubview(textImageView)
        textImageView.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        return view
    }()
    
    let prePareView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(0x0D1015)
        return view
    }()
    
    let userMessageView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    let userAvatarImage: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        return imageView
    }()
    
    let userIdLable: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    let userMicphoneImage: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "room_user_mic", in: tuiRoomKitBundle(), compatibleWith: nil)
        return imageView
    }()
    
    let openCameraButton: UIButton = {
        let button = UIButton(type: .custom)
        let normalIcon = UIImage(named: "room_camera_on", in: tuiRoomKitBundle(), compatibleWith: nil)
        let selectIcon = UIImage(named: "room_camera_off", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(normalIcon, for: .normal)
        button.setImage(selectIcon, for: .selected)
        return button
    }()
    
    let cameraLabel: UILabel = {
        let label = UILabel()
        label.text = .cameraText
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 10.0)
        return label
    }()
    
    let openMicrophoneButton: UIButton = {
        let button = UIButton(type: .custom)
        let normalIcon = UIImage(named: "room_mic_on", in: tuiRoomKitBundle(), compatibleWith: nil)
        let selectIcon = UIImage(named: "room_mic_off", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(normalIcon, for: .normal)
        button.setImage(selectIcon, for: .selected)
        return button
    }()
    
    let microphoneLabel: UILabel = {
        let label = UILabel()
        label.text = .micText
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 10.0)
        return label
    }()
    
    let switchCamera: UIButton = {
        let button = UIButton(type: .custom)
        let normalIcon = UIImage(named: "room_switch_camera", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(normalIcon, for: .normal)
        return button
    }()
    
    let switchMirror: UIButton = {
        let button = UIButton(type: .custom)
        let normalIcon = UIImage(named: "room_mirror", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(normalIcon, for: .normal)
        return button
    }()
    
    let joinRoomButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(.joinRoomText, for: .normal)
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor(0x146EFA)
        let normalIcon = UIImage(named: "room_enter", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(normalIcon, for: .normal)
        return button
    }()
    
    let createRoomButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(.createRoomText, for: .normal)
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor(0x146EFA)
        let normalIcon = UIImage(named: "room_create", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(normalIcon, for: .normal)
        return button
    }()
    
    let tencentImage: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "room_tencent", in: tuiRoomKitBundle(), compatibleWith: nil)
        return imageView
    }()
    
    
    init(viewModel: PrePareViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - view layout
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        initialState()
        backgroundColor = .white
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        avatarButton.roundedRect(rect: avatarButton.bounds,
                                 byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
                                 cornerRadii: CGSize(width: avatarButton.bounds.size.width, height: avatarButton.bounds.size.height))
        prePareView.roundedRect(rect: prePareView.bounds,
                                byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
                                cornerRadii: CGSize(width: 12, height: 12))
        joinRoomButton.roundedRect(rect: joinRoomButton.bounds,
                                   byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
                                   cornerRadii: CGSize(width: 12, height: 12))
        createRoomButton.roundedRect(rect: createRoomButton.bounds,
                                     byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
                                     cornerRadii: CGSize(width: 12, height: 12))
        userAvatarImage.roundedRect(rect: userAvatarImage.bounds,
                                    byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: userAvatarImage.bounds.size.width, height: userAvatarImage.bounds.size.height))
    }
    
    func constructViewHierarchy() {
        addSubview(topViewContainer)
        topViewContainer.addSubview(backButton)
        topViewContainer.addSubview(avatarButton)
        topViewContainer.addSubview(userNameLabel)
        topViewContainer.addSubview(switchLanguageButton)
        addSubview(tencentBigView)
        addSubview(prePareView)
        prePareView.addSubview(switchCamera)
        prePareView.addSubview(switchMirror)
        prePareView.addSubview(userMessageView)
        userMessageView.addSubview(userAvatarImage)
        userMessageView.addSubview(userIdLable)
        userMessageView.addSubview(userMicphoneImage)
        addSubview(openCameraButton)
        addSubview(openMicrophoneButton)
        addSubview(cameraLabel)
        addSubview(microphoneLabel)
        addSubview(joinRoomButton)
        addSubview(createRoomButton)
        addSubview(tencentImage)
    }
    
    func activateConstraints() {
        topViewContainer.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(32.scale375())
        }
        backButton.snp.makeConstraints { make in
            make.height.width.equalTo(32.scale375())
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        avatarButton.snp.makeConstraints { make in
            make.height.width.equalTo(32.scale375())
            make.leading.equalTo(backButton.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        userNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarButton.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        switchLanguageButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(30)
        }
        tencentBigView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(150.scale375())
        }
        
        prePareView.snp.makeConstraints { make in
            make.top.equalTo(topViewContainer.snp.bottom).offset(40.scale375())
            make.centerX.equalToSuperview()
            make.height.width.equalTo(bounds.size.width - 30)
        }
        
        switchCamera.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(15)
        }
        
        switchMirror.snp.makeConstraints { make in
            make.centerY.equalTo(switchCamera)
            make.left.equalTo(switchCamera.snp.right).offset(15)
        }
        
        userMessageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(115.scale375())
            make.centerX.equalToSuperview()
            make.height.equalTo(125)
            make.width.equalTo(100)
        }
        
        userAvatarImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        userMicphoneImage.snp.makeConstraints { make in
            make.top.equalTo(userAvatarImage.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(25)
        }
        
        userIdLable.snp.makeConstraints { make in
            make.centerY.equalTo(userMicphoneImage)
            make.trailing.equalToSuperview()
            make.left.equalTo(userMicphoneImage.snp.right).offset(2)
        }
        
        openMicrophoneButton.snp.makeConstraints { make in
            make.top.equalTo(prePareView.snp.bottom).offset(40.scale375())
            make.height.equalTo(60)
            make.width.equalTo(40)
            make.leading.equalToSuperview().offset(100.scale375())
        }
        
        openCameraButton.snp.makeConstraints { make in
            make.top.equalTo(openMicrophoneButton)
            make.width.height.equalTo(openMicrophoneButton)
            make.trailing.equalToSuperview().offset(-100.scale375())
        }
        
        microphoneLabel.snp.makeConstraints { make in
            make.top.equalTo(openMicrophoneButton.snp.bottom).offset(3)
            make.centerX.equalTo(openMicrophoneButton)
        }
        
        cameraLabel.snp.makeConstraints { make in
            make.top.equalTo(openCameraButton.snp.bottom).offset(3)
            make.centerX.equalTo(openCameraButton)
        }
        
        joinRoomButton.snp.makeConstraints { make in
            make.height.equalTo(48.scale375())
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(self.snp.centerX).offset(-6)
            make.top.equalTo(microphoneLabel.snp.bottom).offset(30.scale375())
        }
        
        createRoomButton.snp.makeConstraints { make in
            make.height.equalTo(48.scale375())
            make.leading.equalTo(self.snp.centerX).offset(6)
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.centerY.equalTo(joinRoomButton)
        }
        
        tencentImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(createRoomButton.snp.bottom).offset(30.scale375())
        }
    }
    
    func bindInteraction() {
        viewModel.viewResponder = self
        setupViewState(item: viewModel)
        backButton.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        joinRoomButton.addTarget(self, action: #selector(joinRoomAction(sender:)), for: .touchUpInside)
        createRoomButton.addTarget(self, action: #selector(createRoomAction(sender:)), for: .touchUpInside)
        switchLanguageButton.addTarget(self, action: #selector(switchLanguageAction(sender:)), for: .touchUpInside)
        openCameraButton.addTarget(self, action: #selector(openCameraAction(sender:)), for: .touchUpInside)
        openMicrophoneButton.addTarget(self, action: #selector(openMicrophoneAction(sender:)), for: .touchUpInside)
        switchCamera.addTarget(self, action: #selector(switchCameraAction(sender:)), for: .touchUpInside)
        switchMirror.addTarget(self, action: #selector(switchMirrorAction(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: PrePareViewModel) {
        let placeholderImage = UIImage(named: "room_default_avatar", in: tuiRoomKitBundle(), compatibleWith: nil)
        avatarButton.sd_setImage(with: URL(string: viewModel.currentUser.avatarUrl), for: .normal, placeholderImage: placeholderImage)
        userAvatarImage.sd_setImage(with: URL(string: viewModel.currentUser.avatarUrl), placeholderImage: placeholderImage)
        userNameLabel.text = viewModel.currentUser.userName
        userIdLable.text = viewModel.currentUser.userName
        if !item.enablePrePareView {
            prePareView.isHidden = true
            tencentImage.isHidden = true
            openCameraButton.isHidden = true
            openMicrophoneButton.isHidden = true
            microphoneLabel.isHidden = true
            cameraLabel.isHidden = true
            tencentBigView.isHidden = false
            createRoomButton.snp.remakeConstraints { make in
                make.height.equalTo(48.scale375())
                make.centerX.equalToSuperview()
                make.width.equalTo(204.scale375())
                make.bottom.equalToSuperview().offset(-130.scale375())
            }
            joinRoomButton.snp.remakeConstraints { make in
                make.height.equalTo(createRoomButton)
                make.centerX.equalToSuperview()
                make.width.equalTo(createRoomButton)
                make.bottom.equalTo(createRoomButton.snp.top).offset(-30.scale375())
            }
        }
    }
    
    func initialState() {
        if viewModel.enablePrePareView {
            viewModel.initialState(view: prePareView)
        }
    }
    
    @objc
    func backAction(sender: UIButton) {
        viewModel.backAction()
    }
    
    @objc
    func joinRoomAction(sender: UIButton) {
        viewModel.joinRoom()
    }
    
    @objc
    func createRoomAction(sender: UIButton) {
        viewModel.createRoom()
    }
    
    @objc
    func switchLanguageAction(sender: UIButton) {
        viewModel.switchLanguageAction()
    }
    
    @objc
    func openCameraAction(sender: UIButton) {
        viewModel.openCameraAction(sender: sender, placeholderImage: userMessageView)
    }
    
    @objc
    func openMicrophoneAction(sender: UIButton) {
        viewModel.openMicrophoneAction(sender: sender)
    }
    
    @objc
    func switchCameraAction(sender: UIButton) {
        viewModel.switchCameraAction(sender: sender)
    }
    
    @objc
    func switchMirrorAction(sender: UIButton) {
        viewModel.switchMirrorAction(sender: sender)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension PrePareView: PrePareViewEventProtocol {
    func updateButtonState() {
        openCameraButton.isSelected = !viewModel.roomInfo.isOpenCamera
        openMicrophoneButton.isSelected = !viewModel.roomInfo.isOpenMicrophone
        userMessageView.isHidden = viewModel.roomInfo.isOpenCamera
    }
    func changeLanguage() {
        cameraLabel.text = .cameraText
        microphoneLabel.text = .micText
        joinRoomButton.setTitle(.joinRoomText, for: .normal)
        createRoomButton.setTitle(.createRoomText, for: .normal)
    }
}

private extension String {
    static var joinRoomText: String {
        localized("TUIRoom.join.room")
    }
    static var createRoomText: String {
        localized("TUIRoom.create.room")
    }
    static var cameraText: String {
        localized("TUIRoom.camera")
    }
    static var micText: String {
        localized("TUIRoom.mic")
    }
}

