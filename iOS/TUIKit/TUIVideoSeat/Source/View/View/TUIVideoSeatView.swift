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
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: - TUIVideoSeatViewResponder

extension TUIVideoSeatView: TUIVideoSeatViewResponder {
    func reloadData() {
        attendeeCollectionView.reloadData()
    }

    func updateSeatItem(_ item: VideoSeatItem) {
        if let seatItem = moveMiniscreen.seatItem, seatItem.userId == item.userId {
            moveMiniscreen.updateUI(item: seatItem)
        }
        guard let cellIndexPath = item.cellIndexPath else { return }
        guard let cell = attendeeCollectionView.cellForItem(at: cellIndexPath) as? TUIVideoSeatCell else { return }
        if item == cell.seatItem {
            cell.updateUI(item: item)
        }
    }

    func updateSeatVolume(_ item: VideoSeatItem) {
        guard let cellIndexPath = item.cellIndexPath else { return }
        guard let cell = attendeeCollectionView.cellForItem(at: cellIndexPath) as? TUIVideoSeatCell else { return }
        if cell.seatItem == item {
            cell.updateUIVolume(item: item)
        }
    }

    func getSeatVideoRenderView(_ item: VideoSeatItem) -> UIView? {
        guard let cellIndexPath = item.cellIndexPath else { return nil }
        guard let cell = attendeeCollectionView.cellForItem(at: cellIndexPath) as? TUIVideoSeatCell else { return nil }
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
        if Int(attendeeCollectionView.contentOffset.x / max(attendeeCollectionView.mm_w, 1)) != 0 {
            return
        }

        if let lastItem = moveMiniscreen.seatItem,
           viewModel.videoSeatViewType != .largeSmallWindowType,
           lastItem.userId != item.userId {
            if let firstItem = viewModel.listSeatItem.first,
               firstItem.userId == lastItem.userId,
               firstItem.type != .share {
            } else {
                viewModel.stopPlayVideo(item: lastItem)
            }
        }

        moveMiniscreen.updateSize(size: videoSeatLayout.getMiniscreenFrame(item: item).size)
        moveMiniscreen.isHidden = false
        moveMiniscreen.updateUI(item: item)
        if item.isHasVideoStream {
            viewModel.startPlayVideo(item: item, renderView: moveMiniscreen.renderView)
        } else {
            viewModel.stopPlayVideo(item: item)
        }
        moveMiniscreen.superview?.bringSubviewToFront(moveMiniscreen)
    }

    func updateMiniscreenVolume(_ item: VideoSeatItem) {
        moveMiniscreen.updateUIVolume(item: item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TUIVideoSeatView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let seatCell = cell as? TUIVideoSeatCell, let seatItem = seatCell.seatItem {
            if seatItem.isHasVideoStream {
                viewModel.startPlayVideo(item: seatItem, renderView: seatCell.renderView)
            } else {
                viewModel.stopPlayVideo(item: seatItem)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let seatCell = cell as? TUIVideoSeatCell, let seatItem = seatCell.seatItem else { return }
        let currentPageIndex = Int(collectionView.contentOffset.x / collectionView.mm_w)
        if viewModel.isNeedStopPlayVideo(item: seatItem, currentPageIndex: currentPageIndex) {
            viewModel.stopPlayVideo(item: seatItem)
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
        let seatItem = viewModel.listSeatItem[indexPath.item]
        seatItem.cellIndexPath = indexPath
        cell.updateUI(item: seatItem)
        if seatItem.isHasVideoStream {
            viewModel.startPlayVideo(item: seatItem, renderView: cell.renderView)
        } else {
            viewModel.stopPlayVideo(item: seatItem)
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
