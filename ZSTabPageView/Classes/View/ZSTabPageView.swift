//
//  ZSTabPageView.swift
//  JadeToB
//
//  Created by 张森 on 2020/1/13.
//  Copyright © 2020 张森. All rights reserved.
//

import UIKit

@objcMembers open class ZSTabPageView: UIView {
    
    /// tabView的高度
    public var tabViewHeight: CGFloat = 44 {
        didSet {
            layoutSubviews()
        }
    }
    
    /// spaceView的高度
    public var spaceViewHeight: CGFloat = 0 {
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
        layout.scrollDirection = .horizontal
        
        let tabView = ZSTabView(collectionViewFlowLayout: layout)
        
        if #available(iOS 11.0, *) {
            tabView.contentInsetAdjustmentBehavior = .never
        }
        
        tabView.sliderVerticalAlignment = .Bottom
        tabView.sliderHorizontalAlignment = .Center
        tabView.backgroundColor = .clear
        tabView.showsHorizontalScrollIndicator = false
        
        addSubview(tabView)
        return tabView
    }()
    
    public lazy var spaceView: UIImageView = {
        
        let spaceView = UIImageView()
        
        spaceView.backgroundColor = .systemGray
        
        addSubview(spaceView)
        return spaceView
    }()
    
    public lazy var pageView: ZSPageView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let pageView = ZSPageView(frame: .zero, collectionViewLayout: layout)
        
        if #available(iOS 11.0, *) {
            pageView.contentInsetAdjustmentBehavior = .never
        }
        
        pageView.backgroundColor = .clear
        pageView.showsHorizontalScrollIndicator = false
        
        addSubview(pageView)
        return pageView
    }()
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        tabView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: tabViewHeight)
        spaceView.frame = CGRect(x: spaceViewInsets.left, y: tabView.frame.maxY + spaceViewInsets.top - spaceViewInsets.bottom, width: bounds.width - spaceViewInsets.left - spaceViewInsets.right, height: spaceViewHeight)
        pageView.frame = CGRect(x: 0, y: tabView.frame.maxY, width: bounds.width, height: bounds.height - tabView.frame.maxY)
    }
}
