//
//  ZSTabView.swift
//  ZSTabPageView
//
//  Created by 张森 on 2020/1/13.
//  Copyright © 2020 张森. All rights reserved.
//

import UIKit

@objc public enum ZSTabViewSliderVerticalAlignment: Int {
    
    case Center = 0, Top = 1, Bottom = 2
}

@objc public enum ZSTabViewSliderHorizontalAlignment: Int {
    
    case Center = 0, Left = 1, Right = 2
}

@objc public enum ZSTabViewSliderAnimation: Int {
    
    case Default = 0, KeepSlide = 1, Together = 2, KeepTogetherSlide = 3
}


@objcMembers open class ZSTabView: UICollectionView {
    
    /// 是否隐藏底部的滑块
    public var isSliderHidden: Bool = false {
        
        didSet {
            sliderView.isHidden = isSliderHidden
        }
    }
    
    /// 滑块的宽度
    public var sliderWidth: CGFloat = 2
    
    /// 滑块的长度
    public var sliderLength: CGFloat = 0
    
    /// slider 垂直方向的对齐方式
    public var sliderVerticalAlignment: ZSTabViewSliderVerticalAlignment = .Bottom
    
    /// slider 水平方向的对齐方式
    public var sliderHorizontalAlignment: ZSTabViewSliderHorizontalAlignment = .Center
    
    /// slider 滑动的动画
    public var sliderAnimation: ZSTabViewSliderAnimation = .Default
    
    /// slider 根据Insets来进行调整偏移
    public var sliderInset: UIEdgeInsets = .zero
    
    /// 当前选择的 tab 索引
    private var selectIndex: Int = 0
    
    public lazy var sliderView: UIImageView = {
        
        let sliderView = UIImageView()
        sliderView.isHidden = isSliderHidden
        sliderView.backgroundColor = UIColor.systemGray
        return sliderView
    }()
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    convenience public init(collectionViewFlowLayout layout: UICollectionViewFlowLayout) {
        
        self.init(frame: .zero, collectionViewLayout: layout)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// TODO: 动画处理
@objc extension ZSTabView {
    
    open func layoutSliderView(to cell: UICollectionViewCell,
                               isHorizontal: Bool) -> CGFloat {
        
        var sliderOffset: CGFloat = 0
        
        // SliderView 位置初始化
        if isHorizontal
        {
            sliderView.frame.size.width = sliderLength > 0 ? sliderLength : (cell.frame.width - sliderInset.left - sliderInset.right)
            sliderView.frame.size.height = sliderWidth > 0 ? sliderWidth :  (cell.frame.height - sliderInset.top - sliderInset.bottom)
        }
        else
        {
            sliderView.frame.size.width = sliderWidth > 0 ? sliderWidth :  (cell.frame.width - sliderInset.left - sliderInset.right)
            sliderView.frame.size.height = sliderLength > 0 ? sliderLength : (cell.frame.height - sliderInset.top - sliderInset.bottom)
        }
        
        switch sliderVerticalAlignment {
        case .Center:
            
            if isHorizontal
            {
                sliderView.frame.origin.y = cell.frame.origin.y + (cell.frame.size.height - sliderView.frame.size.height) * 0.5 + sliderInset.top - sliderInset.bottom
            }
            else
            {
                sliderOffset = cell.frame.origin.y + (cell.frame.size.height - sliderView.frame.size.height) * 0.5 + sliderInset.top - sliderInset.bottom
            }
            break
            
        case .Top:
            
            if isHorizontal
            {
                sliderView.frame.origin.y = sliderInset.top
            }
            else
            {
                sliderOffset = cell.frame.origin.y + sliderInset.top
            }
            break
            
        case .Bottom:
            
            if isHorizontal
            {
                sliderView.frame.origin.y = frame.size.height - sliderView.frame.size.height - sliderInset.bottom
            }
            else
            {
                sliderOffset = cell.frame.maxY - sliderView.frame.size.height - sliderInset.bottom
            }
            break
        }
        
        switch sliderHorizontalAlignment {
        case .Center:
            
            if isHorizontal
            {
                sliderOffset = cell.frame.origin.x + (cell.frame.size.width - sliderView.frame.size.width) * 0.5 + sliderInset.left - sliderInset.right
            }
            else
            {
                sliderView.frame.origin.x = cell.frame.origin.x + (cell.frame.size.width - sliderView.frame.size.width) * 0.5 + sliderInset.left - sliderInset.right
            }
            break
            
        case .Left:
            
            if isHorizontal
            {
                sliderOffset = cell.frame.origin.x + sliderInset.left
            }
            else
            {
                sliderView.frame.origin.x = sliderInset.left
            }
            break
            
        case .Right:
            
            if isHorizontal
            {
                sliderOffset = cell.frame.maxX - sliderView.frame.size.width - sliderInset.right
            }
            else
            {
                sliderView.frame.origin.x = frame.size.width - sliderView.frame.size.width - sliderInset.right
            }
            break
        }
        
        return sliderOffset
    }
    
    open func sliderMove(offset: CGFloat,
                         isHorizontal: Bool) {
        
        if isHorizontal
        {
            sliderView.frame.origin.x = offset
        }
        else
        {
            sliderView.frame.origin.y = offset
        }
    }
    
    open func sliderViewAnimation(to index: Int,
                                  cell: UICollectionViewCell,
                                  isHorizontal: Bool,
                                  isAnimation: Bool,
                                  completion: ((Bool) -> Void)? = nil) {
        
        let sliderOffset: CGFloat = layoutSliderView(to: cell, isHorizontal: isHorizontal)
        
        if sliderView.superview == nil
        {
            insertSubview(sliderView, at: 0)
        }
        
        // SliderView 动画
        if !isAnimation
        {
            completion?(true)
            sliderMove(offset: sliderOffset, isHorizontal: isHorizontal)
            isUserInteractionEnabled = true
        }
        else
        {
            switch sliderAnimation {
                
            case .Default,
                 .Together:
                
                if abs(index - selectIndex) > 1
                {
                    selectIndex = index
                    sliderView.alpha = 0;
                    completion?(true)
                    sliderMove(offset: sliderOffset, isHorizontal: isHorizontal)
                    sliderView.layoutIfNeeded()
                    
                    UIView.animate(withDuration: 0.3, animations: { [weak self] in
                        
                        self?.sliderView.alpha = 1
                        
                    }) { [weak self] (finished) in
                        
                        self?.isUserInteractionEnabled = true
                    }
                    return
                }
                
            default:
                break
            }
            
            selectIndex = index
            sliderView.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
            
            self?.sliderMove(offset: sliderOffset, isHorizontal: isHorizontal)
            
            }) { [weak self] (finished) in
                
                self?.isUserInteractionEnabled = true
                completion?(finished)
            }
        }
    }
    
    open func cellForIndex(_ index: Int, isHorizontal: Bool) -> UICollectionViewCell? {
        
        reloadData()
        layoutIfNeeded()
        let indexPath = IndexPath(item: index, section: 0)
        
        let cell = cellForItem(at: indexPath)
        
        if cell == nil
        {
            scrollToItem(at: indexPath, at: isHorizontal ? .centeredHorizontally : .centeredVertically, animated: false)
            layoutIfNeeded()
            return cellForItem(at: indexPath)
        }
        
        return cell
    }
    
    open func beginScrollToIndex(_ index: Int,
                                 isAnimation: Bool) {
        
        guard frame != .zero else { return }
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let isHorizontal = flowLayout.scrollDirection == .horizontal
        
        guard let cell = cellForIndex(index, isHorizontal: isHorizontal) else { return }
        
        isUserInteractionEnabled = false
        
        let min: CGFloat = 0
        var max =  isHorizontal ? (contentSize.width - frame.width) : (contentSize.height - frame.height)
        max = max > 0 ? max : 0
        
        let cellCenter = isHorizontal ? cell.center.x : cell.center.y
        let centerContentOffset = cellCenter - (isHorizontal ? center.x : center.y)
        
        var point: CGPoint = .zero
        
        if contentOffset.x >= min
        {
            if centerContentOffset > max
            {
                point = isHorizontal ? CGPoint(x: max, y: 0) : CGPoint(x: 0, y: max)
            }
            else if centerContentOffset > 0
            {
                point = isHorizontal ? CGPoint(x: centerContentOffset, y: 0) : CGPoint(x: 0, y: centerContentOffset)
            }
        }
        
        switch sliderAnimation
        {
        case .Default, .KeepSlide:
            sliderViewAnimation(to: index, cell: cell, isHorizontal: isHorizontal, isAnimation: isAnimation) { [weak self] (finished) in
                
                self?.setContentOffset(point, animated: isAnimation)
            }
            break
        case .Together, .KeepTogetherSlide:
            setContentOffset(point, animated: isAnimation)
            sliderViewAnimation(to: index, cell: cell, isHorizontal: isHorizontal, isAnimation: isAnimation)
            break
        default:
            break;
        }
        
        reloadData()
    }
}
