//
//  TRTCLoginRootView.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit

class TRTCLoginRootView: UIView {
    
    lazy var bgView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "login_bg"))
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 32)
        label.textColor = UIColor(hex: "333333") ?? .black
        label.text = .titleText
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    
    lazy var countryCodeTipsImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "detail"))
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    lazy var phoneNumTextField: UITextField = {
        let textField = createTextField(.phoneNumPlaceholderText)
        textField.keyboardType = .phonePad
        return textField
    }()
    
    lazy var phoneNumBottomLine: UIView = {
        let view = createSpacingLine()
        return view
    }()
    
    lazy var verifyCodeBottomLine: UIView = {
        let view = createSpacingLine()
        return view
    }()
    
    lazy var loginBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(.loginText, for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.setBackgroundImage(UIColor(hex: "006EFF")?.trans2Image(), for: .normal)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 18)
        btn.layer.shadowColor = UIColor(hex: "006EFF")?.cgColor ?? UIColor.blue.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.shadowRadius = 16
        btn.layer.shadowOpacity = 0.4
        btn.layer.masksToBounds = true
        btn.isEnabled = false
        return btn
    }()
    
    private func createSpacingLine() -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: "EEEEEE")
        return view
    }
    
    private func createTextField(_ placeholder: String) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.backgroundColor = .white
        textField.font = UIFont(name: "PingFangSC-Regular", size: 16)
        textField.textColor = UIColor(hex: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.font : UIFont(name: "PingFangSC-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor(hex: "BBBBBB") ?? .gray])
        textField.delegate = self
        return textField
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.roundedRect(rect: contentView.bounds, byRoundingCorners: .topRight, cornerRadii: CGSize(width: 40, height: 40))
        loginBtn.layer.cornerRadius = loginBtn.frame.height * 0.5
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let current = currentTextField {
            current.resignFirstResponder()
            currentTextField = nil
        }
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
        checkLoginBtnState()
    }
    
    weak var currentTextField: UITextField?
    
    public weak var rootVC: TRTCLoginViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChange(noti:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardFrameChange(noti : Notification) {
        guard let info = noti.userInfo else {
            return
        }
        guard let value = info[UIResponder.keyboardFrameEndUserInfoKey], value is CGRect else {
            return
        }
        guard let superview = loginBtn.superview else {
            return
        }
        let rect = value as! CGRect
        let converted = superview.convert(loginBtn.frame, to: self)
        if rect.intersects(converted) {
            transform = CGAffineTransform(translationX: 0, y: -converted.maxY+rect.minY)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy() // 视图层级布局
        activateConstraints() // 生成约束（此时有可能拿不到父视图正确的frame）
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        addSubview(bgView)
        addSubview(titleLabel)
        addSubview(contentView)
        contentView.addSubview(phoneNumTextField)
        contentView.addSubview(phoneNumBottomLine)
        contentView.addSubview(loginBtn)
    }
    func activateConstraints() {
        bgView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(bgView.snp.width)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(convertPixel(h: 86) + kDeviceSafeTopHeight)
            make.leading.equalToSuperview().offset(convertPixel(w: 40))
            make.trailing.lessThanOrEqualToSuperview().offset(-convertPixel(w: 40))
        }
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(bgView.snp.bottom).offset(-convertPixel(h: 64))
            make.leading.trailing.bottom.equalToSuperview()
        }
        phoneNumTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(convertPixel(h: 40))
            make.leading.equalToSuperview().offset(convertPixel(w: 40))
            make.trailing.equalToSuperview().offset(-convertPixel(w: 40))
            make.height.equalTo(convertPixel(h: 57))
        }
        
        phoneNumBottomLine.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(phoneNumTextField)
            make.height.equalTo(convertPixel(h: 1))
        }
        
        loginBtn.snp.makeConstraints { (make) in
            make.top.equalTo(phoneNumTextField.snp.bottom).offset(convertPixel(h: 40))
            make.leading.equalToSuperview().offset(convertPixel(w: 20))
            make.trailing.equalToSuperview().offset(-convertPixel(w: 20))
            make.height.equalTo(convertPixel(h: 52))
        }
    }
    func bindInteraction() {
        loginBtn.addTarget(self, action: #selector(loginBtnClick), for: .touchUpInside)
    }
    
    @objc func loginBtnClick() {
        if let current = currentTextField {
            current.resignFirstResponder()
        }
        guard let phone = phoneNumTextField.text else {
            return
        }
        rootVC?.login(phone: phone, code: "")
    }
    
    @objc func getVerifyCodeBtnClick() {
        
    }
}

extension TRTCLoginRootView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let last = currentTextField {
            last.resignFirstResponder()
        }
        currentTextField = textField
        textField.becomeFirstResponder()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        currentTextField = nil
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
        checkLoginBtnState()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var maxCount = 11
        if textField == phoneNumTextField {
            maxCount = 11
        }
        else {
            maxCount = 6
        }
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                  return false
              }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        let res = count <= maxCount
        if res {
            var phoneCtt = 0
            var verifyCtt = 0
            if textField == phoneNumTextField {
                phoneCtt = count
                verifyCtt = 6
            }
            else {
                phoneCtt = phoneNumTextField.text?.count ?? 0
                verifyCtt = count
            }
            checkLoginBtnState(phoneCtt: phoneCtt, verifyCtt: verifyCtt)
        }
        return res
    }
    
    func checkLoginBtnState(phoneCtt: Int = -1, verifyCtt: Int = -1) {
        var phone = 0
        var code = 0
        if phoneCtt > -1 || verifyCtt > -1 {
            if phoneCtt > -1 {
                phone = phoneCtt
            }
            else {
                phone = phoneNumTextField.text?.count ?? 0
            }
            if verifyCtt > -1 {
                code = verifyCtt
            }
            else {
                code = 6
            }
        }
        else {
            phone = phoneNumTextField.text?.count ?? 0
            code = 6
        }
        loginBtn.isEnabled = phone > 0 && code == 6
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let titleText = LoginLocalize(key: "Demo.TRTC.Login.welcome")
    static let phoneNumPlaceholderText = LoginLocalize(key:"V2.Live.LinkMicNew.enterphonenumber")
    static let verifyCodePlaceholderText = LoginLocalize(key:"V2.Live.LinkMicNew.enterverificationcode")
    static let getVerifyCodeText = LoginLocalize(key:"V2.Live.LinkMicNew.getverificationcode")
    static let loginText = LoginLocalize(key:"V2.Live.LoginMock.login")
}
