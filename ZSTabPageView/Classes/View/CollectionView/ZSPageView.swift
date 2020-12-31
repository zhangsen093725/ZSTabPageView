//
//  ZSPageView.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/14.
//

import UIKit

@objcMembers open class ZSPageView: UICollectionView {
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        
        super.init(frame: frame, collectionViewLayout: layout)
        isPagingEnabled = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var isPagingEnabled: Bool {
        set {
            super.isPagingEnabled = true
        }
        get {
            return true
        }
    }
    
    // TODO: 动画处理
    open func zs_setSelectedIndex(_ index: Int,
                                  isAnimation: Bool) {
        reloadData()
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        
        if flowLayout?.scrollDirection == .horizontal
        {
            scrollToItem(at: IndexPath(item: index, section: 0), at: .right, animated: isAnimation)
        }
        else
        {
            scrollToItem(at: IndexPath(item: index, section: 0), at: .bottom, animated: isAnimation)
        }
    }
}
