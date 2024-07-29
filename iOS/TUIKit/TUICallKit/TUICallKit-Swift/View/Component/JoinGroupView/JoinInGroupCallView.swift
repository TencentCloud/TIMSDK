//
//  JoinInGroupCallView.swift
//  TUICallKit-Swift
//
//  Created by noah on 2024/1/23.
//

import UIKit
import SnapKit
import TUICore
import TUICallEngine

let kJoinGroupCallViewDefaultHeight: CGFloat = 52.0
let kJoinGroupCallViewExpandHeight: CGFloat = 225.0
let kJoinGroupCallItemWidth: CGFloat = 50.0
let kJoinGroupCallSpacing: CGFloat = 12.0

protocol JoinInGroupCallViewDelegate: AnyObject {
    func updatePageContent(isExpand: Bool)
    func joinInGroupCall()
}

class JoinInGroupCallView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: JoinInGroupCallViewDelegate?
    var listDate = Array<User>()
    
    lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_join_group_bottom_container_bg_color",
                                                                              defaultHex: "#FFFFFF")
        view.layer.cornerRadius = 6.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var titleIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = TUICallKitCommon.getBundleImage(name: "icon_join_group")
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_join_group_title_color", defaultHex: "#999999")
        label.textAlignment = .left
        return label
    }()
    
    lazy var expandButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(TUICallKitCommon.getBundleImage(name: "icon_join_group_expand"), for: .normal)
        button.setImage(TUICallKitCommon.getBundleImage(name: "icon_join_group_zoom"), for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    lazy var expandView: UIView = {
        let view = UIView()
        view.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_join_group_expand_bg_color", defaultHex: "#EEF0F2")
        view.isHidden = true
        view.layer.cornerRadius = 6.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.alpha = 0.1
        view.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_join_group_line_color", defaultHex: "#707070")
        return view
    }()
    
    lazy var joinButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Semibold", size: 14.0)
        button.setTitleColor(TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_join_group_button_color", defaultHex: "#333333"),
                             for: .normal)
        button.setTitle(TUICallKitLocalize(key: "TUICallKit.JoinGroupView.join"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_join_group_bg_color", defaultHex: "#ECF0F5")
        self.frame = CGRect(x: 0, y: 0, width: Screen_Width, height: kJoinGroupCallViewDefaultHeight)
        let tap = UITapGestureRecognizer(target: self, action: #selector(expandButtonClick(sender:)))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(bottomContainerView)
        bottomContainerView.addSubview(titleIcon)
        bottomContainerView.addSubview(titleLabel)
        bottomContainerView.addSubview(expandButton)
        bottomContainerView.addSubview(expandView)
        expandView.addSubview(collectionView)
        expandView.addSubview(lineView)
        expandView.addSubview(joinButton)
    }
    
    func activateConstraints() {
        bottomContainerView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(8)
            make.leading.equalTo(self).offset(16)
            make.center.equalTo(self)
        }
        titleIcon.snp.makeConstraints { make in
            make.top.equalTo(bottomContainerView).offset(8)
            make.leading.equalTo(bottomContainerView).offset(16)
            make.width.height.equalTo(20)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleIcon)
            make.leading.equalTo(titleIcon.snp.trailing).offset(10)
            make.width.equalTo(200)
            make.height.equalTo(20)
        }
        expandButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleIcon)
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.trailing.equalTo(bottomContainerView).offset(-16)
            make.width.height.equalTo(30)
        }
        expandView.snp.makeConstraints { make in
            make.top.equalTo(bottomContainerView).offset(36)
            make.leading.equalTo(bottomContainerView).offset(16)
            make.trailing.equalTo(bottomContainerView).offset(-16)
            make.height.equalTo(157)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(expandView).offset(37)
            make.leading.equalTo(expandView).offset(10)
            make.trailing.equalTo(expandView).offset(-10)
            make.height.equalTo(kJoinGroupCallItemWidth)
        }
        lineView.snp.makeConstraints { make in
            make.top.equalTo(expandView).offset(117)
            make.leading.trailing.equalTo(self.expandView)
            make.height.equalTo(1)
        }
        joinButton.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(5)
            make.centerX.equalTo(self.expandView)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
    }
    
    func bindInteraction() {
        expandButton.addTarget(self, action: #selector(expandButtonClick(sender: )), for: .touchUpInside)
        joinButton.addTarget(self, action: #selector(joinButtonClick(sender: )), for: .touchUpInside)
        collectionView.register(JoinInGroupCallUserCell.self,
                                forCellWithReuseIdentifier: String(describing: JoinInGroupCallUserCell.self))
    }
    
    @objc func expandButtonClick(sender: UIButton) {
        expandView.isHidden = expandButton.isSelected
        expandButton.isSelected = !expandButton.isSelected
        delegate?.updatePageContent(isExpand: expandButton.isSelected)
    }
    
    @objc func joinButtonClick(sender: UIButton) {
        expandButton.isSelected = false;
        delegate?.joinInGroupCall()
    }
    
    func updateView(with userList: [User], callMediaType: TUICallMediaType) {
        listDate.removeAll()
        userList.forEach {
            obj in if obj.id.value != TUILogin.getUserID() { listDate.append(obj) } }
        titleLabel.isHidden = listDate.isEmpty
        titleLabel.text = String(format: TUICallKitLocalize(key: "TUICallKit.JoinGroupView.title") ?? "",
                                 listDate.count,
                                 getCallMediaTypeStr(with: callMediaType))
        titleLabel.textAlignment = TUICoreDefineConvert.getIsRTL() ? .right : .left
        collectionView.reloadData()
    }
    
    func getCallMediaTypeStr(with callMediaType: TUICallMediaType) -> String {
        var callMediaTypeStr: String = ""
        if callMediaType == .audio {
            callMediaTypeStr = TUICallKitLocalize(key: "TUICallKit.JoinGroupView.audioCall") ?? ""
        } else if callMediaType == .video {
            callMediaTypeStr = TUICallKitLocalize(key: "TUICallKit.JoinGroupView.videoCall") ?? ""
        }
        return callMediaTypeStr
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension JoinInGroupCallView {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listDate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: JoinInGroupCallUserCell.self),
                                                      for: indexPath) as! JoinInGroupCallUserCell
        let model = listDate[indexPath.item]
        cell.setModel(user: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kJoinGroupCallItemWidth, height: kJoinGroupCallItemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kJoinGroupCallSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCellWidth: CGFloat = kJoinGroupCallItemWidth * CGFloat(listDate.count)
        let totalSpacingWidth: CGFloat = kJoinGroupCallSpacing * (CGFloat(listDate.count - 1) < 0 ? 0 : CGFloat(listDate.count - 1))
        let leftInset = (CGFloat(collectionView.bounds.size.width) - (totalCellWidth + totalSpacingWidth)) / 2
        if leftInset > 0 {
            let rightInset = leftInset
            let sectionInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
            return sectionInset
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}
