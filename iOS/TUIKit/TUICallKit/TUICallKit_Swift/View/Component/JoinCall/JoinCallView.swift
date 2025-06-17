//
//  JoinCallView.swift
//  Pods
//
//  Created by vincepzhang on 2025/3/3.
//

import UIKit
import TUICore
import RTCRoomEngine

let kJoinGroupCallViewDefaultHeight: CGFloat = 52.0
let kJoinGroupCallViewExpandHeight: CGFloat = 225.0
let kJoinGroupCallItemWidth: CGFloat = 50.0
let kJoinGroupCallSpacing: CGFloat = 12.0

protocol JoinCallViewDelegate: AnyObject {
    func updatePageContent(isExpand: Bool)
    func joinCall()
}

class JoinCallView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: JoinCallViewDelegate?
    var listDate = Array<User>()
    
    let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_join_group_bottom_container_bg_color",
                                                                              defaultHex: "#FFFFFF")
        view.layer.cornerRadius = 6.0
        view.layer.masksToBounds = true
        return view
    }()
    
    let titleIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = CallKitBundle.getBundleImage(name: "icon_join_group")
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_join_group_title_color", defaultHex: "#999999")
        label.textAlignment = .left
        return label
    }()
    
    let expandButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(CallKitBundle.getBundleImage(name: "icon_join_group_expand"), for: .normal)
        button.setImage(CallKitBundle.getBundleImage(name: "icon_join_group_zoom"), for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let expandView: UIView = {
        let view = UIView()
        view.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_join_group_expand_bg_color", defaultHex: "#EEF0F2")
        view.isHidden = true
        view.layer.cornerRadius = 6.0
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
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
    
    let lineView: UIView = {
        let view = UIView()
        view.alpha = 0.1
        view.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_join_group_line_color", defaultHex: "#707070")
        return view
    }()
    
    let joinButton: UIButton = {
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
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            bottomContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            bottomContainerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            bottomContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        titleIcon.translatesAutoresizingMaskIntoConstraints = false
        if let superview = titleIcon.superview {
            NSLayoutConstraint.activate([
                titleIcon.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 8),
                titleIcon.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 16),
                titleIcon.widthAnchor.constraint(equalToConstant: 20),
                titleIcon.heightAnchor.constraint(equalToConstant: 20)
            ])
        }

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        if let superview = titleLabel.superview {
            NSLayoutConstraint.activate([
                titleLabel.centerYAnchor.constraint(equalTo: titleIcon.centerYAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: titleIcon.trailingAnchor, constant: 10),
                titleLabel.widthAnchor.constraint(equalToConstant: 200),
                titleLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
        }

        expandButton.translatesAutoresizingMaskIntoConstraints = false
        if let superview = expandButton.superview {
            NSLayoutConstraint.activate([
                expandButton.centerYAnchor.constraint(equalTo: titleIcon.centerYAnchor),
                expandButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
                expandButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -16),
                expandButton.widthAnchor.constraint(equalToConstant: 30),
                expandButton.heightAnchor.constraint(equalToConstant: 30)
            ])
        }

        expandView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = expandView.superview {
            NSLayoutConstraint.activate([
                expandView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 36),
                expandView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 16),
                expandView.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -16),
                expandView.heightAnchor.constraint(equalToConstant: 157)
            ])
        }

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: expandView.topAnchor, constant: 37),
            collectionView.leadingAnchor.constraint(equalTo: expandView.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: expandView.trailingAnchor, constant: -10),
            collectionView.heightAnchor.constraint(equalToConstant: kJoinGroupCallItemWidth)
        ])

        lineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: expandView.topAnchor, constant: 117),
            lineView.leadingAnchor.constraint(equalTo: expandView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: expandView.trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])

        joinButton.translatesAutoresizingMaskIntoConstraints = false
        if let superview = joinButton.superview, let expandSuperview = expandView.superview {
            NSLayoutConstraint.activate([
                joinButton.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 5),
                joinButton.centerXAnchor.constraint(equalTo: expandSuperview.centerXAnchor),
                joinButton.widthAnchor.constraint(equalTo: expandSuperview.widthAnchor),
                joinButton.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
    }
    
    func bindInteraction() {
        expandButton.addTarget(self, action: #selector(expandButtonClick(sender: )), for: .touchUpInside)
        joinButton.addTarget(self, action: #selector(joinButtonClick(sender: )), for: .touchUpInside)
        collectionView.register(JoinCallUserCell.self,
                                forCellWithReuseIdentifier: String(describing: JoinCallUserCell.self))
    }
    
    @objc func expandButtonClick(sender: UIButton) {
        expandView.isHidden = expandButton.isSelected
        expandButton.isSelected = !expandButton.isSelected
        delegate?.updatePageContent(isExpand: expandButton.isSelected)
    }
    
    @objc func joinButtonClick(sender: UIButton) {
        expandButton.isSelected = false;
        delegate?.joinCall()
    }
    
    func updateView(with userList: [User], callMediaType: TUICallMediaType) {
        listDate.removeAll()
        userList.forEach {
            obj in if obj.id.value != TUILogin.getUserID() { listDate.append(obj) } }
        titleLabel.isHidden = listDate.isEmpty
        titleLabel.text = String(format: TUICallKitLocalize(key: "TUICallKit.JoinGroupView.title") ?? "",
                                 listDate.count)
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
extension JoinCallView {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listDate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: JoinCallUserCell.self),
                                                      for: indexPath) as! JoinCallUserCell
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
