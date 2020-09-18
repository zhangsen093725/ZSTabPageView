//
//  ZSPageViewServe.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/2/14.
//

import UIKit

@objc public protocol ZSPageViewServeDelegate {
    
    /// Page需要展示的View
    /// - Parameter index: 当前Page的索引
    func zs_pageView(at index: Int) -> UIView
    
    /// Page将要消失的View
    /// - Parameter index: 当前Page的索引
    func zs_pageViewWillDisappear(at index: Int)
    
    /// Page将要显示的View
    /// - Parameter index: 当前Page的索引
    func zs_pageViewWillAppear(at index: Int)
}

@objc public protocol ZSPageViewScrollDelegate {
    
    /// page 滚动的回调
    /// - Parameters:
    ///   - scrollView: 当前滚动的ScrollView
    ///   - page: 当前的页码
    func zs_pageViewDidScroll(_ scrollView: UIScrollView, page: Int)
    
    /// page 将要滚动，手指放上
    /// - Parameter scrollView: 当前滚动的ScrollView
    @objc optional func zs_pageViewWillBeginDecelerating(_ scrollView: UIScrollView)
    
    /// page 滚动结束，手指离开
    /// - Parameter scrollView: 当前滚动的ScrollView
    @objc optional func zs_pageViewDidEndDecelerating(_ scrollView: UIScrollView)
}

@objcMembers open class ZSPageViewServe: NSObject, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// UICollectionView 是否允许ScrollToIndex
    fileprivate var collectionViewScrollToIndexEnable: Bool = true
    
    public weak var collectionView: ZSPageView? {
        
        didSet {
            oldValue?.removeObserver(self, forKeyPath: "frame")
            collectionView?.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
        }
    }
    
    weak var delegate: ZSPageViewServeDelegate?
    
    public weak var scrollDelegate: ZSPageViewScrollDelegate?
    
    /// tab count
    public var tabCount: Int = 0 {
        didSet {
            collectionView?.reloadData()
            collectionView?.beginScrollToIndex(selectIndex, isAnimation: false)
        }
    }
    
    private var _selectIndex_: Int = 0
    
    private override init() {
        super.init()
    }
    
    public convenience init(selectIndex: Int) {
        self.init()
        _selectIndex_ = selectIndex
    }
    
    /// 当前选择的 tab 索引
    public var selectIndex: Int { return _selectIndex_ }
    
    open func zs_setSelectedIndex(_ index: Int) {
        
        guard tabCount > 0 else { return }
        let _index = index > 0 ? index : 0
        _selectIndex_ = _index < tabCount ? _index : tabCount - 1
        guard collectionViewScrollToIndexEnable else { return }
        collectionView?.beginScrollToIndex(selectIndex, isAnimation: false)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let _object = (object as? ZSPageView) else { return }
        
        if _object == collectionView
        {
            let new = change?[.newKey] as? CGRect
            let old = change?[.oldKey] as? CGRect
            
            guard new != old else { return }
            
            zs_setSelectedIndex(selectIndex)
        }
    }
    
    deinit {
        collectionView?.removeObserver(self, forKeyPath: "frame")
    }
}



/**
 * 1. ZSPageViewServe 提供外部重写的方法
 * 2. 需要自定义每个Tab Page的样式，可重新以下的方法达到目的
 */
@objc extension ZSPageViewServe {
    
    open func zs_bindView(_ collectionView: ZSPageView) {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.collectionView = collectionView
        zs_configTabPageView()
    }
    
    open func zs_configTabPageView() {
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(UICollectionViewCell.self))
    }
    
    open func zs_configTabPageCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(UICollectionViewCell.self), for: indexPath)
        
        cell.isExclusiveTouch = true
        
        for subView in cell.contentView.subviews {
            
            subView.removeFromSuperview()
        }
        
        guard let view = delegate?.zs_pageView(at: indexPath.item) else {
            return cell
        }
        
        cell.contentView.addSubview(view)
        view.frame = cell.contentView.bounds
        
        return cell
    }
}



/**
 * 1. UICollectionView 的代理
 * 2. 可根据需求进行重写
 */
@objc extension ZSPageViewServe {
    
    // TODO: UIScrollViewDelegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        
        guard collectionViewScrollToIndexEnable == false else { return }
        
        var page: Int = 0
        
        if flowLayout?.scrollDirection == .horizontal
        {
           page = Int(scrollView.contentOffset.x / scrollView.frame.width + 0.5)
        }
        else
        {
           page = Int(scrollView.contentOffset.y / scrollView.frame.height + 0.5)
        }
        
        if selectIndex != page && page < tabCount
        {
            delegate?.zs_pageViewWillAppear(at: page)
            delegate?.zs_pageViewWillDisappear(at: selectIndex)
        }
        
        scrollDelegate?.zs_pageViewDidScroll(scrollView, page: page)
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        collectionViewScrollToIndexEnable = false
        scrollDelegate?.zs_pageViewWillBeginDecelerating?(scrollView)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        collectionViewScrollToIndexEnable = true
        scrollDelegate?.zs_pageViewDidEndDecelerating?(scrollView)
    }
    
    // TODO: UICollectionViewDataSource
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return tabCount
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return zs_configTabPageCell(collectionView, cellForItemAt: indexPath)
    }
    
    // TODO: UICollectionViewDelegateFlowLayout
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.bounds.size
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return .zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}
