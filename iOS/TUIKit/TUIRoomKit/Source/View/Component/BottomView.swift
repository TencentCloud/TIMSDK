//
//  BottomView.swift
//  TUIRoomKit
//
//  Created by aby on 2022/12/21.
//  Copyright © 2022 Tencent. All rights reserved.
//

import UIKit

class BottomView: UIView {
    // MARK: - store property
    let viewModel: BottomViewModel
    private var viewArray: [BottomItemView] = []
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .equalSpacing
        return view
    }()
    
    // MARK: - initialized function
    init(viewModel: BottomViewModel) {
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
    }
    
    func constructViewHierarchy() {
        addSubview(stackView)
        for item in viewModel.viewItems {
            let view = BottomItemView(itemData: item)
            viewArray.append(view)
            stackView.addArrangedSubview(view)
            let size = item.size ?? CGSize(width: 52.scale375(), height: 52.scale375())
            view.snp.makeConstraints { make in
                make.height.equalTo(size.height)
                make.width.equalTo(size.width)
            }
            view.backgroundColor = item.backgroundColor ?? UIColor(0x2A2D38)
        }
    }
    
    func activateConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
    }
    
    func bindInteraction() {
        viewModel.viewResponder = self
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension BottomView: BottomViewModelResponder {
    func updateStackView(item: ButtonItemData, index: Int) {
        guard viewArray.count > index else { return }
        viewArray[index].removeFromSuperview()
        let view = BottomItemView(itemData: item)
        viewArray[index] = view
        stackView.insertArrangedSubview(view, at: index)
        view.snp.makeConstraints { make in
            make.height.equalTo(52.scale375())
            make.width.equalTo(52.scale375())
        }
        view.backgroundColor = item.backgroundColor ?? UIColor(0x2A2D38)
    }
    
    func showExitRoomAlert(isRoomOwner: Bool, isOnlyOneUserInRoom: Bool) {
        var title: String?
        var message: String?
        let dismissRoomAction = UIAlertAction(title: .dismissMeetingText, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.exitRoom(isHomeowner: true)
        }
        let transferMasterAction = UIAlertAction(title: .leaveMeetingText, style: .default) { _ in
            RoomRouter.shared.presentPopUpViewController(viewType: .transferMasterViewType,height: nil)
        }
        let leaveRoomAction = UIAlertAction(title: .leaveMeetingText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.exitRoom(isHomeowner: false)
        }
        let cancelAction = UIAlertAction(title: .cancelText, style: .cancel, handler: nil)
        let alertVC = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .actionSheet)
        if isRoomOwner {
            if isOnlyOneUserInRoom {
                title = .destroyRoomTitle
                message = nil
                alertVC.addAction(dismissRoomAction)
                alertVC.addAction(cancelAction)
            } else {
                title = .dismissMeetingTitle
                message = .appointNewHostText
                alertVC.addAction(transferMasterAction)
                alertVC.addAction(dismissRoomAction)
                alertVC.addAction(cancelAction)
            }
        } else {
            title = .leaveRoomTitle
            message = nil
            alertVC.addAction(leaveRoomAction)
            alertVC.addAction(cancelAction)
        }
        alertVC.title = title
        alertVC.message = message
        RoomRouter.shared.presentAlert(alertVC)
    }
    
    func makeToast(text: String) {
        RoomRouter.makeToast(toast: text)
    }
}

private extension String {
    static var leaveRoomTitle: String {
        localized("TUIRoom.sure.leave.room")
    }
    static var destroyRoomTitle: String {
        localized("TUIRoom.sure.destroy.room")
    }
    static var destroyRoomCancelTitle: String {
        localized("TUIRoom.destroy.room.cancel")
    }
    static var logoutOkText: String {
        localized("TUIRoom.ok")
    }
    static var dismissMeetingTitle: String {
        localized("TUIRoom.dismiss.meeting.Title")
    }
    static var appointNewHostText: String {
        localized("TUIRoom.appoint.new.host")
    }
    static var leaveMeetingText: String {
        localized("TUIRoom.leave.meeting")
    }
    static var dismissMeetingText: String {
        localized("TUIRoom.dismiss.meeting")
    }
    static var cancelText: String {
        localized("TUIRoom.cancel")
    }
}

