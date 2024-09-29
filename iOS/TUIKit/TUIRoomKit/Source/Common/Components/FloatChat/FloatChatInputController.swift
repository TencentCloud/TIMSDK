//
//  FloatChatInputController.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/5/11.
//  Copyright © 2024 Tencent. All rights reserved.
//

import UIKit
import SnapKit
import Foundation
import TUICore
import Factory

class FloatChatInputController: UIViewController {
    @Injected(\.floatChatService) private var store: FloatChatStoreProvider
    @Injected(\.conferenceStore) private var operation
    
    private var textViewBottomConstraint: Constraint?
    private var textViewHeightConstraint: Constraint?
    private var emojiPanelTopConstraint: Constraint?
    private let maxNumberOfLines = 3
    private let emojiPanelHeight = 274.0
    
    private let inputBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.tui_color(withHex: "#22262E")
        return view
    }()
    
    private let emojiButton: LargeTapAreaButton = {
        let button = LargeTapAreaButton()
        let img = UIImage(named: "room_emoji_icon", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(img, for: .normal)
        return button
    }()
    
    private let inputTextView: UITextView = {
        let view = UITextView(frame: .zero)
        view.font = UIFont.systemFont(ofSize: 17.5)
        view.returnKeyType = UIReturnKeyType.send
        view.enablesReturnKeyAutomatically = true
        view.textContainer.lineBreakMode = .byCharWrapping
        view.textContainerInset = UIEdgeInsets(top: view.textContainerInset.top, left: 10, bottom: view.textContainerInset.bottom, right: 10)
        view.textContainer.lineFragmentPadding = 0
        view.layer.cornerRadius = view.sizeThatFits(.zero).height / 2
        view.layer.masksToBounds = true
        view.isHidden = true
        view.textColor = UIColor.tui_color(withHex: "#D5F4F2", alpha: 0.6)
        view.backgroundColor = UIColor.tui_color(withHex: "#4F586B", alpha: 0.3)
        return view
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle(.sendText, for: .normal)
        button.layer.cornerRadius = 18
        button.backgroundColor = UIColor.tui_color(withHex: "#006CFF")
        return button
    }()
    
    private let backgroundView: UIView = {
        let view = UITextView(frame: .zero)
        view.backgroundColor = UIColor.tui_color(withHex: "#22262E")
        return view
    }()
    
    private lazy var emojiPanel: EmotionBoardView = {
        let emotionBoardView = EmotionBoardView()
        let emotionHelper = EmotionHelper.shared
        emotionBoardView.emotions = emotionHelper.emotions
        emotionBoardView.delegate = self
        emotionBoardView.backgroundColor = UIColor.tui_color(withHex: "#22262E")
        emotionBoardView.isHidden = true
        return emotionBoardView
    }()
    
    private lazy var maxHeightOfTextView: CGFloat = {
        let lineHeight = inputTextView.font?.lineHeight ?? 0
        return ceil(lineHeight * CGFloat(maxNumberOfLines) + inputTextView.textContainerInset.top + inputTextView.textContainerInset.bottom)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showInputView()
    }
    
    private func constructViewHierarchy() {
        inputBarView.addSubview(emojiButton)
        inputBarView.addSubview(inputTextView)
        inputBarView.addSubview(sendButton)
        view.addSubview(backgroundView)
        view.addSubview(inputBarView)
        view.addSubview(emojiPanel)
    }
    
    private func activateConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(inputBarView.snp.top)
        }
        
        inputBarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(inputTextView).offset(2 * 12)
            textViewBottomConstraint = make.bottom.equalTo(view).constraint
        }
        emojiButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(10)
        }
        sendButton.snp.makeConstraints { make in
            make.width.equalTo(64)
            make.height.equalTo(36)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10)
        }
        inputTextView.snp.makeConstraints { make in
            make.leading.equalTo(emojiButton.snp.trailing).offset(10)
            make.trailing.equalTo(sendButton.snp.leading).offset(-10)
            let size = inputTextView.sizeThatFits(.zero)
            textViewHeightConstraint = make.height.equalTo(size.height).constraint
            make.centerY.equalToSuperview()
        }
        emojiPanel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(emojiPanelHeight)
            emojiPanelTopConstraint = make.top.equalTo(view.snp.bottom).constraint
        }
    }
    
    private func bindInteraction() {
        inputTextView.delegate = self
        emojiButton.addTarget(self, action: #selector(onEmojiButtonTapped), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(onSendButtonTapped), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideInputView))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }
        
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardRect: CGRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let curve: UInt = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else {
            return
        }
        let intersection = CGRectIntersection(keyboardRect, self.view.frame)
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve)) { [weak self] in
            guard let self = self else { return }
            self.textViewBottomConstraint?.update(offset: -CGRectGetHeight(intersection))
        }
    }
    
    @objc private func onSendButtonTapped(sender: UIButton) {
        if inputTextView.normalText.isEmpty {
            operation.dispatch(action: ViewActions.showToast(payload: ToastInfo(message: .inputCannotBeEmpty, position: .center)))
        } else {
            store.dispatch(action: FloatChatActions.sendMessage(payload: inputTextView.normalText))
        }
        hideInputView()
    }

    private func showInputView() {
        inputTextView.isHidden = false
        inputTextView.becomeFirstResponder()
    }
    
    @objc private func hideInputView() {
        inputBarView.isHidden = true
        view.endEditing(true)
        store.dispatch(action: FloatViewActions.showFloatInputView(payload: false))
    }
    
    @objc private func onEmojiButtonTapped(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            showEmojiPanel()
        } else {
           hideEmojiPanel()
        }
    }
    
    private func showEmojiPanel() {
        inputTextView.resignFirstResponder()
        emojiPanel.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {  [weak self] in
            guard let self = self else { return }
            self.emojiPanelTopConstraint?.update(offset: -self.emojiPanelHeight)
            self.textViewBottomConstraint?.update(offset: -self.emojiPanelHeight)
        }
    }
    
    private func hideEmojiPanel() {
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.emojiPanelTopConstraint?.update(offset: self.emojiPanelHeight)
        } completion: {[weak self]  _ in
            guard let self = self else { return }
            self.emojiPanel.isHidden = true
            self.inputTextView.becomeFirstResponder()
        }
    }
    
    private func updateTextViewHeight() {
        let currentHeight = ceil(inputTextView.sizeThatFits(CGSize(width: inputTextView.bounds.size.width, height: CGFloat.greatestFiniteMagnitude)).height)
        inputTextView.isScrollEnabled = currentHeight > maxHeightOfTextView
        if currentHeight <= maxHeightOfTextView  {
            textViewHeightConstraint?.update(offset: currentHeight)
        }
    }
}

extension FloatChatInputController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        inputTextView.becomeFirstResponder()
    }

    func textViewDidChange(_ textView: UITextView) {
        updateTextViewHeight()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        inputTextView.resignFirstResponder()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            store.dispatch(action: FloatChatActions.sendMessage(payload: textView.normalText))
            hideInputView()
            return false
        }
        return true
    }
}

extension FloatChatInputController: EmotionBoardViewDelegate {
    func emotionView(emotionBoardView: EmotionBoardView, didSelectEmotion emotion: Emotion, atIndex index: Int) {
        let attributedString = EmotionHelper.shared.obtainImageAttributedString(byImageKey: emotion.displayName,
                                                                         font: inputTextView.font ?? UIFont(), useCache: false)
        inputTextView.insertEmotionAttributedString(emotionAttributedString: attributedString)
    }
    
    func emotionViewDidSelectDeleteButton(emotionBoardView: EmotionBoardView) {
        if !inputTextView.deleteEmotion() {
            inputTextView.deleteBackward()
        }
    }
}

class LargeTapAreaButton: UIButton {

    var tapAreaPadding: CGFloat = 20

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let largerBounds = bounds.insetBy(dx: -tapAreaPadding, dy: -tapAreaPadding)
        return largerBounds.contains(point)
    }
}

private extension String {
    static var sendText: String {
        localized("Send")
    }
    static let inputCannotBeEmpty = localized("Input can't be empty!")
}

