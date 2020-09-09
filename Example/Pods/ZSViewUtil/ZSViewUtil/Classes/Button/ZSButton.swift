//
//  ZSButton.swift
//  JadeToB
//
//  Created by 张森 on 2019/11/12.
//  Copyright © 2019 张森. All rights reserved.
//

import UIKit

@objc public extension ZSButton {
    
    @objc enum ImageInset: Int {
        case left
        case right
        case top
        case bottom
    }
}


@objcMembers open class ZSButton: UIButton {
    
    @objc public var imageInset: ZSButton.ImageInset = .left
    
    @objc public var imageBackView: UIView {
        return _imageBackView
    }
    
    private lazy var _imageBackView: UIView = {
        
        let imageBackView = UIView()
        imageBackView.backgroundColor = .clear
        imageBackView.isUserInteractionEnabled = false
        imageBackView.addSubview(imageView ?? UIImageView())
        addSubview(imageBackView)
        return imageBackView
    }()
    
    private var _gradientLayer: CAGradientLayer?
    private var _gradientColors: [UIColor] = []
    
    /// 设置Button的背景渐变色
    /// - Parameters:
    ///   - locations: [颜色改变的位置，范围[0, 1]，0表示头部，1表示尾部，0.5表示中心，一个位置对应一个颜色]
    ///   - colors: [渐变的颜色，至少2个，和需要改变颜色的位置一一对应]
    ///   - startPoint: 渐变颜色的起始点，范围[0, 1], (0, 0）表示左上角，(0, 1)表示左下角，(1, 0)表示右上角，(1, 1)表示右下角
    ///   - endPoint: 渐变颜色的终止点，范围[0, 1], (0, 0）表示左上角，(0, 1)表示左下角，(1, 0)表示右上角，(1, 1)表示右下角
    open func zs_addBackgroundGradient(in locations: [NSNumber], colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        
        let _startPoint_ = CGPoint(x: CGFloat(fabsf(Float(startPoint.x)) < 1 ? fabsf(Float(startPoint.x)) : 1),
                                   y: CGFloat(fabsf(Float(startPoint.y)) < 1 ? fabsf(Float(startPoint.y)) : 1))
        
        let _endPoint_ = CGPoint(x: CGFloat(fabsf(Float(endPoint.x)) < 1 ? fabsf(Float(endPoint.x)) : 1),
                                 y: CGFloat(fabsf(Float(endPoint.y)) < 1 ? fabsf(Float(endPoint.y)) : 1))
        
        _gradientColors = colors
        
        let _colors_: [CGColor] = colors.map{ $0.cgColor }
        
        let _locations_: [NSNumber] = locations.map{ NSNumber(value: fabsf($0.floatValue) < 1 ? fabsf($0.floatValue) : 1)  }
        
        if _gradientLayer == nil
        {
            _gradientLayer = CAGradientLayer()
        }
        _gradientLayer?.locations = _locations_
        _gradientLayer?.colors = _colors_
        _gradientLayer?.startPoint = _startPoint_
        _gradientLayer?.endPoint = _endPoint_
        
        layer.addSublayer(_gradientLayer!)
    }
    
    /// 移除Button的背景渐变色
    open func zs_removeBackgroundGradient() {
        
        guard _gradientLayer != nil else { return }
        
        _gradientLayer?.removeFromSuperlayer()
        _gradientLayer = nil
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        switch imageInset {
        case .left:
            
            layoutImageLeft()
            break
        case .right:
            
            layoutImageRight()
            break
        case .top:
            
            layoutImageTop()
            break
        case .bottom:
            
            layoutImageBottom()
            break
        }
    }
    
    func layoutImageLeft() {
        
        let imageBackSize = min(frame.height, frame.width - titleEdgeInsets.left - titleEdgeInsets.right)
        
        imageBackView.frame = CGRect(x: 0, y: (frame.height - imageBackSize) * 0.5, width: imageBackSize, height: imageBackSize)
        
        let imageWidth = imageBackSize - imageEdgeInsets.left - imageEdgeInsets.right
        let imageHeight = imageBackSize - imageEdgeInsets.top - imageEdgeInsets.bottom
        
        imageView?.frame = CGRect(x: (imageBackView.frame.width - imageWidth) * 0.5, y: (imageBackView.frame.height - imageHeight) * 0.5, width: imageWidth, height: imageHeight)
        
        let titleWidth = frame.width - imageBackView.frame.maxX - titleEdgeInsets.left - titleEdgeInsets.right
        let titleHeight = frame.height - titleEdgeInsets.top - titleEdgeInsets.bottom
        
        titleLabel?.frame = CGRect(x: imageBackView.frame.maxX + titleEdgeInsets.left, y: titleEdgeInsets.top, width: titleWidth, height: titleHeight)
        titleLabel?.textAlignment = .left
    }
    
    
    func layoutImageRight() {
        
        let imageBackSize = min(frame.height, frame.width - titleEdgeInsets.left - titleEdgeInsets.right)
        
        imageBackView.frame = CGRect(x: frame.width - imageBackSize, y: (frame.height - imageBackSize) * 0.5, width: imageBackSize, height: imageBackSize)
        
        let imageWidth = imageBackView.frame.width - imageEdgeInsets.left - imageEdgeInsets.right
        let imageHeight = imageBackView.frame.height - imageEdgeInsets.top - imageEdgeInsets.bottom
        
        imageView?.frame = CGRect(x: (imageBackView.frame.width - imageWidth) * 0.5, y: (imageBackView.frame.height - imageHeight) * 0.5, width: imageWidth, height: imageHeight)
        
        let titleWidth = imageBackView.frame.origin.x - titleEdgeInsets.left - titleEdgeInsets.right
        let titleHeight = frame.height - titleEdgeInsets.top - titleEdgeInsets.bottom
        
        titleLabel?.frame = CGRect(x: titleEdgeInsets.left, y: titleEdgeInsets.top, width: titleWidth, height: titleHeight)
        titleLabel?.textAlignment = .right
    }
    
    
    func layoutImageTop() {
        
        let imageBackSize = min(frame.height - (titleLabel?.font.lineHeight ?? 0) - titleEdgeInsets.top - titleEdgeInsets.bottom, frame.width)
        
        imageBackView.frame = CGRect(x: (frame.width - imageBackSize) * 0.5, y: 0, width: imageBackSize, height: imageBackSize)
        
        let imageWidth = imageBackSize - imageEdgeInsets.left - imageEdgeInsets.right
        let imageHeight = imageBackSize - imageEdgeInsets.top - imageEdgeInsets.bottom
        
        imageView?.frame = CGRect(x: (imageBackView.frame.width - imageWidth) * 0.5, y: (imageBackView.frame.height - imageHeight) * 0.5, width: imageWidth, height: imageHeight)
        
        
        let titleWidth = frame.width - titleEdgeInsets.left - titleEdgeInsets.right
        let titleHeight = frame.height - imageBackView.frame.maxY - titleEdgeInsets.top - titleEdgeInsets.bottom
        
        titleLabel?.frame = CGRect(x: titleEdgeInsets.left, y: imageBackView.frame.maxY + titleEdgeInsets.top, width: titleWidth, height: titleHeight)
        titleLabel?.textAlignment = .center
    }
    
    func layoutImageBottom() {
        
        let imageBackSize = min(frame.height - (titleLabel?.font.lineHeight ?? 0) - titleEdgeInsets.top - titleEdgeInsets.bottom, frame.width)
        
        let titleWidth = frame.width - titleEdgeInsets.left - titleEdgeInsets.right
        let titleHeight = frame.height - imageBackSize - titleEdgeInsets.top - titleEdgeInsets.bottom
        
        titleLabel?.frame = CGRect(x: titleEdgeInsets.left, y: titleEdgeInsets.top, width: titleWidth, height: titleHeight)
        titleLabel?.textAlignment = .center
        
        
        imageBackView.frame = CGRect(x: (frame.width - imageBackSize) * 0.5, y: (titleLabel?.frame.maxY ?? 0) + titleEdgeInsets.bottom, width: imageBackSize, height: imageBackSize)
        
        let imageWidth = imageBackSize - imageEdgeInsets.left - imageEdgeInsets.right
        let imageHeight = imageBackSize - imageEdgeInsets.top - imageEdgeInsets.bottom
        
        imageView?.frame = CGRect(x: (imageBackView.frame.width - imageWidth) * 0.5, y: (imageBackView.frame.height - imageHeight) * 0.5, width: imageWidth, height: imageHeight)
    }
}
