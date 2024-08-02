//
//  SelectedMembersViewController.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/24.
//

import Foundation
import RTCRoomEngine

protocol SelectedMemberCellProtocol: AnyObject {
    func didDeleteButtonClicked(in memberCell: SelectedMemberCell)
}

class SelectedMembersViewController: UIViewController {
    private(set) var showDeleteButton: Bool = true
    var selectedMember: [UserInfo] = []
    var didDeselectMember: ((UserInfo) -> Void)?
    private let arrowViewHeight: CGFloat = 35.0
    
    init(showDeleteButton: Bool = true, selectedMembers: [UserInfo] = []) {
        self.showDeleteButton = showDeleteButton
        self.selectedMember = selectedMembers
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.register(SelectedMemberCell.self, forCellReuseIdentifier: SelectedMemberCell.reuseIdentifier)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
         return tableView
     }()
    
    private let dropArrowView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let dropArrowImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "room_drop_arrow", in:tuiRoomKitBundle(), compatibleWith: nil)
        return view
    }()
    
    let contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.tui_color(withHex: "0F1014", alpha: 0.6)
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    private func constructViewHierarchy() {
        view.addSubview(contentView)
        dropArrowView.addSubview(dropArrowImageView)
        contentView.addSubview(dropArrowView)
        contentView.addSubview(tableView)
    }
    
    private func activateConstraints() {
        contentView.snp.makeConstraints { make in
            make.height.equalTo(610)
            make.leading.bottom.trailing.equalToSuperview()
        }
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
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    private func bindInteraction() {
        tableView.delegate = self
        tableView.dataSource = self
        let dropArrowTap = UITapGestureRecognizer(target: self, action: #selector(dropDownPopUpViewAction(sender:)))
        dropArrowView.addGestureRecognizer(dropArrowTap)
        dropArrowView.isUserInteractionEnabled = true
    }
    
    @objc func dropDownPopUpViewAction(sender: UIView) {
        self.dismiss(animated: true)
    }
}

extension SelectedMembersViewController: SelectedMemberCellProtocol{
    func didDeleteButtonClicked(in memberCell: SelectedMemberCell) {
        guard let indexPath = self.tableView.indexPath(for: memberCell) else {
            return
        }
        let member = selectedMember[indexPath.row]
        self.didDeselectMember?(member)
        selectedMember.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .none)
    
        guard let headerView = tableView.headerView(forSection: 0) as? SelectedMemberHeaderView else {
            return
        }
        headerView.updateLabel(with: selectedMember.count)
    }
}

extension SelectedMembersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SelectedMemberHeaderView(reuseIdentifier: "CustomHeaderView")
        headerView.updateLabel(with: selectedMember.count)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
}

extension SelectedMembersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedMember.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectedMemberCell.reuseIdentifier, for: indexPath)
                as? SelectedMemberCell else {
            return UITableViewCell()
        }
        let member = selectedMember[indexPath.row]
        cell.updateView(with: member)
        cell.delegate = self
        if showDeleteButton {
            cell.showDeleteButton()
        } else {
            cell.hideDeleteButton()
        }
        return cell
    }
}

class SelectedMemberCell: UITableViewCell {
    static let reuseIdentifier = "SelectedMemberCell"
    weak var delegate: SelectedMemberCellProtocol?
    private let avatarImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 2
        imgView.layer.masksToBounds = true
        return imgView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.tui_color(withHex: "22262E")
        label.textAlignment = isRTL ? .right : .left
        label.font = UIFont(name: "PingFangSC-Regular", size: 14)
        label.numberOfLines = 1
        return label
    }()
    
     let deleteButton: UIButton = {
        let button = LargerHitAreaButton()
        let image = UIImage(named: "room_delete", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(image, for: .normal)
        return button
    }()
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        selectionStyle = .none
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        contentView.backgroundColor = .clear
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(deleteButton)
    }
    
    private func activateConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
        }
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
    }
    
    func updateView(with info: UserInfo) {
        let placeholder = UIImage(named: "room_default_avatar_rect", in: tuiRoomKitBundle(), compatibleWith: nil)
        if let url = URL(string: info.avatarUrl) {
            avatarImageView.sd_setImage(with: url, placeholderImage: placeholder)
        } else {
            avatarImageView.image = placeholder
        }
        
        if !info.userName.isEmpty {
            nameLabel.text = info.userName
        } else {
            nameLabel.text = info.userId
        }
    }
    
    func hideDeleteButton() {
        self.deleteButton.isHidden = true
    }
    
    func showDeleteButton() {
        self.deleteButton.isHidden = false
    }
    
    private func bindInteraction() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped(sender:)), for: .touchUpInside)
    }
    
    @objc func deleteButtonTapped(sender: UIButton) {
        self.delegate?.didDeleteButtonClicked(in: self)
    }
}

class SelectedMemberHeaderView: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundView = UIView()
        backgroundView?.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.tui_color(withHex: "4F586B")
        label.font = UIFont(name: "PingFangSC-Medium", size: 18)
        label.text = .selectedText
        label.sizeToFit()
        return label
    }()
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
    }
    
    private func constructViewHierarchy() {
        addSubview(label)
    }
    
    private func activateConstraints() {
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview()
        }
    }
    
    func updateLabel(with count: Int) {
        let text = .selectedText + " (" + "\(count)" + ")"
        self.label.text = text
    }
}

class LargerHitAreaButton: UIButton {
    var hitAreaEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let largerFrame = bounds.inset(by: hitAreaEdgeInsets)
        return largerFrame.contains(point)
    }
}

private extension String {
    static var selectedText: String {
        localized("Selected")
    }
}
