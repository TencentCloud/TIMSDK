//
//  ChatExtensionRoomSettingsView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/6/26.
//

import Foundation

class ChatExtensionRoomSettingsView: UIView {
    let viewModel : ChatExtensionRoomSettingsViewModel
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 0
        return view
    }()
    
    init(viewModel: ChatExtensionRoomSettingsViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - view layout
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        backgroundColor = .white
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    private func constructViewHierarchy() {
        addSubview(stackView)
        for item in viewModel.roomSettingsViewItems {
            let view = ChatExtensionRoomSettingsItemView(itemData: item)
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.height.equalTo(60.scale375())
                make.width.equalToSuperview()
            }
        }
    }
    
    private func activateConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
