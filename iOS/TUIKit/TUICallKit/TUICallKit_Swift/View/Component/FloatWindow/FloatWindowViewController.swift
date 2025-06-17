//
//  FloatWindowViewController.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/25.
//

class FloatWindowViewController: UIViewController{
    weak var delegate: GestureViewDelegate?
    
    private let floatWindowView: UIView = {
        if CallManager.shared.viewState.callingViewType.value == .one2one {
            return FloatWindowSingleView(frame: .zero)
        }
        return FloatWindowGroupView(frame: .zero)
    }()
    
    private let gestureView = UIView()

    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        view.addSubview(floatWindowView)
        view.addSubview(gestureView)

        floatWindowView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = floatWindowView.superview {
            NSLayoutConstraint.activate([
                floatWindowView.topAnchor.constraint(equalTo: superview.topAnchor),
                floatWindowView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                floatWindowView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                floatWindowView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }

        gestureView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = gestureView.superview {
            NSLayoutConstraint.activate([
                gestureView.topAnchor.constraint(equalTo: superview.topAnchor),
                gestureView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                gestureView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                gestureView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        
        gestureView.backgroundColor = UIColor.clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(tapGesture: )))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(panGesture: )))
        gestureView.addGestureRecognizer(tap)
        pan.require(toFail: tap)
        gestureView.addGestureRecognizer(pan)
    }
    
    // MARK: Gesture Action
    @objc func tapGesture(tapGesture: UITapGestureRecognizer) {
        if self.delegate != nil && ((self.delegate?.responds(to: Selector(("tapGestureAction")))) != nil) {
            self.delegate?.tapGestureAction?(tapGesture: tapGesture)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: EVENT_TAP_FLOATWINDOW), object: nil)
    }
    
    @objc func panGesture(panGesture: UIPanGestureRecognizer) {
        if self.delegate != nil && ((self.delegate?.responds(to: Selector(("panGestureAction")))) != nil) {
            self.delegate?.panGestureAction?(panGesture: panGesture)
        }
        
    }

}
