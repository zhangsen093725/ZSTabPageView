//
//  ZSTabSectionPageServe.swift
//  ZSTabPageView
//
//  Created by Josh on 2020/12/18.
//

import UIKit

@objcMembers open class ZSTabSectionPageServe: NSObject, ZSTabViewServeDelegate, ZSPageViewScrollDelegate {
    
    public var tabViewServe: ZSTabViewServe!
    
    public var pageViewServe: ZSPageViewServe!
    
    public weak var delegate: ZSPageViewServeDelegate? {
        didSet {
            pageViewServe.delegate = delegate
        }
    }
    
    public weak var dataSource: ZSTabViewServeDataSource? {
        didSet {
            tabViewServe.dataSource = dataSource
        }
    }
    
    /// tabView的高度
    public var tabViewHeight: CGFloat = 44
    
    /// section是否开启悬浮
    public var isSectionFloatEnable: Bool = true
    
    /// base view 是否可以滚动
    var isShouldBaseScroll: Bool = true
    
    /// tab page 是否可以滚动
    var isShouldPageScroll: Bool = false
    
    public var tabCount: Int = 0 {
        didSet {
            _selectIndex_ = selectIndex < tabCount ? selectIndex : tabCount - 1
            tabViewServe.tabCount = tabCount
            pageViewServe.tabCount = tabCount
        }
    }
    
    var _selectIndex_: Int = 0
    
    public var selectIndex: Int { return _selectIndex_ }
    
    private override init() {
        super.init()
    }
    
    public convenience init(selectIndex: Int = 0) {
        self.init()
        _selectIndex_ = selectIndex
        zs_initServe(selectIndex: selectIndex)
    }
    
    open func zs_initServe(selectIndex: Int = 0) {
        tabViewServe = ZSTabViewServe(selectIndex: selectIndex)
        pageViewServe = ZSPageViewServe(selectIndex: selectIndex)
    }
    
    open func zs_setSelectedIndex(_ index: Int) {
        _selectIndex_ = index
        tabViewServe.zs_setSelectedIndex(selectIndex)
        pageViewServe.zs_setSelectedIndex(selectIndex)
    }
}


/**
 * 1. ZSTabSectionViewServe 提供外部重写的方法
 * 2. 需要自定义TabContentView的样式，可重新以下的方法达到目的
 */
@objc extension ZSTabSectionPageServe {
    
    open func zs_configTabViewServe(_ tabView: ZSTabView, tabCellClass: ZSTabCell.Type) {
        
        tabViewServe.zs_bind(collectionView: tabView, register: tabCellClass)
        tabViewServe.delegate = self
    }
    
    open func zs_configPageServe(_ pageView: ZSPageView) {
        
        pageViewServe.zs_bindView(pageView)
        pageViewServe.scrollDelegate = self
    }
    
    open func zs_tabPagePlainContentScrollViewDidScroll() -> (_ scrollView: UIScrollView, _ currentOffset: CGPoint) -> CGPoint {
        
        return { [weak self] (scrollView, currentOffset) in
            
            if self?.isShouldPageScroll == false
            {
                scrollView.contentOffset = currentOffset
                return currentOffset
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
}



/**
 * 1. ZSPageViewScrollDelegate 和 ZSTabViewServeDelegate
 * 2. 可根据需求进行重写
 */
@objc extension ZSTabSectionPageServe {
    
    // TODO: ZSPageViewScrollDelegate
    open func zs_pageView(scrollView: UIScrollView, didChange page: Int) {
        
        if page < tabCount
        {
            zs_setSelectedIndex(page)
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
