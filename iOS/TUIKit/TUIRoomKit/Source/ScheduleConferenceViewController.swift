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

public typealias MemberSelectionFactory = ([User]) -> ContactViewProtocol

@objcMembers public class ScheduleConferenceViewController: UIViewController {
    private var cancellableSet = Set<AnyCancellable>()
    let memberSelectionFactory: MemberSelectionFactory?
    private let durationTime = 1800
    private let reminderSecondsBeforeStart = 600
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
        
        let selector = Selector(keyPath: \ConferenceInfo.basicInfo.isPasswordEnabled)
        store.select(selector)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] isPasswordEnabled in
                guard let self = self else { return }
                var conferenceInfo = store.conferenceInfo
                conferenceInfo.basicInfo.password = isPasswordEnabled ? getRandomNumber(numberOfDigits: 6) : ""
                store.update(conference: conferenceInfo)
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
        getConferenceInfo { [weak self] conferenceInfo in
            guard let self = self else { return }
            self.store.update(conference: conferenceInfo)
            self.store.fetchAttendees(cursor: "")
        }
    }
    
    private func getConferenceInfo(onGetConferenceInfo: @escaping (ConferenceInfo)->()) {
        FetchRoomId.getRoomId { [weak self] roomId in
            guard let self = self else { return }
            var info = ConferenceInfo()
            info.scheduleStartTime = self.getStartTime()
            info.durationTime = UInt(self.durationTime)
            info.reminderSecondsBeforeStart = self.reminderSecondsBeforeStart
            var basicInfo = RoomInfo()
            basicInfo.roomId = roomId
            basicInfo.name = localizedReplace(.temporaryRoomText, replace: self.operation.selectCurrent(UserSelectors.getSelfUserName))
            basicInfo.isCameraDisableForAllUser = false
            basicInfo.isMicrophoneDisableForAllUser = false
            info.basicInfo = basicInfo
            onGetConferenceInfo(info)
        }
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
    
    private func getRandomNumber(numberOfDigits: Int) -> String {
        let minNumber = Int(truncating: NSDecimalNumber(decimal: pow(10, numberOfDigits - 1)))
        let maxNumber = Int(truncating: NSDecimalNumber(decimal: pow(10, numberOfDigits))) - 1
        let randomNumber = arc4random_uniform(UInt32(maxNumber - minNumber)) + UInt32(minNumber)
        return String(randomNumber)
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

extension ScheduleConferenceViewController: ContactViewSelectDelegate {
    public func onMemberSelected(_ viewController: ContactViewProtocol, 
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
