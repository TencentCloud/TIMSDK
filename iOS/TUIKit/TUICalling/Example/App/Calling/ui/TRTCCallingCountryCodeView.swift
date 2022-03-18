//
//  TRTCCallingCountryCodeView.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/30.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation
import TXAppBasic
import UIKit
import ImSDK_Plus

public class TRTCCallingCountryAlert: TRTCCallingAlertContentView {
    
    lazy var dataSource: [TRTCCallingCountryModel] = {
        let list = TRTCCallingCountryModel.loginCountryList
        return list
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.clear
        return tableView
    }()
    
    public var didSelect: ((_ model: TRTCCallingCountryModel)->())?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        titleLabel.text = .titleText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(tableView)
    }
    override func activateConstraints() {
        super.activateConstraints()
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(ScreenHeight * 2 / 3)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    override func bindInteraction() {
        super.bindInteraction()
        
        tableView.register(TRTCCallingCountryListCell.self, forCellReuseIdentifier: "TRTCCallingCountryListCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension TRTCCallingCountryAlert: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TRTCCallingCountryListCell", for: indexPath)
        if let scell = cell as? TRTCCallingCountryListCell {
            let model = dataSource[indexPath.row]
            scell.model = model
        }
        return cell
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
extension TRTCCallingCountryAlert: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let action = didSelect {
            action(dataSource[indexPath.row])
        }
        dismiss()
    }
}

class TRTCCallingCountryListCell: UITableViewCell {
    
    var model: TRTCCallingCountryModel? {
        didSet {
            guard let model = model else {
                return
            }
            titleLabel.text = model.countryName
            descLabel.text = model.displayTitle
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 18)
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var descLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = UIColor.black
        label.alpha = 0.6
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)
    }
    
    func activateConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        descLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    func bindInteraction() {
        
    }
}
public class TRTCCallingAlertContentView: UIView {
    lazy var bgView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.black
        view.alpha = 0.6
        return view
    }()
    lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor.black
        label.font = UIFont(name: "PingFangSC-Medium", size: 24)
        return label
    }()
    
    public var willDismiss: (()->())?
    public var didDismiss: (()->())?
    
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        contentView.transform = CGAffineTransform(translationX: 0, y: ScreenHeight)
        alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady = false
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    public func show() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.contentView.transform = .identity
        }
    }
    
    public func dismiss() {
        if let action = willDismiss {
            action()
        }
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: ScreenHeight)
        } completion: { (finish) in
            if let action = self.didDismiss {
                action()
            }
            self.removeFromSuperview()
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        if !contentView.frame.contains(point) {
            dismiss()
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.roundedRect(rect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
    }
    
    func constructViewHierarchy() {
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(titleLabel)
    }
    func activateConstraints() {
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(32)
        }
    }
    func bindInteraction() {
        
    }
}

public class TRTCCallingCountryModel: NSObject {
    public let code: String
    let displayEN: String
    let displayZH: String
    init(code: Int, displayEN: String, displayZH: String) {
        self.code = String(code)
        self.displayEN = displayEN
        self.displayZH = displayZH
        super.init()
    }
    
    public var displayTitle: String {
        get {
            return "+\(code)"
        }
    }
    
    public var countryName: String {
        get {
            if isChineseLanguage() {
                return displayZH
            }
            else {
                return displayEN
            }
        }
    }
    
    func isChineseLanguage() -> Bool {
        guard let preferredLang = Bundle.main.preferredLocalizations.first else {
            return false
        }
        return String(describing: preferredLang).hasPrefix("zh-")
    }
    
    static var loginCountryList: [TRTCCallingCountryModel] {
        get {
            let list = loadLoginCountryJson()
            var res : [TRTCCallingCountryModel] = []
            list.forEach { (dic) in
                if let code = dic["code"] as? Int, let en = dic["en"] as? String, let zh = dic["zh"] as? String {
                    let model = TRTCCallingCountryModel(code: code, displayEN: en, displayZH: zh)
                    res.append(model)
                }
            }
            return res
        }
    }
    
    static func loadLoginCountryJson() -> [[String:Any]] {
        guard let path = Bundle.main.path(forResource: "LoginCountryList", ofType: "json") else {
            return []
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return []
        }
        let value = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        if let res = value as? [[String:Any]] {
            return res
        }
        return []
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let titleText = CallingLocalize("Demo.TRTC.Login.countrycode")
}
