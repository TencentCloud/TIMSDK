//
//  ResolutionAlert.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
#if TXLiteAVSDK_TRTC
import TXLiteAVSDK_TRTC
#elseif TXLiteAVSDK_Professional
import TXLiteAVSDK_Professional
#endif

class BitrateTableData: NSObject {
    let resolutionName: String
    let resolution: TRTCVideoResolution
    let defaultBitrate: Float
    let minBitrate: Float
    let maxBitrate: Float
    let stepBitrate: Float
    
    init(resolutionName: String,
         resolution: TRTCVideoResolution,
         defaultBitrate: Float,
         minBitrate: Float,
         maxBitrate: Float,
         stepBitrate: Float) {
        self.resolutionName = resolutionName
        self.resolution = resolution
        self.defaultBitrate = defaultBitrate
        self.minBitrate = minBitrate
        self.maxBitrate = maxBitrate
        self.stepBitrate = stepBitrate
        super.init()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: Resolution

class ResolutionAlert: AlertContentView {
    var dataSource: [BitrateTableData] = []
    var selectIndex = 3
    var titleText: String = ""
    var didSelectItem: ((_ index: Int) -> Void)?
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(0x1B1E26)
        return tableView
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
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
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(248)
        }
    }
    
    override func bindInteraction() {
        super.bindInteraction()
        titleLabel.text = titleText
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ResolutionTableViewCell.self,
                           forCellReuseIdentifier: "ResolutionTableViewCell")
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension ResolutionAlert: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResolutionTableViewCell", for: indexPath)
        if let scell = cell as? ResolutionTableViewCell {
            let model = dataSource[indexPath.row]
            scell.titleLabel.text = model.resolutionName
            scell.isSelected = indexPath.row == selectIndex
        }
        return cell
    }
}

extension ResolutionAlert: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectIndex = indexPath.row
        tableView.reloadSections(IndexSet(integer: 0), with: .none)
        if let action = didSelectItem {
            action(selectIndex)
        }
        dismiss()
    }
}

class ResolutionTableViewCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Medium", size: 16)
        label.textColor = UIColor(0x666666)
        return label
    }()
    
    let checkboxImageView: UIImageView = {
        let norImage = UIImage(named: "tuiroom_checkbox_nor")
        let imageView = UIImageView(image: norImage)
        return imageView
    }()
    
    override var isSelected: Bool {
        didSet {
            checkboxImageView.image = isSelected ? UIImage(named: "tuiroom_checkbox_sel") : UIImage(named: "tuiroom_checkbox_nor")
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = .clear
        selectionStyle = .none
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkboxImageView)
    }
    
    func activateConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        checkboxImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: Base

class AlertContentView: UIView {
    let bgView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        view.alpha = 0.6
        return view
    }()
    
    let contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(0x1B1E26)
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = UIFont(name: "PingFangSC-Medium", size: 24)
        return label
    }()
    
    var willDismiss: (() -> Void)?
    var didDismiss: (() -> Void)?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        contentView.transform = CGAffineTransform(translationX: 0, y: kScreenHeight)
        alpha = 0
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
    
    func show(rootView: UIView) {
        rootView.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.alpha = 1
            self.contentView.transform = .identity
        }
    }
    
    func dismiss() {
        if let action = willDismiss {
            action()
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.alpha = 0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: kScreenHeight)
        } completion: { [weak self] _ in
            guard let self = self else { return }
            if let action = self.didDismiss {
                action()
            }
            self.removeFromSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        if !contentView.frame.contains(point) {
            dismiss()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.roundedRect(rect: contentView.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 12, height: 12))
    }
    
    func constructViewHierarchy() {
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(titleLabel)
    }
    
    func activateConstraints() {
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(32)
        }
    }
    
    func bindInteraction() {
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
