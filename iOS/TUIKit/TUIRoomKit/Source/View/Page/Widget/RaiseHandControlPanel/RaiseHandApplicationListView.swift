//
//  RaiseHandApplicationListView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/1/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class RaiseHandApplicationListView: UIView {
    let viewModel: RaiseHandApplicationListViewModel
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = .takeSeatApplyTitle
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(0xD5E0F2)
        label.backgroundColor = .clear
        return label
    }()
    
    let allAgreeButton : UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitle(.agreeAllText, for: .normal)
        button.setTitleColor(UIColor(0xFFFFFF), for: .normal)
        button.setBackgroundImage(UIColor(0x1C66E5).withAlphaComponent(0.5).trans2Image(), for: .disabled)
        button.setBackgroundImage(UIColor(0x1C66E5).trans2Image(), for: .normal)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    let allRejectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitle(.rejectAllText, for: .normal)
        button.setTitleColor(UIColor(0xB2BBD1), for: .normal)
        button.setBackgroundImage(UIColor(0x4F586B).withAlphaComponent(0.5).trans2Image(), for: .disabled)
        button.setBackgroundImage(UIColor(0x4F586B).trans2Image(), for: .normal)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    let placeholderUIImageView: UIImageView = {
        let image = UIImage(named: "room_apply_placeholder", in: tuiRoomKitBundle(), compatibleWith: nil)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = .noMemberApplicationText
        label.textColor = UIColor(0xB2BBD1)
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    lazy var applyTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(RaiseHandApplicationCell.self, forCellReuseIdentifier: "RaiseHandCell")
        return tableView
    }()
    
    init(viewModel: RaiseHandApplicationListViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = UIColor(0x22262E)
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(titleLabel)
        addSubview(placeholderUIImageView)
        addSubview(placeholderLabel)
        addSubview(applyTableView)
        addSubview(allRejectButton)
        addSubview(allAgreeButton)
    }
    
    func activateConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10.scale375Height())
            make.leading.equalToSuperview().offset(16.scale375())
        }
        placeholderUIImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(48.scale375())
            make.centerY.equalToSuperview().offset(-30.scale375Height())
        }
        placeholderLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(placeholderUIImageView.snp.bottom).offset(8.scale375Height())
            make.height.equalTo(22.scale375Height())
        }
        applyTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.top.equalTo(titleLabel.snp.bottom).offset(26.scale375Height())
            make.bottom.equalTo(allAgreeButton.snp.top).offset(-10.scale375Height())
        }
        allRejectButton.snp.remakeConstraints { make in
            make.leading.equalTo(applyTableView)
            make.bottom.equalToSuperview().offset(-34.scale375Height())
            make.height.equalTo(40.scale375Height())
            make.width.equalTo(167.scale375())
        }
        allAgreeButton.snp.makeConstraints { make in
            make.trailing.equalTo(applyTableView)
            make.bottom.height.width.equalTo(allRejectButton)
        }
    }
    
    func bindInteraction() {
        viewModel.viewResponder = self
        allAgreeButton.addTarget(self, action: #selector(allAgreeStageAction(sender:)), for: .touchUpInside)
        allRejectButton.addTarget(self, action: #selector(allRejectAction(sender:)), for: .touchUpInside)
        setupPlaceholderViewState(isShown: viewModel.isPlaceholderViewShown)
        setupApplyButtonState(isEnabled: viewModel.isApplyButtonEnabled)
    }
    
    @objc func allAgreeStageAction(sender: UIButton) {
        viewModel.respondAllRequest(isAgree: true)
    }
    
    @objc func allRejectAction(sender: UIButton) {
        viewModel.respondAllRequest(isAgree: false)
    }
    
    private func setupPlaceholderViewState(isShown: Bool) {
        placeholderLabel.isHidden = !isShown
        placeholderUIImageView.isHidden = !isShown
        applyTableView.isHidden = isShown
    }
    
    private func setupApplyButtonState(isEnabled: Bool) {
        allAgreeButton.isEnabled = isEnabled
        allRejectButton.isEnabled = isEnabled
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension RaiseHandApplicationListView: UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.inviteSeatList.count
    }
}

extension RaiseHandApplicationListView: UITableViewDelegate {
    internal func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attendeeModel = viewModel.inviteSeatList[indexPath.row]
        let cell = RaiseHandApplicationCell(attendeeModel: attendeeModel, viewModel: viewModel)
        cell.selectionStyle = .none
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.scale375()
    }
}

extension RaiseHandApplicationListView: RaiseHandApplicationListViewResponder {
    func updateApplyButtonState(isEnabled: Bool) {
        setupApplyButtonState(isEnabled: isEnabled)
    }
    
    func updatePlaceholderViewState(isShown: Bool) {
        setupPlaceholderViewState(isShown: isShown)
    }
    
    func reloadApplyListView() {
        applyTableView.reloadData()
    }
    
    func makeToast(text: String) {
        RoomRouter.makeToastInCenter(toast: text, duration: 1)
    }
}

private extension String {
    static var takeSeatApplyTitle: String {
        localized("Participants apply to come on stage")
    }
    static var rejectAllText: String {
        localized("Reject all")
    }
    static var noMemberApplicationText: String {
        localized("No participants's application yet")
    }
    static var agreeAllText: String {
        localized("Agree to all")
    }
}
