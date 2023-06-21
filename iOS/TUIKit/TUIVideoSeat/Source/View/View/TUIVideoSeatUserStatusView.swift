//
//  TUIVideoSeatUserStatusView.swift
//  TUIVideoSeat
//
//  Created by jack on 2023/3/6.
//  Copyright © 2023 Tencent. All rights reserved.

import Foundation

class TUIVideoSeatUserStatusView: UIView {
    private var isOwner: Bool = false
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        backgroundColor = UIColor(0x121723, alpha: 0.8)
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }

    private func constructViewHierarchy() {
        addSubview(homeOwnerImageView)
        addSubview(voiceVolumeImageView)
        addSubview(userNameLabel)
    }

    private let homeOwnerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "tuiroom_homeowners_icon", in: tuiVideoSeatBundle(), compatibleWith: nil))
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let user = UILabel()
        user.textColor = .white
        user.backgroundColor = UIColor.clear
        user.textAlignment = .left
        user.numberOfLines = 1
        user.font = UIFont(name: "PingFangSC-Regular", size: 12)
        return user
    }()

    private let voiceVolumeImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private func activateConstraints() {
        updateOwnerImageConstraints()
        voiceVolumeImageView.snp.remakeConstraints { make in
            make.leading.equalTo(homeOwnerImageView.snp.trailing).offset(5)
            make.width.height.equalTo(14)
            make.centerY.equalToSuperview()
        }
        userNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(voiceVolumeImageView.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-8)
        }
    }

    private func updateOwnerImageConstraints() {
        guard let _ = homeOwnerImageView.superview else { return }
        homeOwnerImageView.snp.remakeConstraints { make in
            make.leading.equalToSuperview()
            make.width.height.equalTo(isOwner ? 24 : 0)
            make.top.bottom.equalToSuperview()
        }
    }
}

// MARK: - Public

extension TUIVideoSeatUserStatusView {
    func updateUserStatus(_ item: VideoSeatItem) {
        if !item.userName.isEmpty {
            userNameLabel.text = item.userName
        } else {
            userNameLabel.text = item.userId
        }
        isOwner = item.userRole == .roomOwner
        homeOwnerImageView.isHidden = !isOwner
        updateOwnerImageConstraints()
        updateUserVolume(hasAudio: item.hasAudioStream, volume: item.audioVolume)
    }

    func updateUserVolume(hasAudio: Bool, volume: Int) {
        if hasAudio {
            let volumeImageName = volume <= 0 ? "tuiroom_voice_volume1" : "tuiroom_voice_volume2"
            voiceVolumeImageView.image = UIImage(named: volumeImageName, in: tuiVideoSeatBundle(), compatibleWith: nil)
        } else {
            voiceVolumeImageView.image = UIImage(named: "tuiroom_audio_none", in: tuiVideoSeatBundle(), compatibleWith: nil)
        }
    }
}
