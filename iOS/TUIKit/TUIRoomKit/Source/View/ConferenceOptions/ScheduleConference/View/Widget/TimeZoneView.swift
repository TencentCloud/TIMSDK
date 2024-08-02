//
//  TimeZoneView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/27.
//

import Foundation
import Factory

class TimeZoneView: UIView {
    lazy var menus = TimeZone.knownTimeZoneIdentifiers.sorted { id1, id2 in
        let timeZone1 = TimeZone(identifier: id1)?.secondsFromGMT() ?? 0
        let timeZone2 = TimeZone(identifier: id2)?.secondsFromGMT() ?? 0
        return timeZone1 < timeZone2
    }
    
    var selectedTimeZone: String? {
        didSet {
            self.updateSelected()
        }
    }
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "room_back_black", in:  tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 10.scale375Height(), left: 20.scale375(), bottom: 10.scale375Height(), right: 20.scale375())
        return button
    }()
    
    let topLabel: UILabel = {
        let label = UILabel()
        label.text = .selectTimeZoneText
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(0x2B2E38)
        label.textAlignment = .center
        return label
    }()
    
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(0x17181F)
        tableView.register(TimeZoneCell.self, forCellReuseIdentifier: TimeZoneCell.identifier)
        tableView.backgroundColor = UIColor(0xFFFFFF)
        return tableView
    }()
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = UIColor(0xFFFFFF)
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
        selectedTimeZone = self.store.conferenceInfo.timeZone.identifier
    }
    
    func constructViewHierarchy() {
        addSubview(backButton)
        addSubview(topLabel)
        addSubview(tableView)
    }
    
    func activateConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
        }
        topLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(10.scale375Height())
            make.leading.equalToSuperview().offset(20.scale375())
            make.trailing.equalToSuperview().offset(-20.scale375())
            make.bottom.equalToSuperview().offset(-20.scale375Height())
        }
    }
    
    func bindInteraction() {
        backButton.addTarget(self, action: #selector(backAction(sender: )), for: .touchUpInside)
    }
    
    @objc func backAction(sender: UIButton) {
        route.pop()
    }
    
    private func updateSelected() {
        if let selectedTimeZone = selectedTimeZone,
           let index = menus.firstIndex(of: selectedTimeZone) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
        }
    }
    
    deinit{
        debugPrint("deinit:\(self)")
    }
    
    @Injected(\.navigation) private var route
    @Injected(\.modifyScheduleStore) var store: ScheduleConferenceStore
}

extension TimeZoneView: UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
}

extension TimeZoneView: UITableViewDelegate {
    internal func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeZoneCell.identifier, for: indexPath)
        if let timeZoneCell = cell as? TimeZoneCell, let timeZone = TimeZone(identifier: menus[indexPath.row]) {
            timeZoneCell.title = timeZone.getTimeZoneName()
            
            if selectedTimeZone == menus[indexPath.row] {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let timeZone = TimeZone(identifier: menus[indexPath.row]) {
            var conferenceInfo = store.conferenceInfo
            conferenceInfo.timeZone = timeZone
            conferenceInfo.scheduleStartTime = UInt(conferenceInfo.scheduleStartTime)
            store.update(conference: conferenceInfo)
        }
        route.pop()
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.scale375Height()
    }
}

private extension String {
    static var roomDurationText: String {
        localized("Room duration")
    }
    static let selectTimeZoneText: String = localized("Select time zone")
}

class TimeZoneCell: UITableViewCell {
    static let identifier = "TimeZoneCell"
    var title: String = "" {
        didSet {
            label.text = title
        }
    }
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(0x22262E)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: TimeZoneCell.identifier)
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = UIColor(0xFFFFFF)
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(label)
    }
    
    func activateConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
