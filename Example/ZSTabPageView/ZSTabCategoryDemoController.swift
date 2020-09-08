//
//  ZSTabCategoryDemoController.swift
//  ZSTabPageView_Example
//
//  Created by Josh on 2020/9/3.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ZSTabPageView

class ZSTabCategoryDemoController: UIViewController, ZSPageViewServeDelegate, ZSTabViewServeDataSource {

    lazy var tabPageView: ZSTabCategoryView = {
        
        let tabPageView = ZSTabCategoryView()
        tabPageView.tabView.sliderLength = 20
        tabPageView.tabView.isSliderHidden = false
        view.addSubview(tabPageView)
        return tabPageView
    }()
    
    lazy var tabPageServe: ZSTabCategoryViewServe = {
        
        let tabPageServe = ZSTabCategoryViewServe(selectIndex: 0)
        tabPageServe.delegate = self
        tabPageServe.dataSource = self
        tabPageServe.tabViewServe.minimumSpacing = 18
        return tabPageServe
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        tabPageServe.zs_bindTabView(tabPageView)
        tabPageServe.tabCount = tabTexts.count
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tabPageView.frame = view.bounds
    }
    
    var tabTexts: [String] = ["0", "1", "2", "3", "4", "5", "6"]

    // TODO: ZSPageViewServeDelegate
    func zs_pageView(at index: Int) -> UIView {
        
        var controller: UIViewController!
        if (index < children.count)
        {
            controller = children[index]
        }
        else
        {
            controller = TableViewController()
           addChild(controller)
        }
        controller.didMove(toParent: self)
        return controller.view
    }
    
    func zs_pageViewWillDisappear(at index: Int) {
        
        print(index)
    }
    
    func zs_pageViewWillAppear(at index: Int) {
        
        
    }
    
    // TODO: ZSTabViewServeDataSource
    func zs_configTabCellSize(forItemAt index: Int) -> CGSize {
        
        return CGSize(width: 30, height: 64 + index * 10)
    }
    
    func zs_configTabCell(_ cell: ZSTabCell, forItemAt index: Int) {
        
        let textCell = cell as? ZSTabTextCell
        
        let isSelected: Bool = (index == tabPageServe.selectIndex)
        
        let normalTextColor: UIColor = .systemGray
        let selectedTextColor: UIColor = .black
        
        let normalTextFont: UIFont = .systemFont(ofSize: 16)
        let selectedTextFont: UIFont = .boldSystemFont(ofSize: 16)
        
        textCell?.titleLabel.textColor = isSelected ? selectedTextColor : normalTextColor
        textCell?.titleLabel.font = isSelected ? selectedTextFont : normalTextFont
        textCell?.titleLabel.text = tabTexts[index]
    }

}
