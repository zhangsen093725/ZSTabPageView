//
//  ZSTabSectionPageCollectionViewServe.swift
//  ZSTabPageView
//
//  Created by Josh on 2020/12/18.
//

import UIKit

@objcMembers open class ZSTabSectionPageCollectionViewServe: ZSTabSectionPageServe, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public weak var baseCollectionView: ZSTabSectionPageCollectionView?
    
    /// tabView的高度
    public override var tabViewHeight: CGFloat {
        didSet {
            baseCollectionView?.reloadData()
        }
    }

    public override var tabCount: Int {
        didSet {
            super.tabCount = tabCount
            baseCollectionView?.reloadData()
        }
    }
    
    public override var isSectionFloatEnable: Bool {
        
        didSet {
            if #available(iOS 9.0, *) {
                (baseCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionHeadersPinToVisibleBounds = isSectionFloatEnable
            } else {
                // Fallback on earlier versions
            }
        }
    }
}


/**
 * 1. ZSTabSectionViewServe 提供外部重写的方法
 * 2. 需要自定义TabContentView的样式，可重新以下的方法达到目的
 */
@objc extension ZSTabSectionPageCollectionViewServe {
    
    open func zs_bind(collectionView: ZSTabSectionPageCollectionView,
                               tabView: ZSTabView,
                               pageView: ZSPageView,
                               tabCellClass: ZSTabCell.Type = ZSTabTextCell.self) {
        
        zs_config(collectionView:collectionView)
        zs_configTabViewServe(tabView, tabCellClass: tabCellClass)
        zs_configPageServe(pageView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        self.baseCollectionView = collectionView
    }
    
    open func zs_config(collectionView: ZSTabSectionPageCollectionView) {
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(UICollectionViewCell.self))
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self))
    }
}



/**
 * 1. UITableView 的代理
 * 2. 可根据需求进行重写
 */
@objc extension ZSTabSectionPageCollectionViewServe {
    
    // UIScrollViewDelegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView.contentSize != .zero else { return }
        
        let bottomOffset = scrollView.contentSize.height - scrollView.bounds.height
        
        if isSectionFloatEnable == false
        {
            if scrollView.contentOffset.y <= bottomOffset - tabViewHeight && scrollView.contentOffset.y >= 0
            {
                scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
            }
            else if scrollView.contentOffset.y >= bottomOffset - tabViewHeight
            {
                scrollView.contentInset = UIEdgeInsets(top: -(bottomOffset - tabViewHeight), left: 0, bottom: 0, right: 0);
            }
        }
        
        if scrollView.contentOffset.y >= bottomOffset
        {
            scrollView.contentOffset = CGPoint(x: 0, y: bottomOffset)
            if isShouldBaseScroll
            {
                isShouldBaseScroll = false
                isShouldPageScroll = true
            }
            return
        }
        
        if isShouldBaseScroll == false
        {
            scrollView.contentOffset = CGPoint(x: 0, y: bottomOffset)
            return
        }
    }
    
    // TODO: UICollectionViewDataSource
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(UICollectionViewCell.self), for: indexPath)
        
        cell.isExclusiveTouch = true
        
        for subView in cell.contentView.subviews
        {
            subView.removeFromSuperview()
        }
        
        guard let view = pageViewServe.collectionView else
        {
            return cell
        }
        
        cell.contentView.addSubview(view)
        view.frame = cell.contentView.bounds
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
   
        return (flowLayout!.scrollDirection == .horizontal) ?
            CGSize(width: collectionView.frame.width - tabViewHeight, height: collectionView.frame.size.height) :
            CGSize(width: collectionView.frame.width, height: collectionView.frame.size.height - tabViewHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
 
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self), for: indexPath)
        
        for subView in header.subviews
        {
            subView.removeFromSuperview()
        }
        
        guard let view = tabViewServe.collectionView else
        {
            return header
        }
        
        header.addSubview(view)
        view.frame = header.bounds
        
        return header
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
   
        return (flowLayout!.scrollDirection == .horizontal) ?
            CGSize(width: tabViewHeight, height: collectionView.frame.size.height) :
            CGSize(width: collectionView.frame.width, height: tabViewHeight)
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return tabViewHeight
    }
}
