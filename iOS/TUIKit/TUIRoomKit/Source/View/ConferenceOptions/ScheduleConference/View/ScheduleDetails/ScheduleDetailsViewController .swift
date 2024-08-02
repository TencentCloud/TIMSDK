//
//  ScheduleDetailsViewController .swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/24.
//

import Foundation
import Factory
import Combine
import TUICore
import RTCRoomEngine

class ScheduleDetailsViewController: UIViewController {
    var conferenceInfo: ConferenceInfo
    private var cancellableSet = Set<AnyCancellable>()
    
    private lazy var rootView: ScheduleConferenceTableView = {
        return ScheduleConferenceTableView(menus: ScheduleDetailsDataHelper.generateScheduleConferenceData(route: route, store: store, operation: operation))
    }()
    
    private lazy var conferenceListPublisher = {
        operation.select(ConferenceListSelectors.getConferenceList)
    }()
    
    init(conferenceInfo: ConferenceInfo) {
        self.conferenceInfo = conferenceInfo
        super.init(nibName: nil, bundle: nil)
        store.update(conference: self.conferenceInfo)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    lazy var modifyButton: UIButton = {
        let button = UIButton()
        button.setTitle(.reviseText, for: .normal)
        button.setTitleColor(UIColor(0x1C66E5), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(modifyAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initState()
        subscribeToast()
        subscribeScheduleSubject()
        navigationItem.title = .roomDetailsText
        if store.conferenceInfo.basicInfo.ownerId == operation.selectCurrent(UserSelectors.getSelfId),
           store.conferenceInfo.status == .notStarted {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: modifyButton)
        }
        store.fetchAttendees(cursor: "")
        let cursorSelector = Selector(keyPath: \ConferenceInfo.attendeeListResult.fetchCursor)
        store.select(cursorSelector)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] cursor in
                guard let self = self else { return }
                if !cursor.isEmpty {
                    self.store.fetchAttendees(cursor: cursor)
                }
            }
            .store(in: &cancellableSet)
        
        operation.select(ViewSelectors.getPopDetailFlag)
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] shouldPopDetail in
                guard let self = self else { return }
                if shouldPopDetail {
                    self.route.pop(route: .scheduleDetails(conferenceInfo:self.conferenceInfo))
                }
            }
            .store(in: &cancellableSet)
        
        conferenceListPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] list in
                guard let self = self else { return }
                guard let selectedConferenceInfo = list.first(where: { $0.basicInfo.roomId == self.conferenceInfo.basicInfo.roomId }) else { return }
                guard selectedConferenceInfo.status != self.store.conferenceInfo.status, selectedConferenceInfo.status == .running else { return }
                self.modifyButton.isHidden = true
                var conferenceInfo = self.store.conferenceInfo
                conferenceInfo.status = selectedConferenceInfo.status
                self.store.update(conference: conferenceInfo)
                let menus = ScheduleDetailsDataHelper.generateScheduleConferenceData(route: self.route, store: self.store, operation: self.operation)
                self.rootView.menus = menus
                self.rootView.tableView.reloadData()
            }
            .store(in: &cancellableSet)
    }
    
    private func initState() {
        self.operation.dispatch(action: UserActions.getSelfInfo())
        self.operation.dispatch(action: ScheduleViewActions.resetPopDetailFlag())
    }
    
    @objc func modifyAction(sender: UIButton) {
        route.pushTo(route: .modifySchedule(conferenceInfo: store.conferenceInfo))
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    // MARK: - private property.
    @Injected(\.navigation) private var route
    @Injected(\.scheduleStore) private var store
    @Injected(\.conferenceStore) private var operation
}

extension ScheduleDetailsViewController {
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
                if self.presentedViewController == nil {
                    self.view.makeToast(toast.message, duration: toast.duration, position: position)
                }
            }
            .store(in: &cancellableSet)
    }
    
    private func subscribeScheduleSubject() {
        operation.scheduleActionSubject
            .receive(on: RunLoop.main)
            .filter { $0.id == ScheduleResponseActions.onCancelSuccess.id }
            .sink { [weak self] action in
                guard let self = self else { return }
                self.route.pop()
            }
            .store(in: &cancellableSet)
    }
}

private extension String {
    static let roomDetailsText = localized("Room Details")
    static let reviseText = localized("Revise")
}
