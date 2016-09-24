//
//  JSModel.swift
//  CProject
//
//  Created by wpf on 16/9/21.
//  Copyright © 2016年 alex. All rights reserved.
//

import UIKit
import JavaScriptCore

@objc protocol JSModelExports: JSExport{
    /// 获取设备码
    func getPhone() -> String
    
    /// 获取版本
    func getBeta() -> String
    
    /// 跳转网页
    func gotoUrl(url: String)
    
    /// 跳转网页
    func openUrl(url: String)
    
    /// 显示提醒
    func showMsg(msg: String)
    
    /// 虚拟币不够，跳转到苹果支付
    func phonepay(_ productsID: String)
    
    /// 支付宝支付
    ///
    /// orderID 订单ID
    /// subject 商品标题
    /// body 描述
    /// price 价格
    /// notification ture直接支付 false充值
    func alipay(_ orderID: String, _ subject:String, _ body:String, _ price:String, _ notification:Bool)
    
    
    /// 微信支付
    ///
    /// orderID 订单ID
    /// body 商品描述
    /// price 价格
    /// notification ture直接支付 false充值
    func wechatpay(_ orderID: String, _ body:String, _ price:String, _ notification:Bool)

}

typealias GotoUrlBlock = (_ url: String) -> ()
typealias OpenUrlBlock = (_ url: String) -> ()
typealias PhonePayBlock = (_ productsID: String) -> ()
typealias AliPayBlock = (_ orderID: String, _ subject:String, _ body:String, _ price:String, _ notification:Bool) -> ()
typealias WechatBlock = (_ orderID: String, _ body:String, _ price:String, _ notification:Bool) -> ()


class JSModel: NSObject , JSModelExports{
    
    weak var jsContext: JSContext? = nil
    weak var webView: UIWebView? = nil
    
    var guBlock: GotoUrlBlock?
    var opBlock: OpenUrlBlock?
    var pBlock:  PhonePayBlock?
    var aBlock: AliPayBlock?
    var wBlock: WechatBlock?
    
    /// 获取设备码
    func getPhone() -> String {
        return PD_UUID()
    }
    
    /// 获取版本
    func getBeta() -> String {
        return PD_GetV()
    }
    
    /// 跳转网页
    func gotoUrl(url: String) {
        if self.guBlock != nil {
            self.guBlock!(url)
        }
    }
    
    /// 跳转网页
    func openUrl(url: String) {
        if self.opBlock != nil {
            self.opBlock!(url)
        }
    }
    
    
    /// 显示提醒
    func showMsg(msg: String) {
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .cancel, handler: nil))
            let delegate:AppDelegate! = UIApplication.shared.delegate as? AppDelegate
            delegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    /// 虚拟币不够，跳转到苹果支付
    func phonepay(_ productsID: String) {
        
        if self.pBlock != nil {
            self.pBlock!(productsID)
        }
    }
    
    /// 支付宝支付
    ///
    /// orderID 订单ID
    /// subject 商品标题
    /// body 描述
    /// price 价格
    /// notification ture直接支付 false充值
    func alipay(_ orderID: String, _ subject:String, _ body:String,  _ price:String, _ notification:Bool) {
        if self.aBlock != nil {
            self.aBlock!(orderID, subject, body, price, notification)
        }
    }
    
    /// 微信支付
    ///
    /// orderID 订单ID
    /// body 商品描述
    /// price 价格
    func wechatpay(_ orderID: String, _ body:String, _ price:String, _ notification:Bool) {
        if self.wBlock != nil {
            self.wBlock!(orderID, body, price, notification)
        }
    }
    
    // 空间设置  充值   0  false
    // 说说赞    支付   1  true
}
