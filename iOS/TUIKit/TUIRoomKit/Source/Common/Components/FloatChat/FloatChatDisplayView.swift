//
//  FloatChatDisplayView.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/5/9.
//  Copyright © 2024 Tencent. All rights reserved.
//

import UIKit
#if USE_OPENCOMBINE
import OpenCombine
import OpenCombineDispatch
#else
import Combine
#endif
import Factory

class FloatChatDisplayView: UIView {
    @Injected(\.floatChatService) private var store: FloatChatStoreProvider
    private lazy var messagePublisher = self.store.select(FloatChatSelectors.getLatestMessage)
    private var messages: [FloatChatMessageView] = []
    var cancellableSet = Set<AnyCancellable>()
    private let messageSpacing: CGFloat = 8
    
    private lazy var blurLayer: CALayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(1).cgColor
        ]
        layer.locations = [0, 0.2]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)

        return layer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurLayer.frame = self.bounds
    }
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        bindInteraction()
        isViewReady = true
    }

    private func constructViewHierarchy() {
        self.layer.mask = blurLayer
    }
    
    func bindInteraction() {
        messagePublisher
            .filter{ !$0.content.isEmpty }
            .receive(on: DispatchQueue.mainQueue)
            .sink { [weak self] floatMessage in
                guard let self = self else { return }
                self.addMessage(floatMessage)
            }
            .store(in: &cancellableSet)
    }
    
    private func addMessage(_ message: FloatChatMessage) {
        let messageView = FloatChatMessageView(floatMessage: message)
        if currentMessageHeight() + messageView.height + messageSpacing > bounds.height {
            removeOldestMessage()
        }
        addSubview(messageView)
        messageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
            make.height.lessThanOrEqualToSuperview()
            if let lastMessage = messages.last {
                make.top.equalTo(lastMessage.snp.bottom).offset(messageSpacing).priority(.high)
            }
            make.bottom.lessThanOrEqualToSuperview()
        }
        messages.append(messageView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.removeMessageWithAnimation(message: messageView)
        }
    }
    
    private func currentMessageHeight() -> CGFloat {
        return messages.reduce(0) { $0 + $1.height + messageSpacing}
    }
    
    private func removeOldestMessage() {
        guard let oldest = messages.first else { return }
        removeMessage(message: oldest)
    }
    
    private func removeMessageWithAnimation(message: FloatChatMessageView) {
        UIView.animate(withDuration: 0.3) {
            message.alpha = 0
        } completion: { _ in
            self.removeMessage(message: message)
        }
    }
    
    private func removeMessage(message: FloatChatMessageView) {
        if let index = messages.firstIndex(of: message) {
            message.removeFromSuperview()
            messages.remove(at: index)
        }
    }
}

extension FloatChatDisplayView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}
