//
//  ZSTabSectionPageTableViewServe.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/14.
//

import UIKit

@objcMembers open class ZSTabSectionPageTableViewServe: ZSTabSectionPageServe, UITableViewDelegate, UITableViewDataSource {
    
    public weak var baseTableView: ZSTabSectionPageTableView?
    
    /// tabView的高度
    public override var tabViewHeight: CGFloat {
        didSet {
            baseTableView?.reloadData()
        }
    }

    public override var tabCount: Int {
        didSet {
            super.tabCount = tabCount
            baseTableView?.reloadData()
        }
    }
}



/**
 * 1. ZSTabSectionViewServe 提供外部重写的方法
 * 2. 需要自定义TabContentView的样式，可重新以下的方法达到目的
 */
@objc extension ZSTabSectionPageTableViewServe {
    
    open func zs_bind(tableView: ZSTabSectionPageTableView,
                               tabView: ZSTabView,
                               pageView: ZSPageView,
                               tabCellClass: ZSTabCell.Type = ZSTabTextCell.self) {
        
        zs_config(tableView: tableView)
        zs_configTabViewServe(tabView, tabCellClass: tabCellClass)
        zs_configPageServe(pageView)
        
        tableView.delegate = self
        tableView.dataSource = self
        self.baseTableView = tableView
    }
    
    open func zs_config(tableView: UITableView) {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
    }
}



/**
 * 1. UITableView 的代理
 * 2. 可根据需求进行重写
 */
@objc extension ZSTabSectionPageTableViewServe {
    
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
        
        return tableView.frame.size.height - tabViewHeight
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let view = tabViewServe.collectionView else { return nil }
        return view
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return tabViewHeight
    }
}

