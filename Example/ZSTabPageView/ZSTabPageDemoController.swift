//
//  ZSTabPageDemoController.swift
//  ZSTabPageView_Example
//
//  Created by Josh on 2020/7/2.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ZSTabPageView

class ZSTabPageDemoController: UIViewController, ZSPageViewServeDelegate, ZSTabViewServeDataSource {

    lazy var tabPageView: ZSTabPageView = {
        
        let tabPageView = ZSTabPageView()
        tabPageView.tabView.sliderView.image = UIImage(named: "ic_tab_selected")
        tabPageView.tabView.sliderView.backgroundColor = .clear
        tabPageView.tabView.sliderLength = 24
        tabPageView.tabView.sliderWidth = 14
        tabPageView.tabView.sliderVerticalAlignment = .Bottom
        tabPageView.tabView.sliderHorizontalAlignment = .Right
        tabPageView.tabView.sliderInset = UIEdgeInsets(top: 0, left: 0, bottom: -4, right: -8);
        tabPageView.tabView.isSliderHidden = false
        view.addSubview(tabPageView)
        return tabPageView
    }()
    
    lazy var tabPageServe: ZSTabPageViewServe = {
        
        let tabPageServe = ZSTabPageViewServe(selectIndex: 0)
        tabPageServe.delegate = self
        tabPageServe.dataSource = self
        tabPageServe.tabViewServe.tabViewInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
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
        
        return CGSize(width: 30 + index * 10, height: 20)
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
