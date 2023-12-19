//
//  TimerView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//

import Foundation
import TUICallEngine

class TimerView: UIView {
    let viewModel = TimerViewModel()
    
    let timeCountObserver = Observer()
    
    lazy var timerLabel: UILabel = {
        let timerLabel = UILabel(frame: CGRect.zero)
        timerLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        timerLabel.backgroundColor = UIColor.clear
        timerLabel.textAlignment = .center
        timerLabel.textColor = UIColor.t_colorWithHexString(color: "#D5E0F2")
        timerLabel.text = viewModel.getCallTimeString()
        return timerLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.timeCount.removeObserver(timeCountObserver)
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
        addSubview(timerLabel)
    }
    
    func activateConstraints() {
        timerLabel.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callTimeChange()
    }
    
    func callTimeChange() {
        viewModel.timeCount.addObserver(timeCountObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            DispatchCallKitMainAsyncSafe {
                self.timerLabel.text = self.viewModel.getCallTimeString()
            }
        })
    }
}
