//
//  TimePickerView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/14.
//

import Foundation
import Factory

class TimePickerView: UIView {
    var dismissAction: (() -> Void)?
    var pickerDate: Date?
    
    let topView: UIView = {
       let view = UIView()
        return view
    }()
    
    let topLabel: UILabel = {
        let label = UILabel()
        label.text = .startingTimeText
        label.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        label.textColor = UIColor(0x22262E)
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "schedule_wrong", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        return button
    }()
    
    let sureButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "schedule_right", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        return button
    }()
    
    lazy var timePickerView: UIDatePicker = {
        let pickerView = UIDatePicker()
        pickerView.datePickerMode = .dateAndTime
        if #available(iOS 14.0, *) {
            pickerView.preferredDatePickerStyle = .wheels
        }
        pickerView.minuteInterval = 5
        pickerView.timeZone = store.conferenceInfo.timeZone
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        var minimumTime = Date().timeIntervalSince1970
        let remainder = minimumTime.remainder(dividingBy: 300)
        if remainder > 60 || remainder < 0 {
            minimumTime = Date().addingTimeInterval(150).timeIntervalSince1970
            minimumTime =  minimumTime - minimumTime.remainder(dividingBy: 300)
        }
        if let pickerDate = pickerDate {
            pickerView.date = pickerDate
        } else {
            pickerView.date = Date(timeIntervalSince1970: minimumTime)
        }
        pickerView.minimumDate = Date(timeIntervalSince1970: minimumTime)
        return pickerView
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
    }
    
    func constructViewHierarchy() {
        addSubview(topView)
        topView.addSubview(topLabel)
        topView.addSubview(cancelButton)
        topView.addSubview(sureButton)
        addSubview(timePickerView)
    }
    
    func activateConstraints() {
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(timePickerView.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(54.scale375Height())
        }
        topLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        cancelButton.snp.makeConstraints { make in
            make.width.height.equalTo(24.scale375())
            make.leading.equalToSuperview().offset(20.scale375())
            make.centerY.equalToSuperview()
        }
        sureButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20.scale375())
            make.width.height.equalTo(cancelButton)
            make.centerY.equalTo(cancelButton)
        }
        timePickerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(300.scale375Height())
            make.bottom.equalToSuperview().offset(-5.scale375Height())
        }
    }
    
    func bindInteraction() {
        self.layer.cornerRadius = 12
        sureButton.addTarget(self, action: #selector(sureAction(sender:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelAction(sender:)), for: .touchUpInside)
    }
    
    @objc func sureAction(sender: UIButton) {
        var conferenceInfo = store.conferenceInfo
        conferenceInfo.scheduleStartTime = UInt(timePickerView.date.timeIntervalSince1970)
        store.update(conference: conferenceInfo)
        dismissAction?()
    }
    
    @objc func cancelAction(sender: UIButton) {
        dismissAction?()
    }
    
    deinit{
        debugPrint("deinit:\(self)")
    }
    
    @Injected(\.modifyScheduleStore) var store: ScheduleConferenceStore
}

private extension String {
    static var startingTimeText: String {
        localized("Starting time")
    }
}
