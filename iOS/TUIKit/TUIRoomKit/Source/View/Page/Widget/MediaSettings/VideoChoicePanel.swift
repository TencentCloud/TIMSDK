//
//  VideoChoicePanel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/17.
//  Copyright © 2023 Tencent. All rights reserved.
//  视频的分辨率或者帧率的选择面板
//

import Foundation
#if TXLiteAVSDK_TRTC
import TXLiteAVSDK_TRTC
#elseif TXLiteAVSDK_Professional
import TXLiteAVSDK_Professional
#endif



// MARK: Resolution

class VideoChoicePanel: AlertContentView {
    var dataSource: [String] = []
    var selectIndex = 3
    var titleText: String = ""
    var didSelectItem: ((_ index: Int) -> Void)?
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(0x22262E)
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
            make.top.equalTo(titleLabel.snp.bottom).offset(space.scale375Height())
            make.leading.trailing.bottom.equalToSuperview()
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

extension VideoChoicePanel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResolutionTableViewCell", for: indexPath)
        if let scell = cell as? ResolutionTableViewCell {
            scell.titleLabel.text = dataSource[indexPath.row]
            scell.isSelected = indexPath.row == selectIndex
        }
        return cell
    }
}

extension VideoChoicePanel: UITableViewDelegate {
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
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = UIColor(0xD1D9EC)
        return label
    }()
    
    let checkboxImageView: UIImageView = {
        let norImage = UIImage(named: "room_checkbox_sel", in: tuiRoomKitBundle(), compatibleWith: nil)
        let imageView = UIImageView(image: norImage)
        imageView.isHidden = true
        return imageView
    }()
    
    override var isSelected: Bool {
        didSet {
            checkboxImageView.isHidden = !isSelected
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
            make.size.equalTo(CGSize(width: 16, height: 16))
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
    let space: Int = 16
    let landscapeHight: CGFloat = min(kScreenWidth, kScreenHeight)
    let portraitHight: CGFloat = 718
    private var currentLandscape: Bool = isLandscape
    let bgView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        view.alpha = 0.6
        return view
    }()

    let contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(0x22262E)
        view.layer.cornerRadius = 12
        return view
    }()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "room_back_white", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        button.backgroundColor = .clear
        return button
    }()

    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(0xD1D9EC)
        label.textAlignment = .center
        label.font = UIFont(name: "PingFangSC-Medium", size: 16)
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
        let backButtonFrame = backButton.frame.inset(by: UIEdgeInsets.init(top: -space.scale375Height(), left: -space.scale375(), bottom: -space.scale375Height(), right: -space.scale375()))
        if !contentView.frame.contains(point) || backButtonFrame.contains(point) {
            dismiss()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard currentLandscape != isLandscape else { return }
        setupViewOrientation(isLandscape: isLandscape)
        currentLandscape = isLandscape
    }

    func constructViewHierarchy() {
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
    }

    func activateConstraints() {
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupViewOrientation(isLandscape: isLandscape)
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.leading.equalToSuperview().offset(space.scale375())
            make.centerY.equalTo(titleLabel)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(space.scale375Height())
            make.centerX.equalToSuperview()
            make.width.equalTo(64.scale375())
        }
    }

    func bindInteraction() {
        backButton.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
    }
    
    private func setupViewOrientation(isLandscape: Bool) {
        contentView.snp.remakeConstraints { make in
            if isLandscape {
                make.height.equalTo(landscapeHight)
            } else {
                make.height.equalTo(portraitHight)
            }
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    @objc func backAction(sender: UIButton) {
        dismiss()
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
