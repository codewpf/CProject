//
//  WPFKeychain.swift
//  CProject
//
//  Created by wpf on 16/9/19.
//  Copyright © 2016年 alex. All rights reserved.
//

import UIKit

class WPFKeychain: NSObject {

    
    class func readValue() -> String? {
        do {
            let passwordItems:[KeychainPasswordItem] = try KeychainPasswordItem.passwordItems(forService: PDefine.Keychain(type: .key))
            
            if passwordItems.count > 0 {
                return try passwordItems[0].readPassword()
            }else {
                return nil
            }
        } catch  {
            fatalError("Error fetching password - \(error)")
        }
    }
    
    class func saveValue(value:String) -> Void {
        
        do {
            let passwordItem = KeychainPasswordItem(service: PDefine.Keychain(type: .key), account: PDefine.Keychain(type: .key), accessGroup: nil)
            try passwordItem.savePassword(value)
        }
        catch {
            fatalError("Error updating keychain - \(error)")
        }


    }
}
