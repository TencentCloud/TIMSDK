//
//  RoomVideoFloatView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/7/11.
//  悬浮窗
//

import Foundation

class RoomVideoFloatView: UIView {
    private var isDraging: Bool = false
    private let viewModel: RoomVideoFloatViewModel
    private let space: CGFloat = 10
    private let renderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x5C5C5C)
        return view
    }()
    
    private let shutterView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x17181F)
        view.isHidden = true
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    private let userStatusView: RoomUserStatusView = {
        let view = RoomUserStatusView(frame: .zero)
        return view
    }()
    
    override init(frame: CGRect) {
        viewModel = RoomVideoFloatViewModel()
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        debugPrint("deinit:\(self)")
    }
    
    // MARK: - view layout
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        backgroundColor = .clear
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        roundedRect(rect: bounds,
                                byRoundingCorners: .allCorners,
                                cornerRadii: CGSize(width: 10, height: 10))
        avatarImageView.roundedCircle(rect: avatarImageView.bounds)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDraging {
            self.center = adsorption(centerPoint: self.center)
        }
    }
    
    func constructViewHierarchy() {
        addSubview(renderView)
        addSubview(shutterView)
        addSubview(avatarImageView)
        addSubview(userStatusView)
    }
    
    func activateConstraints() {
        renderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        shutterView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        avatarImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(50)
        }
        userStatusView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.width.lessThanOrEqualTo(self).multipliedBy(0.9)
        }
    }
    
    func bindInteraction() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(panGesture:)))
        addGestureRecognizer(panGesture)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        addGestureRecognizer(tap)
        viewModel.viewResponder = self
        viewModel.showFloatWindowViewVideo(renderView: renderView)
        setupViewState()
    }
    
    private func setupViewState() {
        guard let userModel = viewModel.engineManager.store.attendeeList.first(where: { $0.userId == viewModel.userId }) else { return }
        let placeholder = UIImage(named: "room_default_user", in: tuiRoomKitBundle(), compatibleWith: nil)
        avatarImageView.sd_setImage(with: URL(string: userModel.avatarUrl), placeholderImage: placeholder)
        userStatusView.updateUserVolume(hasAudio: userModel.hasAudioStream, volume: userModel.userVoiceVolume)
    }
    
    @objc func didTap(sender: UIView) {
        viewModel.showRoomMainView()
    }
    
    @objc func didPan(panGesture: UIPanGestureRecognizer) {
        guard let viewSuperview = superview else { return }
        // 移动状态
        let moveState = panGesture.state
        let viewCenter = center
        switch moveState {
        case .changed:
            isDraging = true
            let point = panGesture.translation(in: viewSuperview)
            center = CGPoint(x: viewCenter.x + point.x, y: viewCenter.y + point.y)
            break
        case .ended:
            let point = panGesture.translation(in: viewSuperview)
            let newPoint = CGPoint(x: viewCenter.x + point.x, y: viewCenter.y + point.y)
            // 自动吸边动画
            UIView.animate(withDuration: 0.2) {
                self.center = self.adsorption(centerPoint: newPoint)
            }
            isDraging = false
            break
        default: break
        }
        // 重置 panGesture
        panGesture.setTranslation(.zero, in: viewSuperview)
    }
    
    class func show(width: CGFloat = 100, height: CGFloat = 180) {
        DispatchQueue.main.async {
            guard let currentWindow = RoomRouter.getCurrentWindow() else { return }
            let roomFloatView = RoomVideoFloatView()
            currentWindow.addSubview(roomFloatView)
            roomFloatView.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-5)
                make.bottom.equalToSuperview().offset(-100)
                make.width.equalTo(width)
                make.height.equalTo(height)
            }
        }
    }
    
    class func dismiss() {
        DispatchQueue.main.async {
            guard let currentWindow = RoomRouter.getCurrentWindow() else { return }
            for view in currentWindow.subviews where view is RoomVideoFloatView {
                view.removeFromSuperview()
            }
        }
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
    
    private func resetVolume() {
       NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(resetVolumeView), object: nil)
       perform(#selector(resetVolumeView), with: nil, afterDelay: 1)
   }
   
    @objc func resetVolumeView() {
        guard let userItem = viewModel.getUserEntity(userId: viewModel.userId) else { return }
        userStatusView.updateUserVolume(hasAudio: userItem.hasAudioStream, volume: 0)
    }
}

extension RoomVideoFloatView: RoomVideoFloatViewResponder {
    func makeToast(text: String) {
        RoomRouter.makeToastInCenter(toast: text, duration: 0.5)
    }
    
    func updateUserStatus(user: UserEntity) {
        let placeholder = UIImage(named: "room_default_user", in: tuiRoomKitBundle(), compatibleWith: nil)
        avatarImageView.sd_setImage(with: URL(string: user.avatarUrl), placeholderImage: placeholder)
        userStatusView.updateUserStatus(userModel: user)
    }
    
    func updateUserAudioVolume(hasAudio: Bool, volume: Int) {
        userStatusView.updateUserVolume(hasAudio: hasAudio, volume: volume)
        resetVolume()
    }
    
    func showAvatarImageView(isShow: Bool) {
        shutterView.isHidden = !isShow
        avatarImageView.isHidden = !isShow
    }
}
