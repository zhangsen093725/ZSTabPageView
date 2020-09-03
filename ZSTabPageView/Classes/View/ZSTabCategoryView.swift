//
//  ZSTabCategoryView.swift
//  Pods-ZSTabPageView_Example
//
//  Created by Josh on 2020/9/3.
//

import UIKit

@objcMembers open class ZSTabCategoryView: UIView {

    /// tabView的宽度
    public var tabViewWidth: CGFloat = 80 {
        didSet {
            layoutSubviews()
        }
    }
    
    /// spaceView的宽度
    public var spaceViewWidth: CGFloat = 0.5 {
        didSet {
            layoutSubviews()
        }
    }
    
    /// spaceView的Insets
    public var spaceViewInsets: UIEdgeInsets = .zero {
        didSet {
            layoutSubviews()
        }
    }
    
    public lazy var tabView: ZSTabView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let tabView = ZSTabView(collectionViewFlowLayout: layout)
        
        if #available(iOS 11.0, *) {
            tabView.contentInsetAdjustmentBehavior = .never
        }
        
        tabView.backgroundColor = .clear
        tabView.showsVerticalScrollIndicator = false
        
        addSubview(tabView)
        return tabView
    }()
    
    public lazy var spaceView: UIImageView = {
        
        let spaceView = UIImageView()
        
        spaceView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
        
        addSubview(spaceView)
        return spaceView
    }()
    
    public lazy var pageView: ZSPageView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let pageView = ZSPageView(frame: .zero, collectionViewLayout: layout)
        
        if #available(iOS 11.0, *) {
            pageView.contentInsetAdjustmentBehavior = .never
        }
        
        pageView.backgroundColor = .clear
        pageView.showsVerticalScrollIndicator = false
        
        addSubview(pageView)
        return pageView
    }()
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        tabView.frame = CGRect(x: 0, y: 0, width: tabViewWidth, height: bounds.height)
        spaceView.frame = CGRect(x: tabView.frame.maxX + spaceViewInsets.left - spaceViewInsets.right, y: spaceViewInsets.top, width: spaceViewWidth, height: bounds.height - spaceViewInsets.top - spaceViewInsets.bottom)
        pageView.frame = CGRect(x: tabView.frame.maxX, y: 0, width: bounds.width - spaceView.frame.maxX, height: bounds.height)
    }
}
