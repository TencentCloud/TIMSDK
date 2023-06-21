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
    func showExitRoomAlert() {
        let alertVC = UIAlertController(title: .audienceLogoutTitle,
                                        message: nil,
                                        preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: .destroyRoomCancelTitle, style: .cancel, handler: nil)
        let sureAction = UIAlertAction(title: .logoutOkText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.exitRoomLogic(isHomeowner: false)
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(sureAction)
        RoomRouter.shared.presentAlert(alertVC)
    }
    func showDestroyRoomAlert() {
        let alertController = UIAlertController(title: .dismissMeetingTitleText, message: .appointNewHostText, preferredStyle: .actionSheet)
        let leaveRoomAction = UIAlertAction(title: .leaveMeetingText, style: .default) { _ in
            RoomRouter.shared.presentPopUpViewController(viewType: .transferMasterViewType,height: nil)
        }
        let dismissRoomAction = UIAlertAction(title: .dismissMeetingText, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.exitRoomLogic(isHomeowner: true)
        }
        let cancelAction = UIAlertAction(title: .cancelText, style: .cancel) { _ in
        }
        alertController.addAction(leaveRoomAction)
        alertController.addAction(dismissRoomAction)
        alertController.addAction(cancelAction)
        RoomRouter.shared.presentAlert(alertController)
        
    }
    func makeToast(text: String) {
        RoomRouter.makeToast(toast: text)
    }
}

private extension String {
    static var audienceLogoutTitle: String {
        localized("TUIRoom.sure.leave.room")
    }
    static var destroyRoomCancelTitle: String {
        localized("TUIRoom.destroy.room.cancel")
    }
    static var logoutOkText: String {
        localized("TUIRoom.ok")
    }
    static var dismissMeetingTitleText: String {
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

