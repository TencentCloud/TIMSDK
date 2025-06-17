//
//  CallVideoLayout.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/19.
//

public class CallVideoLayout: UIView {
    private var isViewReady = false
    private var aiSubtitle = AISubtitle(frame: .zero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        isViewReady = true

        if CallManager.shared.viewState.callingViewType.value == .one2one {
            addSingleCallingView()
        } else if CallManager.shared.viewState.callingViewType.value == .multi {
            addMultiCallingView()
        }
    }
    
    private func addSingleCallingView() {
        cleanView()
        let singleCallingView = SingleCallVideoLayout(frame: .zero)
        addSubview(singleCallingView)
        addSubview(aiSubtitle)
        singleCallingView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = singleCallingView.superview {
            NSLayoutConstraint.activate([
                singleCallingView.topAnchor.constraint(equalTo: superview.topAnchor),
                singleCallingView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                singleCallingView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                singleCallingView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        
        aiSubtitle.translatesAutoresizingMaskIntoConstraints = false
        if let superview = aiSubtitle.superview {
            NSLayoutConstraint.activate([
                aiSubtitle.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                aiSubtitle.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: 120.scale375Height()),
                aiSubtitle.heightAnchor.constraint(equalToConstant: 24.scale375Width()),
                aiSubtitle.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.8)
            ])
        }
    }
    
    private func addMultiCallingView() {
        cleanView()
        let multiCallingView = MultiCallVideoLayout(frame: .zero)
        addSubview(multiCallingView)
        addSubview(aiSubtitle)
        multiCallingView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = multiCallingView.superview {
            NSLayoutConstraint.activate([
                multiCallingView.topAnchor.constraint(equalTo: superview.topAnchor),
                multiCallingView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                multiCallingView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                multiCallingView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        
        aiSubtitle.translatesAutoresizingMaskIntoConstraints = false
        if let superview = aiSubtitle.superview {
            NSLayoutConstraint.activate([
                aiSubtitle.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                aiSubtitle.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: 120.scale375Height()),
                aiSubtitle.heightAnchor.constraint(equalToConstant: 24.scale375Width()),
                aiSubtitle.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.8)
            ])
        }
    }
    
    private func cleanView() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
}
