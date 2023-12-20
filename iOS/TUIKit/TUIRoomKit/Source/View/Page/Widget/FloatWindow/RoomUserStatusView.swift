//
//  RoomUserStatusView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/7/24.
//

import Foundation

class RoomUserStatusView: UIView {
    private var isOwner: Bool = false
    private var isViewReady: Bool = false
    private let homeOwnerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "room_homeowner", in: tuiRoomKitBundle(), compatibleWith: nil))
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let user = UILabel()
        user.textColor = .white
        user.backgroundColor = UIColor.clear
        user.textAlignment = isRTL ? .right : .left
        user.numberOfLines = 1
        user.font = UIFont(name: "PingFangSC-Regular", size: 12)
        return user
    }()

    private let voiceVolumeImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        backgroundColor = UIColor(0x22262E, alpha: 0.8)
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }

    private func constructViewHierarchy() {
        addSubview(homeOwnerImageView)
        addSubview(voiceVolumeImageView)
        addSubview(userNameLabel)
    }

    private func activateConstraints() {
        updateViewConstraints()
        userNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(voiceVolumeImageView.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-8)
        }
    }

    private func updateViewConstraints() {
        guard homeOwnerImageView.superview != nil else { return }
        if isOwner {
            homeOwnerImageView.isHidden = false
            homeOwnerImageView.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.width.height.equalTo(24)
                make.top.bottom.equalToSuperview()
            }
            voiceVolumeImageView.snp.remakeConstraints { make in
                make.leading.equalTo(homeOwnerImageView.snp.trailing).offset(6.scale375())
                make.width.height.equalTo(14)
                make.centerY.equalToSuperview()
            }
        } else {
            homeOwnerImageView.isHidden = true
            voiceVolumeImageView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(5)
                make.width.height.equalTo(14)
                make.centerY.equalToSuperview()
            }
        }
    }
}

extension RoomUserStatusView {
    func updateUserStatus(userModel: UserEntity) {
        if !userModel.userName.isEmpty {
            userNameLabel.text = userModel.userName
        } else {
            userNameLabel.text = userModel.userId
        }
        isOwner = userModel.userId == EngineManager.createInstance().store.roomInfo.ownerId
        updateViewConstraints()
        updateUserVolume(hasAudio: userModel.hasAudioStream, volume: userModel.userVoiceVolume)
    }

    func updateUserVolume(hasAudio: Bool, volume: Int) {
        if !hasAudio {
            voiceVolumeImageView.image = UIImage(named: "room_mute_audio", in: tuiRoomKitBundle(), compatibleWith: nil)?.checkOverturn()
        } else {
            let volumeImageName = volume <= 0 ? "room_voice_volume1" : "room_voice_volume2"
            voiceVolumeImageView.image = UIImage(named: volumeImageName, in: tuiRoomKitBundle(), compatibleWith: nil)
        }
    }
}
