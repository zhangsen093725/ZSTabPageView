//
//  ZSTabPagePlainDemoController.swift
//  ZSViewUtil
//
//  Created by zhangsen093725 on 01/14/2020.
//  Copyright (c) 2020 zhangsen093725. All rights reserved.
//

import UIKit
import ZSTabPageView
import ZSViewUtil

class ZSTabPagePlainDemoController: UIViewController, ZSTabSectionPageServeDelegate, ZSTabSectionPageServeDataSource {
    
    public lazy var tableView: ZSTabSectionPageTableView = {
        
        let tableView = ZSTabSectionPageTableView(frame: .zero, style: .plain)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        let header = UILabel()
        header.text = "头部View"
        header.textAlignment = .center
        header.frame.size.height = 200
        
        tableView.tableHeaderView = header
        
        view.addSubview(tableView)
        return tableView
    }()
    
    lazy var contentServe: ZSTabSectionPageTableViewServe = {
        
        let contentServe = ZSTabSectionPageTableViewServe(selectIndex: -1,
                                                          bind: tableView,
                                                          tabView: tabView,
                                                          pageView: pageView)
        contentServe.delegate = self
        contentServe.dataSource = self
        contentServe.isSectionFloatEnable = true
        return contentServe
    }()
    
    open lazy var tabView: ZSTabView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let tabView = ZSTabView(collectionViewFlowLayout: layout)
        
        if #available(iOS 11.0, *) {
            tabView.contentInsetAdjustmentBehavior = .never
        }
        
        tabView.backgroundColor = .clear
        tabView.showsHorizontalScrollIndicator = false
        
        return tabView
    }()
    
    public lazy var pageView: ZSPageView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let pageView = ZSPageView(frame: .zero, collectionViewLayout: layout)
        
        if #available(iOS 11.0, *) {
            pageView.contentInsetAdjustmentBehavior = .never
        }
        
        pageView.isPagingEnabled = true
        pageView.backgroundColor = .clear
        pageView.showsHorizontalScrollIndicator = false
        
        return pageView
    }()
    
    var tabTexts: [String] = ["0", "1", "2", "3", "4", "5", "6"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .white
        
        contentServe.tabCount = self.tabTexts.count
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO: ZSPageViewServeDelegate
    func zs_pageViewWillDisappear(at index: Int) {
        
        print(index)
    }
    
    func zs_pageViewWillAppear(at index: Int) {
        
        
    }
    
    func zs_pageView(scrollView: UIScrollView, didChange index: Int) {
        
    }
    
    func zs_tabViewDidSelected(at index: Int) {
        
    }
    
    // TODO: ZSTabViewServeDataSource
    func zs_pageView(at index: Int) -> UIView {
        
        var controller: TableViewController!
        if (index < children.count)
        {
            controller = children[index] as? TableViewController
        }
        else
        {
            controller = TableViewController()
            addChild(controller)
        }
        
        controller.scrollToTop = contentServe.tabPagePlainDidScrollHandle
        controller.didMove(toParent: self)
        return controller.view
    }
    
    func zs_configTabCellSize(forItemAt index: Int) -> CGSize {
        
        return CGSize(width: 30 + index * 10, height: 44)
    }
    
    func zs_configTabCell(_ cell: ZSTabCollectionViewCell, forItemAt index: Int) {
        
        let textCell = cell as? ZSTabLabelCollectionViewCell
        
        let isSelected: Bool = (index == contentServe.selectIndex)
        
        let normalTextColor: UIColor = .systemGray
        let selectedTextColor: UIColor = .black
        
        let normalTextFont: UIFont = .systemFont(ofSize: 16)
        let selectedTextFont: UIFont = .boldSystemFont(ofSize: 16)
        
        textCell?.titleLabel.textColor = isSelected ? selectedTextColor : normalTextColor
        textCell?.titleLabel.font = isSelected ? selectedTextFont : normalTextFont
        textCell?.titleLabel.text = tabTexts[index]
    }
    
}

