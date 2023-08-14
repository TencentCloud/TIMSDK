//
//  TUIVideoSeat.swift
//  TUIVideoSeat
//
//  Created by WesleyLei on 2022/9/13.
//  Copyright © 2022 Tencent. All rights reserved.
//

import TUIRoomEngine
import UIKit
#if TXLiteAVSDK_TRTC
    import TXLiteAVSDK_TRTC
#elseif TXLiteAVSDK_Professional
    import TXLiteAVSDK_Professional
#endif

class TUIVideoSeatView: UIView {
    private let CellID_Normal = "TUIVideoSeatCell_Normal"
    private let viewModel: TUIVideoSeatViewModel
    private var isViewReady: Bool = false

    private var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPage = 0
        control.numberOfPages = 1
        control.hidesForSinglePage = true
        control.isUserInteractionEnabled = false
        return control
    }()

    init(frame: CGRect, roomEngine: TUIRoomEngine, roomId: String) {
        viewModel = TUIVideoSeatViewModel(roomEngine: roomEngine, roomId: roomId)
        super.init(frame: frame)
        viewModel.viewResponder = self
        isUserInteractionEnabled = true
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let item = moveMiniscreen.seatItem,!moveMiniscreen.isHidden {
            moveMiniscreen.updateSize(size: videoSeatLayout.getMiniscreenFrame(item: item).size)
        }
        let offsetYu = Int(attendeeCollectionView.contentOffset.x) % Int(attendeeCollectionView.mm_w)
        let offsetMuti = CGFloat(offsetYu) / attendeeCollectionView.mm_w
        let currentPage = (offsetMuti > 0.5 ? 1 : 0) + (Int(attendeeCollectionView.contentOffset.x) / Int(attendeeCollectionView.mm_w))
        if currentPage != pageControl.currentPage {
            attendeeCollectionView.setContentOffset(
                CGPoint(x: CGFloat(pageControl.currentPage) * attendeeCollectionView.frame.size.width,
                        y: attendeeCollectionView.contentOffset.y), animated: false)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var videoSeatLayout: TUIVideoSeatLayout = {
        let layout = TUIVideoSeatLayout(viewModel: viewModel)
        layout.delegate = self
        return layout
    }()

    lazy var attendeeCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), collectionViewLayout:
            videoSeatLayout)
        collection.register(TUIVideoSeatCell.self, forCellWithReuseIdentifier: CellID_Normal)
        collection.isPagingEnabled = true
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.isUserInteractionEnabled = true
        collection.contentMode = .scaleToFill
        collection.backgroundColor = .black
        if #available(iOS 11.0, *) {
            collection.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 10.0, *) {
            collection.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()

    lazy var moveMiniscreen: TUIVideoSeatDragCell = {
        let cell = TUIVideoSeatDragCell(frame: videoSeatLayout.getMiniscreenFrame(item: nil)) { [weak self] in
            guard let self = self else { return }
            self.viewModel.switchPosition()
        }
        cell.isHidden = true
        addSubview(cell)
        return cell
    }()

    func constructViewHierarchy() {
        backgroundColor = .clear
        addSubview(attendeeCollectionView)
        addSubview(pageControl)
    }

    func activateConstraints() {
        attendeeCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageControl.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
        }
    }

    func updatePageControl() {
        let offsetYu = Int(attendeeCollectionView.contentOffset.x) % Int(attendeeCollectionView.mm_w)
        let offsetMuti = CGFloat(offsetYu) / attendeeCollectionView.mm_w
        pageControl.currentPage = (offsetMuti > 0.5 ? 1 : 0) + (Int(attendeeCollectionView.contentOffset.x) / Int(attendeeCollectionView.mm_w))

        if let seatItem = moveMiniscreen.seatItem, seatItem.hasVideoStream {
            if pageControl.currentPage == 0 && !moveMiniscreen.isHidden {
                viewModel.startPlayVideo(item: seatItem, renderView: moveMiniscreen.renderView)
            } else {
                viewModel.startPlayVideo(item: seatItem, renderView: getSeatVideoRenderView(seatItem))
            }
        }
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: - TUIVideoSeatViewResponder

extension TUIVideoSeatView: TUIVideoSeatViewResponder {
    private func freshCollectionView(block: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock { [weak self] in
            guard let self = self else { return }
            self.viewModel.clearSubscribeVideoStream(items: self.getNoLoadHasVideoItems())
        }
        block()
        CATransaction.commit()
    }

    func reloadData() {
        freshCollectionView {
            self.attendeeCollectionView.reloadData()
        }
    }

    func insertItems(at indexPaths: [IndexPath]) {
        freshCollectionView {
            self.attendeeCollectionView.performBatchUpdates {
                self.attendeeCollectionView.insertItems(at: indexPaths)
            }
        }
    }

    func deleteItems(at indexPaths: [IndexPath]) {
        freshCollectionView {
            self.attendeeCollectionView.performBatchUpdates {
                self.attendeeCollectionView.deleteItems(at: indexPaths)
            }
        }
    }

    func reloadItems(at indexPaths: [IndexPath]) {
        freshCollectionView {
            self.attendeeCollectionView.performBatchUpdates {
                self.attendeeCollectionView.reloadItems(at: indexPaths)
            }
        }
    }

    func updateSeatItem(_ item: VideoSeatItem) {
        if let seatItem = moveMiniscreen.seatItem, seatItem.userId == item.userId {
            moveMiniscreen.updateUI(item: seatItem)
        }
        guard let cell = item.boundCell else { return }
        if item == cell.seatItem {
            cell.updateUI(item: item)
            if item.hasVideoStream {
                viewModel.startPlayVideo(item: item, renderView: cell.renderView)
            }
        }
    }

    func updateSeatVolume(_ item: VideoSeatItem) {
        guard let cell = item.boundCell else { return }
        if cell.seatItem == item {
            cell.updateUIVolume(item: item)
        }
    }

    func getSeatVideoRenderView(_ item: VideoSeatItem) -> UIView? {
        guard let cell = item.boundCell else { return nil }
        if cell.seatItem == item {
            return cell.renderView
        }
        return nil
    }

    func updateMiniscreen(_ item: VideoSeatItem?) {
        guard let item = item else {
            moveMiniscreen.isHidden = true
            return
        }
        if attendeeCollectionView.contentOffset.x > 0 {
            return
        }

        if let lastSeatItem = moveMiniscreen.seatItem, lastSeatItem.isHasVideoStream {
            if let renderView = getSeatVideoRenderView(lastSeatItem) {
                viewModel.startPlayVideo(item: lastSeatItem, renderView: renderView)
            } else {
                viewModel.unboundCell(item: lastSeatItem)
            }
        }

        moveMiniscreen.updateSize(size: videoSeatLayout.getMiniscreenFrame(item: item).size)
        moveMiniscreen.isHidden = false
        moveMiniscreen.updateUI(item: item)
        if item.isHasVideoStream {
            viewModel.startPlayVideo(item: item, renderView: moveMiniscreen.renderView)
        }
        moveMiniscreen.superview?.bringSubviewToFront(moveMiniscreen)
    }

    func updateMiniscreenVolume(_ item: VideoSeatItem) {
        moveMiniscreen.updateUIVolume(item: item)
    }

    func getMoveMiniscreen() -> TUIVideoSeatDragCell {
        return moveMiniscreen
    }

    private func getNoLoadHasVideoItems() -> [VideoSeatItem] {
        var hasVideoStreamItems = viewModel.listSeatItem.filter({ $0.isHasVideoStream })
        let visibleCells = Array(attendeeCollectionView.visibleCells)
        for cell in visibleCells {
            if let seatCell = cell as? TUIVideoSeatCell,
               let seatItem = seatCell.seatItem,
               let seatItemIndex = hasVideoStreamItems.firstIndex(where: { $0 == seatItem }) {
                hasVideoStreamItems.remove(at: seatItemIndex)
            }
        }
        if let seatItem = moveMiniscreen.seatItem,
           let seatItemIndex = hasVideoStreamItems.firstIndex(where: {
               if $0.userId == seatItem.userId && $0.type != .share {
                   return true
               } else {
                   return false
               }
           }) {
            hasVideoStreamItems.remove(at: seatItemIndex)
        }
        return hasVideoStreamItems
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TUIVideoSeatView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let seatCell = cell as? TUIVideoSeatCell, let seatItem = seatCell.seatItem {
            if seatItem.isHasVideoStream {
                viewModel.startPlayVideo(item: seatItem, renderView: seatCell.renderView)
            }
        }
    }
}

extension TUIVideoSeatView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPageIndex = Int(scrollView.contentOffset.x / scrollView.mm_w)
        viewModel.updateSpeakerPlayVideoState(currentPageIndex: currentPageIndex)
        if currentPageIndex == 0 {
            addSubview(moveMiniscreen)
        } else {
            attendeeCollectionView.addSubview(moveMiniscreen)
        }
        viewModel.clearSubscribeVideoStream(items: getNoLoadHasVideoItems())
        updatePageControl()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        attendeeCollectionView.addSubview(moveMiniscreen)
    }
}

// MARK: - UICollectionViewDataSource

extension TUIVideoSeatView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.listSeatItem.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellID_Normal,
            for: indexPath) as! TUIVideoSeatCell
        if indexPath.item >= viewModel.listSeatItem.count {
            return cell
        }

        // 解绑cell和item的绑定
        let seatItem = viewModel.listSeatItem[indexPath.item]
        if let lastSeatItem = cell.seatItem, lastSeatItem != seatItem, lastSeatItem.boundCell == cell {
            lastSeatItem.boundCell = nil
            viewModel.stopPlayVideo(item: lastSeatItem)
        }

        seatItem.boundCell = cell
        cell.updateUI(item: seatItem)
        if seatItem.isHasVideoStream {
            viewModel.startPlayVideo(item: seatItem, renderView: cell.renderView)
        }
        return cell
    }
}

// MARK: - UICollectionViewDataSource

extension TUIVideoSeatView: TUIVideoSeatLayoutDelegate {
    func updateNumberOfPages(numberOfPages: NSInteger) {
        pageControl.numberOfPages = numberOfPages
    }
}
