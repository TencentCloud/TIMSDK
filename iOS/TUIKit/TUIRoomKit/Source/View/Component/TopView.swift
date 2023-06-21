//
//  TopView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2022/12/30.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation

class TopView: UIView {
    // MARK: - store property
    let viewModel: TopViewModel
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 10
        return view
    }()
    
    let meetingTitleView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let meetingNameLabel: UILabel = {
        let label = UILabel()
        label.text = EngineManager.shared.store.roomInfo.name
        label.textColor = UIColor(0xD1D9EC)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let dropDownButton: UIButton = {
        let button = UIButton(type: .custom)
        let normalIcon = UIImage(named: "room_drop_down", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(normalIcon, for: .normal)
        button.isEnabled = true
        return button
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xD1D9EC)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "PingFangSC-Medium", size: 14)
        return label
    }()
    
    let downLineView: UIView = {
        let view = UIView()
        return view
    }()
    
    var menuButtons: [UIView] = []
    
    // MARK: - initialized function
    init(viewModel: TopViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - view layout
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
#if RTCube_APPSTORE
        injectReport()
#endif
    }
    
    func constructViewHierarchy() {
        addSubview(meetingTitleView)
        addSubview(stackView)
        meetingTitleView.addSubview(meetingNameLabel)
        meetingTitleView.addSubview(dropDownButton)
        meetingTitleView.addSubview(timeLabel)
        addSubview(downLineView)
        for item in viewModel.viewItems {
            let view = TopItemView(itemData: item)
            menuButtons.append(view)
            stackView.addArrangedSubview(view)
            let size = item.size ?? CGSize(width: 40.scale375(), height: 40.scale375())
            view.snp.makeConstraints { make in
                make.height.equalTo(size.height)
                make.width.equalTo(size.width)
            }
        }
    }
    
    func activateConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
        }
        meetingTitleView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(stackView.snp.left)
        }
        meetingNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(24.scale375())
            make.width.equalTo(111.scale375())
        }
        dropDownButton.snp.makeConstraints { make in
            make.left.equalTo(meetingNameLabel.snp.right).offset(5)
            make.centerY.equalTo(meetingNameLabel)
            make.width.height.equalTo(25.scale375())
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(meetingNameLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.height.equalTo(20)
        }
        downLineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(timeLabel.snp.bottom).offset(2)
            make.height.equalTo(0.3)
        }
    }
    
    func bindInteraction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dropDownAction(sender:)))
        meetingTitleView.addGestureRecognizer(tap)
        viewModel.viewResponder = self
        viewModel.updateTimerLabelText()
    }
    
    @objc func dropDownAction(sender: UIView) {
        viewModel.dropDownAction(sender: sender)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension TopView: TopViewModelResponder {
    func updateTimerLabel(text: String) {
        self.timeLabel.text = text
    }
}

#if RTCube_APPSTORE
extension TopView {

    func injectReport() {
        let roomInfo = EngineManager.shared.store.roomInfo
        if EngineManager.shared.store.currentUser.userId == roomInfo.ownerId {
           return
        }
        guard let menuView =  menuButtons.first else{ return}
        let reportBtn = UIButton(type: .custom)
        reportBtn.setImage(UIImage(named: "room_report", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        reportBtn.adjustsImageWhenHighlighted = false
        
        addSubview(reportBtn)
        reportBtn.snp.makeConstraints({ make in
            make.centerY.equalTo(menuView.snp.centerY)
            make.right.equalTo(menuView.snp.left).offset(-10)
            make.width.height.equalTo(menuView)
        })
        reportBtn.addTarget(self, action: #selector(clickReport), for: .touchUpInside)

    }
    
    @objc func clickReport() {
        let selector = NSSelectorFromString("showReportAlertWithRoomId:ownerId:")
        if responds(to: selector) {
            let roomInfo = EngineManager.shared.store.roomInfo
            perform(selector, with: roomInfo.roomId, with: roomInfo.ownerId)
        }
    }
    
}
#endif
