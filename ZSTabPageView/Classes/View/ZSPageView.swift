//
//  ZSPageView.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/14.
//

import UIKit

@objcMembers open class ZSPageView: UICollectionView {
    
    open override var isPagingEnabled: Bool {
        set {
            super.isPagingEnabled = true
        }
        get {
            return true
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        isPagingEnabled = true
    }
    
    // TODO: 动画处理
    open func beginScrollToIndex(_ index: Int,
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
