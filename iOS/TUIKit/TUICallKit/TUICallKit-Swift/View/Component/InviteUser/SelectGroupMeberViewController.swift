//
//  SelectGroupMeberViewController.swift
//  Alamofire
//
//  Created by vincepzhang on 2023/5/12.
//

import Foundation

class SelectGroupMeberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let viewModel = SelectGroupMeberViewModel()
    let groupMemberObserver = Observer()

    let selectTableView: UITableView = {
        let selectTableView = UITableView(frame: CGRectZero)
        selectTableView.backgroundColor = UIColor.t_colorWithHexString(color: "#F2F2F2")
        return selectTableView
    }()
    
    lazy var rightBtn: UIBarButtonItem = {
        let item = UIBarButtonItem(title: TUICallKitLocalize(key: "LoginNetwork.AppUtils.determine"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(addUser))
        return item
    }()
    
    lazy var leftBtn: UIBarButtonItem = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        btn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        if let image = TUICallKitCommon.getBundleImage(name: "main_mine_about_back") {
            btn.setImage(image, for: .normal)
        }
        let leftBtn = UIBarButtonItem(customView: btn)
        return leftBtn
    }()
    
    //MARK: UI Specification Processing
    override func viewDidLoad() {
        title = TUICallKitLocalize(key: "TUICallKit.Recents.addUser")
        navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.t_colorWithHexString(color: "#242424")]

        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        registerObserve() 
    }
    
    func constructViewHierarchy() {
        view.addSubview(selectTableView)
    }

    func activateConstraints() {
        selectTableView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }

    func bindInteraction() {
        navigationItem.rightBarButtonItem = rightBtn
        navigationItem.leftBarButtonItem = leftBtn
        selectTableView.dataSource = self
        selectTableView.delegate = self
        selectTableView.register(SelectGroupMeberCell.self, forCellReuseIdentifier: "SelectCell")
    }
    
    func registerObserve() {
        viewModel.groupMerberList.addObserver(groupMemberObserver) {[weak self] _, _ in
            guard let self = self else { return }
            self.selectTableView.reloadData()
        }
    }

    //MARK: Action
    @objc func addUser() {
        var userIds: [String] = []
        for state in viewModel.groupMerberStateOrigin {
            if state.value {
                continue
            }
            if let isSelect = viewModel.groupMerberState[state.key] {
                if isSelect {
                    userIds.append(state.key)
                }
            }
        }
        
        CallEngineManager.instance.inviteUser(userIds: userIds)
        dismiss(animated: true)
    }
    
    @objc func goBack() {
        dismiss(animated: true)
    }
}

extension SelectGroupMeberViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.groupMerberList.value.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCell", for: indexPath) as? SelectGroupMeberCell
        if indexPath.row == 0 {
            cell?.configCell(user: viewModel.selfUser.value, isSelect: true)
        } else {
            let user = viewModel.groupMerberList.value[indexPath.row - 1]
            let isSelect = viewModel.groupMerberState[user.id.value]
            cell?.configCell(user: user, isSelect: isSelect ?? false)
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            return
        }
        
        let user = viewModel.groupMerberList.value[indexPath.row - 1]
        if viewModel.groupMerberStateOrigin[user.id.value] ?? false {
            return
        }
        
        if viewModel.groupMerberState[user.id.value] ?? false {
            viewModel.groupMerberState[user.id.value] = false
        } else {
            viewModel.groupMerberState[user.id.value] = true
        }
        
        selectTableView.reloadData()
    }
}
