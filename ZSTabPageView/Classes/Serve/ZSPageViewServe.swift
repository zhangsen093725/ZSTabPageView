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
    
    /// page 滚动结束的回调
    /// - Parameters:
    ///   - scrollView: 当前滚动的ScrollView
    ///   - page: 当前的页码
    func zs_pageView(scrollView: UIScrollView, didChange index: Int)
    
    /// scrollView 滚动的回调
    /// - Parameters:
    ///   - scrollView: 当前滚动的ScrollView
    @objc optional func zs_pageViewDidScroll(_ scrollView: UIScrollView)
    
    /// scrollView 将要滚动，手指放上
    /// - Parameter scrollView: 当前滚动的ScrollView
    @objc optional func zs_pageViewWillBeginDecelerating(_ scrollView: UIScrollView)
    
    /// scrollView 滚动结束，手指离开
    /// - Parameter scrollView: 当前滚动的ScrollView
    @objc optional func zs_pageViewDidEndDecelerating(_ scrollView: UIScrollView)
}

@objcMembers open class ZSPageViewServe: NSObject, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private override init() {
        super.init()
    }
    
    public convenience init(selectIndex: Int = 0,
                            bind pageView: ZSPageView) {
        self.init()
        _selectIndex_ = selectIndex
        
        pageView.delegate = self
        pageView.dataSource = self
        pageView.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
        
        zs_config(pageView: pageView)
        self.pageView = pageView
    }
    
    public weak var pageView: ZSPageView?
    {
        didSet
        {
            oldValue?.removeObserver(self, forKeyPath: "frame")
            pageView?.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
        }
    }
    
    
    /// 当前选择的 tab 索引
    public var selectIndex: Int { return _selectIndex_ }
    /// 当前选择的 tab 索引
    private var _selectIndex_: Int = 0
    {
        willSet
        {
            if (newValue == selectIndex) { return; }
            
            delegate?.zs_pageViewWillAppear(at: newValue)
            delegate?.zs_pageViewWillDisappear(at: newValue)
        }
    }
    
    weak var delegate: ZSPageViewServeDelegate?
    
    public weak var scrollDelegate: ZSPageViewScrollDelegate?
    
    /// tab count
    public var pageCount: Int = 0
    {
        didSet
        {
            zs_clearCache()
            pageView?.reloadData()
            zs_setSelectedIndex(selectIndex)
        }
    }
    
    /// UICollectionView 是否允许ScrollToIndex
    fileprivate var pageViewScrollToIndexEnable: Bool = true
    
    private var displayLink: _ZSPageViewServeDisplayLink?
    private let _displayLinkCount: Int = 8
    private var displayLinkCount: Int = 8
    
    private var _cellContentCacheViewMap: [Int : UIView] = [:]
    public var cellContentCacheViewMap: [Int : UIView] {
        
        return _cellContentCacheViewMap
    }
    
    deinit {
        pageView = nil
    }
}


/**
 *  DisplayLink
 */
@objc extension ZSPageViewServe {
    
    private func startDisplayLink() {

        guard displayLink == nil else { return }
        
        displayLink = _ZSPageViewServeDisplayLink(fps: 60, block: { [weak self] (displayLink) in
            
            self?.runDisplayLink()
        })
    }
    
    private func runDisplayLink() {
        displayLinkCount -= 1
        
        if displayLinkCount <= 0
        {
            zs_showCellContentCacheView()
            stopDisplayLink()
        }
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    private func zs_showCellContentCacheView() {
        
        guard let cell = pageView?.cellForItem(at: IndexPath(row: selectIndex, section: 0)) else { return }
        
        var view = cellContentCacheViewMap[selectIndex]
        
        if view == nil
        {
            view = delegate?.zs_pageView(at: selectIndex)
            _cellContentCacheViewMap[selectIndex] = view
            cell.contentView.addSubview(view!)
        }
        
        view?.frame = cell.contentView.bounds
    }
}



/**
 *  ZSPageViewServe 提供外部重写的方法
 */
@objc extension ZSPageViewServe {
    
    /// 清除PageView的缓存
    open func zs_clearCache() {
        _cellContentCacheViewMap.removeAll()
    }
    
    open func zs_config(pageView: ZSPageView) {
        
        pageView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(UICollectionViewCell.self))
    }
    
    open func zs_setSelectedIndex(_ index: Int) {
        
        guard pageCount > 0 else { return }
        
        var _index = index > 0 ? index : 0
        _index = _index < pageCount ? _index : pageCount - 1
        
        _selectIndex_ = _index
        
        guard pageViewScrollToIndexEnable else { return }
        
        pageView?.zs_setSelectedIndex(selectIndex, isAnimation: false)
        pageView?.layoutIfNeeded()
        
        stopDisplayLink()
        displayLinkCount = _displayLinkCount
        startDisplayLink()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let _object = (object as? ZSPageView) else { return }
        
        if _object == pageView
        {
            let new = change?[.newKey] as? CGRect
            let old = change?[.oldKey] as? CGRect
            
            guard new != old else { return }
            
            zs_setSelectedIndex(selectIndex)
        }
    }
}



/**
 * 1. UICollectionView 的代理
 * 2. 可根据需求进行重写
 */
@objc extension ZSPageViewServe {
    
    // TODO: UIScrollViewDelegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        scrollDelegate?.zs_pageViewDidScroll?(scrollView)
        
        let flowLayout = pageView?.collectionViewLayout as? UICollectionViewFlowLayout
        
        guard pageViewScrollToIndexEnable == false else { return }
        
        var page: Int = 0
        
        if flowLayout?.scrollDirection == .horizontal
        {
           page = Int(scrollView.contentOffset.x / scrollView.frame.width + 0.5)
        }
        else
        {
           page = Int(scrollView.contentOffset.y / scrollView.frame.height + 0.5)
        }
        
        guard selectIndex != page else { return }
        
        scrollDelegate?.zs_pageView(scrollView: scrollView, didChange: page)
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        stopDisplayLink()
        displayLinkCount = _displayLinkCount
        pageViewScrollToIndexEnable = false
        scrollDelegate?.zs_pageViewWillBeginDecelerating?(scrollView)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        startDisplayLink()
        pageViewScrollToIndexEnable = true
        scrollDelegate?.zs_pageViewDidEndDecelerating?(scrollView)
    }
    
    // TODO: UICollectionViewDataSource
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return pageCount
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(UICollectionViewCell.self), for: indexPath)
        
        cell.isExclusiveTouch = true
        cell.contentView.frame = cell.bounds

        for subView in cell.contentView.subviews
        {
            subView.isHidden = true
            subView.removeFromSuperview()
        }
        
        guard let view = cellContentCacheViewMap[indexPath.item] else { return cell }
        
        cell.contentView.addSubview(view)
        view.isHidden = false
        view.frame = cell.contentView.bounds
        
        return cell
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



fileprivate class _ZSPageViewServeDisplayLink: NSObject {
    
    private var userInfo: ((_ displayLink: CADisplayLink) -> Void)?
    private var displayLink: CADisplayLink?
    
    private override init() {
        super.init()
    }
    
    /// 初始化CADisplayLink
    /// - Parameters:
    ///   - fps: 刷新频率，表示一秒钟刷新多少次，默认是60次
    ///   - block: 回调
    public convenience init(fps: Int = 60,
                            block: @escaping (_ displayLink: CADisplayLink) -> Void) {
        
        self.init()
        
        userInfo = block
        
        displayLink = CADisplayLink(target: self, selector: #selector(runDisplayLink(_:)))
        
        if #available(iOS 10.0, *) {
            displayLink?.preferredFramesPerSecond = fps
        } else {
            displayLink?.frameInterval = fps
        }
        displayLink?.add(to: RunLoop.current, forMode: .default)
    }
    
    @objc private func runDisplayLink(_ displayLink: CADisplayLink) -> Void {
        
        guard userInfo != nil else { return }
        userInfo!(displayLink)
    }
    
    public func invalidate() {
        displayLink?.remove(from: RunLoop.current, forMode: .default)
        displayLink?.invalidate()
        displayLink = nil
        userInfo = nil
    }
}
