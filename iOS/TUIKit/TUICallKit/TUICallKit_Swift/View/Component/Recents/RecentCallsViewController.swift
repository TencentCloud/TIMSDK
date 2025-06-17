//
//  RecentsCallsViewController.swift
//  Pods
//
//  Created by vincepzhang on 2025/3/3.
//

import Foundation
import UIKit
import TUICore
import RTCCommon

@objc public class RecentCallsViewController: UIViewController {
    
    private let viewModel = RecentCallsViewModel()
    private let dataSourceObserver = Observer()
    
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
    
    private let editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(CallKitBundle.getBundleImage(name: "ic_calls_edit"), for: .normal)
        button.titleLabel?.textAlignment = TUICoreDefineConvert.getIsRTL() ? .right : .left
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private let clearButton: UIButton = {
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
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(TUICallKitLocalize(key: "TUICallKit.Recents.done"), for: .normal)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_nav_item_title_text_color",
                                                                            defaultHex: "#000000"), for: .normal)
        button.titleLabel?.sizeToFit()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.isHidden = true
        return button
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let items = [TUICallKitLocalize(key: "TUICallKit.Recents.all"), TUICallKitLocalize(key: "TUICallKit.Recents.missed")]
        let control = UISegmentedControl(items: items as [Any])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private let notRecordCallsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let tableHeaderView: UIView = {
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 80))
        let label = UILabel()
        label.textColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_recents_tableHeader_title_text_color",
                                                                         defaultHex: "#000000")
        label.text = TUICallKitLocalize(key: "TUICallKit.Recents.calls")
        label.font = UIFont(name: "PingFangHK-Semibold", size: 34)
        label.textAlignment = TUICoreDefineConvert.getIsRTL() ? .right : .left
        tableHeaderView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        if let superview = label.superview {
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: tableHeaderView.leadingAnchor, constant: 20)
            ])
        }
        return tableHeaderView
    }()
    
    private lazy var recordCallsList: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.tableHeaderView = tableHeaderView
        tableView.backgroundColor = view.backgroundColor
        return tableView
    }()
    
    
    init(recordCallsUIStyle: RecentCallsUIStyle) {
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
    
    // Register the UI data refresh callback when the page appears, close it when the page disappears, to prevent the UI refresh from running in a non-main thread.
    public override func viewWillAppear(_ animated: Bool) {
        registerObserve()
        viewModel.queryRecentCalls()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        unregisterObserve()
    }
    
    // MARK: UI Specification Processing
    public override func viewDidLoad() {
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
        containerView.translatesAutoresizingMaskIntoConstraints = false
        if let view = view {
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: view.topAnchor),
                containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
                containerView.heightAnchor.constraint(equalToConstant: StatusBar_Height + 44)
            ])
        }
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: containerView.topAnchor, constant: StatusBar_Height + 6.0),
            segmentedControl.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: 180),
            segmentedControl.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editButton.centerYAnchor.constraint(equalTo: segmentedControl.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            editButton.widthAnchor.constraint(equalToConstant: 32),
            editButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        clearButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clearButton.centerYAnchor.constraint(equalTo: segmentedControl.centerYAnchor),
            clearButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            clearButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.centerYAnchor.constraint(equalTo: segmentedControl.centerYAnchor),
            doneButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        recordCallsList.translatesAutoresizingMaskIntoConstraints = false
        if let view = view {
            NSLayoutConstraint.activate([
                recordCallsList.topAnchor.constraint(equalTo: view.topAnchor, constant: StatusBar_Height + 44),
                recordCallsList.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                recordCallsList.widthAnchor.constraint(equalTo: view.widthAnchor),
                recordCallsList.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        notRecordCallsLabel.translatesAutoresizingMaskIntoConstraints = false
        if let view = view {
            NSLayoutConstraint.activate([
                notRecordCallsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                notRecordCallsLabel.widthAnchor.constraint(equalTo: view.widthAnchor)
            ])
        }
    }
    
    func bindInteraction() {
        recordCallsList.delegate = self
        recordCallsList.dataSource = self
        recordCallsList.register(RecentCallsCell.self, forCellReuseIdentifier: NSStringFromClass(RecentCallsCell.self))
        
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
        var type: RecentCallsType = .all
        
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

extension RecentCallsViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.value.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(RecentCallsCell.self),
                                                       for: indexPath) as? RecentCallsCell else { return UITableViewCell() }
        cell.moreBtnClickedHandler =  { [weak self] in
            guard let self = self else { return }
            guard let navigationController = self.navigationController else { return }
            self.viewModel.jumpUserInfoController(indexPath: indexPath, navigationController: navigationController)
        }
        cell.configViewModel(viewModel.dataSource.value[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.repeatCall(indexPath)
    }
}
