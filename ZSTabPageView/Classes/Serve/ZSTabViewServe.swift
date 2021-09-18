//
//  ZSTabPageViewServe.swift
//  ZSTabPageView
//
//  Created by 张森 on 2020/1/13.
//  Copyright © 2020 张森. All rights reserved.
//

import UIKit

@objc public protocol ZSTabViewServeDelegate {
    
    /// tab 点击回调
    /// - Parameter index: 当前点击的索引
    func zs_tabViewDidSelected(at index: Int)
}

@objc public protocol ZSTabViewServeDataSource {
    
    /// tab cell的大小
    /// - Parameter index: 当前Cell的索引
    @objc func zs_configTabCellSize(forItemAt index: Int) -> CGSize
    
    /// tab cell
    /// - Parameters:
    ///   - cell: 当前的Cell
    ///   - index: 当前Cell的索引
    @objc func zs_configTabCell(_ cell: ZSTabCollectionViewCell, forItemAt index: Int)
}

@objcMembers open class ZSTabViewServe: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private override init() {
        super.init()
    }
    
    public convenience init(selectIndex: Int = 0,
                            bind tabView: ZSTabView,
                            register tabCellClass: ZSTabCollectionViewCell.Type) {
        self.init()
        _selectIndex_ = selectIndex
        
        tabView.delegate = self
        tabView.dataSource = self
        
        tabView.register(tabCellClass, forCellWithReuseIdentifier: tabCellClass.zs_identifier)
        tabView.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
        
        self.tabView = tabView
        self.cellClass = tabCellClass
    }
    
    public weak var tabView: ZSTabView? {

        didSet {
            oldValue?.removeObserver(self, forKeyPath: "frame")
            tabView?.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
        }
    }
    
    public var cellClass: ZSTabCollectionViewCell.Type = ZSTabCollectionViewCell.self
    
    public weak var delegate: ZSTabViewServeDelegate?
    
    weak var dataSource: ZSTabViewServeDataSource?
    
    /// tab count
    public var tabCount: Int = 0 {
        
        didSet {
            tabView?.reloadData()
            
            if tabCount > 0
            {
                _selectIndex_ = selectIndex < tabCount ? selectIndex : tabCount - 1
                tabView?.zs_setSelectedIndex(selectIndex, isAnimation: false)
            }
            else
            {
                _selectIndex_ = 0
            }
        }
    }
    
    /// tab 之间的间隙
    public var minimumSpacing: CGFloat = 8 {
        
        didSet {
            tabView?.reloadData()
        }
    }
    
    /// tab insert
    public var tabViewInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) {
        
        didSet {
            tabView?.reloadData()
        }
    }
    
    /// 当前选择的 tab 索引
    public var selectIndex: Int { return _selectIndex_ }
    private var _selectIndex_: Int = 0
    
    open func zs_setSelectedIndex(_ index: Int, animation: Bool = true) {
        
        guard tabCount > 0 else { return }
        
        let _index = index > 0 ? index : 0
        _selectIndex_ = _index < tabCount ? _index : tabCount - 1
        tabView?.zs_setSelectedIndex(selectIndex, isAnimation: animation)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let _object = (object as? ZSTabView) else { return }
        
        if _object == tabView
        {
            let new = change?[.newKey] as? CGRect
            let old = change?[.oldKey] as? CGRect
            
            guard new != old else { return }
    
            zs_setSelectedIndex(selectIndex)
        }
    }
    
    deinit {
        tabView = nil
    }
}



/**
 * 1. UICollectionView 的代理
 * 2. 可根据需求进行重写
 */
@objc extension ZSTabViewServe {
    
    // TODO: UICollectionViewDataSource
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return tabCount
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.zs_identifier, for: indexPath) as! ZSTabCollectionViewCell
        
        dataSource?.zs_configTabCell(cell, forItemAt: indexPath.item)
        
        return cell
    }
    
    // TODO: UICollectionViewDelegateFlowLayout
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return dataSource?.zs_configTabCellSize(forItemAt: indexPath.item) ?? .zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return tabViewInset
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return minimumSpacing
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return minimumSpacing
    }
    
    // TODO: UICollectionViewDelegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        delegate?.zs_tabViewDidSelected(at: indexPath.item)
    }
}
