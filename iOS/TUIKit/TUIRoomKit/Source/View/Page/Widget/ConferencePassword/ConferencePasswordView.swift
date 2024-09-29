//
//  ConferencePasswordView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/7/30.
//

import Foundation
import Factory
import RTCRoomEngine

class ConferencePasswordView: UIView {
    var roomId: String?
    private let maxNumber = 6
    weak var viewModel: ConferenceMainViewModel?
    
    let shieldingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x0F1014).withAlphaComponent(0.7)
        return view
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0xFFFFFF)
        view.layer.cornerRadius = 10
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.text = .conferencePassword
        view.backgroundColor = .clear
        view.textColor = UIColor(0x0F1014)
        view.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.textAlignment = .center
        return view
    }()
    
    lazy var textField: UITextField = {
        let view = UITextField(frame: .zero)
        view.backgroundColor = .clear
        view.placeholder = .pleaseEnterTheConferencePassword
        view.textColor = UIColor(0x2B2E38)
        view.tintColor = UIColor(0x2B2E38).withAlphaComponent(0.7)
        view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        view.keyboardType = .numberPad
        view.textAlignment = isRTL ? .right : .left
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(0x1C66E5).cgColor
        view.delegate = self
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.leftViewMode = .always
        let deleteButton = UIButton(type: .system)
        deleteButton.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        deleteButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        deleteButton.setImage(UIImage(named: "room_cancel", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteAction(sender:)), for: .touchUpInside)
        view.rightView = deleteButton
        view.rightViewMode = .whileEditing
        return view
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(.cancel, for: .normal)
        button.setTitleColor(UIColor(0x4F586B), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor(0xD5E0F2).withAlphaComponent(0.5).cgColor
        return button
    }()
    
    let sureButton: UIButton = {
        let button = UIButton()
        button.setTitle(.join, for: .normal)
        button.setTitleColor(UIColor(0x1C66E5), for: .normal)
        button.setTitleColor(UIColor(0x1C66E5).withAlphaComponent(0.5), for: .disabled)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor(0xD5E0F2).withAlphaComponent(0.5).cgColor
        return button
    }()
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    private func constructViewHierarchy() {
        addSubview(shieldingView)
        addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        contentView.addSubview(cancelButton)
        contentView.addSubview(sureButton)
    }
    
    private func activateConstraints() {
        shieldingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(323.scale375())
            make.height.equalTo(180.scale375Height())
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24.scale375Height())
            make.centerX.equalToSuperview()
        }
        textField.snp.makeConstraints { make in
            make.height.equalTo(40.scale375Height())
            make.width.equalTo(298.scale375())
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(14.scale375Height())
        }
        cancelButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.leading.equalToSuperview()
            make.height.equalTo(54.scale375Height())
            make.bottom.equalToSuperview()
        }
        sureButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.trailing.equalToSuperview()
            make.height.equalTo(54.scale375Height())
            make.bottom.equalToSuperview()
        }
    }
    
    private func bindInteraction() {
        cancelButton.addTarget(self, action: #selector(cancelAction(sender:)), for: .touchUpInside)
        sureButton.addTarget(self, action: #selector(sureAction(sender:)), for: .touchUpInside)
        updateSureButton()
    }
    
    private func updateSureButton() {
        guard let text = textField.text else { return }
        sureButton.isEnabled = text.count > 0
    }
    
    @objc func cancelAction(sender: UIButton) {
        guard superview != nil else { return }
        removeFromSuperview()
        guard let roomId = roomId else { return }
        viewModel?.handleWrongPasswordFault(roomId: roomId)
    }
    
    @objc func sureAction(sender: UIButton) {
        guard superview != nil else { return }
        viewModel?.joinConferenceParams?.password = textField.text
        viewModel?.joinConference()
    }
    
    func hide() {
        self.isHidden = true
        textField.resignFirstResponder()
    }
    
    func show(roomId: String) {
        self.roomId = roomId
        self.isHidden = false
    }
    
    @objc func deleteAction(sender: UIButton) {
        textField.text = ""
        sureButton.isEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        guard layer.contains(point) else { return }
        textField.resignFirstResponder()
    }
    
    deinit {
        debugPrint("deinit:\(self)")
    }
    
    @Injected(\.conferenceStore) private var store
}

extension ConferencePasswordView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.isSecureTextEntry = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isSecureTextEntry = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newText = NSString(string: text).replacingCharacters(in: range, with: string)
        sureButton.isEnabled = newText.count > 0
        return newText.count <= maxNumber
    }
}

private extension String {
    static let conferencePassword = localized("Conference password")
    static let join = localized("Join")
    static let cancel = localized("Cancel")
    static let pleaseEnterTheConferencePassword = localized("Please enter your room password")
}
