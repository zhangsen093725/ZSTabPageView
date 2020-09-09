//
//  ZSFixedSpecingFlowLayout.swift
//  Kingfisher
//
//  Created by Josh on 2020/8/28.
//

import UIKit

@objc public enum ZSFixedSpecingAlignment: Int {
    
    case Left = 0, Right = 2
}

@objcMembers open class ZSFixedSpecingFlowLayout: UICollectionViewFlowLayout {
    
    private override init() {
        
        super.init()
    }
    
    private var _alignment_: ZSFixedSpecingAlignment = .Left
    
    convenience public init(with alignment: ZSFixedSpecingAlignment) {
        
        self.init()
        _alignment_ = alignment
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var scrollDirection: UICollectionView.ScrollDirection {
        
        set { }
        
        get {
           return .vertical
        }
    }
    
    /**
     * 这个方法的返回值是一个数组（数组里面存放着rect范围内所有元素的布局属性）
     * 这个方法的返回值决定了rect范围内所有元素的排布（frame）
     */
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        // 获得super已经计算好的布局的属性
        let origins = super.layoutAttributesForElements(in: rect) ?? []
        let attributes: [UICollectionViewLayoutAttributes] = origins.map({$0.copy() as! UICollectionViewLayoutAttributes})
        
        // 计算collectionView最中心点的值
        for (index, attribute) in attributes.enumerated()
        {
            if attribute.representedElementCategory != .cell { continue }
            
            let pre = index > 0 ? attributes[index - 1] : nil
            
            switch _alignment_
            {
            case .Left:
                if pre?.frame.minY == attribute.frame.minY
                {
                    attribute.frame.origin.x = pre!.frame.maxX + minimumLineSpacing
                }
                else
                {
                    attribute.frame.origin.x = sectionInset.left
                }
                break
            case .Right:
                
                if pre?.frame.minY == attribute.frame.minY
                {
                    attribute.frame.origin.x = pre!.frame.minX - attribute.frame.size.width - minimumLineSpacing
                }
                else
                {
                    attribute.frame.origin.x = collectionView!.frame.maxX - attribute.frame.size.width - sectionInset.right
                }
                break
            }
        }
        
        return attributes
    }
    
    /**
     * 当collectionView的显示范围发生改变的时候，是否需要重新刷新布局
     * 一旦重新刷新布局，就会重新调用下面的方法：
     * 1.prepareLayout
     * 2.layoutAttributesForElementsInRect:方法
     */
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
