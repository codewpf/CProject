//
//  PDefine.swift
//  CProject
//
//  Created by wpf on 16/9/19.
//  Copyright © 2016年 alex. All rights reserved.
//

import UIKit

class PDefine: NSObject {

    class func SystemColor() -> UIColor {
        return UIColor(red: 58.0/255.0, green: 194.0/255.0, blue: 126.0/255.0, alpha: 1)
    }
    
    class func SVProgressColor() -> UIColor {
        return UIColor(red: 51/255, green: 51/255, blue: 52/255, alpha: 1)
    }
    
    class func TabbarHeigth() -> CGFloat {
        return 49;
    }

    class func PBunldeName() -> String {
        let dic:Dictionary = Bundle.main.infoDictionary!
        return dic["CFBundleIdentifier"] as! String
    }
}
