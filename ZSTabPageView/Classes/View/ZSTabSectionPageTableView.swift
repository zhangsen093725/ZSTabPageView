//
//  ZSTabSectionPageTableView.swift
//  ZSTabPageView
//
//  Created by Josh on 2020/12/18.
//

import UIKit

@objcMembers open class ZSTabSectionPageTableView: UITableView, UIGestureRecognizerDelegate {
    
    // TODO: UIGestureRecognizerDelegate
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
