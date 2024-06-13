//
//  FloatChatDisplayView.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/5/9.
//  Copyright © 2024 Tencent. All rights reserved.
//

import UIKit
#if USE_OPENCOMBINE
import OpenCombine
import OpenCombineDispatch
#else
import Combine
#endif

class FloatChatDisplayView: UIView {
    @Injected private var store: FloatChatStoreProvider
    private lazy var messageListPublisher = self.store.select(FloatChatSelectors.getMessageList)
    private var messageList: [FloatChatMessage] = []
    var cancellableSet = Set<AnyCancellable>()
    
    private lazy var blurLayer: CALayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(1).cgColor
        ]
        layer.locations = [0, 0.2]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)

        return layer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurLayer.frame = self.bounds
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(FloatChatDefaultCell.self, forCellReuseIdentifier: FloatChatDefaultCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        return tableView
    }()
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }

    private func constructViewHierarchy() {
        addSubview(tableView)
        self.layer.mask = blurLayer
    }

    private func activateConstraints() {
        tableView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    func bindInteraction() {
        tableView.dataSource = self
        
        messageListPublisher
            .filter{ !$0.isEmpty }
            .receive(on: DispatchQueue.mainQueue)
            .sink { [weak self] floatMessages in
                guard let self = self else { return }
                let rowsBefore = self.messageList.count
                let rowsAfter = floatMessages.count
                let numberOfRowsInserted = rowsAfter - rowsBefore
                if numberOfRowsInserted > 0 {
                    var insertIndexs = [IndexPath]()
                    for i in 0..<numberOfRowsInserted {
                        insertIndexs.append(IndexPath(row: rowsBefore + i, section: 0))
                    }
                    self.messageList = floatMessages
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: insertIndexs, with: .automatic)
                    self.tableView.endUpdates()
                } else {
                    self.messageList = floatMessages
                    self.tableView.reloadData()
                }
                let lastIndexPath = IndexPath(row: rowsAfter - 1, section: 0)
                self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
            }
            .store(in: &cancellableSet)
    }
}

// MARK: - UITableViewDataSource

extension FloatChatDisplayView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FloatChatDefaultCell.identifier, for: indexPath)
        if let cell = cell as? FloatChatDefaultCell, indexPath.row < messageList.count {
            cell.floatMessage = messageList[indexPath.row]
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
}

extension FloatChatDisplayView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
         let view = super.hitTest(point, with: event)
         if view == tableView {
             return nil
         }
         return view
     }
}
