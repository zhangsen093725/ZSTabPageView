//
//  ZSLayout.swift
//  ZSViewUtil
//
//  Created by Josh on 2020/8/5.
//

import Foundation

public enum KDevice {
    
    // MARK: - 屏幕宽高、frame
    static public let width: CGFloat = UIScreen.main.bounds.width
    static public let height: CGFloat = UIScreen.main.bounds.height
    static public let bounds: CGRect = UIScreen.main.bounds
    
    // MARK: - 关于刘海屏幕适配
    static public let tabbarHeight: CGFloat = KDevice.isBangs ? 83 : 49
    static public let safeBottom: CGFloat = KDevice.isBangs ? 34 : 0
    static public let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    static public let navigationHeight: CGFloat = 44 + statusBarHeight
    
    // MARK: - 设备类型
    static public let isPhone: Bool = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone)
    static public let isPad: Bool = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad)
    static public let isBangs: Bool = (String(format: "%.2f", 9.0 / 19.5) == String(format: "%.2f", KDevice.width / KDevice.height))
}

// MARK: - iPhone以375 * 667为基础机型的比例系数，iPad以768 * 1024为基础机型的比例系数
public extension CGFloat {
    
    var zs_px: CGFloat { return self * KDevice.width / 375.0 }
    
    var ratio_width: CGFloat { return self * ( KDevice.isPad ?  768.0 / 1024.0 : 375.0 / 667.0 ) }
    
    var ratio_height: CGFloat { return self * ( KDevice.isPad ?  1024.0 / 768.0 : 667.0 / 375.0 ) }
}

public extension Int {
    
    var zs_px: CGFloat { return CGFloat(self).zs_px }
    
    var ratio_width: CGFloat { return CGFloat(self).ratio_width }
    
    var ratio_height: CGFloat { return CGFloat(self).ratio_height }
}

public extension Float {
    
    var zs_px: CGFloat { return CGFloat(self).zs_px }
    
    var ratio_width: CGFloat { return CGFloat(self).ratio_width }
    
    var ratio_height: CGFloat { return CGFloat(self).ratio_height }
}

public extension Double {
    
    var zs_px: CGFloat { return CGFloat(self).zs_px }
    
    var ratio_width: CGFloat { return CGFloat(self).ratio_width }
    
    var ratio_height: CGFloat { return CGFloat(self).ratio_height }
}


// MARK: - UIView 扩展
@objc public extension UIView {
    
    var zs_right: CGFloat { return self.frame.maxX }
    
    var zs_bottom: CGFloat { return self.frame.maxY }
    
    func zs_margin(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        
        zs_margin = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    var zs_margin: UIEdgeInsets {
        set
        {
            zs_left = newValue.left
            zs_top = newValue.top
            zs_width = (superview?.frame.width ?? 0) - newValue.left - newValue.right
            zs_height = (superview?.frame.height ?? 0) - newValue.top - newValue.bottom
        }
        get
        {
            return UIEdgeInsets(top: zs_top,
                                left: zs_left,
                                bottom: (superview?.frame.height ?? 0) - zs_right,
                                right: (superview?.frame.height ?? 0) - zs_bottom)
        }
    }
    
    var zs_left: CGFloat {
        set
        {
            frame.origin.x = newValue
        }
        get
        {
            return frame.minX
        }
    }
    
    var zs_top: CGFloat {
        set
        {
            frame.origin.y = newValue
        }
        get
        {
            return frame.minY
        }
    }
    
    var zs_centerX: CGFloat {
        set
        {
            center.x = newValue
        }
        get
        {
            return center.x
        }
    }
    
    var zs_centerY: CGFloat {
        set
        {
            center.y = newValue
        }
        get
        {
            return center.y
        }
    }
    
    var zs_width: CGFloat {
        set
        {
            frame.size.width = newValue
        }
        get
        {
            return frame.width
        }
    }
    
    var zs_height: CGFloat {
        set
        {
            frame.size.height = newValue
        }
        get
        {
            return frame.height
        }
    }
}

// MARK: - UIColor扩展
@objc extension UIColor {
    
    public convenience init(hexCode: String, alpha: CGFloat = 1) {
        
        var cString: String = hexCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#"))
        {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6)
        {
            self.init()
            return
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        self.init(r: CGFloat((rgbValue & 0xFF0000) >> 16),
                  g: CGFloat((rgbValue & 0x00FF00) >> 8),
                  b: CGFloat(rgbValue & 0x0000FF),
                  a: alpha)
    }
    
    public convenience init(r red: CGFloat,
                            g green: CGFloat,
                            b blue: CGFloat,
                            a alpha: CGFloat = 1) {
        
        self.init(red: red / 255.0,
                  green: green / 255.0,
                  blue: blue / 255.0,
                  alpha: alpha)
    }
    
    @available(iOS 13.0, *)
    public convenience init(lightR: CGFloat, darkR: CGFloat,
                            lightG: CGFloat, darkG: CGFloat,
                            lightB: CGFloat, darkB: CGFloat,
                            lightA: CGFloat, darkA: CGFloat) {
        
        self.init { (traitCollection) -> UIColor in
            
            switch traitCollection.userInterfaceStyle {
            case .light:
                return UIColor(r: lightR, g: lightG, b: lightB, a: lightA)
            case .dark:
                return UIColor(r: darkR, g: darkG, b: darkB, a: darkA)
            default:
                fatalError()
            }
        }
    }
    
    @available(iOS 13.0, *)
    public func dark(r red: CGFloat, g green: CGFloat, b blue: CGFloat, a alpha: CGFloat = 1) -> UIColor {
        
        return dark(UIColor(r: red/255.0, g: green/255.0, b: blue/255.0, a: alpha))
    }
    
    @available(iOS 13.0, *)
    public func dark(hexCode: String) -> UIColor {
        
        return dark(UIColor(hexCode: hexCode))
    }
    
    @available(iOS 13.0, *)
    public func dark(_ color: UIColor) -> UIColor {
        
        return UIColor { (traitCollection) -> UIColor in
            
            switch traitCollection.userInterfaceStyle {
            case .light:
                return self
            case .dark:
                return color
            default:
                fatalError()
            }
        }
    }
}
