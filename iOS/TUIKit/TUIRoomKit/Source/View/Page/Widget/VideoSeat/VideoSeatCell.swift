//
//  VideoSeatCell.swift
//  TUIVideoSeat
//
//  Created by WesleyLei on 2021/12/16.
//  Copyright © 2021 Tencent. All rights reserved.
//

import SnapKit
import TUIRoomEngine
import UIKit

class VideoSeatCell: UICollectionViewCell {
    var seatItem: VideoSeatItem?
    var viewModel: TUIVideoSeatViewModel?
    
    let renderView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(0x17181F)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()
    
    let backgroundMaskView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(0x17181F)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()
    
    let userInfoView: VideoSeatUserStatusView = {
        let view = VideoSeatUserStatusView()
        return view
    }()
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        contentView.backgroundColor = .clear
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(renderView)
        contentView.addSubview(backgroundMaskView)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(userInfoView)
    }
    
    private func activateConstraints() {
        renderView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }
        backgroundMaskView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }
        userInfoView.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(5)
            make.width.lessThanOrEqualTo(self).multipliedBy(0.9)
        }
    }
    
    @objc private func resetVolumeView() {
        guard let seatItem = seatItem else { return }
        userInfoView.updateUserVolume(hasAudio: seatItem.hasAudioStream, volume: 0)
        renderView.layer.borderColor = UIColor.clear.cgColor
        backgroundMaskView.layer.borderColor = UIColor.clear.cgColor
    }
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        debugPrint("deinit \(self)")
    }
}

// MARK: - Public

extension VideoSeatCell {
    func updateUI(item: VideoSeatItem) {
        seatItem = item
        let placeholder = UIImage(named: "room_default_user", in: tuiRoomKitBundle(), compatibleWith: nil)
        avatarImageView.sd_setImage(with: URL(string: item.avatarUrl), placeholderImage: placeholder)
        avatarImageView.isHidden = item.type == .share ? item.isHasVideoStream : item.hasVideoStream
        backgroundMaskView.isHidden = item.type == .share ? item.isHasVideoStream : item.hasVideoStream
        userInfoView.updateUserStatus(item)
        resetVolumeView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            let width = min(self.mm_w / 2, 72)
            self.avatarImageView.layer.cornerRadius = width * 0.5
            guard let _ = self.avatarImageView.superview else { return }
            self.avatarImageView.snp.remakeConstraints { make in
                make.height.width.equalTo(width)
                make.center.equalToSuperview()
            }
        }
    }
    
    func updateUIVolume(item: VideoSeatItem) {
        userInfoView.updateUserVolume(hasAudio: item.hasAudioStream, volume: item.audioVolume)
        if item.audioVolume > 0 && item.hasAudioStream {
            if item.type != .share {
                renderView.layer.borderColor = UIColor(0xA5FE33).cgColor
                backgroundMaskView.layer.borderColor = UIColor(0xA5FE33).cgColor
            }
        } else {
            renderView.layer.borderColor = UIColor.clear.cgColor
            backgroundMaskView.layer.borderColor = UIColor.clear.cgColor
        }
        resetVolume()
    }
    
    func resetVolume() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(resetVolumeView), object: nil)
        perform(#selector(resetVolumeView), with: nil, afterDelay: 1)
    }
}

class TUIVideoSeatDragCell: VideoSeatCell {
    typealias DragCellClickBlock = () -> Void
    private let clickBlock: DragCellClickBlock
    init(frame: CGRect, clickBlock: @escaping DragCellClickBlock) {
        self.clickBlock = clickBlock
        super.init(frame: frame)
        addGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSize(size: CGSize) {
        var frame = self.frame
        frame.size = size
        self.frame = frame
        center = adsorption(centerPoint: center)
    }
}

// MARK: - gesture

extension TUIVideoSeatDragCell {
    private func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(click))
        addGestureRecognizer(tap)
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragViewDidDrag(gesture:)))
        addGestureRecognizer(dragGesture)
    }
    
    @objc private func click() {
        clickBlock()
    }
    
    @objc private func dragViewDidDrag(gesture: UIPanGestureRecognizer) {
        guard let viewSuperview = superview else { return }
        // 移动状态
        let moveState = gesture.state
        let viewCenter = center
        switch moveState {
        case .changed:
            let point = gesture.translation(in: viewSuperview)
            center = CGPoint(x: viewCenter.x + point.x, y: viewCenter.y + point.y)
            break
        case .ended:
            let point = gesture.translation(in: viewSuperview)
            let newPoint = CGPoint(x: viewCenter.x + point.x, y: viewCenter.y + point.y)
            // 自动吸边动画
            UIView.animate(withDuration: 0.2) {
                self.center = self.adsorption(centerPoint: newPoint)
            }
            break
        default: break
        }
        // 重置 panGesture
        gesture.setTranslation(.zero, in: viewSuperview)
    }
    
    private func adsorption(centerPoint: CGPoint) -> CGPoint {
        guard let viewSuperview = superview else { return centerPoint }
        let limitMargin = 5.0
        let frame = self.frame
        let point = CGPoint(x: centerPoint.x - frame.width / 2, y: centerPoint.y - frame.height / 2)
        var newPoint = point
        // 吸边
        if centerPoint.x < (viewSuperview.frame.width / 2) {
            newPoint.x = limitMargin
        } else {
            newPoint.x = viewSuperview.frame.width - frame.width - limitMargin
        }
        if point.y <= limitMargin {
            newPoint.y = limitMargin
        } else if (point.y + frame.height) > (viewSuperview.frame.height - limitMargin) {
            newPoint.y = viewSuperview.frame.height - frame.height - limitMargin
        }
        return CGPoint(x: newPoint.x + frame.width / 2, y: newPoint.y + frame.height / 2)
    }
}
