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
    
    let floatButton: FloatingWindowCustomButton = {
        let floatButton = FloatingWindowCustomButton(type: .system)
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
    
    // MARK: UI Specification Processing
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
            make.width.height.equalTo(24)
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
        if let image = TUICallKitCommon.getBundleImage(name: "icon_min_window") {
            floatButton.setBackgroundImage(image, for: .normal)
        }
    }
}

class FloatingWindowCustomButton: UIButton {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let expandedBounds = bounds.insetBy(dx: -6, dy: -6)
        return expandedBounds.contains(point) ? self : nil
    }
}
