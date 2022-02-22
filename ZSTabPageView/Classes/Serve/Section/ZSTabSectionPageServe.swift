//
//  ZSTabSectionPageServe.swift
//  ZSTabPageView
//
//  Created by Josh on 2020/12/18.
//

import UIKit

public typealias ZSTabPagePlainDidScrollHandle = (_ scrollView: UIScrollView, _ currentOffset: CGPoint) -> CGPoint

@objc public protocol ZSTabSectionPageServeDelegate : ZSTabViewServeDelegate, ZSPageViewServeDelegate {
    
}

@objc public protocol ZSTabSectionPageServeDataSource : ZSTabViewServeDataSource, ZSPageViewServeDataSource {
    
}


@objcMembers open class ZSTabSectionPageServe: NSObject, ZSTabViewServeDelegate, ZSPageViewServeDelegate {
    
    public var tabViewServe: ZSTabViewServe?
    
    public var pageViewServe: ZSPageViewServe?
    
    public weak var delegate: ZSTabSectionPageServeDelegate?
    
    public weak var dataSource: ZSTabSectionPageServeDataSource? {
        
        didSet {
            pageViewServe?.dataSource = dataSource
            tabViewServe?.dataSource = dataSource
        }
    }
    
    var _selectIndex_: Int = 0
    public var selectIndex: Int { return _selectIndex_ }
    
    /// tabView的高度
    public var tabViewHeight: CGFloat = 44
    
    /// section是否开启悬浮
    public var isSectionFloatEnable: Bool = true
    
    open var tabPagePlainDidScrollHandle: ZSTabPagePlainDidScrollHandle {
        
        return { [weak self] (scrollView, cacheContentOffset) in
            
            if self?.isShouldPageScroll == false
            {
                scrollView.contentOffset = cacheContentOffset
                return cacheContentOffset
            }
            
            if scrollView.contentOffset.y <= 0
            {
                self?.isShouldBaseScroll = true
                self?.isShouldPageScroll = false
                scrollView.contentOffset = .zero
                return .zero
            }
            
            return scrollView.contentOffset
        }
    }
    
    /// base view 是否可以滚动
    public var isShouldBaseScroll: Bool = true
    
    /// tab page 是否可以滚动
    public var isShouldPageScroll: Bool = false
    
    public var isScrollDirectionVertical: Bool = false
    public var isScrollDirectionHorizontal: Bool = false
    
    public var tabCount: Int = 0 {
        
        didSet {
            
            if tabCount > 0
            {
                _selectIndex_ = selectIndex < tabCount ? selectIndex : tabCount - 1
            }
            else
            {
                _selectIndex_ = 0
            }
            
            tabViewServe?.tabCount = tabCount
            pageViewServe?.pageCount = tabCount
        }
    }
    
    override init() {
        super.init()
    }
    
    open func zs_setSelectedIndex(_ index: Int) {
        
        _selectIndex_ = index
        
        tabViewServe?.zs_setSelectedIndex(selectIndex)
        pageViewServe?.zs_setSelectedIndex(selectIndex)
    }
}


/**
 * 1. ZSTabSectionViewServe 提供外部重写的方法
 * 2. 需要自定义TabContentView的样式，可重新以下的方法达到目的
 */
@objc extension ZSTabSectionPageServe {
    
    open func zs_bind(tabView: ZSTabView, register tabCellClass: ZSTabCollectionViewCell.Type) {
        
        tabViewServe = ZSTabViewServe(selectIndex: selectIndex,
                                      bind: tabView,
                                      register: tabCellClass)
        tabViewServe?.delegate = self
    }
    
    open func zs_bind(pageView: ZSPageView) {
        
        pageViewServe = ZSPageViewServe(selectIndex: selectIndex,
                                        bind: pageView)
        pageViewServe?.delegate = self
    }
}



/**
 * 1. ZSPageViewScrollDelegate 和 ZSTabViewServeDelegate
 * 2. 可根据需求进行重写
 */
@objc extension ZSTabSectionPageServe {
    
    // TODO: ZSPageViewScrollDelegate
    open func zs_pageView(scrollView: UIScrollView, didChange index: Int) {
        
        if index < tabCount
        {
            zs_setSelectedIndex(index)
        }
        
        guard scrollView.contentSize != .zero else { return }
        
        if scrollView.contentOffset.x >= 0
        {
            isShouldPageScroll = !isShouldBaseScroll
            return
        }
    }
    
    open func zs_pageViewWillAppear(at index: Int) {
        
        delegate?.zs_pageViewWillAppear?(at: index)
    }
    
    open func zs_pageViewWillDisappear(at index: Int) {
        
        delegate?.zs_pageViewWillDisappear?(at: index)
    }
    
    // TODO: ZSTabViewServeDelegate
    open func zs_tabViewDidSelected(at index: Int) {
        
        zs_setSelectedIndex(index)
        delegate?.zs_tabViewDidSelected?(at: index)
    }
}




/**
 * 1. UIScrollViewDelegate
 * 2. 可根据需求进行重写
 */
@objc extension ZSTabSectionPageServe {
    
    // TODO: UIScrollViewDelegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        delegate?.scrollViewDidScroll?(scrollView)
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    
        delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}
