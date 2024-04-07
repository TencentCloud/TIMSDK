//
//  LocalAudioView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2024/1/5.
//

import Foundation

class LocalAudioView: UIView {
    let viewModel: LocalAudioViewModel
    lazy var muteAudioButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "room_mic_on", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "room_mic_off", in: tuiRoomKitBundle(), compatibleWith: nil), for: .selected)
        button.isSelected = viewModel.checkMuteAudioSelectedState()
        button.backgroundColor = UIColor(0x2A2D38)
        button.layer.cornerRadius = 12
        return button
    }()
    
    init(viewModel: LocalAudioViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.transform = CGAffineTransform(translationX: 0, y: kScreenHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit:\(self)")
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
    
    private func constructViewHierarchy() {
        addSubview(muteAudioButton)
    }
    
    private func activateConstraints() {
        muteAudioButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bindInteraction() {
        viewModel.viewResponder = self
        muteAudioButton.addTarget(self, action: #selector(muteAudioAction(sender:)), for: .touchUpInside)
    }
    
    @objc func muteAudioAction(sender: UIButton) {
        viewModel.muteAudioAction()
    }
    
    func show() {
        UIView.animate(withDuration: 0.3) { [weak self] () in
            guard let self = self else { return }
            self.transform = .identity
        } completion: { _ in
        }
    }
    
    func hide() {
        self.transform = CGAffineTransform(translationX: 0, y: kScreenHeight)
    }
}

extension LocalAudioView: LocalAudioViewModelResponder {
    func updateMuteAudioButton(isSelected: Bool) {
        muteAudioButton.isSelected = isSelected
    }
    func makeToast(text: String) {
        RoomRouter.makeToastInCenter(toast: text, duration: 1)
    }
}
