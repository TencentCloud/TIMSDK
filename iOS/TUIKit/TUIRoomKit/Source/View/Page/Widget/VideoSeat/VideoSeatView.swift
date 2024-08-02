//
//  TUIVideoSeat.swift
//  TUIVideoSeat
//
//  Created by WesleyLei on 2022/9/13.
//  Copyright © 2022 Tencent. All rights reserved.
//

import UIKit

protocol TUIVideoSeatViewResponder: AnyObject {
    func switchPosition()
    func clickVideoSeat()
    func startPlayVideoStream(item: VideoSeatItem, renderView: UIView?)
    func stopPlayVideoStream(item: VideoSeatItem)
    func updateSpeakerPlayVideoState(currentPageIndex: Int)
    func stopScreenCapture()
}

class TUIVideoSeatView: UIView {
    private let CellID_Normal = "VideoSeatCell_Normal"
    private let CellID_Mini = "VideoSeatCell_Mini"
    private let viewModel: TUIVideoSeatViewModel
    private var isViewReady: Bool = false
    weak var responder: TUIVideoSeatViewResponder?
    
    private var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPage = 0
        control.numberOfPages = 1
        control.hidesForSinglePage = true
        control.isUserInteractionEnabled = false
        return control
    }()
    
    init(viewModel: TUIVideoSeatViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        viewModel.viewResponder = self
        responder = viewModel
        isUserInteractionEnabled = true
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
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
        attendeeCollectionView.setContentOffset(
            CGPoint(x: CGFloat(pageControl.currentPage) * attendeeCollectionView.frame.size.width,
                    y: attendeeCollectionView.contentOffset.y), animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var videoSeatLayout: VideoSeatLayout = {
        let layout = VideoSeatLayout(viewModel: viewModel)
        layout.delegate = self
        return layout
    }()
    
    lazy var attendeeCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), collectionViewLayout:
                                            videoSeatLayout)
        collection.register(VideoSeatCell.self, forCellWithReuseIdentifier: CellID_Normal)
        collection.register(TUIVideoSeatDragCell.self, forCellWithReuseIdentifier: CellID_Mini)
        collection.isPagingEnabled = true
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.isUserInteractionEnabled = true
        collection.contentMode = .scaleToFill
        collection.backgroundColor = UIColor(0x0F1014)
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
        let cell = TUIVideoSeatDragCell()
        cell.frame = videoSeatLayout.getMiniscreenFrame(item: nil)
        cell.isHidden = true
        addSubview(cell)
        return cell
    }()
    
    lazy var screenCaptureMaskView: ScreenCaptureMaskView = {
        let view = ScreenCaptureMaskView(frameType: .fullScreen)
        view.responder = self.responder
        view.isHidden = true
        return view
    }()
    
    let placeholderView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        return view
    }()
        
    func constructViewHierarchy() {
        backgroundColor = .clear
        addSubview(placeholderView)
        addSubview(attendeeCollectionView)
        addSubview(pageControl)
        addSubview(screenCaptureMaskView)
    }
    
    func activateConstraints() {
        placeholderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        attendeeCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageControl.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
        }
        screenCaptureMaskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bindInteraction() {
        screenCaptureMaskView.isHidden = !EngineManager.shared.store.currentUser.hasScreenStream
        addGesture()
    }
    
    private func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickVideoSeat))
        addGestureRecognizer(tap)
    }
    
    @objc private func clickVideoSeat() {
        responder?.clickVideoSeat()
    }
    
    func updatePageControl() {
        let offsetYu = Int(attendeeCollectionView.contentOffset.x) % Int(attendeeCollectionView.mm_w)
        let offsetMuti = CGFloat(offsetYu) / attendeeCollectionView.mm_w
        pageControl.currentPage = (offsetMuti > 0.5 ? 1 : 0) + (Int(attendeeCollectionView.contentOffset.x) / Int(attendeeCollectionView.mm_w))
        
        if let seatItem = moveMiniscreen.seatItem, seatItem.hasVideoStream {
            if pageControl.currentPage == 0 && !moveMiniscreen.isHidden {
                responder?.startPlayVideoStream(item: seatItem, renderView: moveMiniscreen.renderView)
            } else {
                responder?.startPlayVideoStream(item: seatItem, renderView: getVideoVisibleCell(seatItem)?.renderView)
            }
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: - TUIVideoSeatViewModelResponder

extension TUIVideoSeatView: TUIVideoSeatViewModelResponder {
    private func freshCollectionView(block: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        block()
        CATransaction.commit()
    }
    
    func reloadData() {
        freshCollectionView { [weak self] in
            guard let self = self else { return }
            self.attendeeCollectionView.reloadData()
        }
    }
    
    func insertItems(at indexPaths: [IndexPath]) {
        freshCollectionView { [weak self] in
            guard let self = self else { return }
            let cellNumber = self.attendeeCollectionView.numberOfItems(inSection: 0)
            let listSeatItemNumber = self.viewModel.listSeatItem.count
            guard cellNumber + indexPaths.count == listSeatItemNumber else { return }
            self.attendeeCollectionView.performBatchUpdates { [weak self] in
                guard let self = self else { return }
                self.attendeeCollectionView.insertItems(at: indexPaths)
            }
        }
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        freshCollectionView { [weak self] in
            guard let self = self else { return }
            var resultArray: [IndexPath] = []
            let numberOfSections = self.attendeeCollectionView.numberOfSections
            for indexPath in indexPaths {
                let section = indexPath.section
                let item = indexPath.item
                guard section < numberOfSections && item < self.attendeeCollectionView.numberOfItems(inSection: section)
                else { continue }
                resultArray.append(indexPath)
            }
            let cellNumber = self.attendeeCollectionView.numberOfItems(inSection: 0)
            let listSeatItemNumber = self.viewModel.listSeatItem.count
            guard cellNumber - indexPaths.count == listSeatItemNumber else { return }
            self.attendeeCollectionView.performBatchUpdates { [weak self] in
                guard let self = self else { return }
                self.attendeeCollectionView.deleteItems(at: resultArray)
            }
        }
    }
    
    func updateVideoSeatCellUI(_ item: VideoSeatItem) {
        if let seatItem = moveMiniscreen.seatItem, seatItem.userId == item.userId {
            moveMiniscreen.updateUI(item: seatItem)
        }
        guard let cell = getVideoVisibleCell(item) else { return }
        cell.updateUI(item: item)
    }
    
    func updateSeatVolume(_ item: VideoSeatItem) {
        guard let cell = getVideoVisibleCell(item) else { return }
        cell.updateUIVolume(item: item)
    }
    
    func getVideoVisibleCell(_ item: VideoSeatItem) -> VideoSeatCell? {
        let cellArray = attendeeCollectionView.visibleCells
        guard let cell = cellArray.first(where: { cell in
            if let seatCell = cell as? VideoSeatCell, seatCell.seatItem == item {
                return true
            } else {
                return false
            }
        }) as? VideoSeatCell else { return nil }
        return cell
    }
    
    func updateMiniscreen(_ item: VideoSeatItem?) {
        guard let item = item else {
            moveMiniscreen.isHidden = true
            return
        }
        if attendeeCollectionView.contentOffset.x > 0 {
            return
        }
        if let seatItem = moveMiniscreen.seatItem, seatItem.userId != item.userId, (getVideoVisibleCell(seatItem) == nil) {
            responder?.stopPlayVideoStream(item: seatItem)
        }
        moveMiniscreen.updateSize(size: videoSeatLayout.getMiniscreenFrame(item: item).size)
        moveMiniscreen.isHidden = false
        bringSubviewToFront(moveMiniscreen)
        moveMiniscreen.updateUI(item: item)
        if item.isHasVideoStream {
            responder?.startPlayVideoStream(item: item, renderView: moveMiniscreen.renderView)
        }
    }
    
    func updateMiniscreenVolume(_ item: VideoSeatItem) {
        moveMiniscreen.updateUIVolume(item: item)
    }
    
    func getMoveMiniscreen() -> TUIVideoSeatDragCell {
        return moveMiniscreen
    }
    
    func showScreenCaptureMaskView(isShow: Bool) {
        screenCaptureMaskView.isHidden = !isShow
        if isShow {
            screenCaptureMaskView.superview?.bringSubviewToFront(screenCaptureMaskView)
        }
    }
    
    func destroyVideoSeatResponder() {
        responder = nil
        attendeeCollectionView.delegate = nil
        attendeeCollectionView.dataSource = nil
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TUIVideoSeatView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let seatItem = viewModel.listSeatItem[safe: indexPath.item] else { return }
        guard let seatCell = cell as? VideoSeatCell else { return }
        if seatItem.isHasVideoStream {
            responder?.startPlayVideoStream(item: seatItem, renderView: seatCell.renderView)
        } else {
            responder?.stopPlayVideoStream(item: seatItem)
        }
        seatCell.updateUI(item: seatItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let seatCell = cell as? VideoSeatCell else { return }
        if let seatItem = seatCell.seatItem {
            responder?.stopPlayVideoStream(item: seatItem)
        }
    }
}

extension TUIVideoSeatView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPageIndex = Int(scrollView.contentOffset.x / scrollView.mm_w)
        responder?.updateSpeakerPlayVideoState(currentPageIndex: currentPageIndex)
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
        if viewModel.videoSeatViewType == .largeSmallWindowType, indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID_Mini, for: indexPath) as! TUIVideoSeatDragCell
            cell.clickBlock = {[weak self] in
                guard let self = self else { return }
                self.viewModel.switchPosition()
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellID_Normal,
                for: indexPath) as! VideoSeatCell
            return cell
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TUIVideoSeatView: VideoSeatLayoutDelegate {
    func updateNumberOfPages(numberOfPages: NSInteger) {
        pageControl.numberOfPages = numberOfPages
    }
}
