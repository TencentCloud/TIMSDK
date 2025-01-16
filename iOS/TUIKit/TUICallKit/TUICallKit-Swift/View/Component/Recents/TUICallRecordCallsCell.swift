//
//  TUICallRecordCallsCell.swift
//
//
//  Created by vincepzhang on 2023/8/28.
//

import Foundation
import UIKit
import TUICallEngine

class TUICallRecordCallsCell: UITableViewCell {
    
    private let faceURLObserver = Observer()
    private let titleObserver = Observer()
    
    typealias TUICallRecordCallsCellMoreBtnClickedHandler = () -> Void
    var moreBtnClickedHandler: TUICallRecordCallsCellMoreBtnClickedHandler = {}
    
    private var isViewReady = false
    private var viewModel: TUICallRecordCallsCellViewModel = TUICallRecordCallsCellViewModel(TUICallRecords())
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "PingFangHK-Semibold", size: 14)
        label.textAlignment = TUICoreDefineConvert.getIsRTL() ? .right : .left
        return label
    }()
    
    private lazy var mediaTypeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.textColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_recents_cell_subtitle_color",
                                                                         defaultHex: "#888888")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = TUICoreDefineConvert.getIsRTL() ? .right : .left
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_recents_cell_time_color",
                                                                         defaultHex: "#BBBBBB")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = TUICoreDefineConvert.getIsRTL() ? .left : .right
        return label
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(TUICallKitCommon.getBundleImage(name: "ic_recents_more"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_recents_cell_bg_color",
                                                                                     defaultHex: "#FFFFFF")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterObserve()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(mediaTypeImageView)
        contentView.addSubview(resultLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(moreButton)
    }
    
    private func activateConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView).offset(16)
            make.width.height.equalTo(40)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(14)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(timeLabel.snp.leading).offset(-20)
        }
        mediaTypeImageView.snp.makeConstraints { make in
            make.bottom.equalTo(contentView).offset(-14)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(8)
            make.width.equalTo(19)
            make.height.equalTo(12)
        }
        resultLabel.snp.makeConstraints { make in
            make.centerY.equalTo(mediaTypeImageView)
            make.leading.equalTo(mediaTypeImageView.snp.trailing).offset(4)
            make.width.equalTo(100)
        }
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(moreButton.snp.leading).offset(-4)
            make.width.equalTo(100)
        }
        moreButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(-8)
            make.width.height.equalTo(24)
        }
    }
    
    private func bindInteraction() {
        moreButton.addTarget(self, action: #selector(moreButtonClick(_:)), for: .touchUpInside)
    }
    
    func configViewModel(_ viewModel: TUICallRecordCallsCellViewModel) {
        self.viewModel = viewModel
        registerObserve()
        
        titleLabel.text = viewModel.titleLabelStr.value
        avatarImageView.sd_setImage(with: URL(string: viewModel.faceURL.value), placeholderImage: viewModel.avatarImage)
        resultLabel.text = viewModel.resultLabelStr
        timeLabel.text = viewModel.timeLabelStr
        mediaTypeImageView.image = TUICallKitCommon.getBundleImage(name: viewModel.mediaTypeImageStr)
        
        if viewModel.callRecord.result == .missed {
            titleLabel.textColor = UIColor.red
        } else {
            titleLabel.textColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_recents_cell_title_color",
                                                                                  defaultHex: "#000000")
        }
    }
    
    func registerObserve() {
        viewModel.faceURL.addObserver(faceURLObserver) { [weak self] _, _ in
            guard let self = self else { return }
            self.avatarImageView.sd_setImage(with: URL(string: self.viewModel.faceURL.value),
                                             placeholderImage: self.viewModel.avatarImage)
        }
        
        viewModel.titleLabelStr.addObserver(titleObserver) { [weak self] _, _ in
            guard let self = self else { return }
            self.titleLabel.text = self.viewModel.titleLabelStr.value
        }
    }
    
    func unregisterObserve() {
        viewModel.faceURL.removeObserver(faceURLObserver)
        viewModel.titleLabelStr.removeObserver(titleObserver)
    }
    
    @objc private func moreButtonClick(_ button: UIButton) {
        moreBtnClickedHandler()
    }
}
