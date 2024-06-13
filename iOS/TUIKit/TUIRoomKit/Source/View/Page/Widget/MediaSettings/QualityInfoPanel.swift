//
//  QualityInfoPanel.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/4/19.
//  Copyright © 2024 Tencent. All rights reserved.
//

import Foundation

class QualityInfoPanel: UIView {
    var viewModel: QualityInfoViewModel = QualityInfoViewModel()
    let landscapeHight: CGFloat = min(kScreenWidth, kScreenHeight)
    let portraitHight: CGFloat = 411.scale375Height()
    private let arrowViewHeight: CGFloat = 35.0
    private let cellHeight: CGFloat = 33.0
    private let lineViewHorizontalMargin = 16.0
    private let headerHeight = 48
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
    
    private let dropArrowView : UIView = {
        let view = UIView()
        return view
    }()
    
    private let dropArrowImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "room_drop_arrow", in:tuiRoomKitBundle(), compatibleWith: nil)
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(0x22262E)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QualityTableViewCell.self,
                           forCellReuseIdentifier: "QualityTableViewCell")
        tableView.sectionHeaderHeight = headerHeight.scale375()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } 
        return tableView
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
        self.viewModel.viewResponder = self
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard currentLandscape != isLandscape else { return }
        setupViewOrientation(isLandscape: isLandscape)
        currentLandscape = isLandscape
    }

    func constructViewHierarchy() {
        addSubview(bgView)
        addSubview(contentView)
        dropArrowView.addSubview(dropArrowImageView)
        contentView.addSubview(dropArrowView)
        contentView.addSubview(tableView)
    }

    func activateConstraints() {
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupViewOrientation(isLandscape: isLandscape)
        dropArrowView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(arrowViewHeight)
        }
        dropArrowImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(24.scale375())
            make.height.equalTo(3.scale375())
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(dropArrowView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func bindInteraction() {
        let dropArrowTap = UITapGestureRecognizer(target: self, action: #selector(dropDownPopUpViewAction(sender:)))
        dropArrowView.addGestureRecognizer(dropArrowTap)
        dropArrowView.isUserInteractionEnabled = true
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
    
    @objc func dropDownPopUpViewAction(sender: UIView) {
        dismiss()
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

extension QualityInfoPanel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
}

extension QualityInfoPanel: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QualityTableViewCell", for: indexPath)
        if let qualityCell = cell as? QualityTableViewCell {
            qualityCell.setCellModel(model: self.viewModel.sections[indexPath.section].items[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight.scale375()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[safe: section]?.titleText
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        view.textLabel?.textColor = UIColor(0x99A2B2)
        view.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.textLabel?.textAlignment = isRTL ? .right : .left
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == self.viewModel.sections.count - 1 {
            return 0
        }
        return 0.5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == self.viewModel.sections.count - 1 {
            return nil
        }
        let footerView = UIView()
        let lineView = UIView(frame: CGRect(x: lineViewHorizontalMargin, 
                                            y: 0,
                                            width: tableView.frame.size.width - 2 * lineViewHorizontalMargin,
                                            height: 0.5))
        lineView.backgroundColor = UIColor(0xB2BBD1)
        footerView.addSubview(lineView)
        return footerView
    }
}

extension QualityInfoPanel: QualityViewResponder {
    func reloadData() {
        self.tableView.reloadData()
    }
}

class QualityTableViewCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = UIColor(0xE7ECF6)
        label.sizeToFit()
        return label
    }()
    
    let normalInfoLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = UIColor(0xE7ECF6)
        label.isHidden = true
        label.sizeToFit()
        return label
    }()
    
    let upInfoLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = UIColor(0xE7ECF6)
        label.isHidden = true
        label.sizeToFit()
        return label
    }()
    
    let uplinkImageView: UIImageView = {
        let norImage = UIImage(named: "room_uplink_arrow", in: tuiRoomKitBundle(), compatibleWith: nil)
        let imageView = UIImageView(image: norImage)
        imageView.isHidden = true
        return imageView
    }()
    
    let downInfoLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = UIColor(0xE7ECF6)
        label.isHidden = true
        label.sizeToFit()
        return label
    }()
    
    let downlinkImageView: UIImageView = {
        let norImage = UIImage(named: "room_downlink_arrow", in: tuiRoomKitBundle(), compatibleWith: nil)
        let imageView = UIImageView(image: norImage)
        imageView.isHidden = true
        return imageView
    }()
    
    
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
    
    private func constructViewHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(normalInfoLabel)
        contentView.addSubview(downInfoLabel)
        contentView.addSubview(downlinkImageView)
        contentView.addSubview(upInfoLabel)
        contentView.addSubview(uplinkImageView)
        
    }
    
    private func activateConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        normalInfoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }
        downlinkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }
        downInfoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(downlinkImageView.snp.leading).offset(-4)
        }
        uplinkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(downInfoLabel.snp.leading).offset(-16)
        }
        upInfoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(uplinkImageView.snp.leading).offset(-4)
        }
    }
    
    func setCellModel(model: QualityCellModel) {
        self.titleLabel.text = model.titleText
        if model.type == .upDown {
            showUpDownInfo(isShow: true)
            showNormalInfo(isShow: false)
            upInfoLabel.text = model.uplinkString
            downInfoLabel.text = model.downlinkString
        } else {
            showUpDownInfo(isShow: false)
            showNormalInfo(isShow: true)
            normalInfoLabel.text = model.normalString
        }
    }
    
    private func showUpDownInfo(isShow: Bool) {
        upInfoLabel.isHidden = !isShow
        uplinkImageView.isHidden = !isShow
        downInfoLabel.isHidden = !isShow
        downlinkImageView.isHidden = !isShow
    }
    
    private func showNormalInfo(isShow: Bool) {
        normalInfoLabel.isHidden = !isShow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
