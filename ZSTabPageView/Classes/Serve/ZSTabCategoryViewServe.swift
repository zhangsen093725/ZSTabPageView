//
//  ZSTabCategoryViewServe.swift
//  Pods-ZSTabPageView_Example
//
//  Created by Josh on 2020/9/3.
//

import UIKit

@objcMembers open class ZSTabCategoryViewServe: NSObject, ZSTabViewServeDelegate, ZSPageViewScrollDelegate {
    
    /// tab view item 样式Serve
    public var tabViewServe: ZSTabViewServe!
    
    /// page view item 样式 Serve
    public var pageViewServe: ZSPageViewServe!
    
    public weak var tabCategoryView: ZSTabCategoryView?
    
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
    
    public var tabCount: Int = 0 {
        didSet {
            tabViewServe.tabCount = tabCount
            pageViewServe.tabCount = tabCount
        }
    }
    
    /// 当前选中的 TabPage 索引
    private var _selectIndex_: Int = 0
    
    private override init() {
        super.init()
    }
    
    public convenience init(selectIndex: Int) {
        self.init()
        _selectIndex_ = selectIndex
        tabViewServe = ZSTabViewServe(selectIndex: selectIndex)
        pageViewServe = ZSPageViewServe(selectIndex: selectIndex)
    }
    
    /// 当前选择的 tab 索引
    public var selectIndex: Int { return _selectIndex_ }
    
    open func zs_setSelectedIndex(_ index: Int) {
        _selectIndex_ = index
        tabViewServe.zs_setSelectedIndex(selectIndex)
        pageViewServe.zs_setSelectedIndex(selectIndex)
    }
}



/**
 * 1. ZSTabCategoryViewServe 提供外部重写的方法
 * 2. 需要自定义Serve，可重新以下的方法达到目的
 */
@objc extension ZSTabCategoryViewServe {
    
    open func zs_bindTabView(_ tabCategoryView: ZSTabCategoryView,
                             tabCellClass: ZSTabCell.Type = ZSTabTextCell.self) {
        self.tabCategoryView = tabCategoryView
        zs_configTabViewServe(tabCategoryView, tabCellClass: tabCellClass)
        zs_configPageViewServe(tabCategoryView)
    }
    
    open func zs_configTabViewServe(_ tabCategoryView: ZSTabCategoryView,
                                    tabCellClass: ZSTabCell.Type) {
        tabViewServe.zs_bind(collectionView: tabCategoryView.tabView, register: tabCellClass)
        tabViewServe.delegate = self
    }
    
    open func zs_configPageViewServe(_ tabCategoryView: ZSTabCategoryView) {
        pageViewServe.zs_bindView(tabCategoryView.pageView)
        pageViewServe.scrollDelegate = self
    }
}


/**
 * 1. ZSTabCategoryViewServe 的代理
 * 2. 可根据需求进行重写
 */
@objc extension ZSTabCategoryViewServe {
    
    // TODO: ZSPageViewScrollDelegate
    open func zs_pageViewDidScroll(_ scrollView: UIScrollView, page: Int) {
        
        if selectIndex != page && page < tabCount {
            zs_setSelectedIndex(page)
        }
    }
    
    open func zs_pageViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    open func zs_pageViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    // TODO: ZSTabViewServeDelegate
    open func zs_tabViewDidSelected(at index: Int) {
        zs_setSelectedIndex(index)
    }
}
