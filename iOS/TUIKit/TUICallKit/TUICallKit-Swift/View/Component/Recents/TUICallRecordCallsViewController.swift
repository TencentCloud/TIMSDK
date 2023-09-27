//
//  TUICallRecordCallsViewController.swift
//  
//
//  Created by vincepzhang on 2023/8/28.
//

import Foundation
import UIKit
import SnapKit
import TUICore

class TUICallRecordCallsViewController: UIViewController {
    
    private let viewModel = TUICallRecordCallsViewModel()
    private let dataSourceObserver = Observer()
    
    // 头部导航容器视图
    private lazy var containerView: UIView = {
        let view = UIView()
        if viewModel.recordCallsUIStyle == .classic {
            view.backgroundColor = TUICoreDefineConvert.getTUICoreDynamicColor(colorKey: "head_bg_gradient_start_color",
                                                                               defaultHex:  "#EBF0F6")
        } else {
            view.backgroundColor = TUICoreDefineConvert.getTUICoreDynamicColor(colorKey: "callkit_recents_bg_color",
                                                                               defaultHex:  "#FFFFFF")
        }
        return view
    }()
    
    // 开始编辑按钮
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(TUICallKitCommon.getBundleImage(name: "ic_calls_edit"), for: .normal)
        button.titleLabel?.textAlignment = TUICoreDefineConvert.getIsRTL() ? .right : .left
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    // 清除所有记录按钮
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(TUICallKitLocalize(key: "TUICallKit.Recents.clear"), for: .normal)
        button.titleLabel?.textAlignment = TUICoreDefineConvert.getIsRTL() ? .right : .left
        button.contentHorizontalAlignment = TUICoreDefineConvert.getIsRTL() ? .right : .left
        button.setTitleColor(TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_nav_title_text_color",
                                                                            defaultHex: "#000000"), for: .normal)
        button.isHidden = true
        button.titleLabel?.sizeToFit()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    // 编辑完成按钮
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(TUICallKitLocalize(key: "TUICallKit.Recents.done"), for: .normal)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_nav_title_text_color",
                                                                            defaultHex: "#000000"), for: .normal)
        button.titleLabel?.sizeToFit()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.isHidden = true
        return button
    }()
    
    // 分段控制视图
    private lazy var segmentedControl: UISegmentedControl = {
        let items = [TUICallKitLocalize(key: "TUICallKit.Recents.all"), TUICallKitLocalize(key: "TUICallKit.Recents.missed")]
        let control = UISegmentedControl(items: items as [Any])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    // 无最近通话提示文本
    private lazy var notRecordCallsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // 列表表头视图
    private lazy var tableHeaderView: UIView = {
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 80))
        let label = UILabel()
        label.textColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_recents_tableHeader_title_text_color",
                                                                         defaultHex: "#000000")
        label.text = TUICallKitLocalize(key: "TUICallKit.Recents.calls")
        label.font = UIFont(name: "PingFangHK-Semibold", size: 34)
        label.textAlignment = TUICoreDefineConvert.getIsRTL() ? .right : .left
        tableHeaderView.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalTo(tableHeaderView).offset(20)
        }
        return tableHeaderView
    }()
    
    // 通话记录列表
    private lazy var recordCallsList: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.tableHeaderView = tableHeaderView
        tableView.backgroundColor = view.backgroundColor
        return tableView
    }()
    
    
    init(recordCallsUIStyle: TUICallKitRecordCallsUIStyle) {
        super.init(nibName: nil, bundle: nil)
        
        viewModel.recordCallsUIStyle = recordCallsUIStyle
        
        view.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_recents_bg_color",
                                                                              defaultHex: "#FFFFFF")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Observe
    func registerObserve() {
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidChange),
                                               name: UIWindow.didBecomeKeyNotification, object: nil)
        
        viewModel.dataSource.addObserver(dataSourceObserver) {[weak self] _, _ in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.recordCallsList.reloadData()
            }
        }
    }
    
    func unregisterObserve() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.didBecomeKeyNotification, object: nil)
        viewModel.dataSource.removeObserver(dataSourceObserver)
    }
    
    // 页面出现的时候注册刷行UI的数据回调，页面消失关闭，防止页面UI刷新在非主线程中运行
    override func viewWillAppear(_ animated: Bool) {
        registerObserve()
        viewModel.queryRecentCalls()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unregisterObserve()
    }
    
    //MARK: UI Specification Processing
    override func viewDidLoad() {
        super.viewDidLoad()
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        viewModel.queryRecentCalls()
    }
    
    func constructViewHierarchy() {
        view.addSubview(containerView)
        containerView.addSubview(segmentedControl)
        containerView.addSubview(editButton)
        containerView.addSubview(clearButton)
        containerView.addSubview(doneButton)
        view.addSubview(notRecordCallsLabel)
        view.addSubview(recordCallsList)
    }
    
    func activateConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.centerX.width.equalTo(view)
            make.height.equalTo(StatusBar_Height + 44)
        }
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(StatusBar_Height + 6.0)
            make.centerX.equalTo(containerView)
            make.width.equalTo(180)
            make.height.equalTo(32)
        }
        editButton.snp.makeConstraints { make in
            make.centerY.equalTo(segmentedControl)
            make.trailing.equalTo(containerView).offset(-20)
            make.width.height.equalTo(32)
        }
        clearButton.snp.makeConstraints { make in
            make.centerY.equalTo(segmentedControl)
            make.leading.equalTo(containerView).offset(20)
            make.height.equalTo(32)
        }
        doneButton.snp.makeConstraints { make in
            make.centerY.equalTo(segmentedControl)
            make.trailing.equalTo(containerView).offset(-20)
            make.height.equalTo(32)
        }
        recordCallsList.snp.makeConstraints { make in
            make.top.equalTo(view).offset(StatusBar_Height + 44)
            make.centerX.width.bottom.equalTo(view)
        }
        notRecordCallsLabel.snp.makeConstraints { make in
            make.center.width.equalTo(view)
        }
    }
    
    func bindInteraction() {
        recordCallsList.delegate = self
        recordCallsList.dataSource = self
        recordCallsList.register(TUICallRecordCallsCell.self, forCellReuseIdentifier: NSStringFromClass(TUICallRecordCallsCell.self))
        
        clearButton.addTarget(self, action: #selector(clearButtonClick(_:)), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonClick(_:)), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonClick(_:)), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(segmentSelectItem(_:)), for: .valueChanged)
    }
    
    @objc func windowDidChange() {
        viewModel.queryRecentCalls()
    }
    
    @objc func clearButtonClick(_ button: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let clearAction = UIAlertAction(title: TUICallKitLocalize(key: "TUICallKit.Recents.clear.all"),
                                        style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.recordCallsList.setEditing(false, animated: true)
            self.setShowEditButton(true)
            self.viewModel.deleteAllRecordCalls()
        }
        let cancelAction = UIAlertAction(title: TUICallKitLocalize(key: "TUICallKit.Recents.clear.cancel"), style: .cancel)
        alertController.addAction(clearAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func editButtonClick(_ button: UIButton) {
        recordCallsList.setEditing(true, animated: true)
        setShowEditButton(false)
    }
    
    @objc func doneButtonClick(_ button: UIButton) {
        recordCallsList.setEditing(false, animated: true)
        setShowEditButton(true)
    }
    
    @objc func segmentSelectItem(_ sender: UISegmentedControl) {
        var type: TUICallRecordCallsType = .all
        
        if sender.selectedSegmentIndex == 1 {
            type = .missed
        }
        
        viewModel.switchRecordCallsType(type)
    }
    
    func setShowEditButton(_ isShow: Bool) {
        editButton.isHidden = !isShow
        clearButton.isHidden = isShow
        doneButton.isHidden = isShow
    }
}

extension TUICallRecordCallsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteRowAction = UIContextualAction(style: .normal,
                                                 title: TUICallKitLocalize(key: "TUICallKit.Recents.delete"))
        { [weak self] action, sourceView, completionHandler in
            guard let self = self else { return }
            self.viewModel.deleteRecordCall(indexPath)
        }
        deleteRowAction.backgroundColor = .red
        let config = UISwipeActionsConfiguration(actions: [deleteRowAction])
        config.performsFirstActionWithFullSwipe = false
        self.setShowEditButton(false)
        return config
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TUICallRecordCallsCell.self),
                                                       for: indexPath) as? TUICallRecordCallsCell else { return UITableViewCell() }
        cell.moreBtnClickedHandler =  { [weak self] in
            guard let self = self else { return }
            guard let navigationController = self.navigationController else { return }
            self.viewModel.jumpUserInfoController(indexPath: indexPath, navigationController: navigationController)
        }
        cell.configViewModel(viewModel.dataSource.value[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.repeatCall(indexPath)
    }
}
