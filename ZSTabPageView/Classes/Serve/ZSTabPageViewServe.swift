//
//  ZSTabPageViewServe.swift
//  ZSTabPageView
//
//  Created by 张森 on 2020/1/13.
//  Copyright © 2020 张森. All rights reserved.
//

import UIKit

@objcMembers open class ZSTabPageViewServe: NSObject, ZSTabViewServeDelegate, ZSPageViewScrollDelegate {
    
    private override init() {
        super.init()
    }
    
    public convenience init(selectIndex: Int = 0,
                            bind tabPageView: ZSTabPageView,
                            register tabCellClass: ZSTabCollectionViewCell.Type = ZSTabLabelCollectionViewCell.self) {
        self.init()
        _selectIndex_ = selectIndex
        
        zs_configTabViewServe(tabPageView, tabCellClass: tabCellClass)
        zs_configPageViewServe(tabPageView)
        
        self.tabPageView = tabPageView
    }
    
    /// tab view item 样式Serve
    public var tabViewServe: ZSTabViewServe!
    
    /// page view item 样式 Serve
    public var pageViewServe: ZSPageViewServe!
    
    public weak var tabPageView: ZSTabPageView?
    
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
        
        didSet
        {
            _selectIndex_ = selectIndex < tabCount ? selectIndex : tabCount - 1
            tabViewServe.tabCount = tabCount
            pageViewServe.pageCount = tabCount
        }
    }
    
    
    /// 当前选择的 tab 索引
    public var selectIndex: Int { return _selectIndex_ }
    /// 当前选中的 TabPage 索引
    private var _selectIndex_: Int = 0
}



/**
 * 1. ZSTabPageViewServe 提供外部重写的方法
 * 2. 需要自定义Serve，可重新以下的方法达到目的
 */
@objc extension ZSTabPageViewServe {
    
    open func zs_setSelectedIndex(_ index: Int) {
        
        _selectIndex_ = index
        tabViewServe.zs_setSelectedIndex(selectIndex)
        pageViewServe.zs_setSelectedIndex(selectIndex)
    }
    
    open func zs_configTabViewServe(_ tabPageView: ZSTabPageView,
                                    tabCellClass: ZSTabCollectionViewCell.Type) {
        
        tabViewServe = ZSTabViewServe(selectIndex: selectIndex,
                                      bind: tabPageView.tabView,
                                      register: tabCellClass)
        tabViewServe.delegate = self
    }
    
    open func zs_configPageViewServe(_ tabPageView: ZSTabPageView) {
        
        pageViewServe = ZSPageViewServe(selectIndex: selectIndex,
                                        bind: tabPageView.pageView)
        pageViewServe.scrollDelegate = self
    }
}


/**
 * 1. ZSPageViewScrollDelegate 的代理
 * 2. 可根据需求进行重写
 */
@objc extension ZSTabPageViewServe {
    
    // TODO: ZSPageViewScrollDelegate
    open func zs_pageView(scrollView: UIScrollView, didChange index: Int) {
        
        if index < tabCount
        {
            zs_setSelectedIndex(index)
        }
    }
    
    // TODO: ZSTabViewServeDelegate
    open func zs_tabViewDidSelected(at index: Int) {
        
        zs_setSelectedIndex(index)
    }
}
