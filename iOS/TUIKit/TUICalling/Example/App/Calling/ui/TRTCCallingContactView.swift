//
//  TRTCCallingContactView.swift
//  TRTCAPP_AppStore
//
//  Created by noah on 2021/12/21.
//

import UIKit
import Foundation
import Toast_Swift
import TUICalling
import ImSDK_Plus

enum TRTCCallingUserRemoveReason: UInt32 {
    case leave = 0
    case reject
    case noresp
    case busy
}

public class TRTCCallingContactView: UIView {
    var selectedFinished: (([V2TIMUserFullInfo])->Void)? = nil
    var btnType: CallingSelectUserButtonType = .call
    @objc var callType: CallType = .audio
    /// 是否展示搜索结果
    var shouldShowSearchResult: Bool = false {
        didSet {
            if oldValue != shouldShowSearchResult {
                selectTable.reloadData()
            }
        }
    }
    
    /// 搜索结果model
    var searchResult: V2TIMUserFullInfo? = nil
    
    let searchContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = .searchPhoneNumberText
        searchBar.backgroundColor = UIColor(hex: "F4F5F9")
        searchBar.barTintColor = UIColor.clear
        searchBar.returnKeyType = .search
        searchBar.keyboardType = .phonePad
        searchBar.layer.cornerRadius = 20
        return searchBar
    }()
    
    /// 搜索按钮
    lazy var searchBtn: UIButton = {
        let done = UIButton(type: .custom)
        done.setTitle(.searchText, for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        done.backgroundColor = UIColor(hex: "006EFF")
        done.clipsToBounds = true
        done.layer.cornerRadius = 20
        return done
    }()
    
    lazy var userInfoMarkView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: "999999")
        view.layer.cornerRadius = 1.5
        return view
    }()
    
    let userInfoLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "\(String.yourUserNameText)\("\(V2TIMManager.sharedInstance()?.getLoginUser() ?? "")")"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = UIColor.black
        label.textAlignment = .left
        return label
    }()
    
    /// 选择列表
    lazy var selectTable: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.tableFooterView = UIView(frame: .zero)
        table.backgroundColor = UIColor.clear
        table.register(CallingSelectUserTableViewCell.classForCoder(), forCellReuseIdentifier: "CallingSelectUserTableViewCell")
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    let kUserBorder: CGFloat = 44.0
    let kUserSpacing: CGFloat = 2
    let kUserPanelLeftSpacing: CGFloat = 28
    
    /// 搜索记录为空时，提示
    lazy var noSearchImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "noSearchMembers"))
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    lazy var noMembersTip: UILabel = {
        let label = UILabel()
        label.text = .backgroundTipsText
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor(hex: "BBBBBB")
        return label
    }()
    
    public init(frame: CGRect = .zero, type: CallingSelectUserButtonType, selectHandle: @escaping ([V2TIMUserFullInfo])->Void) {
        super.init(frame: frame)
        btnType = type
        selectedFinished = selectHandle
        backgroundColor = UIColor.white
        setupUI()
        registerButtonTouchEvents()
        hiddenNoMembersImg(isHidden: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit \(self)")
        NotificationCenter.default.removeObserver(self)
    }
    
    var lastNetworkQualityCallTime: Date?
}

extension TRTCCallingContactView {
    
    func setupUI() {
        constructViewHierarchy()
        activateConstraints()
        setupUIStyle()
        hiddenNoMembersImg(isHidden: false)
        selectTable.reloadData()
    }
    
    func constructViewHierarchy() {
        // 添加SearchBar
        addSubview(searchContainerView)
        searchContainerView.addSubview(searchBar)
        searchContainerView.addSubview(searchBtn)
        
        addSubview(userInfoMarkView)
        addSubview(userInfoLabel)
        addSubview(selectTable)
        //        selectTable.isHidden = true
        addSubview(noSearchImageView)
        addSubview(noMembersTip)
    }
    
    func activateConstraints() {
        searchContainerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.height.equalTo(40)
        }
        searchBar.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(searchBtn.snp.leading).offset(-10)
        }
        searchBtn.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview()
            make.width.equalTo(60)
        }
        userInfoMarkView.snp.makeConstraints { (make) in
            make.centerY.equalTo(userInfoLabel)
            make.leading.equalTo(20)
            make.size.equalTo(CGSize(width: 3, height: 12))
        }
        userInfoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(searchContainerView.snp.bottom).offset(20)
            make.leading.equalTo(userInfoMarkView).offset(8)
            make.trailing.equalTo(-20)
            make.height.equalTo(20)
        }
        selectTable.snp.makeConstraints { (make) in
            make.top.equalTo(userInfoLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        noSearchImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.bounds.size.height/3.0)
            make.leading.equalTo(self.bounds.size.width*154.0/375)
            make.trailing.equalTo(-self.bounds.size.width*154.0/375)
            make.height.equalTo(self.bounds.size.width*67.0/375)
        }
        noMembersTip.snp.makeConstraints { (make) in
            make.top.equalTo(noSearchImageView.snp.bottom)
            make.width.equalTo(self.bounds.size.width)
            make.height.equalTo(60)
        }
    }
    
    func setupUIStyle() {
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.layer.cornerRadius = 10.0
            textfield.layer.masksToBounds = true
            textfield.textColor = UIColor.black
            textfield.backgroundColor = UIColor.clear
            textfield.leftViewMode = .always
        }
        ToastManager.shared.position = .bottom
    }
    
    func showCallVC(users: [String]) {
        var type: TUICallingType = .video
        if callType == .audio {
            type = .audio
        }
        TUICalling.shareInstance().call(userIDs: users, type: type)
    }
    
    @objc func hiddenNoMembersImg(isHidden: Bool) {
        selectTable.isHidden = !isHidden
        noSearchImageView.isHidden = isHidden
        noMembersTip.isHidden = isHidden
    }
}

extension TRTCCallingContactView: UITextFieldDelegate {
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hiddenNoMembersImg(isHidden: false)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let input = searchBar.text, input.count > 0 {
            searchUser(input: input)
        }
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text?.count ?? 0 == 0 {
            //show recent table
            shouldShowSearchResult = false
            hiddenNoMembersImg(isHidden: false)
        }
        
        if (searchBar.text?.count ?? 0) > 11 {
            searchBar.text = (searchBar.text as NSString?)?.substring(to: 11)
        }
    }
    
    public func searchUser(input: String)  {
        V2TIMManager.sharedInstance()?.getUsersInfo([input], succ: { [weak self] (userInfos) in
            guard let `self` = self, let userInfo = userInfos?.first else { return }
            self.searchResult = userInfo
            self.shouldShowSearchResult = true
            self.selectTable.reloadData()
            self.hiddenNoMembersImg(isHidden: true)
        }, fail: { [weak self] (_, _) in
            guard let self = self else {return}
            self.searchResult = nil
            self.makeToast(.failedSearchText)
        })
    }
}

extension TRTCCallingContactView: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResult {
            return 1
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallingSelectUserTableViewCell") as! CallingSelectUserTableViewCell
        cell.selectionStyle = .none
        if shouldShowSearchResult {
            if let V2TIMUserFullInfo = searchResult {
                cell.config(model: V2TIMUserFullInfo, type: btnType, selected: false) { [weak self] in
                    guard let `self` = self else { return }
                    if V2TIMUserFullInfo.userID == V2TIMManager.sharedInstance()?.getLoginUser() {
                        self.makeToast(.cantInvateSelfText)
                        return
                    }
                    if let finish = self.selectedFinished {
                        finish([V2TIMUserFullInfo])
                    }
                }
            } else {
                debugPrint("not search result")
            }
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension TRTCCallingContactView {
    
    private func registerButtonTouchEvents() {
        searchBtn.addTarget(self, action: #selector(searchBtnTouchEvent(sender:)), for: .touchUpInside)
    }
    
    @objc private func searchBtnTouchEvent(sender: UIButton) {
        self.searchBar.resignFirstResponder()
        if let input = self.searchBar.text, input.count > 0 {
            self.searchUser(input: input)
        }
    }
}

private extension String {
    static let yourUserNameText = CallingLocalize("Demo.TRTC.calling.yourID")
    static let searchPhoneNumberText = CallingLocalize("Demo.TRTC.calling.searchID")
    static let searchText = CallingLocalize("Demo.TRTC.calling.searching")
    static let backgroundTipsText = CallingLocalize("Demo.TRTC.calling.searchandcall")
    static let enterConvText = CallingLocalize("Demo.TRTC.calling.callingbegan")
    static let cancelConvText = CallingLocalize("Demo.TRTC.calling.callingcancel")
    static let callTimeOutText = CallingLocalize("Demo.TRTC.calling.callingtimeout")
    static let rejectToastText = CallingLocalize("Demo.TRTC.calling.callingrefuse")
    static let leaveToastText = CallingLocalize("Demo.TRTC.calling.callingleave")
    static let norespToastText = CallingLocalize("Demo.TRTC.calling.callingnoresponse")
    static let busyToastText = CallingLocalize("Demo.TRTC.calling.callingbusy")
    static let failedSearchText = CallingLocalize("Demo.TRTC.calling.searchingfailed")
    static let cantInvateSelfText = CallingLocalize("Demo.TRTC.calling.cantinviteself")
    static let localNetworkBadText = CallingLocalize("Demo.TRTC.Calling.yournetworkpoor")
    static let remoteNetworkBadText = CallingLocalize("Demo.TRTC.Calling.othernetworkpoor")
}
