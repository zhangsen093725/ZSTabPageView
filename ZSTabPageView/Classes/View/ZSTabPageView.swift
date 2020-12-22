//
//  ZSTabPageView.swift
//  ZSTabPageView
//
//  Created by 张森 on 2020/1/13.
//  Copyright © 2020 张森. All rights reserved.
//

import UIKit

@objcMembers open class ZSTabPageView: UIView {
    
    /// 当 scrollDirection = horizontal 时， tabViewHeight 表示 tabView 的高度
    /// 当 scrollDirection = vertical 时， tabViewHeight 表示 tabView 的宽度
    public var tabViewHeight: CGFloat = 44 {
        didSet {
            layoutSubviews()
        }
    }
    
    /// 当 scrollDirection = horizontal 时， spaceViewHeight 表示 spaceView 的高度
    /// 当 scrollDirection = vertical 时， spaceViewHeight 表示 spaceView 的宽度
    public var spaceViewHeight: CGFloat = 0.5 {
        didSet {
            layoutSubviews()
        }
    }
    
    /// spaceView 的 Insets
    public var spaceViewInsets: UIEdgeInsets = .zero {
        didSet {
            layoutSubviews()
        }
    }
    
    private var _scrollDirection_: UICollectionView.ScrollDirection = .horizontal
    public var scrollDirection: UICollectionView.ScrollDirection {
        
        return _scrollDirection_
    }
    
    public lazy var tabView: ZSTabView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        
        let tabView = ZSTabView(collectionViewFlowLayout: layout)
        
        if #available(iOS 11.0, *)
        {
            tabView.contentInsetAdjustmentBehavior = .never
        }
        
        tabView.backgroundColor = .clear
        
        if scrollDirection == .horizontal
        {
            tabView.sliderVerticalAlignment = .bottom
            tabView.sliderHorizontalAlignment = .center
            tabView.showsHorizontalScrollIndicator = false
        }
        else
        {
            tabView.sliderVerticalAlignment = .center
            tabView.sliderHorizontalAlignment = .left
            tabView.showsVerticalScrollIndicator = false
        }
        
        insertSubview(tabView, at: 0)
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
        layout.scrollDirection = scrollDirection
        
        let pageView = ZSPageView(frame: .zero, collectionViewLayout: layout)
        
        if #available(iOS 11.0, *)
        {
            pageView.contentInsetAdjustmentBehavior = .never
        }
        
        pageView.backgroundColor = .clear
        
        if scrollDirection == .horizontal
        {
            pageView.isScrollEnabled = true
            pageView.showsHorizontalScrollIndicator = false
        }
        else
        {
            pageView.isScrollEnabled = false
            pageView.showsVerticalScrollIndicator = false
        }
        
        insertSubview(pageView, at: 0)
        return pageView
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public convenience init(scrollDirection: UICollectionView.ScrollDirection = .horizontal) {
        self.init()
        _scrollDirection_ = scrollDirection
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if scrollDirection == .horizontal
        {
            tabView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: tabViewHeight)
            spaceView.frame = CGRect(x: spaceViewInsets.left, y: tabView.frame.maxY + spaceViewInsets.top - spaceViewInsets.bottom, width: bounds.width - spaceViewInsets.left - spaceViewInsets.right, height: spaceViewHeight)
            pageView.frame = CGRect(x: 0, y: tabView.frame.maxY, width: bounds.width, height: bounds.height - tabView.frame.maxY)
        }
        else
        {
            tabView.frame = CGRect(x: 0, y: 0, width: tabViewHeight, height: bounds.height)
            spaceView.frame = CGRect(x: tabView.frame.maxX + spaceViewInsets.left - spaceViewInsets.right, y: spaceViewInsets.top, width: spaceViewHeight, height: bounds.height - spaceViewInsets.top - spaceViewInsets.bottom)
            pageView.frame = CGRect(x: tabView.frame.maxX, y: 0, width: bounds.width - spaceView.frame.maxX, height: bounds.height)
        }
    }
}
