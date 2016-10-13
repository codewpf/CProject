//
//  IAPHelper.swift
//  CProject
//
//  Created by wpf on 16/9/21.
//  Copyright © 2016年 alex. All rights reserved.
//

import UIKit
import StoreKit
import SVProgressHUD


typealias GetProductsSuccess = (_ products: [SKProduct]) ->()
typealias PurchasedSuccess = (_ transaction: SKPaymentTransaction) -> ()
typealias PurchasedFailed = (_ transaction: SKPaymentTransaction) -> ()

class IAPHelper: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    var getProductsSuccessBlock: GetProductsSuccess? = nil
    var purchasedSuccessBlock: PurchasedSuccess? = nil
    var purchasedFailedBlock: PurchasedFailed? = nil

    static let sharedInstance: IAPHelper = IAPHelper()
    
    func requestProducts(_ productIdentifiers: NSSet){
        let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        request.delegate = self;
        request.start()
    }
    func buyProductIdentifier(_ product: SKProduct) {
        let payment: SKPayment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if self.getProductsSuccessBlock != nil{
            self.getProductsSuccessBlock!(response.products)
        }
    }
    
    
    func purchasedTranscation(_ transaction: SKPaymentTransaction){
        if self.purchasedSuccessBlock != nil {
            self.purchasedSuccessBlock!(transaction)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func failedTransaction(_ transaction: SKPaymentTransaction){
        if self.purchasedFailedBlock != nil{
            self.purchasedFailedBlock!(transaction)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func otherTransAction(_ transaction: SKPaymentTransaction){
        switch transaction.transactionState {
        case .restored:
            print("restroed")
        case .deferred:
            print("deferred")
        default:
            print("default")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased :
                print("purchased")
                self.purchasedTranscation(transaction)
            case .failed :
                print("failed")
                self.failedTransaction(transaction)
            case .purchasing :
                print("Purchasing")
            default:
                print("default")
                self.otherTransAction(transaction)
            }
        }
    }
    


}
