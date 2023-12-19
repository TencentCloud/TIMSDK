//
//  CallStatusView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//

import Foundation

class CallStatusTipView: UIView {
    
    let viewModel = UserInfoViewModel()
    let selfCallStatusObserver = Observer()
    
    let callStatusLabel: UILabel = {
        let callStatusLabel = UILabel(frame: CGRect.zero)
        callStatusLabel.textColor = UIColor.t_colorWithHexString(color: "#FFFFFF")
        callStatusLabel.font = UIFont.systemFont(ofSize: 15.0)
        callStatusLabel.backgroundColor = UIColor.clear
        callStatusLabel.textAlignment = .center
        return callStatusLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateStatusText()
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.selfCallStatus.removeObserver(selfCallStatusObserver)
    }
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(callStatusLabel)
    }
    
    func activateConstraints() {
        self.callStatusLabel.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callStatusChange()
    }
    
    func callStatusChange() {
        viewModel.selfCallStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateStatusText()
        })
    }
    
    func updateStatusText() {
        switch viewModel.selfCallStatus.value {
        case .waiting:
            self.callStatusLabel.text = viewModel.getCurrentWaitingText()
            break
        case .accept:
            self.callStatusLabel.text = TUICallKitLocalize(key: "TUICallKit.accept") ?? ""
            break
        case .none:
            break
        default:
            break
        }
    }
}
