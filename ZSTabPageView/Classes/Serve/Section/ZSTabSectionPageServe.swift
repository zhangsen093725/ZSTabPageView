//
//  ZSTabSectionPageServe.swift
//  ZSTabPageView
//
//  Created by Josh on 2020/12/18.
//

import UIKit

public typealias ZSTabPagePlainDidScrollHandle = (_ scrollView: UIScrollView, _ currentOffset: CGPoint) -> CGPoint

@objcMembers open class ZSTabSectionPageServe: NSObject, ZSTabViewServeDelegate, ZSPageViewScrollDelegate {
    

    public var tabViewServe: ZSTabViewServe?
    
    public var pageViewServe: ZSPageViewServe?
    
    public weak var delegate: ZSPageViewServeDelegate? {
        didSet {
            pageViewServe?.delegate = delegate
        }
    }
    
    public weak var dataSource: ZSTabViewServeDataSource? {
        didSet {
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
    var isShouldBaseScroll: Bool = true
    
    /// tab page 是否可以滚动
    var isShouldPageScroll: Bool = false
    
    public var tabCount: Int = 0 {
        
        didSet {
            _selectIndex_ = selectIndex < tabCount ? selectIndex : tabCount - 1
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
        pageViewServe?.scrollDelegate = self
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
    
    // TODO: ZSTabViewServeDelegate
    open func zs_tabViewDidSelected(at index: Int) {
        zs_setSelectedIndex(index)
    }
}
