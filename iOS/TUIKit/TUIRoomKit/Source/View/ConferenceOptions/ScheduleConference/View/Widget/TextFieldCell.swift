//
//  TextFieldCell.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/7/2.
//

import Foundation
import Factory

class TextFieldCell: ScheduleBaseCell {
    static let identifier = "TextFieldCell"
    private var item: CellConfigItem?
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = UIColor(0x2B2E38)
        view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        view.textAlignment = isRTL ? .right : .left
        return view
    }()
    
    lazy var textField: UITextField = {
        let view = UITextField(frame: .zero)
        view.backgroundColor = .clear
        view.textColor = UIColor(0x2B2E38).withAlphaComponent(0.7)
        view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        view.keyboardType = .default
        view.textAlignment = isRTL ? .left : .right
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100.scale375(), height: 50.scale375Height()))
        toolbar.barStyle = .default
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil), UIBarButtonItem(title: .ok, style: .done, target: self, action: #selector(saveTextField))]
        view.inputAccessoryView = toolbar
        view.delegate = self
        return view
    }()
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
    }
    
    private func activateConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20.scale375())
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(100.scale375())
        }
        textField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-23.scale375())
            make.leading.equalTo(titleLabel.snp.trailing).offset(20.scale375())
            make.centerY.equalToSuperview()
        }
        
    }
    
    func updateView(item: CellConfigItem) {
        guard let textFieldItem = item as? TextFieldItem else { return }
        self.item = item
        titleLabel.text = item.title
        textField.text = textFieldItem.content
        textField.isEnabled = textFieldItem.isEnable
        textField.keyboardType = textFieldItem.keyboardType
        textField.placeholder = textFieldItem.placeholder
    }
    
    @objc func saveTextField() {
        if let textFieldItem = item as? TextFieldItem, let text = textField.text {
            textFieldItem.saveTextClosure?(text)
        }
        textField.resignFirstResponder()
    }
    
    deinit {
        debugPrint("deinit:\(self)")
    }
}


extension TextFieldCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldItem = item as? TextFieldItem else { return false }
        guard let text = textField.text else { return true }
        if string.count > 0, string.trimmingCharacters(in: .whitespaces).isEmpty, range.location == 0 {
            return false
        }
        let currentLengthInBytes = Array(text.utf8).count
        let replacementLengthInBytes = Array(string.utf8).count
        if currentLengthInBytes + replacementLengthInBytes > textFieldItem.maxLengthInBytes {
            return false
        }
        return true
    }
}

private extension String {
    static let ok = localized("OK")
}
