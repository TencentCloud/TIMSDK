//
//  ScheduleConferenceViewController.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/5.
//

import Foundation
import Factory
import RTCRoomEngine
import Combine
import TUICore

public typealias MemberSelectionFactory = ([User]) -> SelectMemberControllerProtocol

@objcMembers public class ScheduleConferenceViewController: UIViewController {
    private var cancellableSet = Set<AnyCancellable>()
    let memberSelectionFactory: MemberSelectionFactory?
    lazy var rootView: ScheduleConferenceTableView = {
        return ScheduleConferenceTableView(menus: ScheduleConferenceDataHelper.generateScheduleConferenceData(route: route, store: store, operation: operation, viewController: self))
    }()
    
    public override var shouldAutorotate: Bool {
        return false
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    public init(memberSelectFactory: MemberSelectionFactory?) {
        self.memberSelectionFactory = memberSelectFactory
        super.init(nibName: nil, bundle: nil)
        if let factory = memberSelectFactory {
            route.dispatch(action: ConferenceNavigationAction.setMemberSelectionFactory(payload: factory))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        self.view = rootView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
        initializeRoute()
        initializeData()
        
        subscribeScheduleSubject()
        subscribeToast()
        
        let selector = Selector(keyPath: \ConferenceInfo.isEncrypted)
        store.select(selector)
            .receive(on: RunLoop.main)
            .sink { [weak self] isEncrypted in
                guard let self = self else { return }
                self.rootView.menus = ScheduleConferenceDataHelper.generateScheduleConferenceData(route: self.route, store: self.store, operation: self.operation, viewController: self)
                self.rootView.tableView.reloadData()
            }
            .store(in: &cancellableSet)
    }
    
    private func initializeView() {
        view.backgroundColor = UIColor(0xF8F9FB)
        navigationItem.title = .bookRoomText
    }
    
    private func initializeRoute() {
        let viewRoute = ConferenceRoute.init(viewController: self)
        route.initializeRoute(viewController: self, rootRoute: viewRoute)
    }
    
    private func initializeData() {
        operation.dispatch(action: UserActions.getSelfInfo())
        let conferenceInfo = getConferenceInfo()
        store.update(conference: conferenceInfo)
        store.fetchAttendees(cursor: "")
    }
    
    private func getConferenceInfo() -> ConferenceInfo {
        var info = ConferenceInfo()
        info.scheduleStartTime = getStartTime()
        info.durationTime = 1800
        var basicInfo = RoomInfo()
        basicInfo.roomId = FetchRoomId.getRandomRoomId(numberOfDigits: 6)
        basicInfo.name = localizedReplace(.temporaryRoomText, replace: operation.selectCurrent(UserSelectors.getSelfUserName))
        basicInfo.isCameraDisableForAllUser = false
        basicInfo.isMicrophoneDisableForAllUser = false
        info.basicInfo = basicInfo
        return info
    }
    
    private func getStartTime() -> UInt {
        let oneMinutesInterval = 60
        let fiveMinutesInterval = UInt(5 * oneMinutesInterval)
        var time = UInt(Date().timeIntervalSince1970)
        let remainder = time % fiveMinutesInterval
        if  remainder > oneMinutesInterval {
            time = time - remainder
        }
        time = time + fiveMinutesInterval
        return time
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    @Injected(\.navigation) private var route
    @Injected(\.modifyScheduleStore) private var store
    @Injected(\.conferenceStore) private var operation
}

extension ScheduleConferenceViewController {
    private func subscribeToast() {
        operation.toastSubject
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
                self.view.makeToast(toast.message, duration: toast.duration, position: position)
            }
            .store(in: &cancellableSet)
    }
    
    private func subscribeScheduleSubject() {
        operation.scheduleActionSubject
            .receive(on: RunLoop.main)
            .filter { $0.id == ScheduleResponseActions.onScheduleSuccess.id }
            .sink { [weak self] action in
                guard let self = self else { return }
                self.route.pop()
            }
            .store(in: &cancellableSet)
    }
}

extension ScheduleConferenceViewController: MemberSelectionDelegate {
    public func onMemberSelected(_ viewController: SelectMemberControllerProtocol, 
                                 invitees: [User]) {
        var conferenceInfo = store.conferenceInfo
        conferenceInfo.attendeeListResult.attendeeList = invitees.map { $0.userInfo }
        conferenceInfo.attendeeListResult.totalCount = UInt(invitees.count)
        store.update(conference: conferenceInfo)
        route.pop()
    }
}

private extension String {
    static var bookRoomText: String = localized("Schedule Room")
    static var temporaryRoomText: String = localized("xx's temporary room")
}
