//
//  RaiseHandNoticeView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/4/7.
//

import Foundation

class RaiseHandNoticeView: UIView {
    let imageView: UIImageView = {
        let image = UIImage(named: "room_raiseHand_notice", in: tuiRoomKitBundle(), compatibleWith: nil)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    let dismissButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "room_raiseHand_dismiss", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(image, for: .normal)
        return button
    }()
    let label: UILabel = {
        let label = UILabel()
        label.text = .raiseHandNotice
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    init() {
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        debugPrint("deinit \(self)")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    private func constructViewHierarchy() {
        addSubview(imageView)
        addSubview(label)
        addSubview(dismissButton)
    }
    
    private func activateConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-2)
            make.leading.equalToSuperview().offset(12)
            make.width.equalTo(250)
            make.height.equalTo(20)
        }
        dismissButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-2)
            make.trailing.equalToSuperview().offset(-12)
            make.width.height.equalTo(20)
        }
    }
    
    private func bindInteraction() {
        dismissButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
    }
    
    @objc func dismiss() {
        isHidden = true
        EngineManager.createInstance().changeRaiseHandNoticeState(isShown: false)
    }
}

private extension String {
    static var raiseHandNotice: String {
        localized("TUIRoom.raiseHand.notice")
    }
}
