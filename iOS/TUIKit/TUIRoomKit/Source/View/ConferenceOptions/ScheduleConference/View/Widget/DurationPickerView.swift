//
//  DurationPickerView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/14.
//

import Foundation
import Factory

class DurationPickerView: UIView {
    var dismissAction: (() -> Void)?
    var timeDuration: TimeInterval = 1800
    
    let topView: UIView = {
       let view = UIView()
        return view
    }()
    
    let topLabel: UILabel = {
        let label = UILabel()
        label.text = .roomDurationText
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
    
    let timePickerView: UIDatePicker = {
        let pickerView = UIDatePicker()
        pickerView.datePickerMode = .countDownTimer
        if #available(iOS 13.4, *) {
            pickerView.preferredDatePickerStyle = .wheels
        }
        pickerView.minuteInterval = 5
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
            make.height.equalTo(270.scale375Height())
            make.bottom.equalToSuperview().offset(-5.scale375Height())
        }
    }
    
    func bindInteraction() {
        self.layer.cornerRadius = 12
        timePickerView.countDownDuration = timeDuration
        timePickerView.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        sureButton.addTarget(self, action: #selector(sureAction(sender:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelAction(sender:)), for: .touchUpInside)
    }
    
    @objc func sureAction(sender: UIButton) {
        var conferenceInfo = store.conferenceInfo
        conferenceInfo.durationTime = UInt(timePickerView.countDownDuration)
        store.update(conference: conferenceInfo)
        dismissAction?()
    }
    
    @objc func cancelAction(sender: UIButton) {
        dismissAction?()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedTimeInterval = sender.countDownDuration
        let minTimeInterval = TimeInterval(900)
        if selectedTimeInterval < minTimeInterval {
            sender.countDownDuration = minTimeInterval
        }
    }
    
    deinit{
        debugPrint("deinit:\(self)")
    }
    
    @Injected(\.modifyScheduleStore) var store: ScheduleConferenceStore
}

private extension String {
    static var roomDurationText: String {
        localized("Room duration")
    }
}
