//
//  PDefine.swift
//  CProject
//
//  Created by wpf on 16/9/19.
//  Copyright © 2016年 alex. All rights reserved.
//

import UIKit

func WPFLog<T>(_ message: T)
{
    #if DEBUG
        print("\(message)")
    #endif
}

class PDefine: NSObject {

    /// 系统颜色
    class func SystemColor() -> UIColor {
        return UIColor(red: 58.0/255.0, green: 194.0/255.0, blue: 126.0/255.0, alpha: 1)
    }
    
    /// HUD默认颜色
    class func SVProgressColor() -> UIColor {
        return UIColor(red: 51/255, green: 51/255, blue: 52/255, alpha: 1)
    }
    
    /// TabBar高度
    class func TabbarHeigth() -> CGFloat {
        return 49;
    }

    /// 当前项目名称
    class func PBunldeName() -> String {
        let dic:Dictionary = Bundle.main.infoDictionary!
        return dic["CFBundleIdentifier"] as! String
    }
    
    /// 当前应用唯一UUID值
    class func UUID() -> String {
        var uuid: String = ""
        if let temp: String = WPFKeychain.readValue() {
            uuid = temp
        }
        else
        {
            uuid = NSUUID().uuidString
            WPFKeychain.saveValue(value: uuid)
        }
        return uuid;
    }
    
    /// UserDefaults 收据Key
    class func UserDefaultsReceiptKey() -> String {
        return "receipt-datas-dict"
    }
    
    /// 钥匙串枚举
    enum KeychainType {
        case key,value
    }
    /// 钥匙串Key和Value
    class func Keychain(type:KeychainType) -> String {
        switch type {
        case .key:
            return PDefine.PBunldeName().appending(".KeyChain")
        case .value:
            return PDefine.PBunldeName().appending(".Value")
        }
    }
    
    /// 服务器地址
    class func serverURL() -> String {
        return "http://n.fujin.com/ashx/AppleManage.ashx"
    }
    
    /// md5混淆key值
    class func md5Key() -> String {
        return "123456abcapple_is_not_good"
    }
    
    /// 收据验证URL地址
    class func receiptURLType() -> String {
        #if DEBUG
            return "Debug"
        #else
            return "Release"
        #endif

    }
}


extension String {
    var md5String: String! {
        let str = self.cString(using: .utf8)
        let strlen =  CC_LONG(self.lengthOfBytes(using: .utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str, strlen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deallocate(capacity: digestLen)
        
        return String(hash)
    }

}

