//
//  AppStoreListVC.swift
//  CProject
//
//  Created by wpf on 16/9/23.
//  Copyright © 2016年 alex. All rights reserved.
//

import UIKit
import StoreKit
import SVProgressHUD

class AppStoreListVC: RootViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView?
    var dataSource: [SKProduct] = []
    var products: NSSet?
    
    init(productsIDArray: [String]){
        
        self.products = NSSet(array: productsIDArray)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "充值"
        self.createBarButtonItem("返回", self, #selector(self.backAction), .NavBtn_Left, "nav_back", "nav_back")
        
        self.tableView = UITableView(frame: CGRectFromString("{{0, 0}, {0, 0}}"), style: .plain)
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.tableFooterView = UIView()
        self.view.addSubview(self.tableView!)
        self.tableView?.snp.makeConstraints({ [unowned self] (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
            })
        
        IAPHelper.sharedInstance.getProductsSuccessBlock = { (products: [SKProduct]) ->() in
            SVProgressHUD.dismiss()
            self.dataSource = products
            DispatchQueue.main.async {
                let offset: Int = PD_BunldeProjectName().characters.count + 1
                
                self.dataSource.sort(by: { (product1, product2) -> Bool in
                    let identifier1: String = product1.productIdentifier
                    let identifier2: String = product2.productIdentifier
                    
                    let index: String.Index = identifier1.index(identifier1.startIndex, offsetBy: offset)
                    
                    let num1: Int? = Int(identifier1.substring(from: index))
                    let num2: Int? = Int(identifier2.substring(from: index))
                    
                    return num1! < num2!
                })
                self.tableView?.reloadData()
                
            }
        }
        
        IAPHelper.sharedInstance.purchasedSuccessBlock = { (transaction: SKPaymentTransaction) -> () in
            self.testReceipt()
        }
        IAPHelper.sharedInstance.purchasedFailedBlock = { (transaction: SKPaymentTransaction) -> () in
            SVProgressHUD.showError(withStatus: transaction.error?.localizedDescription)
        }
        IAPHelper.sharedInstance.requestProducts(self.products!)
        SVProgressHUD.show(withStatus: "正在获取充值商品列表...")
        
    }
    
    func testReceipt() {
        let path: String = (Bundle.main.appStoreReceiptURL?.path)!
        
        if let recepit: NSData = NSData(contentsOfFile: path) {
            let receipt_data: String = recepit.base64EncodedString(options: .endLineWithLineFeed)
            
            let md5Str = String("\(PD_UUID())apple_is_not_good")?.md5String
            let para = ["receipt-url":PD_ReceiptURLType(), "receipt-data":receipt_data, "md5-data":md5Str, "pc-data":PD_UUID()]
            NetWorkHelper.sharedInstance.netWorkDataWith(.post, url: PD_ServerURL(), para: para as! [String : String], block: { (state, result) in
                
                if state {
                    if let code: NSNumber = result.object(forKey: "code") as? NSNumber {
                        if code == NSNumber(value: 1) {
                            SVProgressHUD.showSuccess(withStatus: "充值成功！")
                            self.backAction()
                        } else {
                            let msg: String? = result.object(forKey: "msg") as? String
                            SVProgressHUD.showError(withStatus: msg)
                        }
                    } else {
                        SVProgressHUD.showError(withStatus: "数据错误!")
                        self.saveReceipt(receipt_data)
                    }
                } else {
                    SVProgressHUD.showError(withStatus: "网络超时！")
                    self.saveReceipt(receipt_data)
                }
                
                
            })
            
            
        } else {
            SVProgressHUD.showError(withStatus: "位置错误，请联系客服！")
        }
    }
    
    func saveReceipt(_ receipt_data: String) {
        
        var dict: [String:String]? = UserDefaults.standard.object(forKey: PD_UserReceiptKey()) as! [String : String]?
        dict?[String(Date().timeIntervalSince1970)] = receipt_data
        UserDefaults.standard.setValue(dict, forKeyPath: PD_UserReceiptKey())
        UserDefaults.standard.synchronize()
    }
    
    
    func backAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String = "AppStoreListCell"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        }
        
        let product: SKProduct = self.dataSource[indexPath.row]
        cell?.textLabel?.text = product.localizedTitle
        cell?.detailTextLabel?.text = String("\(product.price)元")
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let product: SKProduct = self.dataSource[indexPath.row]
        IAPHelper.sharedInstance.buyProductIdentifier(product)
        SVProgressHUD.show()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
