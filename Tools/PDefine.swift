//
//  swift
//  CProject
//
//  Created by wpf on 16/9/19.
//  Copyright © 2016年 alex. All rights reserved.
//

import UIKit
/// 自定义输出
func WPFLog<T>(_ message: T)
{
    #if DEBUG
        print("\(message)")
    #endif
}


// MARK: - 颜色设定 -
/// 系统颜色
func PD_NavbarColor() -> UIColor {
    switch PD_CurrentTabBarType() {
    case .first_Bottom:
        return UIColor(red: 0, green: 3.0/255.0, blue: 21.0/255.0, alpha: 1)
    case .second_Top:
        return UIColor(red: 58.0/255.0, green: 194.0/255.0, blue: 126.0/255.0, alpha: 1)
    }
}

/// HUD默认颜色
func PD_SVProgressColor() -> UIColor {
    return UIColor(red: 51/255, green: 51/255, blue: 52/255, alpha: 1)
}


// MARK: - 系统设定 -
/// 当前项目名称
func PD_BunldeProjectName() -> String {
    let dic: Dictionary = Bundle.main.infoDictionary!
    return dic["CFBundleIdentifier"] as! String
}

/// 当前应用唯一UUID值
func PD_UUID() -> String {
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

/// 当前屏幕宽度
func PD_Width() -> Float {
    return Float(UIScreen.main.bounds.width)
}

/// 当前屏幕高度
func PD_Height() -> Float {
    return Float(UIScreen.main.bounds.height)
}

/// 钥匙串类型
enum PD_KeychainType {
    case key,value
}
/// 钥匙串Key和Value
func PD_CurrentKeychain(type:PD_KeychainType) -> String {
    switch type {
    case .key:
        return PD_BunldeProjectName().appending(".KeyChain")
    case .value:
        return PD_BunldeProjectName().appending(".Value")
    }
}

/// UserDefaults 收据Key
func PD_SserReceiptKey() -> String {
    return "receipt-datas-dict"
}


/// 服务器地址
func PD_ServerURL() -> String {
    return "http://n.fujin.com/ashx/AppleManage.ashx"
}

/// md5混淆key值
func PD_MD5Key() -> String {
    return "123456abcapple_is_not_good"
}

/// 收据验证URL地址类型
func PD_ReceiptURLType() -> String {
    #if DEBUG
        return "Debug"
    #else
        return "Release"
    #endif
    
}

// 网页V值
func PD_GetV() -> String {
    return "11328"
}

/// 返回网页URLType
enum PD_RootURLType {
    case home,order,my
}
/// 返回网页URLType
func PD_RootVCURL(_ type:PD_RootURLType) -> String{
    switch type {
    case .home:
        return String(format: "http://app2.fujin.com/wap/index_wap.htm?f=ios&v=%@&openid=?", PD_GetV())
    case .order:
        return "http://n.fujin.com/android/weibi/buy_list_ios.htm"
    case .my:
        return "http://n.fujin.com/android/ios_my.htm"
    }
}


// MARK: - TabBar类型设定 -

/// TabBar类型
enum PD_TabBarType {
    case first_Bottom,second_Top
}
/// 返回TabBar类型
func PD_CurrentTabBarType() -> PD_TabBarType {
    return .first_Bottom
}

/// TabBar高度
func PD_TabbarHeigth() -> CGFloat {
    switch PD_CurrentTabBarType() {
    case .first_Bottom:
        return 49
    case .second_Top:
        return 40
    }
}




// MARK: - Extension -
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




// MARK: - This Class -
class PDefine: NSObject {
    
    
}


