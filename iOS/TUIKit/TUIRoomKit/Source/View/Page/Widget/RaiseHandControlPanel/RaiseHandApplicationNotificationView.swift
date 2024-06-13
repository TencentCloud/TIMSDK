//
//  RaiseHandApplicationNotificationView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/5/8.
//

import Foundation

protocol RaiseHandApplicationNotificationViewListener: AnyObject {
    func onHidden()
    func onShown()
}

class RaiseHandApplicationNotificationView: UIView {
    let viewModel: RaiseHandApplicationNotificationViewModel
    weak var delegate: RaiseHandApplicationNotificationViewListener?
    private let imageView: UIImageView = {
        let image = UIImage(named: "room_raise_hand_notification", in: tuiRoomKitBundle(), compatibleWith: nil)
        return UIImageView(image: image)
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = isRTL ? .right : .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(0x181820)
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    
    private let checkButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle(.checkText, for: .normal)
        button.setTitleColor(UIColor(0x1C66E5), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    init(viewModel: RaiseHandApplicationNotificationViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.viewModel.responder = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - view layout
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(imageView)
        addSubview(label)
        addSubview(checkButton)
    }
    
    func activateConstraints() {
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8.scale375Height())
            make.width.height.equalTo(24.scale375())
        }
        checkButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-6.scale375())
            make.height.equalTo(22.scale375Height())
            make.width.equalTo(48.scale375())
        }
        label.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(10.scale375())
            make.trailing.equalTo(checkButton.snp.leading).offset(-10.scale375())
            make.centerY.equalToSuperview()
            make.height.equalTo(22.scale375Height())
        }
    }
    
    func bindInteraction() {
        isHidden = true
        backgroundColor = UIColor(0xFFFFFF)
        layer.cornerRadius = 6
        checkButton.addTarget(self, action: #selector(checkAction(sender:)), for: .touchUpInside)
        guard viewModel.isShownRaiseHandApplicationNotificationView else { return }
        guard let userId = viewModel.userId, let userName = viewModel.userName, let count = viewModel.applicationCount else { return }
        show(userId: userId, userName: userName, count: count)
    }
    
    @objc private func checkAction(sender: UIButton) {
        hide()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hide), object: nil)
        viewModel.checkRaiseHandApplicationAction()
    }
    
    func show(userId: String, userName: String, count: Int) {
        isHidden = false
        let nameText = userName ?? userId
        let title = count > 1 ?
            .multiApplyingOnStageText.replacingOccurrences(of: "xx", with: nameText).replacingOccurrences(of: "yy", with: String(count))
            : localizedReplace(.singleApplyingOnStageText, replace: nameText)
        label.text = title
        delegate?.onShown()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hide), object: nil)
        guard viewModel.delayDisappearanceTime > 0 else { return }
        perform(#selector(hide), with: nil, afterDelay: viewModel.delayDisappearanceTime)
    }
    
    @objc func hide() {
        isHidden = true
        delegate?.onHidden()
    }
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
}

extension RaiseHandApplicationNotificationView: RaiseHandApplicationNotificationViewModelResponder {
    func showRaiseHandApplicationNotificationView(userId: String, userName: String, count: Int) {
        show(userId: userId, userName: userName, count: count)
    }
    
    func hideRaiseHandApplicationNotificationView() {
        hide()
    }
}

private extension String {
    static var checkText: String {
        localized("Check")
    }
    static var singleApplyingOnStageText: String {
        localized("xx is applying to be on stage.")
    }
    static var multiApplyingOnStageText: String {
        localized("Including xx, yy people are applying to be on stage.")
    }
}
