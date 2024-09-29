//
//  ConferenceListView.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/3.
//

import UIKit
import Combine
import Factory
import TUICore
import RTCRoomEngine

struct ConferenceSection {
    let date: Date
    let conferences: [ConferenceInfo]
}

@objcMembers public class ConferenceListView: UIView {
    // MARK: - Intailizer
    public init(viewController: UIViewController, memberSelectFactory: MemberSelectionFactory?) {
        super.init(frame: .zero)
        let viewRoute = ConferenceRoute.init(viewController: viewController)
        navigation.initializeRoute(viewController: viewController, rootRoute: viewRoute)
        if let factory = memberSelectFactory {
            navigation.dispatch(action: ConferenceNavigationAction.setMemberSelectionFactory(payload: factory))
        }
    }
    
    @available(*, unavailable, message: "Use init(viewController:) instead")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, unavailable, message: "Use init(viewController:) instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not implement ")
    }
    
    // MARK: - Public Methods
    public func reloadList() {
        store.dispatch(action: ScheduleViewActions.refreshConferenceList())
    }
    
    // MARK: Private Properties
    private let conferencesPerFetch = 10
    
    private lazy var conferenceListPublisher = {
        self.store.select(ConferenceListSelectors.getConferenceList)
    }()
    
    private lazy var cursorPublisher = {
        self.store.select(ConferenceListSelectors.getConferenceListCursor)
    }()
    
    private lazy var needRefreshPublisher = {
        self.store.select(ViewSelectors.getRefreshListFlag)
    }()
    
    private var fetchListCursor = ""
    private var sections: [ConferenceSection] = []
    var cancellableSet = Set<AnyCancellable>()
    
    private let historyRooms: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(.historyConferenceText, for: .normal)
        button.setTitleColor(UIColor.tui_color(withHex: "1C66E5"), for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 14)
        let normalIcon = UIImage(named: "room_right_blue_arrow", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(normalIcon, for: .normal)
        button.sizeToFit()
        
        var imageWidth = button.imageView?.bounds.size.width ?? 0
        var titleWidth = button.titleLabel?.bounds.size.width ?? 0
        button.titleEdgeInsets = UIEdgeInsets(top: 0,
                                              left: -imageWidth,
                                              bottom: 0,
                                              right: imageWidth);
        button.imageEdgeInsets = UIEdgeInsets(top: 0,
                                              left: titleWidth,
                                              bottom: 0,
                                              right: -titleWidth)
        return button
    }()
    
    private lazy var tableview: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(ConferenceListCell.self, forCellReuseIdentifier: ConferenceListCell.reusedIdentifier)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()
    
   private  let noScheduleTipLabel: UILabel = {
        let tip = UILabel()
        tip.textAlignment = .center
        tip.font = UIFont.systemFont(ofSize: 14)
        tip.textColor = UIColor.tui_color(withHex: "8F9AB2")
        tip.text = .noScheduleText
        tip.adjustsFontSizeToFitWidth = true
        return tip
    }()
    
    private let noScheduleImageView: UIImageView = {
        let image = UIImage(named: "room_no_schedule", in: tuiRoomKitBundle(), compatibleWith: nil)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    private lazy var dateFormater: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = .current
        return dateFormatter
    }()
    
    // MARK: - view layout
    private var isViewReady: Bool = false
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        backgroundColor = .white
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    // MARK: Private Methods
    private func constructViewHierarchy() {
        addSubview(noScheduleImageView)
        addSubview(noScheduleTipLabel)
        addSubview(tableview)
    }
    
    private func activateConstraints() {
        tableview.snp.makeConstraints { make in
            make.leading.bottom.trailing.top.equalToSuperview()
        }
        noScheduleImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(160)
            make.width.equalTo(120.scale375())
            make.height.equalTo(79.scale375())
            
        }
        noScheduleTipLabel.snp.makeConstraints { make in
            make.top.equalTo(noScheduleImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    private func bindInteraction() {
        subscribeToast()
        subscribeScheduleSubject()
        store.dispatch(action: ConferenceListActions.fetchConferenceList(payload: (fetchListCursor, conferencesPerFetch)))
        conferenceListPublisher
            .receive(on: DispatchQueue.global(qos: .default))
            .map { [weak self] newInfos -> (Int, [ConferenceSection]) in
                guard let self = self else { return (0, []) }
                let newSections = self.groupAndSortInfos(newInfos)
                return (newInfos.count, newSections)
            }
            .receive(on: DispatchQueue.mainQueue)
            .sink { [weak self] (conferenceCount, newSections) in
                guard let self = self else { return }
                self.sections = newSections
                self.tableview.reloadData()
                if conferenceCount > 0 {
                    self.noScheduleImageView.isHidden = true
                    self.noScheduleTipLabel.isHidden = true
                } else {
                    self.noScheduleImageView.isHidden = false
                    self.noScheduleTipLabel.isHidden = false
                }
            }
            .store(in: &cancellableSet)
        
        cursorPublisher
            .receive(on: DispatchQueue.mainQueue)
            .sink { [weak self] cursor in
                guard let self = self else { return }
                self.fetchListCursor = cursor
            }
            .store(in: &cancellableSet)
        
        needRefreshPublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] needRefresh in
                guard let self = self else { return }
                if needRefresh {
                    store.dispatch(action: ConferenceListActions.resetConferenceList())
                    store.dispatch(action: ConferenceListActions.fetchConferenceList(payload: ("", conferencesPerFetch)))
                    store.dispatch(action: ScheduleViewActions.stopRefreshList())
                }
            }
            .store(in: &cancellableSet)
    }
    
    private func groupAndSortInfos(_ infos: [ConferenceInfo]) -> [ConferenceSection] {
        var groupedInfos: [Date: [ConferenceInfo]] = [:]
        
        let calendar = Calendar.current
        for info in infos {
            let date = calendar.startOfDay(for: Date(timeIntervalSince1970: TimeInterval(info.scheduleStartTime)))
            groupedInfos[date, default: []].append(info)
        }

        var retData: [ConferenceSection] = groupedInfos.map { (date, infos) in
            print("")
            return ConferenceSection(date: date, conferences: infos.sorted { (confercence1, conference2) -> Bool in
                if confercence1.scheduleStartTime == conference2.scheduleStartTime {
                    return confercence1.basicInfo.createTime < conference2.basicInfo.createTime
                } else {
                    return confercence1.scheduleStartTime < conference2.scheduleStartTime
                }
            })
        }
        
        retData.sort(by: { $0.date < $1.date })
        
        return retData
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    // MARK: - private property.
    @Injected(\.conferenceStore) var store: ConferenceStore
    @Injected(\.navigation) var navigation: Route
}

extension ConferenceListView: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].conferences.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConferenceListCell.reusedIdentifier, for: indexPath)
        if let cell = cell as? ConferenceListCell, indexPath.row < sections[indexPath.section].conferences.count {
            let info = sections[indexPath.section].conferences[indexPath.row]
            cell.updateCell(with: info)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conferenceInfo = sections[indexPath.section].conferences[indexPath.row]
        navigation.pushTo(route: .scheduleDetails(conferenceInfo: conferenceInfo))
    }
}


extension ConferenceListView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        
        let calendarImage = UIImage(named: "room_calendar", in: tuiRoomKitBundle(), compatibleWith: nil)
        let imageView = UIImageView(image: calendarImage)
        headerView.addSubview(imageView)
        
        let headerLabel = UILabel()
        headerLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        headerLabel.textColor = UIColor.tui_color(withHex: "969EB4")
        headerLabel.text = self.dateFormater.string(from: sections[section].date)
        headerView.addSubview(headerLabel)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(headerLabel)
            make.height.width.equalTo(16)
        }
        headerLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(4)
            make.top.equalToSuperview()
        }
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            if !fetchListCursor.isEmpty {
                store.dispatch(action: ConferenceListActions.fetchConferenceList(payload: (fetchListCursor, conferencesPerFetch)))
            }
        }
    }
}

extension ConferenceListView {
    private func subscribeScheduleSubject() {
        store.scheduleActionSubject
            .receive(on: RunLoop.main)
            .filter { $0.id == ScheduleResponseActions.onScheduleSuccess.id }
            .sink { [weak self] action in
                guard let self = self else { return }
                if let action = action as? AnonymousAction<TUIConferenceInfo> {
                    let view = InviteEnterRoomView(conferenceInfo: ConferenceInfo(with: action.payload), style: .inviteWhenSuccess)
                    self.navigation.present(route: .popup(view: view))
                }
            }
            .store(in: &cancellableSet)
    }
    
    private func subscribeToast() {
        store.toastSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] toast in
                guard let self = self else { return }
                var position = TUICSToastPositionBottom
                switch toast.position {
                    case .center:
                        position = TUICSToastPositionCenter
                    default:
                        break
                }
                if self.isPresenting() {
                    self.makeToast(toast.message, duration: toast.duration, position: position)
                }
            }
            .store(in: &cancellableSet)
    }
}

private extension String {
    static var noScheduleText: String {
        localized("No Room Scheduled")
    }
    static var historyConferenceText: String {
        localized("History Room")
    }
}

extension UIView {
    func isPresenting() -> Bool {
        guard let viewController = self.parentViewController else { return false }
        return viewController.presentedViewController == nil
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

