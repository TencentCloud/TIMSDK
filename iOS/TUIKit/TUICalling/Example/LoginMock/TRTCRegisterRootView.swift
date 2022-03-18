//
//  TRTCRegisterRootView.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit
import Kingfisher

class TRTCRegisterRootView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor(hex: "333333") ?? .black
        label.text = .titleText
        return label
    }()
    
    lazy var headImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var textField: UITextField = {
        let textField = createTextField(.nicknamePlaceholderText)
        return textField
    }()
    
    lazy var textFieldSpacingLine: UIView = {
        let view = createSpacingLine()
        return view
    }()
    
    lazy var descLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = .darkGray
        label.text = .descText
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var registBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(.registText, for: .normal)
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
    
    private func createTextField(_ placeholder: String) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.backgroundColor = .white
        textField.font = UIFont(name: "PingFangSC-Regular", size: 16)
        textField.textColor = UIColor(hex: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.font : UIFont(name: "PingFangSC-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor(hex: "BBBBBB") ?? .gray])
        textField.delegate = self
        return textField
    }
    
    private func createSpacingLine() -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: "EEEEEE")
        return view
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        registBtn.layer.cornerRadius = registBtn.frame.height * 0.5
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
        checkRegistBtnState()
    }
    
    public weak var rootVC: TRTCRegisterViewController?
    
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
        guard let superview = textField.superview else {
            return
        }
        let rect = value as! CGRect
        let converted = superview.convert(textField.frame, to: self)
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
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        
        if let url = ProfileManager.shared.curUserModel?.avatar, url.count > 0 {
            headImageView.kf.setImage(with: URL(string: url))
        } else {
            let url = "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png"
            ProfileManager.shared.curUserModel?.avatar = url
            headImageView.kf.setImage(with: URL(string: url))
        }
    }
    
    func constructViewHierarchy() {
        addSubview(titleLabel)
        addSubview(headImageView)
        addSubview(textField)
        addSubview(textFieldSpacingLine)
        addSubview(descLabel)
        addSubview(registBtn)
    }
    func activateConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(kDeviceSafeTopHeight+10)
        }
        headImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(headImageView.snp.bottom).offset(convertPixel(h: 40))
            make.leading.equalToSuperview().offset(convertPixel(w: 40))
            make.trailing.equalToSuperview().offset(-convertPixel(w: 40))
            make.height.equalTo(convertPixel(h: 57))
        }
        textFieldSpacingLine.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(textField)
            make.height.equalTo(1)
        }
        descLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(convertPixel(w: 40))
            make.trailing.lessThanOrEqualToSuperview().offset(convertPixel(w: -40))
        }
        registBtn.snp.makeConstraints { (make) in
            make.top.equalTo(descLabel.snp.bottom).offset(convertPixel(h: 40))
            make.leading.equalToSuperview().offset(convertPixel(w: 20))
            make.trailing.equalToSuperview().offset(-convertPixel(w: 20))
            make.height.equalTo(convertPixel(h: 52))
        }
    }
    func bindInteraction() {
        registBtn.addTarget(self, action: #selector(registBtnClick), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(headBtnClick))
        headImageView.addGestureRecognizer(tap)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        guard let superview = headImageView.superview else {
            return super.hitTest(point, with: event)
        }
        let rect = superview.convert(headImageView.frame, to: self)
        if rect.contains(point) {
            return headImageView
        }
        return super.hitTest(point, with: event)
    }
    
    @objc func headBtnClick() {
        
    }
    
    @objc func registBtnClick() {
        textField.resignFirstResponder()
        guard let name = textField.text else {
            return
        }
        ProfileManager.shared.curUserModel?.name = name
        rootVC?.regist(name)
    }
    
    func checkRegistBtnState(_ count: Int = -1) {
        if count > -1 {
            registBtn.isEnabled = count > 0
        }
        else {
            registBtn.isEnabled = false
        }
    }
}

extension TRTCRegisterRootView : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
        checkRegistBtnState()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCount = 20
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                  return false
              }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        let res = count <= maxCount
        if res {
            checkRegistBtnState(count)
        }
        return res
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let titleText = LoginLocalize(key:"Demo.TRTC.Login.regist")
    static let nicknamePlaceholderText = LoginLocalize(key:"Demo.TRTC.Login.enterusername")
    static let descText = LoginLocalize(key:"Demo.TRTC.Login.limit20count")
    static let registText = LoginLocalize(key:"Demo.TRTC.Login.regist")
}
