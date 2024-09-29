//
//  ModifyScheduleViewController.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/26.
//

import Foundation
import Factory
import Combine
import TUICore

class ModifyScheduleViewController: UIViewController {
    private var cancellableSet = Set<AnyCancellable>()
    var conferenceInfo: ConferenceInfo
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    init(conferenceInfo: ConferenceInfo) {
        self.conferenceInfo = conferenceInfo
        super.init(nibName: nil, bundle: nil)
        modifyStore.update(conference: self.conferenceInfo)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = ScheduleConferenceTableView(menus: ModifyScheduleDataHelper.generateScheduleConferenceData(route: route, store: store, operation: operation, modifyStore: modifyStore, viewController: self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = .modifyRoomText
        subscribeScheduleSubject()
        subscribeToast()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    @Injected(\.navigation) private var route
    @Injected(\.scheduleStore) private var store
    @Injected(\.conferenceStore) private var operation
    @Injected(\.modifyScheduleStore) private var modifyStore
}

extension ModifyScheduleViewController {
    private func subscribeScheduleSubject() {
        operation.scheduleActionSubject
            .receive(on: RunLoop.main)
            .filter { $0.id == ScheduleResponseActions.onUpdateInfoSuccess.id }
            .sink { [weak self] action in
                guard let self = self else { return }
                self.route.pop()
            }
            .store(in: &cancellableSet)
    }
    
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
}

extension ModifyScheduleViewController: ContactViewSelectDelegate {
    public func onMemberSelected(_ viewController: ContactViewProtocol,
                                 invitees: [User]) {
        var conferenceInfo = modifyStore.conferenceInfo
        conferenceInfo.attendeeListResult.attendeeList = invitees.map { $0.userInfo }
        conferenceInfo.attendeeListResult.totalCount = UInt(invitees.count)
        modifyStore.update(conference: conferenceInfo)
        route.pop()
    }
}

private extension String {
    static var modifyRoomText: String {
        localized("Modify Room")
    }
}
