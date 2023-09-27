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
    var moreButtonItem: BottomItemView?
    var dropButtonItem: BottomItemView?
    var recordButtonItem: BottomItemView?
    var shareScreenButtonItem: BottomItemView?
    var memberButtonItem: BottomItemView?

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
        addFunctionalButton()
        layoutMoreButtonMenu()
    }
    
    func addFunctionalButton() {
        for item in viewModel.viewItems {
            let view = BottomItemView(itemData: item)
            viewArray.append(view)
            initButtonItem(view: view)

            if viewModel.roomInfo.speechMode == .freeToSpeak {
                switch view.itemData.buttonType {
                case .memberItemType,
                     .muteAudioItemType,
                     .muteVideoItemType,
                     .shareScreenItemType,
                     .chatItemType,
                     .moreItemType:
                    baseButtonMenuView.addArrangedSubview(view)
                case .inviteItemType,
                     .floatWindowItemType,
                     .setupItemType,
                     .advancedSettingItemType,
                     .recordItemType:
                    moreButtonMenuView.addArrangedSubview(view)
                default:
                    break
                }
            } else if viewModel.roomInfo.speechMode == .applySpeakAfterTakingSeat {
                switch view.itemData.buttonType {
                case .memberItemType,
                     .muteAudioItemType,
                     .muteVideoItemType,
                     .shareScreenItemType,
                     .raiseHandItemType,
                     .leaveSeatItemType,
                     .moreItemType:
                    baseButtonMenuView.addArrangedSubview(view)
                case .chatItemType,
                     .inviteItemType,
                     .floatWindowItemType,
                     .setupItemType,
                     .advancedSettingItemType,
                     .recordItemType:
                    moreButtonMenuView.addArrangedSubview(view)
                default:
                    break
                }
            }

            let size = item.size ?? CGSize(width: 52.scale375(), height: 52.scale375())
            view.snp.makeConstraints { make in
                make.height.equalTo(size.height)
                make.width.equalTo(size.width)
            }
            view.backgroundColor = item.backgroundColor ?? UIColor(0x2A2D38)
        }
    }
    
    func layoutMoreButtonMenu() {
        let emptyViewCount = baseButtonMenuView.subviews.count - moreButtonMenuView.subviews.count
        if emptyViewCount == 0 {return}
        for _ in 1...emptyViewCount {
            let emptyView = BottomItemView(itemData: ButtonItemData())
            emptyView.snp.makeConstraints { make in
                make.height.equalTo(52.scale375())
                make.width.equalTo(52.scale375())
                moreButtonMenuView.addArrangedSubview(emptyView)
            }
        }
    }

    func initButtonItem(view: BottomItemView) {
        if view.itemData.buttonType == .moreItemType {
            moreButtonItem = view
        }
        if view.itemData.buttonType == .dropItemType {
            dropButtonItem = view
        }
        if view.itemData.buttonType == .recordItemType {
            recordButtonItem = view
            recordButtonItem?.alpha = 0
            recordButtonItem?.button.isEnabled = false
        }
        if view.itemData.buttonType == .shareScreenItemType {
            shareScreenButtonItem = view
        }
        if view.itemData.buttonType == .memberItemType {
            memberButtonItem = view
        }
    }

    func activateConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(60.scale375())
        }
        buttonMenuView.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width - 16)
            make.bottom.centerX.height.equalToSuperview()
        }
        baseButtonMenuView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8.scale375())
            make.height.equalTo(52.scale375())
            make.width.equalToSuperview()
        }
        moreButtonMenuView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(52.scale375())
            make.width.equalToSuperview()
        }
    }

    func bindInteraction() {
        viewModel.viewResponder = self
        let title = localizedReplace(.memberText,replace: String(viewModel.attendeeList.count))
        memberButtonItem?.button.setTitle(title, for: .normal)
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
        baseButtonMenuView.insertArrangedSubview(view, at: index)
        view.snp.makeConstraints { make in
            make.height.equalTo(52.scale375())
            make.width.equalTo(52.scale375())
        }
        view.backgroundColor = item.backgroundColor ?? UIColor(0x2A2D38)
    }

    func makeToast(text: String) {
        RoomRouter.makeToastInCenter(toast: text, duration: 1)
    }

    private func updateBottomViewConstraints(isUnfold: Bool, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3) { [weak self] () in
            guard let self = self else { return }
            self.snp.updateConstraints { make in
                make.height.equalTo(isUnfold ? 130.scale375() : 60.scale375())
            }
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            completion()
        }
    }

    private func changeButtonMenuState(isUnfold: Bool) {
        if isUnfold {
            updateBaseButtonMeunContent(isUnfold: true)
            moreButtonMenuView.isHidden = false
        } else {
            updateBaseButtonMeunContent(isUnfold: false)
            moreButtonMenuView.isHidden = true
        }
    }

    private func updateBaseButtonMeunContent(isUnfold: Bool) {
        if isUnfold {
            moreButtonItem?.removeFromSuperview()
            guard let drop = dropButtonItem else { return }
            baseButtonMenuView.addArrangedSubview(drop)
        } else {
            dropButtonItem?.removeFromSuperview()
            guard let more = moreButtonItem else { return }
            baseButtonMenuView.addArrangedSubview(more)
        }
    }

    func updataBottomView(isUp: Bool) {
        buttonMenuView.backgroundColor = isUp ? UIColor(0x2A2D38) : UIColor(0x0F1014)
        if isUp {
            updateBottomViewConstraints(isUnfold: true) { [weak self] in
                guard let self = self else { return }
                self.changeButtonMenuState(isUnfold: true)
            }
        } else {
            self.changeButtonMenuState(isUnfold: false)
            updateBottomViewConstraints(isUnfold: false) {}
        }
    }

    func updateButtonItemViewSelectState(shareScreenSeletecd: Bool) {
        shareScreenButtonItem?.button.isSelected = shareScreenSeletecd
    }

    func updateButtonItemViewEnableState(shareScreenEnable: Bool) {
        shareScreenButtonItem?.button.isEnabled = shareScreenEnable
    }
    
    func reloadBottomView() {
        memberButtonItem?.button.setTitle(.memberText + "(\(viewModel.attendeeList.count))", for: .normal)
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
    
    static var memberText: String {
        localized("TUIRoom.conference.member")
    }
}
