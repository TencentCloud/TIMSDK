//
//  FloatingWindowButton.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//

import Foundation

class FloatingWindowButton: UIView {
    
    let viewModel = FloatingWindowButtonViewModel()
    let mediaTypeObserver = Observer()
    let floatButton: UIButton = {
    let floatButton = UIButton(type: .system)
    return floatButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateImage()
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.mediaType.removeObserver(mediaTypeObserver)
    }
    
    //MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }

    func constructViewHierarchy() {
        addSubview(floatButton)
    }

    func activateConstraints() {
        floatButton.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
    }

    func bindInteraction() {
        floatButton.addTarget(self, action: #selector(clickFloatButton(sender: )), for: .touchUpInside)
    }

    // MARK:  Action Event
    @objc func clickFloatButton(sender: UIButton) {
        WindowManager.instance.showFloatWindow()
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateImage()
        }
    }

    func updateImage() {
        if viewModel.mediaType.value == .audio {
            if let image = TUICallKitCommon.getBundleImage(name: "ic_min_window_dark") {
                floatButton.setBackgroundImage(image, for: .normal)
            }
        } else if viewModel.mediaType.value == .video {
            if let image = TUICallKitCommon.getBundleImage(name: "ic_min_window_white") {
                floatButton.setBackgroundImage(image, for: .normal)
            }
        }
    }
}
