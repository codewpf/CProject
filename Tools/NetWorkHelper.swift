//
//  NetWorkHelper.swift
//  CProject
//
//  Created by wpf on 16/9/21.
//  Copyright © 2016年 alex. All rights reserved.
//

import UIKit
import Alamofire

typealias NetWorkDataBlock = (_ state: Bool, _ result:AnyObject) -> ()


class NetWorkHelper: NSObject {

    static let sharedInstance: NetWorkHelper = NetWorkHelper()
    
    func netWorkReachabilityWithURLString(url: String) -> Bool{
        
        let reach: NetworkReachabilityManager = NetworkReachabilityManager()!
        if reach.isReachable {
            return true
        }else{
            return false
        }
    }
    
    func netWorkDataWith(_ method: Alamofire.HTTPMethod, url: String, para: [String : Any] , block: @escaping NetWorkDataBlock){
                Alamofire.request(url, method: method, parameters: para, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                if response.result.isSuccess {
                    block(true, response.result.value! as AnyObject)
                } else{
                    block(false, response.result.error! as AnyObject)
                }
                
        }
        
    }

    class func rePostData() {
        if let temp: NSDictionary = UserDefaults.standard.object(forKey: PD_UserReceiptKey()) as! NSDictionary? {
            let dict: NSMutableDictionary = NSMutableDictionary.init(dictionary: temp)
            for (key,value) in dict {
                
                let md5Str = String("\(PD_UUID())apple_is_not_good")?.md5String
                let para = ["receipt-url":PD_ReceiptURLType(), "receipt-data":value, "md5-data":md5Str, "pc-data":PD_UUID()]
                NetWorkHelper.sharedInstance.netWorkDataWith(.post, url: PD_ServerURL(), para: para, block: { (state, result) in
                    if state {
                        if let code: NSNumber = (result.object(forKey: "code") as? NSNumber) {
                            if code == NSNumber(integerLiteral: 1) {
                                dict.removeObject(forKey: key)
                                UserDefaults.standard.set(dict, forKey: PD_UserReceiptKey())
                                UserDefaults.standard.synchronize()
                            }
                        }
                    }
                    
                })
                
            }
        }
    }
    
    
    
}

