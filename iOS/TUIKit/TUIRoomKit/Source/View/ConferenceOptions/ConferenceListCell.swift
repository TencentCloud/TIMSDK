//
//  ConferenceOptionCell.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/6.
//

import Foundation
import UIKit
import Factory

class ConferenceListCell: UITableViewCell {
    @Injected(\.conferenceStore) private var store
    static let reusedIdentifier = "ConferenceListCell"
    private var conferenceInfo: ConferenceInfo?
    
    let roomNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Medium", size: 16)
        label.textColor = UIColor.tui_color(withHex: "4F586B")
        return label
    }()
    
    let interactiveIcon: UIImageView = {
        let image = UIImage(named: "room_right_black_arrow", in: tuiRoomKitBundle(), compatibleWith: nil)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel(frame: .zero)
        return label
    }()
    
    let enterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(.enterText, for: .normal)
        button.setTitleColor(UIColor.tui_color(withHex: "#4E5461"), for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 14)
        button.backgroundColor = UIColor.tui_color(withHex: "F0F3FA")
        button.sizeToFit()
        button.layer.cornerRadius = button.frame.height / 2
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(roomNameLabel)
        contentView.addSubview(interactiveIcon)
        contentView.addSubview(detailLabel)
        contentView.addSubview(enterButton)
    }
    
    private func activateConstraints() {
        enterButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.width.greaterThanOrEqualTo(68)
            make.top.equalToSuperview().offset(8)
        }
        interactiveIcon.snp.makeConstraints { make in
            make.trailing.lessThanOrEqualTo(enterButton.snp.leading).offset(-5)
            make.width.height.equalTo(16)
            make.centerY.equalTo(roomNameLabel)
        }
        roomNameLabel.snp.makeConstraints { make in
            make.trailing.equalTo(interactiveIcon.snp.leading)
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        detailLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(roomNameLabel.snp.bottom).offset(6)
            make.trailing.lessThanOrEqualTo(enterButton.snp.leading).offset(-20)
        }
    }
    
    private func bindInteraction() {
        enterButton.addTarget(self, action: #selector(enterAction(sender:)), for: .touchUpInside)
    }
    
    @objc func enterAction(sender: UIButton) {
        guard let info = conferenceInfo else {
            return
        }
        if !info.basicInfo.roomId.isEmpty {
            store.dispatch(action: RoomActions.joinConference(payload: info.basicInfo.roomId))
        }
    }
    
    func updateCell(with info: ConferenceInfo) {
        conferenceInfo = info
        roomNameLabel.text = info.basicInfo.name
        detailLabel.attributedText = getAttributedText(from: info)
    }
    
    private func getAttributedText(from info: ConferenceInfo) -> NSMutableAttributedString {
        let normalAttributes: [NSAttributedString.Key: Any] =
            [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.tui_color(withHex: "4F586B")]
        let duration = getDuration(from: info)
        var result = NSMutableAttributedString(string: duration, attributes: normalAttributes)
        
        addDelimiter(to: &result)
        let roomId = addSpaces(to: info.basicInfo.roomId)
        let roomIdAtrributeString = NSMutableAttributedString(string: roomId, attributes: normalAttributes)
        result.append(roomIdAtrributeString)
        
        guard info.status == .running else { return result }
        
        addDelimiter(to: &result)
        let status = getStatusString(from: info)
        let statusAttributes: [NSAttributedString.Key: Any] =
        [.font:UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.tui_color(withHex: "1C66E5")]
        let statusAtrributeString = NSMutableAttributedString(string: status, attributes: statusAttributes)
        result.append(statusAtrributeString)
        
        return result
    }
    
    private func addDelimiter(to attributeString: inout NSMutableAttributedString) {
        let delimiterAtrributeString = NSMutableAttributedString(string:"  |  ",
                                                                 attributes: [
                                                                    .font: UIFont.systemFont(ofSize: 11),
                                                                    .foregroundColor: UIColor.tui_color(withHex: "969EB4"),
                                                                    .baselineOffset: 2
                                                                 ])
        attributeString.append(delimiterAtrributeString)
    }
   
    private func addSpaces(to string: String) -> String {
        var result = ""
        for (index, char) in string.enumerated() {
            if index > 0 && index % 3 == 0 {
                result += " "
            }
            result += String(char)
        }
        return result
    }
    
    private func getDuration(from info: ConferenceInfo) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "HH:mm"
        
        let startDate = Date(timeIntervalSince1970: TimeInterval(info.scheduleStartTime))
        let endDate = Date(timeIntervalSince1970: TimeInterval(info.scheduleEndTime))
        
        let startString = dateFormatter.string(from: startDate)
        let endString = dateFormatter.string(from: endDate)
        return startString + " - " + endString
    }
    
    private func getStatusString(from info: ConferenceInfo) -> String {
        if info.status == .running {
            return .inProgressText
        }
        return ""
    }
    
}

private extension String {
    static var enterText: String {
        localized("Enter")
    }
    static var inProgressText: String {
        localized("Ongoing")
    }
}
