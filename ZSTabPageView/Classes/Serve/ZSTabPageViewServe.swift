//
//  ZSTabPageViewServe.swift
//  ZSTabPageView
//
//  Created by 张森 on 2020/1/13.
//  Copyright © 2020 张森. All rights reserved.
//

import UIKit

@objc public protocol ZSTabPageViewServeDelegate : ZSTabViewServeDelegate, ZSPageViewServeDelegate {
    
}

@objc public protocol ZSTabPageViewServeDataSource : ZSTabViewServeDataSource, ZSPageViewServeDataSource {
    
}

@objcMembers open class ZSTabPageViewServe: NSObject, ZSTabViewServeDelegate, ZSPageViewServeDelegate {
    
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
    
    public weak var delegate: ZSTabPageViewServeDelegate?
    public weak var dataSource: ZSTabPageViewServeDataSource? {
        
        didSet {
            pageViewServe.dataSource = dataSource
            tabViewServe.dataSource = dataSource
        }
    }
    
    public var tabCount: Int = 0 {
        
        didSet
        {
            if tabCount > 0
            {
                _selectIndex_ = selectIndex < tabCount ? selectIndex : tabCount - 1
            }
            else
            {
                _selectIndex_ = 0
            }
            
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
    
    open func zs_setSelectedIndex(_ index: Int, tabAnimation: Bool = true, pageAnimation: Bool = false) {
        
        _selectIndex_ = index
        tabViewServe.zs_setSelectedIndex(selectIndex, animation: tabAnimation)
        pageViewServe.zs_setSelectedIndex(selectIndex, animation: pageAnimation)
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
        pageViewServe.delegate = self
    }
}


/**
 * 1. ZSPageViewServeDelegate 的代理
 * 2. 可根据需求进行重写
 */
@objc extension ZSTabPageViewServe {
    
    // TODO: ZSPageViewServeDelegate
    open func zs_pageView(scrollView: UIScrollView, didChange index: Int) {
        
        if index < tabCount
        {
            zs_setSelectedIndex(index)
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
@objc extension ZSTabPageViewServe {
    
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
