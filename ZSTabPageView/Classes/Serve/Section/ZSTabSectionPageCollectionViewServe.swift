//
//  ZSTabSectionPageCollectionViewServe.swift
//  ZSTabPageView
//
//  Created by Josh on 2020/12/18.
//

import UIKit

@objcMembers open class ZSTabSectionPageCollectionViewServe: ZSTabSectionPageServe, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public convenience init(selectIndex: Int = 0,
                           bind collectionView: ZSTabSectionPageCollectionView,
                           tabView: ZSTabView,
                           pageView: ZSPageView,
                           register tabCellClass: ZSTabCollectionViewCell.Type = ZSTabLabelCollectionViewCell.self) {
        
        self.init()
        
        zs_setSelectedIndex(selectIndex)
        
        zs_bind(tabView: tabView, register: tabCellClass)
        zs_bind(pageView: pageView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        zs_config(collectionView: collectionView)
        self.baseCollectionView = collectionView
    }
    
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
        
        let offset = scrollView.contentSize.height - scrollView.bounds.height
        
        if scrollView.contentOffset.y >= offset
        {
            scrollView.contentOffset = CGPoint(x: 0, y: offset)
            if isShouldBaseScroll
            {
                isShouldBaseScroll = false
                isShouldPageScroll = true
            }
            return
        }
        
        if isShouldBaseScroll == false
        {
            scrollView.contentOffset = CGPoint(x: 0, y: offset)
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
        
        guard let view = pageViewServe?.pageView else
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
            CGSize(width: collectionView.frame.width - (isSectionFloatEnable ? tabViewHeight : 0),
                   height: collectionView.frame.size.height) :
            CGSize(width: collectionView.frame.width,
                   height: collectionView.frame.size.height - (isSectionFloatEnable ? tabViewHeight : 0))
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
 
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self), for: indexPath)
        
        for subView in header.subviews
        {
            subView.removeFromSuperview()
        }
        
        guard let view = tabViewServe?.tabView else
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
            CGSize(width: tabViewHeight, height: collectionView.frame.height) :
            CGSize(width: collectionView.frame.width, height: tabViewHeight)
    }
}
