//
//  SetUpItemView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class SetUpItemView: UIView {
    let viewModel: SetUpViewModel
    private var viewArray: [ListCellItemView] = []
    let viewType: SetUpViewModel.SetUpItemType
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 0
        view.backgroundColor = UIColor(0x1B1E26)
        return view
    }()
    
    init(viewModel: SetUpViewModel, viewType: SetUpViewModel.SetUpItemType) {
        self.viewModel = viewModel
        self.viewType = viewType
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(stackView)
        
        var viewItems: [ListCellItemData] = []
        switch viewType {
        case .videoType:
            viewItems = viewModel.videoItems
            stackView.isHidden = false
        case .audioType:
            viewItems = viewModel.audioItems
            stackView.isHidden = false
        }
        
        for item in viewItems {
            let view = ListCellItemView(itemData: item)
            viewArray.append(view)
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.height.equalTo(40.scale375())
                make.width.equalToSuperview()
            }
        }
    }
    
    func activateConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.width.equalToSuperview()
        }
    }
    
    func updateStackView(item: ListCellItemData, index: Int) {
        guard viewArray.count > index else { return }
        viewArray[index].removeFromSuperview()
        let view = ListCellItemView(itemData: item)
        viewArray[index] = view
        stackView.insertArrangedSubview(view, at: index)
        view.snp.makeConstraints { make in
            make.height.equalTo(40.scale375())
            make.width.equalToSuperview()
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

