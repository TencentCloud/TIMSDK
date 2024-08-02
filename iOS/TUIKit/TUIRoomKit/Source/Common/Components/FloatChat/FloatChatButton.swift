//
//  FloatChatButton.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/5/9.
//  Copyright © 2024 Tencent. All rights reserved.
//

import UIKit
import Foundation
#if USE_OPENCOMBINE
import OpenCombine
import OpenCombineDispatch
#else
import Combine
#endif
import Factory

class FloatChatButton: UIView {
    @Injected(\.floatChatService) private var store: FloatChatStoreProvider
    private lazy var floatInputViewShowState = self.store.select(FloatChatSelectors.getShowFloatInputView)
    var cancellableSet = Set<AnyCancellable>()
    weak var inputController: UIViewController?
    var roomId: String
    
    init(roomId: String) {
        self.roomId = roomId
        super.init(frame: .zero)
        store.dispatch(action: FloatChatActions.setRoomId(payload: roomId))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let emojiView: UIImageView = {
        let emojiImage = UIImage(named: "room_emoji_icon", in: tuiRoomKitBundle(), compatibleWith: nil)
        let imageView = UIImageView(image: emojiImage)
        return imageView
    }()
    
    private let label: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = UIColor.tui_color(withHex: "D5E0F2")
        view.font = UIFont(name: "PingFangSC-Regular", size: 12)
        view.text = .placeHolderText
        view.sizeToFit()
        return view
    }()
    
    private let clickView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    private func constructViewHierarchy() {
        addSubview(emojiView)
        addSubview(label)
        addSubview(clickView)
    }
    
    private func activateConstraints() {
        emojiView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        label.snp.makeConstraints { make in
            make.leading.equalTo(emojiView.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(24)
        }
        clickView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bindInteraction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showInputView))
        clickView.addGestureRecognizer(tap)

        floatInputViewShowState
            .receive(on: DispatchQueue.mainQueue)
            .sink { [weak self] showFloatChatInput in
                guard let self = self else { return }
                if showFloatChatInput {
                    let inputController = FloatChatInputController()
                    inputController.view.backgroundColor = .clear
                    let navController = UINavigationController(rootViewController: inputController)
                    navController.isNavigationBarHidden = true
                    navController.navigationBar.prefersLargeTitles = true
                    navController.modalPresentationStyle = .overFullScreen
                    RoomCommon.getCurrentWindowViewController()?.present(navController, animated: true, completion: nil)
                    self.inputController = inputController
                } else {
                    self.inputController?.dismiss(animated: true)
                }
            }
            .store(in: &cancellableSet)
    }
    
    @objc private func showInputView() {
        store.dispatch(action: FloatViewActions.showFloatInputView(payload: true))
    }
}

private extension String {
    static var placeHolderText: String {
        localized("Say something")
    }
}
