//
//  GroupCallVideoCell.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/2.
//

import Foundation
import TUICallEngine
import SnapKit

class GroupCallVideoCell: UICollectionViewCell {
    
    let selfUserStatusObserver = Observer()
    let remoteUserStatusObserver = Observer()
    let selfUserVideoAvailableObserver = Observer()
    let remoteUserVideoAvailableObserver = Observer()
    let isCameraOpenObserver = Observer()
    let isMicMuteObserver = Observer()
    let remotePlayoutVolumeObserver = Observer()
    let selfPlayoutVolumeObserver = Observer()
    let isShowLargeViewUserIdObserver = Observer()
    let enableBlurBackgroundObserver = Observer()
    let selfNetworkQualityObserver = Observer()
    let remoteNetworkQualityObserver = Observer()
    
    private var viewModel = GroupCallVideoCellViewModel(remote: User())
    private var user: User = User()
    private var isSelf: Bool = false
    
    private var renderView = VideoView()
    
    private let titleLabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.textColor = UIColor.t_colorWithHexString(color: "FFFFFF")
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textAlignment = TUICoreDefineConvert.getIsRTL() ? .right : .left
        return titleLabel
    }()
    
    private let loadingView = {
        let view = GroupLoadingView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let avatarImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let micImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        if let image = TUICallKitCommon.getBundleImage(name: "icon_mic_off") {
            imageView.image = image
        }
        return imageView
    }()
    
    private let volumeImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        if let image = TUICallKitCommon.getBundleImage(name: "icon_volume") {
            imageView.image = image
        }
        return imageView
    }()
    
    private let networkQualityView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        if let image = TUICallKitCommon.getBundleImage(name: "group_network_low_quality") {
            imageView.image = image
        }
        return imageView
    }()
    
    lazy var switchCameraBtn: GroupCallVideoCustomButton = {
        let btn = GroupCallVideoCustomButton(type: .system)
        btn.contentMode = .scaleAspectFit
        if let image = TUICallKitCommon.getBundleImage(name: "group_switch_camera") {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(switchCameraTouchEvent(sender: )), for: .touchUpInside)
        return btn
    }()
    
    lazy var virtualBackgroundBtn: GroupCallVideoCustomButton = {
        let btn = GroupCallVideoCustomButton(type: .system)
        btn.contentMode = .scaleAspectFit
        let imageName = TUICallState.instance.enableBlurBackground.value ? "group_virtual_background_on" : "group_virtual_background_off"
        if let image = TUICallKitCommon.getBundleImage(name: imageName) {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(virtualBackgroundTouchEvent(sender: )), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructViewHierarchy()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if !loadingView.isHidden {
            loadingView.startAnimating()
        }
    }
    
    deinit {
        if isSelf {
            TUICallState.instance.selfUser.value.callStatus.removeObserver(selfUserStatusObserver)
            TUICallState.instance.selfUser.value.videoAvailable.removeObserver(selfUserVideoAvailableObserver)
            TUICallState.instance.selfUser.value.playoutVolume.removeObserver(selfPlayoutVolumeObserver)
            TUICallState.instance.enableBlurBackground.removeObserver(enableBlurBackgroundObserver)
            TUICallState.instance.selfUser.value.networkQualityReminder.removeObserver(selfNetworkQualityObserver)
        } else {
            viewModel.remoteUserStatus.removeObserver(remoteUserStatusObserver)
            viewModel.remoteUserVideoAvailable.removeObserver(remoteUserVideoAvailableObserver)
            viewModel.remoteIsShowLowNetworkQuality.removeObserver(remoteNetworkQualityObserver)
            if TUICallState.instance.showVirtualBackgroundButton {
                viewModel.remoteUserVolume.removeObserver(remotePlayoutVolumeObserver)
            }
        }
        
        TUICallState.instance.showLargeViewUserId.removeObserver(isMicMuteObserver)
        
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
    }
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
        if !loadingView.isHidden {
            loadingView.startAnimating()
        }
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(renderView)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(loadingView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(micImageView)
        contentView.addSubview(volumeImageView)
        contentView.addSubview(networkQualityView)
        contentView.addSubview(switchCameraBtn)
        if TUICallState.instance.showVirtualBackgroundButton {
            contentView.addSubview(virtualBackgroundBtn)
        }
    }
    
    func activateConstraints() {
        renderView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
        avatarImageView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
        loadingView.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.width.height.equalTo(40.scaleWidth())
        }
        
        if viewModel.isShowLargeViewUserId.value {
            activateLargeViewConstraints()
        } else {
            activateSmallViewConstraints()
        }
    }
    
    func activateLargeViewConstraints() {
        titleLabel.snp.remakeConstraints { make in
            make.leading.equalTo(self.contentView).offset(8.scaleWidth())
            make.height.equalTo(24.scaleWidth())
            make.bottom.equalTo(self.contentView).offset(-8.scaleWidth())
        }
        micImageView.snp.remakeConstraints { make in
            make.width.height.equalTo(24.scaleWidth())
            make.leading.equalTo(titleLabel.snp.trailing).offset(8.scaleWidth())
            make.bottom.equalTo(self.contentView).offset(-8.scaleWidth())
        }
        volumeImageView.snp.remakeConstraints { make in
            make.width.height.equalTo(24.scaleWidth())
            make.leading.equalTo(titleLabel.snp.trailing).offset(8.scaleWidth())
            make.bottom.equalTo(self.contentView).offset(-8.scaleWidth())
        }
        if TUICallState.instance.showVirtualBackgroundButton {
            virtualBackgroundBtn.snp.remakeConstraints { make in
                make.width.height.equalTo(24.scaleWidth())
                make.bottom.trailing.equalTo(self.contentView).offset(-8.scaleWidth())
            }
            switchCameraBtn.snp.remakeConstraints { make in
                make.width.height.equalTo(24.scaleWidth())
                make.centerY.equalTo(virtualBackgroundBtn)
                make.trailing.equalTo(virtualBackgroundBtn.snp.leading).offset(-10.scaleWidth())
            }
        } else {
            switchCameraBtn.snp.remakeConstraints { make in
                make.width.height.equalTo(24.scaleWidth())
                make.bottom.trailing.equalTo(self.contentView).offset(-8.scaleWidth())
            }
        }
        networkQualityView.snp.remakeConstraints { make in
            make.width.height.equalTo(24.scaleWidth())
            make.centerY.equalTo(switchCameraBtn)
            make.trailing.equalTo(switchCameraBtn.snp.leading).offset(-10.scaleWidth())
        }
    }
    
    func activateSmallViewConstraints() {
        volumeImageView.snp.remakeConstraints { make in
            make.width.height.equalTo(24.scaleWidth())
            make.leading.equalTo(self.contentView).offset(8.scaleWidth())
            make.bottom.equalTo(self.contentView).offset(-8.scaleWidth())
        }
        networkQualityView.snp.remakeConstraints { make in
            make.width.height.equalTo(24.scaleWidth())
            if self.micImageView.isHidden {
                make.trailing.equalTo(self.contentView).offset(-8.scaleWidth())
            } else {
                make.trailing.equalTo(self.micImageView.snp.leading).offset(-8.scaleWidth())
            }
            make.bottom.equalTo(self.contentView).offset(-8.scaleWidth())
        }
        micImageView.snp.remakeConstraints { make in
            make.width.height.equalTo(24.scaleWidth())
            make.trailing.equalTo(self.contentView).offset(-8.scaleWidth())
            make.bottom.equalTo(self.contentView).offset(-8.scaleWidth())
        }
    }
    
    func initCell(user: User) {
        self.user = user
        viewModel = GroupCallVideoCellViewModel(remote: user)
        isSelf = TUICallState.instance.selfUser.value.id.value == user.id.value ? true : false
        initWaitingUI()
        registerObserveState()
    }
    
    // MARK: Action Event
    @objc func switchCameraTouchEvent(sender: UIButton) {
        CallEngineManager.instance.switchCamera()
    }
    
    @objc func virtualBackgroundTouchEvent(sender: UIButton ) {
        CallEngineManager.instance.setBlurBackground()
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callStatusChanged()
        videoAvailableChanged()
        isCameraOpenChanged()
        volumeChanged()
        isShowLargeViewUserIdChanged()
        isMicMuteChanged()
        enableBlurBackgroundChanged()
        networkQualityChanged()
    }
    
    func callStatusChanged() {
        if isSelf {
            TUICallState.instance.selfUser.value.callStatus.addObserver(selfUserStatusObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.updateSelfUserUI()
            })
        } else {
            viewModel.remoteUserStatus.addObserver(remoteUserStatusObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.updateRemoteUserCellUI()
                
            })
        }
    }
    
    func videoAvailableChanged() {
        if isSelf {
            TUICallState.instance.selfUser.value.videoAvailable.addObserver(selfUserVideoAvailableObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.updateSelfUserUI()
            })
        } else {
            viewModel.remoteUserVideoAvailable.addObserver(remoteUserVideoAvailableObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.updateRemoteUserCellUI()
            })
        }
    }
    
    func volumeChanged() {
        if isSelf {
            TUICallState.instance.selfUser.value.playoutVolume.addObserver(selfPlayoutVolumeObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.volumeImageView.isHidden = newValue == 0 ? true : false
            })
        } else {
            viewModel.remoteUserVolume.addObserver(remotePlayoutVolumeObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.volumeImageView.isHidden = newValue == 0 ? true : false
            })
        }
    }
    
    func isCameraOpenChanged() {
        if isSelf {
            TUICallState.instance.isCameraOpen.addObserver(isCameraOpenObserver) { [weak self] newValue, _ in
                guard let self = self else { return }
                self.updateSelfUserUI()
            }
        }
    }
    
    func isShowLargeViewUserIdChanged() {
        viewModel.isShowLargeViewUserId.addObserver(isShowLargeViewUserIdObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue {
                self.updateLargeViewUI()
            } else {
                self.updateSmallViewUI()
            }
        }
    }
    
    func isMicMuteChanged() {
        if isSelf {
            TUICallState.instance.isMicMute.addObserver(isMicMuteObserver) { [weak self] newValue, _ in
                guard let self = self else { return }
                self.micImageView.isHidden = !newValue
            }
        }
    }
    
    func enableBlurBackgroundChanged () {
        if isSelf && TUICallState.instance.showVirtualBackgroundButton {
            TUICallState.instance.enableBlurBackground.addObserver(enableBlurBackgroundObserver) { [weak self] newValue, _ in
                guard let self = self else { return }
                let imageName = TUICallState.instance.enableBlurBackground.value ? "group_virtual_background_on" : "group_virtual_background_off"
                if let image = TUICallKitCommon.getBundleImage(name: imageName) {
                    self.virtualBackgroundBtn.setBackgroundImage(image, for: .normal)
                }
            }
        }
    }
    
    func networkQualityChanged () {
        if isSelf {
            TUICallState.instance.selfUser.value.networkQualityReminder.addObserver(selfNetworkQualityObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.networkQualityView.isHidden = !newValue
            })
        } else {
            viewModel.remoteIsShowLowNetworkQuality.addObserver(remoteNetworkQualityObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.networkQualityView.isHidden = !newValue
            })
        }
    }
    
    func updateLargeViewUI() {
        if isSelf {
            switchCameraBtn.isHidden = !TUICallState.instance.isCameraOpen.value
            virtualBackgroundBtn.isHidden = !TUICallState.instance.isCameraOpen.value || !TUICallState.instance.showVirtualBackgroundButton
            titleLabel.isHidden = false
            micImageView.isHidden = !TUICallState.instance.isMicMute.value
        } else {
            switchCameraBtn.isHidden = true
            virtualBackgroundBtn.isHidden = true
            titleLabel.isHidden = false
            micImageView.isHidden = true
        }
        activateLargeViewConstraints()
    }
    
    func updateSmallViewUI() {
        switchCameraBtn.isHidden = true
        virtualBackgroundBtn.isHidden = true
        titleLabel.isHidden = true
        
        if isSelf {
            micImageView.isHidden = !TUICallState.instance.isMicMute.value
        } else {
            micImageView.isHidden = true
        }
        activateSmallViewConstraints()
    }
    
    
    // MARK: Update UI
    func initWaitingUI() {
        titleLabel.text = User.getUserDisplayName(user: viewModel.remoteUser)
        setUserAvatar()
        
        if isSelf {
            initSelfUserUI()
        } else {
            updateRemoteUserCellUI()
        }
    }
    
    func initSelfUserUI() {
        hiddenAllSubView()
        micImageView.isHidden = !TUICallState.instance.isMicMute.value
        
        if !VideoFactory.instance.isExistVideoView(videoView: renderView) {
            renderView = VideoFactory.instance.createVideoView(userId: TUICallState.instance.selfUser.value.id.value, frame: CGRect.zero)
            renderView.isUserInteractionEnabled = false
        }
        
        if TUICallState.instance.isCameraOpen.value == true {
            renderView.isHidden = false
            switchCameraBtn.isHidden = false
            CallEngineManager.instance.openCamera(videoView: renderView)
        } else {
            renderView.isHidden = true
            avatarImageView.isHidden = false
        }
    }
    
    func updateSelfUserUI() {
        hiddenAllSubView()
        micImageView.isHidden = !TUICallState.instance.isMicMute.value
        
        if TUICallState.instance.isCameraOpen.value == true {
            renderView.isHidden = false
            switchCameraBtn.isHidden = false
            virtualBackgroundBtn.isHidden = !TUICallState.instance.showVirtualBackgroundButton
        } else {
            switchCameraBtn.isHidden = true
            virtualBackgroundBtn.isHidden = true
            avatarImageView.isHidden = false
        }
    }
    
    func updateRemoteUserCellUI() {
        hiddenAllSubView()
        
        if viewModel.remoteUserStatus.value == .waiting {
            loadingView.isHidden = false
            loadingView.startAnimating()
            avatarImageView.isHidden = false
        } else if viewModel.remoteUserStatus.value == .accept {
            CallEngineManager.instance.startRemoteView(user: viewModel.remoteUser, videoView: renderView)
            
            if viewModel.remoteUserVideoAvailable.value == true {
                renderView.isUserInteractionEnabled = false
                renderView.isHidden = false
            } else {
                avatarImageView.isHidden = false
            }
        }
    }
    
    func hiddenAllSubView() {
        renderView.isHidden = true
        loadingView.isHidden = true
        loadingView.stopAnimating()
        avatarImageView.isHidden = true
        micImageView.isHidden = true
        volumeImageView.isHidden = true
        switchCameraBtn.isHidden = true
        virtualBackgroundBtn.isHidden = true
        networkQualityView.isHidden = true
    }
    
    // MARK: Private Method
    func setUserAvatar() {
        let userIcon: UIImage? = TUICallKitCommon.getBundleImage(name: "default_user_icon")
        
        if viewModel.remoteUser.avatar.value == "" {
            guard let image = userIcon else { return }
            avatarImageView.image = image
        } else {
            avatarImageView.sd_setImage(with: URL(string: viewModel.remoteUser.avatar.value), placeholderImage: userIcon)
        }
    }
}

class GroupCallVideoCustomButton: UIButton {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let expandedBounds = bounds.insetBy(dx: -4.scaleWidth(), dy: -4.scaleWidth())
        return expandedBounds.contains(point) ? self : nil
    }
}
