//
//  TimerView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//

import Foundation

class TimerView: UIView {
    let viewModel = TimerViewModel()
    
    let timeCountObserver = Observer()
    let mediaTypeObserver = Observer()

    lazy var timerLabel: UILabel = {
        let timerLabel = UILabel(frame: CGRectZero)
        timerLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        timerLabel.backgroundColor = UIColor.clear
        timerLabel.textAlignment = .center
        if viewModel.mediaType.value == .audio {
            timerLabel.textColor = UIColor.t_colorWithHexString(color: "#242424")
        } else if viewModel.mediaType.value == .video {
            timerLabel.textColor = UIColor.t_colorWithHexString(color: "#F2F2F2")
        }
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
        viewModel.timeCount.removeObserver(mediaTypeObserver)
    }
    
    //MARK: UI Specification Processing
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
        mediaTypeChange()
    }
    
    func callTimeChange() {
        viewModel.timeCount.addObserver(timeCountObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            DispatchCallKitMainAsyncSafe {
                self.timerLabel.text = self.viewModel.getCallTimeString()
            }
        })
    }
    
    func mediaTypeChange() {
        viewModel.mediaType.addObserver(mediaTypeObserver) {  [weak self] newValue, _  in
            guard let self = self else { return }
            DispatchCallKitMainAsyncSafe {
                if newValue == .audio {
                    self.timerLabel.textColor = UIColor.t_colorWithHexString(color: "#000000")
                } else if newValue == .video {
                    self.timerLabel.textColor = UIColor.t_colorWithHexString(color: "#F2F2F2")
                }
            }
        }
    }
}
