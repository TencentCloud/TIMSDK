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
    let remotePlayoutVolumeObserver = Observer()
    let selfPlayoutVolumeObserver = Observer()
    
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
    
    private let loadingImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        guard let filePath = TUICallKitCommon.getTUICallKitBundle()?.path(forResource: "loading", ofType: "gif") else { return imageView }
        guard let data = NSData(contentsOfFile: filePath) as? Data else { return imageView }
        imageView.image = UIImage.sd_image(withGIFData: data)
        return imageView
    }()
    
    private let avatarImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let micImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        if let image = TUICallKitCommon.getBundleImage(name: "ic_mute") {
            imageView.image = image
        }
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let filePath = TUICallKitCommon.getTUICallKitBundle()?.path(forResource: "loading", ofType: "gif") else { return }
        guard let data = NSData(contentsOfFile:filePath) as? Data else { return }
        loadingImageView.image = UIImage.sd_image(withGIFData: data)
    }
    
    deinit {
        if viewModel.isSelf {
            viewModel.selfUserStatus.removeObserver(selfUserStatusObserver)
            viewModel.selfUserVideoAvailable.removeObserver(selfUserVideoAvailableObserver)
            viewModel.selfPlayoutVolume.removeObserver(selfPlayoutVolumeObserver)
        } else {
            viewModel.remoteUserStatus.removeObserver(remoteUserStatusObserver)
            viewModel.remoteUserVideoAvailable.removeObserver(remoteUserVideoAvailableObserver)
            viewModel.remoteUserVolume.removeObserver(remotePlayoutVolumeObserver)
        }
        
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
    }
    
    //MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(renderView)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(loadingImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(micImageView)
    }
    
    func activateConstraints() {
        renderView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
        
        loadingImageView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView).offset(20)
            make.bottom.equalTo(self.contentView).offset(-5)
            make.width.equalTo(self.contentView)
            make.height.equalTo(20)
        }
        
        micImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.trailing.equalTo(self.contentView).offset(-20)
            make.bottom.equalTo(self.contentView).offset(-5)
        }
    }
    
    func initCell(user: User) {
        self.user = user
        viewModel = GroupCallVideoCellViewModel(remote: user)
        initWaitingUI()
        registerObserveState()
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callStatusChanged()
        videoAvailableChanged()
        isCameraOpenChanged()
        volumChanged()
    }
    
    func callStatusChanged() {
        if viewModel.isSelf {
            viewModel.selfUserStatus.addObserver(selfUserStatusObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.updateSelfUsertUI()
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
                self.updateSelfUsertUI()
            })
        } else {
            viewModel.remoteUserVideoAvailable.addObserver(remoteUserVideoAvailableObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.updateRemoteUserCellUI()
            })
        }
    }
    
    func volumChanged() {
        if viewModel.isSelf {
            viewModel.selfPlayoutVolume.addObserver(selfPlayoutVolumeObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.micImageView.isHidden = newValue == 0 ? true : false
                
            })
        } else {
            viewModel.remoteUserVolume.addObserver(remotePlayoutVolumeObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.micImageView.isHidden = newValue == 0 ? true : false
                
            })
        }
    }
    
    func isCameraOpenChanged() {
        if viewModel.isSelf {
            viewModel.isCameraOpen.addObserver(isCameraOpenObserver) { [weak self] newValue, _ in
                guard let self = self else { return }
                self.updateSelfUsertUI()
            }
        }
    }
    
    //MARK: Update UI
    func initWaitingUI() {
        titleLabel.text = viewModel.remoteUser.nickname.value
        setUserAvatar()
        
        if viewModel.isSelf {
            initSelfUserUI()
        } else {
            updateRemoteUserCellUI()
        }
    }
    
    func initSelfUserUI() {
        hiddenAllSubView()
        
        if viewModel.mediaType.value == .video {
            if viewModel.selfUserStatus.value == .waiting {
                if !VideoFactory.instance.isExistVideoView(videoView: renderView) {
                    renderView = VideoFactory.instance.createVideoView(userId: viewModel.selfUser.value.id.value, frame: CGRect.zero)
                    renderView.isHidden = false
                    viewModel.openCamera(videoView: renderView)
                }
            } else if viewModel.selfUserStatus.value == .accept {
                if !VideoFactory.instance.isExistVideoView(videoView: renderView) {
                    renderView = VideoFactory.instance.createVideoView(userId: viewModel.selfUser.value.id.value, frame: CGRect.zero)
                    viewModel.openCamera(videoView: renderView)
                }
                if viewModel.isCameraOpen.value == true {
                    renderView.isHidden = false
                } else {
                    titleLabel.isHidden = false
                    avatarImageView.isHidden = false
                }
            }
        } else if viewModel.mediaType.value == .audio {
            titleLabel.isHidden = false
            avatarImageView.isHidden = false
        }
    }
    
    func updateSelfUsertUI() {
        hiddenAllSubView()
        
        if viewModel.mediaType.value == .video {
            if viewModel.isCameraOpen.value == true {
                renderView.isHidden = false
            } else {
                titleLabel.isHidden = false
                avatarImageView.isHidden = false
            }
        } else if viewModel.mediaType.value == .audio {
            titleLabel.isHidden = false
            avatarImageView.isHidden = false
        }
    }
    
    
    func updateRemoteUserCellUI() {
        hiddenAllSubView()
        
        if viewModel.mediaType.value == .audio {
            titleLabel.isHidden = false
            avatarImageView.isHidden = false
            if viewModel.remoteUserStatus.value == .waiting {
                loadingImageView.isHidden = false
            }
        } else if viewModel.mediaType.value == .video {
            viewModel.startRemoteView(user: viewModel.remoteUser, videoView: renderView)
            
            if viewModel.remoteUserStatus.value == .waiting {
                loadingImageView.isHidden = false
                titleLabel.isHidden = false
                avatarImageView.isHidden = false
            } else if viewModel.remoteUserStatus.value == .accept {
                if viewModel.remoteUserVideoAvailable.value == true {
                    renderView.isHidden = false
                } else {
                    titleLabel.isHidden = false
                    avatarImageView.isHidden = false
                }
            }
        }
    }
    
    func hiddenAllSubView() {
        renderView.isHidden = true
        titleLabel.isHidden = true
        loadingImageView.isHidden = true
        avatarImageView.isHidden = true
        micImageView.isHidden = true
    }
    
    //MARK: Private Method
    func setUserAvatar() {
        if viewModel.remoteUser.avatar.value == "" {
            if let image = TUICallKitCommon.getBundleImage(name: "userIcon") {
                avatarImageView.image = image
            }
        } else if let image = TUICallKitCommon.getUrlImage(url: viewModel.remoteUser.avatar.value){
            avatarImageView.image = image
        } else {
            if let image = TUICallKitCommon.getBundleImage(name: "userIcon") {
                avatarImageView.image = image
            }
        }
    }
}
