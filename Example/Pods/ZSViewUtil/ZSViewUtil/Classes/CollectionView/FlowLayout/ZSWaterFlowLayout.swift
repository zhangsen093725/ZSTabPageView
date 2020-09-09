//
//  ZSWaterFlowLayout.swift
//  Kingfisher
//
//  Created by Josh on 2020/7/14.
//

import UIKit

@objc public protocol ZSWaterFlowLayoutDataSource: NSObjectProtocol {
    
    /// collectionItem高度
    func zs_heightForRowAtIndexPath(collectionView collection: UICollectionView, layout: ZSWaterFlowLayout, indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat
    
    /// 每个section 列数（默认2列）
    @objc optional func zs_columnNumber(collectionView collection: UICollectionView, layout: ZSWaterFlowLayout, section: Int) -> Int
    
    /// header高度（默认为0）
    @objc optional func zs_referenceSizeForHeader(collectionView collection: UICollectionView, layout: ZSWaterFlowLayout, section: Int) -> CGSize
    
    /// footer高度（默认为0）
    @objc optional func zs_referenceSizeForFooter(collectionView collection: UICollectionView, layout: ZSWaterFlowLayout, section: Int) -> CGSize
    
    /// 每个section 边距（默认为0）
    @objc optional func zs_insetForSection(collectionView collection: UICollectionView, layout: ZSWaterFlowLayout, section: Int) -> UIEdgeInsets
    
    /// 每个section item上下间距（默认为0）
    @objc optional func zs_lineSpacing(collectionView collection: UICollectionView, layout: ZSWaterFlowLayout, section: Int) -> CGFloat
    
    /// 每个section item左右间距（默认为0）
    @objc optional func zs_interitemSpacing(collectionView collection: UICollectionView, layout: ZSWaterFlowLayout, section: Int) -> CGFloat
    
    /// section头部header与上个section尾部footer间距（默认为0）
    @objc optional func zs_sectionSpacing(collectionView collection: UICollectionView, layout: ZSWaterFlowLayout, section: Int) -> CGFloat
}

@objcMembers open class ZSWaterFlowLayout: UICollectionViewFlowLayout {
    
    weak public var dataSource: ZSWaterFlowLayoutDataSource?
    
    /// 存放attribute的数组
    private var attributes: [UICollectionViewLayoutAttributes] = []
    
    /// 存放每个section中各个列的最后一个高度
    private var columnHeights: [Int : CGFloat] = [:]
    
    /// collectionView的contentSize的高度
    private var contentHeight: CGFloat = 0
    
    /// 记录上个section高度最高一列的高度
    private var lastContentHeight: CGFloat = 0
    
    private var minHeightColumn: Int {
        
        var min = CGFloat(MAXFLOAT)
        var column = 0
        
        for (key, vaule) in columnHeights
        {
            if min > vaule
            {
                min = vaule
                column = key
            }
        }
        return column
    }
    
    private var _columnCount_: Int = 2
    private var _sectionInset_: UIEdgeInsets = .zero
    private var _minimumInteritemSpacing_: CGFloat = 0
    private var _minimumLineSpacing_: CGFloat = 0
    private var _headerReferenceSize_: CGSize = .zero
    private var _footerReferenceSize_: CGSize = .zero
    private var _minimumSectionSpacing_: CGFloat = 0
    
    open override func prepare() {
        super.prepare()
        
        contentHeight = 0
        lastContentHeight = 0
        
        columnHeights.removeAll()
        attributes.removeAll()
        
        scrollDirection = .vertical
        
        let sectionCount = collectionView?.numberOfSections ?? 0
        
        // 遍历section
        for section in 0..<sectionCount
        {
            let sectionIndexPath = IndexPath(item: 0, section: section)
            
            _columnCount_ = dataSource?.zs_columnNumber?(collectionView: collectionView!, layout: self, section: section) ?? 2
            _sectionInset_ = dataSource?.zs_insetForSection?(collectionView: collectionView!, layout: self, section: section) ?? sectionInset
            _minimumInteritemSpacing_ = dataSource?.zs_interitemSpacing?(collectionView: collectionView!, layout: self, section: section) ?? minimumInteritemSpacing
            _minimumLineSpacing_ = dataSource?.zs_lineSpacing?(collectionView: collectionView!, layout: self, section: section) ?? minimumLineSpacing
            _headerReferenceSize_ = dataSource?.zs_referenceSizeForHeader?(collectionView: collectionView!, layout: self, section: section) ?? headerReferenceSize
            _footerReferenceSize_ = dataSource?.zs_referenceSizeForFooter?(collectionView: collectionView!, layout: self, section: section) ?? footerReferenceSize
            
            if section > 0
            {
                _minimumSectionSpacing_ = dataSource?.zs_sectionSpacing?(collectionView: collectionView!, layout: self, section: section) ?? 0
            }
            else
            {
                _minimumSectionSpacing_ = 0
            }
            
            // 生成header
            if let header = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: sectionIndexPath)
            {
                attributes.append(header)
                columnHeights.removeAll()
            }
            
            lastContentHeight = contentHeight
            
            // 初始化区 y值
            for column in 0..<_columnCount_
            {
                columnHeights[column] = contentHeight
            }
            
            let itemCount = collectionView?.numberOfItems(inSection: section) ?? 0
            for item in 0..<itemCount
            {
                let cellIndexPath = IndexPath(item: item, section: section)
                if let cell = layoutAttributesForItem(at: cellIndexPath)
                {
                    attributes.append(cell)
                }
            }
            
            // 初始化footer
            if let footer = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: sectionIndexPath)
            {
                attributes.append(footer)
            }
        }
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return attributes
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let cell = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        let weight = (collectionView?.frame.size.width ?? 0) - _sectionInset_.left - _sectionInset_.right - CGFloat(_columnCount_ - 1) * _minimumInteritemSpacing_
        
        let cellWeight = weight / CGFloat(_columnCount_)
        let cellHeight = dataSource?.zs_heightForRowAtIndexPath(collectionView: collectionView!, layout: self, indexPath: indexPath, itemWidth: cellWeight) ?? 0
        
        let cellX = _sectionInset_.left + CGFloat(minHeightColumn) * (cellWeight + _minimumInteritemSpacing_)
        
        let minColumnHeight = columnHeights[minHeightColumn] ?? 0
        
        var cellY: CGFloat = minColumnHeight
        
        if cellY != self.lastContentHeight
        {
            cellY += _minimumLineSpacing_
        }
        
        if contentHeight < minColumnHeight
        {
            contentHeight = minColumnHeight
        }
        
        cell.frame = CGRect(x: cellX, y: cellY, width: cellWeight, height: cellHeight)
        
        columnHeights[minHeightColumn] = cell.frame.maxY
        
        //取最大的
        for (_, vaule) in columnHeights
        {
            if contentHeight < vaule
            {
                contentHeight = vaule
            }
        }
        
        return cell
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let supplementaryView = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        
        if elementKind == UICollectionView.elementKindSectionHeader
        {
            contentHeight += _minimumSectionSpacing_
            
            supplementaryView.frame = CGRect(x: 0, y: contentHeight, width: _headerReferenceSize_.width, height: _headerReferenceSize_.height)
            contentHeight += _headerReferenceSize_.height
            contentHeight += _sectionInset_.top
        }
        else if elementKind == UICollectionView.elementKindSectionFooter
        {
            contentHeight += _sectionInset_.bottom
            supplementaryView.frame = CGRect(x: 0, y: contentHeight, width: _footerReferenceSize_.width, height: _footerReferenceSize_.height)
            contentHeight += _footerReferenceSize_.height
        }
        return supplementaryView
    }
    
    open override var collectionViewContentSize: CGSize {
        
        return CGSize(width: collectionView!.frame.size.width, height: contentHeight)
    }
}
