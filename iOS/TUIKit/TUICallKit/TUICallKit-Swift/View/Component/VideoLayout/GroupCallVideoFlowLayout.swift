//
//  GroupCallVideoFlowLayout.swift
//  TUICallKit
//
//  Created by noah on 2023/11/1.
//

import Foundation
import UIKit

public var showLargeViewIndex: Int = -1

enum MosaicSegmentStyle {
    case fullWidth
    case fiftyFifty
    case oneThird
    case threeOneThirds
    case twoThirdsOneThirdRight
    case twoThirdsOneThirdCenter
    case oneThirdTwoThirds
}

class GroupCallVideoFlowLayout: UICollectionViewFlowLayout {
    private var deletingIndexPaths = [IndexPath]()
    private var insertingIndexPaths = [IndexPath]()
    
    private var contentBounds = CGRect.zero
    private var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        cachedAttributes.removeAll()
        contentBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
        
        let count = collectionView.numberOfItems(inSection: 0)
        var currentIndex = 0
        var segment: MosaicSegmentStyle = getSegment(count: count, currentIndex: currentIndex)
        let cvWidth = collectionView.bounds.size.width
        var lastFrame: CGRect = (count != 2 || showLargeViewIndex >= 0) ? .zero : CGRect(x: 0, y: cvWidth / 5, width: 0, height: 0)
        
        while currentIndex < count {
            var segmentRects = [CGRect]()
            switch segment {
            case .fullWidth:
                segmentRects = [CGRect(x: 0, y: lastFrame.maxY + 1.0, width: cvWidth, height: cvWidth)]
                
            case .fiftyFifty:
                let segmentFrame = CGRect(x: 0, y: lastFrame.maxY + 1.0, width: cvWidth, height: cvWidth / 2)
                let horizontalSlices = segmentFrame.dividedIntegral(fraction: 0.5, from: .minXEdge)
                segmentRects = [horizontalSlices.first, horizontalSlices.second]
                
            case .oneThird:
                segmentRects = [CGRect(x: cvWidth / 4.0, y: lastFrame.maxY + 1.0, width: cvWidth / 2.0, height: cvWidth / 2.0)]
                
            case .threeOneThirds:
                let segmentFrame = CGRect(x: 0, y: lastFrame.maxY + 1.0, width: cvWidth, height: cvWidth / 3)
                let horizontalSlicesFirst = segmentFrame.dividedIntegral(fraction: 1.0 / 3, from: .minXEdge)
                let horizontalSlices = horizontalSlicesFirst.second.dividedIntegral(fraction: 0.5, from: .minXEdge)
                segmentRects = [horizontalSlicesFirst.first, horizontalSlices.first, horizontalSlices.second]
                
            case .twoThirdsOneThirdRight:
                let segmentFrame = CGRect(x: 0, y: lastFrame.maxY + 1.0, width: cvWidth, height: cvWidth * 2 / 3)
                let horizontalSlices = segmentFrame.dividedIntegral(fraction: (1.0 / 3), from: .minXEdge)
                let verticalSlices = horizontalSlices.first.dividedIntegral(fraction: 0.5, from: .minYEdge)
                segmentRects = [verticalSlices.first, verticalSlices.second, horizontalSlices.second]
                
            case .twoThirdsOneThirdCenter:
                let segmentFrame = CGRect(x: 0, y: lastFrame.maxY + 1.0, width: cvWidth, height: cvWidth * 2 / 3)
                let horizontalSlices = segmentFrame.dividedIntegral(fraction: (1.0 / 3), from: .minXEdge)
                let verticalSlices = horizontalSlices.first.dividedIntegral(fraction: 0.5, from: .minYEdge)
                segmentRects = [verticalSlices.first, horizontalSlices.second, verticalSlices.second]
                
            case .oneThirdTwoThirds:
                let segmentFrame = CGRect(x: 0, y: lastFrame.maxY + 1.0, width: cvWidth, height: cvWidth * 2 / 3)
                let horizontalSlices = segmentFrame.dividedIntegral(fraction: (2.0 / 3), from: .minXEdge)
                let verticalSlices = horizontalSlices.second.dividedIntegral(fraction: 0.5, from: .minYEdge)
                segmentRects = [horizontalSlices.first, verticalSlices.first, verticalSlices.second]
            }
            
            // Create and cache layout attributes for calculated frames.
            for rect in segmentRects {
                let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: currentIndex, section: 0))
                attributes.frame = rect
                
                cachedAttributes.append(attributes)
                contentBounds = contentBounds.union(lastFrame)
                
                currentIndex += 1
                lastFrame = rect
            }
            
            segment = getSegment(count: count, currentIndex: currentIndex)
        }
    }
    
    func getSegment(count: Int, currentIndex: Int) -> MosaicSegmentStyle {
        var segment: MosaicSegmentStyle
        
        // Determine first segment style.
        if currentIndex == 0 {
            var segment: MosaicSegmentStyle = .threeOneThirds
            
            if count == 1 {
                segment = .fullWidth
            } else if count >= 2 && count <= 4 {
                if showLargeViewIndex >= 0  {
                    segment = .fullWidth
                } else {
                    segment = .fiftyFifty
                }
            } else if showLargeViewIndex == 0 {
                segment = .oneThirdTwoThirds
            } else if showLargeViewIndex == 1 {
                segment = .twoThirdsOneThirdCenter
            } else if showLargeViewIndex == 2 {
                segment = .twoThirdsOneThirdRight
            }
            
            return segment
        }
        
        // Determine the next segment style.
        switch count - currentIndex {
        case 1:
            if count == 3 {
                segment = .oneThird
            } else if count > 4 && showLargeViewIndex == (count - 1) {
                segment = .oneThirdTwoThirds
            } else {
                segment = .threeOneThirds
            }
        case 2:
            if count == 4 {
                segment = .fiftyFifty
            } else if count > 4 && showLargeViewIndex == currentIndex {
                segment = .oneThirdTwoThirds
            } else if count > 4 && (showLargeViewIndex == currentIndex + 1) {
                segment = .twoThirdsOneThirdCenter
            } else if count > 4 && (showLargeViewIndex == currentIndex + 2) {
                segment = .twoThirdsOneThirdRight
            } else {
                segment = .threeOneThirds
            }
        default:
            if count > 4 && showLargeViewIndex == currentIndex {
                segment = .oneThirdTwoThirds
            } else if count > 4 && (showLargeViewIndex == currentIndex + 1) {
                segment = .twoThirdsOneThirdCenter
            } else if count > 4 && (showLargeViewIndex == currentIndex + 2) {
                segment = .twoThirdsOneThirdRight
            } else {
                segment = .threeOneThirds
            }
            break
        }
        
        return segment
    }
    
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) else { return nil }
        
        if !deletingIndexPaths.isEmpty {
            if deletingIndexPaths.contains(itemIndexPath) {
                attributes.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                attributes.alpha = 0.0
                attributes.zIndex = 0
            }
        }
        
        return attributes
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else { return nil }
        
        if insertingIndexPaths.contains(itemIndexPath) {
            attributes.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            attributes.alpha = 0.0
            attributes.zIndex = 0
        }
        
        return attributes
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        for update in updateItems {
            switch update.updateAction {
            case .delete:
                guard let indexPath = update.indexPathBeforeUpdate else { return }
                deletingIndexPaths.append(indexPath)
            case .insert:
                guard let indexPath = update.indexPathAfterUpdate else { return }
                insertingIndexPaths.append(indexPath)
            default:
                break
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
        deletingIndexPaths.removeAll()
        insertingIndexPaths.removeAll()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        // Find any cell that sits within the query rect.
        guard let lastIndex = cachedAttributes.indices.last,
              let firstMatchIndex = binSearch(rect, start: 0, end: lastIndex) else { return attributesArray }
        
        // Starting from the match, loop up and down through the array until all the attributes
        // have been added within the query rect.
        for attributes in cachedAttributes[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            attributesArray.append(attributes)
        }
        
        for attributes in cachedAttributes[firstMatchIndex...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            attributesArray.append(attributes)
        }
        
        return attributesArray
    }
    
    // Perform a binary search on the cached attributes array.
    func binSearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start { return nil }
        
        let mid = (start + end) / 2
        let attributes = cachedAttributes[mid]
        
        if attributes.frame.intersects(rect) {
            return mid
        } else {
            if attributes.frame.maxY < rect.minY {
                return binSearch(rect, start: (mid + 1), end: end)
            } else {
                return binSearch(rect, start: start, end: (mid - 1))
            }
        }
    }
}
