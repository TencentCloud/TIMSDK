//
//  Toast.swift
//  Pods
//
//  Created by vincepzhang on 2025/3/6.
//

import TUICore
import UIKit

class Toast {
    static let shared = Toast()
    private init() {}
    
    private struct ToastItem {
        let message: String
        let duration: TimeInterval
    }
    
    private let maxWidth: CGFloat = 280
    private let minHeight: CGFloat = 40
    private let verticalOffset: CGFloat = 40
    private let queue = DispatchQueue(label: "toast.queue")
    private var items: [ToastItem] = []
    private var isShowing = false

    static func showToast(_ message: String?, duration: TimeInterval = 2.0) {
        Toast.shared.showToast(message: message ?? "")
    }

    func showToast(message: String, duration: TimeInterval = 2.0) {
        queue.async { [weak self] in
            self?.enqueue(ToastItem(message: message, duration: duration))
        }
    }
    
    private func enqueue(_ item: ToastItem) {
        queue.async { [weak self] in
            self?.items.append(item)
            self?.showNextIfNeeded()
        }
    }
    
    private func showNextIfNeeded() {
        guard !isShowing, let item = items.first else { return }
        
        items.removeFirst()
        isShowing = true
        
        DispatchQueue.main.async {
            self.createAndShowToast(item: item) {
                self.queue.async {
                    self.isShowing = false
                    self.showNextIfNeeded()
                }
            }
        }
    }
    
    private func createAndShowToast(item: ToastItem, completion: @escaping () -> Void) {
        guard let window = getKeyWindow() else {
            completion()
            return
        }
        
        let toastView = createToastView(message: item.message)
        window.addSubview(toastView)
        setupConstraints(toastView, in: window)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            toastView.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + item.duration) {
                self.hideToast(toastView: toastView, completion: completion)
            }
        }
    }
    
    private func createToastView(message: String) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.alpha = 0
        
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12)
        ])
        
        return view
    }
    
    private func setupConstraints(_ toastView: UIView, in window: UIWindow) {
        toastView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            toastView.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor,
                                             constant: -verticalOffset),
            toastView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
            toastView.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            toastView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
        ])
    }
    
    private func hideToast(toastView: UIView, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: {
            toastView.alpha = 0
        }, completion: { _ in
            toastView.removeFromSuperview()
            completion()
        })
    }
    
    private func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first(where: { $0.isKeyWindow })
    }
}
