//
//  VideoSeatLayout.swift
//  TUIVideoSeat
//
//  Created by 唐佳宁 on 2023/3/16.
//

import Foundation

protocol VideoSeatLayoutDelegate: AnyObject {
    func updateNumberOfPages(numberOfPages: NSInteger)
}

class VideoSeatLayout: UICollectionViewFlowLayout {
    private var prePageCount: NSInteger = 1

    private var collectionViewHeight: CGFloat {
        return collectionView?.bounds.height ?? UIScreen.main.bounds.height
    }

    private var collectionViewWidth: CGFloat {
        return collectionView?.bounds.width ?? kScreenWidth
    }

    private var isPortrait: Bool {
        return collectionViewHeight > collectionViewWidth
    }

    // 一行最多展示cell数
    private var kVideoSeatCellNumberOfOneRow: CGFloat {
        return isPortrait ? 2 : 3
    }

    // 一页最多展示cell数
    private var kMaxShowCellCount: Int {
        return 6
    }

    private let itemDiffSpace: CGFloat = 5.0

    // item 宽高
    private var itemWidthHeight: CGFloat {
        let minimumDistance = min(collectionViewHeight, collectionViewWidth)
        let availableSpace = minimumDistance - (kVideoSeatCellNumberOfOneRow + 1) * itemDiffSpace
        if isPortrait {
            return availableSpace / kVideoSeatCellNumberOfOneRow
        } else {
            return availableSpace / (CGFloat(kMaxShowCellCount) / kVideoSeatCellNumberOfOneRow)
        }
    }

    private let viewModel: TUIVideoSeatViewModel
    // 保存所有item
    fileprivate var layoutAttributeArray: [UICollectionViewLayoutAttributes] = []

    init(viewModel: TUIVideoSeatViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()
        calculateEachCellFrame()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributeArray
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: CGFloat(prePageCount) * collectionViewWidth, height: collectionViewHeight)
    }

    weak var delegate: VideoSeatLayoutDelegate?

    // Miniscreen布局信息
    func getMiniscreenFrame(item: VideoSeatItem?) -> CGRect {
        var height = isPortrait ? 180.0 : 100.0
        var width = isPortrait ? 100.0 : 180.0
        if let item = item, !item.hasVideoStream {
            height = 100.0
            width = 100.0
        }
        return CGRect(x: collectionViewWidth - width - itemDiffSpace, y: itemDiffSpace, width: width, height: height)
    }
}

// MARK: - layout

extension VideoSeatLayout {
    // 计算cell的位置和大小，并进行存储
    private func calculateEachCellFrame() {
        guard let collectionViewWidth: CGFloat = collectionView?.bounds.width else { return }
        guard viewModel.listSeatItem.count > 0 else { return }
        layoutAttributeArray = []
        let section: Int = 0
        prePageCount = 1
        if viewModel.videoSeatViewType == .singleType {
            let indexPath = IndexPath(item: 0, section: 0)
            let cell = getFullScreenAttributes(indexPath: indexPath)
            layoutAttributeArray.append(cell)
        } else if viewModel.videoSeatViewType == .largeSmallWindowType {
            let indexPath = IndexPath(item: 0, section: section)
            let cell = getFullScreenAttributes(indexPath: indexPath)
            layoutAttributeArray.append(cell)
        } else if viewModel.videoSeatViewType == .pureAudioType || viewModel.videoSeatViewType == .equallyDividedType {
            guard let itemCount = collectionView?.numberOfItems(inSection: section) else { return }
            let isMultipage = itemCount >= kMaxShowCellCount
            for i in 0 ... itemCount - 1 {
                let indexPath = IndexPath(item: i, section: section)
                var cell: UICollectionViewLayoutAttributes
                if isMultipage {
                    cell = getMultipageEquallyDividedAttributes(indexPath: indexPath, item: i, itemCount: itemCount, leftDiff: 0.0)
                } else {
                    cell = getEquallyDividedAttributes(indexPath: indexPath, item: i, itemCount: itemCount, leftDiff: 0.0)
                }
                layoutAttributeArray.append(cell)
            }
            prePageCount = Int(ceil(CGFloat(itemCount) / CGFloat(kMaxShowCellCount)))
        } else if viewModel.videoSeatViewType == .speechType {
            guard let itemCount = collectionView?.numberOfItems(inSection: section) else { return }
            let isMultipage = (itemCount - 1) >= kMaxShowCellCount
            // 其它页：2,3,4.... 均分
            for i in 0 ... itemCount {
                let indexPath = IndexPath(item: i, section: section)
                var cell: UICollectionViewLayoutAttributes
                if i == 0 {
                    // 演讲者大窗
                    cell = getFullScreenAttributes(indexPath: indexPath)
                } else if isMultipage {
                    cell = getMultipageEquallyDividedAttributes(indexPath: indexPath, item: i - 1,
                                                                itemCount: itemCount - 1,
                                                                leftDiff: collectionViewWidth)
                } else {
                    cell = getEquallyDividedAttributes(indexPath: indexPath, item: i - 1,
                                                       itemCount: itemCount - 1,
                                                       leftDiff: collectionViewWidth)
                }
                layoutAttributeArray.append(cell)
            }
            prePageCount = Int(ceil(CGFloat(itemCount - 1) / CGFloat(kMaxShowCellCount))) + 1
        }
        delegate?.updateNumberOfPages(numberOfPages: prePageCount)
    }

    // 全屏cell布局信息
    private func getFullScreenAttributes(indexPath: IndexPath) ->
        UICollectionViewLayoutAttributes {
        let cell = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        cell.frame = CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewHeight)
        return cell
    }

    // 获取等分居中布局
    private func getEquallyDividedAttributes(indexPath: IndexPath, item: Int, itemCount: Int, leftDiff: CGFloat) ->
        UICollectionViewLayoutAttributes {
        // 为何不直接用indexPath.item,因为演讲者模式，第一页只有2个数据填充页面
        // page:1,2,3 row:1,2,3, item:1,2,3
        // column:0,1,2,3

        /*-----------------item&page&currentPageItemCount&cell-----------------**/
        let item = item + 1
        let page = Int(ceil(CGFloat(item) / CGFloat(kMaxShowCellCount))) // cell在第几页上
        let currentPageItemCount = min(itemCount, page * kMaxShowCellCount) - (page - 1) * kMaxShowCellCount // 当前页item个数
        let cell = UICollectionViewLayoutAttributes(forCellWith: indexPath)

        /*-----------------currentPageAllRow&beginCellY&beginCellLeft-----------------**/
        let currentPageAllRow = Int(ceil(CGFloat(currentPageItemCount) / CGFloat(kVideoSeatCellNumberOfOneRow))) // 计算本页总行数
        let itemAllHeight = (itemWidthHeight + itemDiffSpace) * CGFloat(currentPageAllRow) - itemDiffSpace
        let itemAllWidth = (itemWidthHeight + itemDiffSpace) * kVideoSeatCellNumberOfOneRow - itemDiffSpace
        let beginCellY = (collectionViewHeight - itemAllHeight) * 0.5 // 计算beginCellTop
        let beginCellX = (collectionViewWidth - itemAllWidth) * 0.5 // 计算beginCellTop
        let beginCellLeft = CGFloat(page - 1) * collectionViewWidth // 计算beginCellLeft

        /*-----------------itemIndex&column&row-----------------**/
        let itemIndex = item - (page - 1) * kMaxShowCellCount // 本页的第几个
        let column = (itemIndex - 1) % Int(kVideoSeatCellNumberOfOneRow) // cell当前页上的第几列 从0开始
        let row = Int(ceil(CGFloat(itemIndex) / CGFloat(kVideoSeatCellNumberOfOneRow))) // cell当前页上的第几行
        let itemY = beginCellY + (itemWidthHeight + itemDiffSpace) * CGFloat(row - 1)
        var itemX = 0.0
        if currentPageAllRow == row {
            // 最后一行居中调整
            let lastRowItemCount = currentPageItemCount - (row - 1) * Int(kVideoSeatCellNumberOfOneRow)
            let lastRowBeginCellLeft = (collectionViewWidth - (itemWidthHeight + itemDiffSpace) * CGFloat(lastRowItemCount) - itemDiffSpace) * 0.5
            itemX = lastRowBeginCellLeft + beginCellLeft + (itemWidthHeight + itemDiffSpace) * CGFloat(column)
        } else {
            itemX = beginCellX + beginCellLeft + (itemWidthHeight + itemDiffSpace) * CGFloat(column)
        }
        cell.frame = CGRect(x: leftDiff + itemX, y: itemY, width: itemWidthHeight, height: itemWidthHeight)
        return cell
    }

    // 获取等分固定布局
    private func getMultipageEquallyDividedAttributes(indexPath: IndexPath, item: Int, itemCount: Int, leftDiff: CGFloat) ->
        UICollectionViewLayoutAttributes {
        // 为何不直接用indexPath.item,因为演讲者模式，第一页只有2个数据填充页面
        // page:1,2,3 row:1,2,3, item:1,2,3
        // column:0,1,2,3

        /*-----------------item&page&cell-----------------**/
        let item = item + 1
        let page = Int(ceil(CGFloat(item) / CGFloat(kMaxShowCellCount))) // cell在第几页上
        let cell = UICollectionViewLayoutAttributes(forCellWith: indexPath)

        /*-----------------currentPageAllRow&beginCellY&beginCellLeft-----------------**/
        let currentPageAllRow = kMaxShowCellCount / Int(kVideoSeatCellNumberOfOneRow) // 计算本页总行数
        let itemAllHeight = (itemWidthHeight + itemDiffSpace) * CGFloat(currentPageAllRow) - itemDiffSpace
        let itemAllWidth = (itemWidthHeight + itemDiffSpace) * kVideoSeatCellNumberOfOneRow - itemDiffSpace
        let beginCellY = (collectionViewHeight - itemAllHeight) * 0.5 // 计算beginCellTop
        let beginCellX = (collectionViewWidth - itemAllWidth) * 0.5 // 计算beginCellTop
        let beginCellLeft = CGFloat(page - 1) * collectionViewWidth // 计算beginCellLeft

        /*-----------------itemIndex&column&row-----------------**/
        let itemIndex = item - (page - 1) * kMaxShowCellCount // 本页的第几个
        let column = (itemIndex - 1) % Int(kVideoSeatCellNumberOfOneRow) // cell当前页上的第几列 从0开始
        let row = Int(ceil(CGFloat(itemIndex) / CGFloat(kVideoSeatCellNumberOfOneRow))) // cell当前页上的第几行
        let itemY = beginCellY + (itemWidthHeight + itemDiffSpace) * CGFloat(row - 1)
        let itemX = beginCellX + beginCellLeft + (itemWidthHeight + itemDiffSpace) * CGFloat(column)
        cell.frame = CGRect(x: leftDiff + itemX, y: itemY, width: itemWidthHeight, height: itemWidthHeight)
        return cell
    }
}
