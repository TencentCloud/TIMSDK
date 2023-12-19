//
//  SelectGroupMemberViewController.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/5/12.
//

import Foundation
import TUICore

class SelectGroupMemberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let viewModel = SelectGroupMemberViewModel()
    let groupMemberObserver = Observer()
    
    lazy var navigationView: UIView = {
        let navigationView = UIView()
        navigationView.backgroundColor = TUICoreDefineConvert.getTUICoreDynamicColor(colorKey: "head_bg_gradient_start_color",
                                                                                     defaultHex: "#EBF0F6")
        return navigationView
    }()
    
    lazy var leftBtn: UIButton = {
        let leftBtn = UIButton(type: .custom)
        leftBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        let defaultImage = TUICallKitCommon.getBundleImage(name: "icon_nav_back") ?? UIImage()
        let leftBtnImage = TUICoreDefineConvert.getTUIDynamicImage(imageKey: "icon_nav_back_image",
                                                                   module: TUIThemeModule.calling,
                                                                   defaultImage: defaultImage)
        leftBtn.setImage(leftBtnImage, for: .normal)
        return leftBtn
    }()
    
    lazy var centerLabel: UILabel = {
        let centerLabel = UILabel(frame: CGRect.zero)
        centerLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        centerLabel.textAlignment = .center
        centerLabel.text = TUICallKitLocalize(key: "TUICallKit.Recents.addUser")
        centerLabel.textColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_nav_title_text_color",
                                                                               defaultHex: "#000000")
        return centerLabel
    }()
    
    lazy var rightBtn: UIButton = {
        let rightBtn = UIButton(type: .system)
        rightBtn.addTarget(self, action: #selector(addUser), for: .touchUpInside)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        rightBtn.setTitle(TUICallKitLocalize(key: "TUICallKit.determine"), for: .normal)
        rightBtn.setTitleColor(TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_nav_item_title_text_color",
                                                                              defaultHex: "#000000"), for: .normal)
        return rightBtn
    }()
    
    let selectTableView: UITableView = {
        let selectTableView = UITableView(frame: CGRect.zero)
        selectTableView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_select_group_member_bg_color",
                                                                                         defaultHex: "#F2F2F2")
        return selectTableView
    }()
    
    // MARK: UI Specification Processing
    override func viewDidLoad() {
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        registerObserve()
    }
    
    func constructViewHierarchy() {
        view.addSubview(navigationView)
        view.addSubview(leftBtn)
        view.addSubview(leftBtn)
        view.addSubview(centerLabel)
        view.addSubview(rightBtn)
        view.addSubview(selectTableView)
    }
    
    func activateConstraints() {
        navigationView.snp.makeConstraints({ make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(StatusBar_Height + 44)
        })
        leftBtn.snp.makeConstraints({ make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalTo(centerLabel)
            make.width.height.equalTo(30)
        })
        centerLabel.snp.makeConstraints({ make in
            make.top.equalToSuperview().offset(StatusBar_Height)
            make.centerX.equalToSuperview()
            make.width.equalTo(Screen_Width * 2 / 3)
            make.height.equalTo(44)
        })
        rightBtn.snp.makeConstraints({ make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalTo(centerLabel)
        })
        selectTableView.snp.makeConstraints({ make in
            make.top.equalTo(centerLabel.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        })
    }
    
    func bindInteraction() {
        selectTableView.dataSource = self
        selectTableView.delegate = self
        selectTableView.register(SelectGroupMemberCell.self, forCellReuseIdentifier: NSStringFromClass(SelectGroupMemberCell.self))
    }
    
    func registerObserve() {
        viewModel.groupMemberList.addObserver(groupMemberObserver) {[weak self] _, _ in
            guard let self = self else { return }
            self.selectTableView.reloadData()
        }
    }
    
    // MARK: Action
    @objc func addUser() {
        var userIds: [String] = []
        for state in viewModel.groupMemberStateOrigin {
            if state.value {
                continue
            }
            if let isSelect = viewModel.groupMemberState[state.key] {
                if isSelect {
                    userIds.append(state.key)
                }
            }
        }
        
        if userIds.count + TUICallState.instance.remoteUserList.value.count >=  MAX_USER {
            TUITool.makeToast(TUICallKitLocalize(key: "TUICallKit.User.Exceed.Limit"))
            return
        }
        
        CallEngineManager.instance.inviteUser(userIds: userIds)
        dismiss(animated: true)
    }
    
    @objc func goBack() {
        dismiss(animated: true)
    }
    
}

extension SelectGroupMemberViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.groupMemberList.value.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SelectGroupMemberCell.self),
                                                       for: indexPath) as? SelectGroupMemberCell else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            cell.configCell(user: viewModel.selfUser.value, isSelect: true)
        } else {
            let user = viewModel.groupMemberList.value[indexPath.row - 1]
            let isSelect = viewModel.groupMemberState[user.id.value]
            cell.configCell(user: user, isSelect: isSelect ?? false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        }
        
        let user = viewModel.groupMemberList.value[indexPath.row - 1]
        if viewModel.groupMemberStateOrigin[user.id.value] ?? false {
            return
        }
        
        if viewModel.groupMemberState[user.id.value] ?? false {
            viewModel.groupMemberState[user.id.value] = false
        } else {
            viewModel.groupMemberState[user.id.value] = true
        }
        
        selectTableView.reloadData()
    }
}
