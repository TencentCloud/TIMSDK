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
    var isUnfold: Bool = false //是否展开
    let unfoldHeight = Float(130.scale375Height())
    let packUpHeight = Float(68.scale375Height())

    let baseButtonMenuView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 10
        return view
    }()

    let moreButtonMenuView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 10
        return view
    }()
    
    let buttonMenuView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x0F1014)
        view.layer.cornerRadius = 12
        return view
    }()
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x0F1014)
        return view
    }()

    // MARK: - initialized function

    init(viewModel: BottomViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        backgroundColor = .clear
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
        addSubview(backgroundView)
        addSubview(buttonMenuView)
        buttonMenuView.addSubview(moreButtonMenuView)
        buttonMenuView.addSubview(baseButtonMenuView)
        moreButtonMenuView.isHidden = true
        setupMenuStackView(items: viewModel.viewItems)
        layoutMoreButtonMenu()
    }
    
    func setupMenuStackView(items: [ButtonItemData]) {
        for i in 0...(items.count - 1) {
            guard let item = viewModel.viewItems[safe: i] else { continue }
            let view = BottomItemView(itemData: item)
            let size = item.size ?? CGSize(width: 52.scale375(), height: 52.scale375())
            view.snp.makeConstraints { make in
                make.height.equalTo(size.height)
                make.width.equalTo(size.width)
            }
            view.backgroundColor = item.backgroundColor ?? UIColor(0x2A2D38)
            viewArray.append(view)
            if i < 6 {
                baseButtonMenuView.addArrangedSubview(view)
            } else {
                moreButtonMenuView.addArrangedSubview(view)
            }
        }
    }
    
    func layoutMoreButtonMenu() {
        let emptyViewCount = baseButtonMenuView.subviews.count - moreButtonMenuView.subviews.count
        if emptyViewCount <= 0 {return}
        for _ in 1...emptyViewCount {
            let emptyView = BottomItemView(itemData: ButtonItemData())
            emptyView.snp.makeConstraints { make in
                make.height.equalTo(52.scale375())
                make.width.equalTo(52.scale375())
                moreButtonMenuView.addArrangedSubview(emptyView)
            }
            viewArray.append(emptyView)
        }
    }

    func activateConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(packUpHeight)
        }
        let width = min(kScreenWidth, kScreenHeight)
        buttonMenuView.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.bottom.centerX.height.equalToSuperview()
        }
        baseButtonMenuView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8.scale375())
            make.height.equalTo(52.scale375())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
        }
        moreButtonMenuView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(52.scale375())
            make.leading.trailing.equalTo(baseButtonMenuView)
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
    func updateButtonView(item: ButtonItemData) {
        guard let view = viewArray.first(where: { $0.itemData.buttonType == item.buttonType }) else { return }
        view.setupViewState(item: item)
    }
    
    func showAlert(title: String?, message: String?, sureTitle: String?, declineTitle: String?, sureBlock: (() -> ())?, declineBlock: (() -> ())?) {
        RoomRouter.presentAlert(title: title, message: message, sureTitle: sureTitle, declineTitle: declineTitle, sureBlock: sureBlock, declineBlock: declineBlock)
    }
    
    func updateStackView(items: [ButtonItemData]) {
        viewArray.forEach { view in
            view.removeFromSuperview()
        }
        viewArray = []
        setupMenuStackView(items: items)
        layoutMoreButtonMenu()
    }

    func makeToast(text: String) {
        RoomRouter.makeToastInCenter(toast: text, duration: 1)
    }

    private func updateBottomViewConstraints(isUnfold: Bool, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3) { [weak self] () in
            guard let self = self else { return }
            self.snp.updateConstraints { make in
                make.height.equalTo(isUnfold ? self.unfoldHeight : self.packUpHeight)
            }
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            completion()
        }
    }

    func updataBottomView(isUp: Bool) {
        buttonMenuView.backgroundColor = isUp ? UIColor(0x2A2D38) : UIColor(0x0F1014)
        self.isUnfold = isUp
        if isUp {
            updateBottomViewConstraints(isUnfold: true) { [weak self] in
                guard let self = self else { return }
                self.moreButtonMenuView.isHidden = false
            }
        } else {
            moreButtonMenuView.isHidden = true
            updateBottomViewConstraints(isUnfold: false) {}
        }
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
        localized("TUIRoom.wait")
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
    
    static var memberText: String {
        localized("TUIRoom.conference.member")
    }

    static var toastTitleText: String {
        localized("TUIRoom.toast.shareScreen.title")
    }
    static var toastMessageText: String {
        localized("TUIRoom.toast.shareScreen.message")
    }
    static var toastStopText: String {
        localized("TUIRoom.toast.shareScreen.stop")
    }
}
