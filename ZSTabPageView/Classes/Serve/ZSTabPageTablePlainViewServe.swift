//
//  ZSTabContentViewServe.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/14.
//

import UIKit

@objcMembers open class ZSTabPageTablePlainViewServe: NSObject, UITableViewDelegate, UITableViewDataSource, ZSTabViewServeDelegate, ZSPageViewScrollDelegate {
    
    public weak var tableView: UITableView?
    
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
    public var tabViewHeight: CGFloat = 44 {
        didSet {
            tableView?.reloadData()
        }
    }
    
    /// section是否开启悬浮
    public var isSectionFloatEnable: Bool = true
    
    /// base view 是否可以滚动
    private var isShouldBaseScroll: Bool = true
    
    /// tab page 是否可以滚动
    private var isShouldPageScroll: Bool = false
    
    public var tabCount: Int = 0 {
        didSet {
            _selectIndex_ = selectIndex < tabCount ? selectIndex : tabCount - 1
            tabViewServe.tabCount = tabCount
            pageViewServe.tabCount = tabCount
            tableView?.reloadData()
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
@objc extension ZSTabPageTablePlainViewServe {
    
    open func zs_bindTableView(_ tableView: UITableView,
                               tabView: ZSTabView,
                               pageView: ZSPageView,
                               tabCellClass: ZSTabCell.Type = ZSTabTextCell.self) {
        
        zs_configTableView(tableView)
        zs_configTabViewServe(tabView, tabCellClass: tabCellClass)
        zs_configPageServe(pageView)
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
    }
    
    open func zs_configTableView(_ tableView: UITableView) {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
    }
    
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
@objc extension ZSTabPageTablePlainViewServe {
    
    // TODO: ZSPageViewScrollDelegate
    open func zs_pageViewDidScroll(_ scrollView: UIScrollView, page: Int) {
        
        if selectIndex != page && page < tabCount
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



/**
 * 1. UITableView 的代理
 * 2. 可根据需求进行重写
 */
@objc extension ZSTabPageTablePlainViewServe {
    
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
    
    // TODO: UITableViewDataSource
    open func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        
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
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableView.frame.size.height
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let view = tabViewServe.collectionView else { return nil }
        return view
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return tabViewHeight
    }
}

