//
//  ConferenceRouteDefine.swift
//  TUIRoomKit
//
//  Created by aby on 2024/6/21.
//

import Foundation

enum ConferenceRoute {
    case none
    case schedule(memberSelectFactory: MemberSelectionFactory?)
    case main
    case selectMember(memberSelectParams: MemberSelectParams?)
    case selectedMember(showDeleteButton: Bool, selectedMembers: [UserInfo])
    case timeZone
    case scheduleDetails(conferenceInfo: ConferenceInfo)
    case modifySchedule(conferenceInfo: ConferenceInfo)
    case popup(view: UIView)
    case alert(state: AlertState)
    
    func hideNavigationBar() -> Bool {
        switch self {
        case .main, .selectMember, .timeZone:
                return true
            default:
                return false
        }
    }
    
    init(viewController: UIViewController) {
        switch viewController {
            case is ConferenceMainViewController:
                self = .main
            case is ScheduleConferenceViewController:
                guard let vc = viewController as? ScheduleConferenceViewController else {
                    self = .none
                    break
                }
                self = .schedule(memberSelectFactory: vc.memberSelectionFactory)
            case _ as SelectMemberControllerProtocol:
                self = .selectMember(memberSelectParams: nil)
            case is SelectedMembersViewController:
                let vc = viewController as? SelectedMembersViewController
                let showDeleteButton =  vc?.showDeleteButton ?? true
                let selectedMember = vc?.selectedMember ?? []
                self = .selectedMember(showDeleteButton: showDeleteButton, selectedMembers: selectedMember)
            case is TimeZoneViewController:
                self = .timeZone
            case is ScheduleDetailsViewController:
                let vc = viewController as? ScheduleDetailsViewController
                self = .scheduleDetails(conferenceInfo: vc?.conferenceInfo ?? ConferenceInfo())
            case is ModifyScheduleViewController:
                let vc = viewController as? ModifyScheduleViewController
                self = .modifySchedule(conferenceInfo: vc?.conferenceInfo ?? ConferenceInfo())
            case is PopupViewController:
                let vc = viewController as? PopupViewController
                self = .popup(view: vc?.contentView ?? viewController.view)
            case is UIAlertController:
                let vc = viewController as? UIAlertController
                let alertState = AlertState(title: vc?.title, message: vc?.message, sureAction: vc?.actions.first, declineAction: vc?.actions.last)
                self = .alert(state: alertState)
            default:
                self = .none
        }
    }
}

extension ConferenceRoute {
    var viewController: UIViewController {
        switch self {
            case .main:
                return ConferenceMainViewController()
            case .schedule(memberSelectFactory: let factory):
                return ScheduleConferenceViewController(memberSelectFactory: factory)
            case .selectMember(memberSelectParams: let memberSelectParams):
                guard let params = memberSelectParams else {
                    return UIViewController()
                }
                let selectedUsers = params.selectedUsers
                let delegate = params.delegate
                let vc = params.factory(selectedUsers)
                vc.delegate = delegate
                return vc
            case .selectedMember(showDeleteButton: let isShow, let selectedMembers):
                return SelectedMembersViewController(showDeleteButton: isShow, selectedMembers: selectedMembers)
            case .timeZone:
                return TimeZoneViewController()
            case .scheduleDetails(conferenceInfo: let info):
                return ScheduleDetailsViewController(conferenceInfo: info)
            case .modifySchedule(conferenceInfo: let info):
                return ModifyScheduleViewController(conferenceInfo: info)
            case .popup(view: let view):
                return PopupViewController(contentView: view)
            case .alert(state: let alertState):
                let alertVC = UIAlertController(title: alertState.title,
                                              message: alertState.message,
                                       preferredStyle: .alert)
                if let sureAction = alertState.sureAction {
                    alertVC.addAction(sureAction)
                }
                if let declineAction = alertState.declineAction {
                    alertVC.addAction(declineAction)
                }
                return alertVC
            default:
                return UIViewController()
        }
    }
}

extension ConferenceRoute: Equatable {
    static func ==(lhs: ConferenceRoute, rhs: ConferenceRoute) -> Bool {
        switch (lhs, rhs) {
            case (.none, .none),
                (.schedule, .schedule),
                (.main, .main),
                (.selectMember, .selectMember),
                (.selectedMember, .selectedMember),
                (.timeZone, .timeZone),
                (.scheduleDetails, .scheduleDetails),
                (.modifySchedule, .modifySchedule):
                return true
            case let (.popup(l), .popup(r)):
                return l == r
            case let (.alert(l), .alert(r)):
                return l == r
            case (.none, _),
                (.schedule, _),
                (.main, _),
                (.selectMember, _),
                (.selectedMember, _),
                (.timeZone, _),
                (.scheduleDetails, _),
                (.modifySchedule, _),
                (.alert, _),
                (.popup, _):
                return false
        }
    }
}

 struct AlertState: Equatable {
    var title: String?
    var message: String?
    var sureAction: UIAlertAction?
    var declineAction: UIAlertAction?
}

#if DEBUG
class PrintRouteInterceptor: Interceptor {
    typealias State = ConferenceRouteState
    
    func actionDispatched(action: any Action, oldState: State, newState: State) {
        let name = String(describing: type(of: self))
        let actionName = String(describing: type(of: action))
        print("route action is: \(newState.currentRouteAction)")
        switch newState.currentRouteAction {
            case .presented(route: let route):
                print("route is: \(oldState.currentRoute) to \(route)")
            default:
                break
        }
    }
}
#endif
