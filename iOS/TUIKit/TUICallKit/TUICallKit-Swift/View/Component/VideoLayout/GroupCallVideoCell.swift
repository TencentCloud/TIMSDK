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
    
    private var viewModel = GroupCallVideoCellViewModel(remote: User())
    private var user: User = User()
    
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
    
    lazy var switchCameraBtn: UIButton = {
        let btn = UIButton(type: .system)
        if let image = TUICallKitCommon.getBundleImage(name: "group_switch_camera") {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(switchCameraTouchEvent(sender: )), for: .touchUpInside)
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
        if viewModel.isSelf {
            viewModel.selfUserStatus.removeObserver(selfUserStatusObserver)
            viewModel.selfUserVideoAvailable.removeObserver(selfUserVideoAvailableObserver)
            viewModel.selfPlayoutVolume.removeObserver(selfPlayoutVolumeObserver)
            viewModel.isShowLargeViewUserId.removeObserver(isMicMuteObserver)
        } else {
            viewModel.remoteUserStatus.removeObserver(remoteUserStatusObserver)
            viewModel.remoteUserVideoAvailable.removeObserver(remoteUserVideoAvailableObserver)
            viewModel.remoteUserVolume.removeObserver(remotePlayoutVolumeObserver)
        }
        
        viewModel.isShowLargeViewUserId.removeObserver(isShowLargeViewUserIdObserver)
        
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
        contentView.addSubview(switchCameraBtn)
    }
    
    func activateConstraints() {
        renderView.snp.remakeConstraints { make in
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
        switchCameraBtn.snp.makeConstraints { make in
            make.width.height.equalTo(24.scaleWidth())
            make.bottom.trailing.equalTo(self.contentView).offset(-8.scaleWidth())
        }
    }
    
    func activateSmallViewConstraints() {
        volumeImageView.snp.remakeConstraints { make in
            make.width.height.equalTo(24.scaleWidth())
            make.leading.equalTo(self.contentView).offset(8.scaleWidth())
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
        initWaitingUI()
        registerObserveState()
    }
    
    // MARK: Action Event
    @objc func switchCameraTouchEvent(sender: UIButton) {
        viewModel.switchCamera()
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callStatusChanged()
        videoAvailableChanged()
        isCameraOpenChanged()
        volumeChanged()
        isShowLargeViewUserIdChanged()
        isMicMuteChanged()
    }
    
    func callStatusChanged() {
        if viewModel.isSelf {
            viewModel.selfUserStatus.addObserver(selfUserStatusObserver, closure: { [weak self] newValue, _ in
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
        if viewModel.isSelf {
            viewModel.selfUserVideoAvailable.addObserver(selfUserVideoAvailableObserver, closure: { [weak self] newValue, _ in
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
        if viewModel.isSelf {
            viewModel.selfPlayoutVolume.addObserver(selfPlayoutVolumeObserver, closure: { [weak self] newValue, _ in
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
        if viewModel.isSelf {
            viewModel.isCameraOpen.addObserver(isCameraOpenObserver) { [weak self] newValue, _ in
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
        if viewModel.isSelf {
            viewModel.isMicMute.addObserver(isMicMuteObserver) { [weak self] newValue, _ in
                guard let self = self else { return }
                self.micImageView.isHidden = !newValue
            }
        }
    }
    
    func updateLargeViewUI() {
        activateLargeViewConstraints()
        
        if viewModel.isSelf {
            switchCameraBtn.isHidden = !viewModel.isCameraOpen.value
            titleLabel.isHidden = false
            micImageView.isHidden = !viewModel.isMicMute.value
        } else {
            switchCameraBtn.isHidden = true
            titleLabel.isHidden = false
            micImageView.isHidden = true
        }
    }
    
    func updateSmallViewUI() {
        activateSmallViewConstraints()
        switchCameraBtn.isHidden = true
        titleLabel.isHidden = true
        
        if viewModel.isSelf {
            micImageView.isHidden = !viewModel.isMicMute.value
        } else {
            micImageView.isHidden = true
        }
    }
    
    
    // MARK: Update UI
    func initWaitingUI() {
        titleLabel.text = User.getUserDisplayName(user: viewModel.remoteUser)
        setUserAvatar()
        
        if viewModel.isSelf {
            initSelfUserUI()
        } else {
            updateRemoteUserCellUI()
        }
    }
    
    func initSelfUserUI() {
        hiddenAllSubView()
        
        if !VideoFactory.instance.isExistVideoView(videoView: renderView) {
            renderView = VideoFactory.instance.createVideoView(userId: viewModel.selfUser.value.id.value, frame: CGRect.zero)
            renderView.isUserInteractionEnabled = false
        }
        
        if viewModel.isCameraOpen.value == true {
            renderView.isHidden = false
            viewModel.openCamera(videoView: renderView)
        } else {
            renderView.isHidden = true
            avatarImageView.isHidden = false
        }
        
        micImageView.isHidden = !viewModel.isMicMute.value
    }
    
    func updateSelfUserUI() {
        hiddenAllSubView()
        
        if viewModel.isCameraOpen.value == true {
            renderView.isHidden = false
            micImageView.isHidden = true
            switchCameraBtn.isHidden = false
            viewModel.openCamera(videoView: renderView)
        } else {
            switchCameraBtn.isHidden = true
            micImageView.isHidden = false
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
            viewModel.startRemoteView(user: viewModel.remoteUser, videoView: renderView)
            
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
