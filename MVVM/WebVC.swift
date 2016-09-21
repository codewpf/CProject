//
//  WebVC.swift
//  CProject
//
//  Created by wpf on 16/9/21.
//  Copyright © 2016年 alex. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit
import SVProgressHUD
import JavaScriptCore

class WebVC: RootViewController, UIWebViewDelegate {

    // MARK: - Property
    var jsContext: JSContext? = nil
    var webUrl: String?
    
    var webView: UIWebView? = nil

    init(_ webUrl: String) {
        self.webUrl = webUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
        self.createBarButtonItem("刷新", self, #selector(self.refresh), .NavBtn_Right, "123", "123")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.resultRefresh), name: NSNotification.Name(rawValue: "Pay_Success"), object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "Tab_Refresh"), object: nil)
        
        self.webView = UIWebView()
        self.webView?.delegate = self
        self.webView?.scrollView.keyboardDismissMode = .onDrag
        self.view.addSubview(self.webView!)
        self.webView?.snp.makeConstraints({ [unowned self] (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(PDefine.TabbarHeigth(), 0, -PDefine.TabbarHeigth(), 0))
        })
        self.loadRequest(url: self.webUrl!)

    }
    
    
    // MARK: - PrivateMethods
    /// 加载网页
    func loadRequest(url: String)  {
        let request: NSURLRequest = NSURLRequest(url: NSURL(string: url)! as URL)
        self.webView?.loadRequest(request as URLRequest)
    }
    /// 刷新网页
    func refresh() {
        if self.webView != nil {
            self.webView?.reload()
        }
    }
    
    /// 如果当前是订单页面 收到通知进行刷新
    func resultRefresh() {
        if self.webView != nil && self.webUrl == PDefine.VCURL(.Order) {
            self.webView?.reload()
        }
    }

    /// 返回按钮点击
    func backBtnClick() {
        if self.webView != nil  && self.webView?.canGoBack == true {
            self.webView?.goBack()
        }
    }
    
    /// 返回上一页
    func popVc() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    /// 判断是不是一级页面
    func isRootVC() -> Bool{
        if self.webUrl == PDefine.VCURL(.Home) ||
            self.webUrl == PDefine.VCURL(.Order) ||
            self.webUrl == PDefine.VCURL(.My) {
            return true
        }
        return false
    }
    
    /// 判断是否越狱
    func isJailBreak() -> Bool {
        let path: String = "/User/Applications/"
        if FileManager.default.fileExists(atPath: path) {
            return true
        }
        return false
    }

    /// 跳转苹果内购界面
    func iapList(_ productsID: String) {
        
        var temp: [String] = productsID.components(separatedBy: ",")
        var array: [String] = []
        DispatchQueue.global().async { 
            while temp.count > 0 {
                array.append(String(format: "%@.%@", PDefine.PBunldeName(),temp[0]))
                temp.removeFirst()
            }
        }
        
        DispatchQueue.main.async {
            var message: String = "微币余额不足，请充值~"
            if self.isRootVC() {
                message = "确认充值微币？"
            }
            let alert:UIAlertController = UIAlertController.init(title: "提醒", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "充值", style: .default , handler: { (action) in
                
            }))
            alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
            let delegate:AppDelegate! = UIApplication.shared.delegate as? AppDelegate
            delegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
            
        }
    }

    
    
    
    // MARK: - UIWebViewDelegate
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // 增加返回或者关闭按钮
        self.addBackBtn()
        
        // 开始JS注入
        let context:JSContext? = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        let model:JSModel = JSModel()
        model.webView = self.webView
        model.jsContext = context
        self.jsContext = context
        
        // 当前页面加载网页
        model.guBlock = { (_ url: String) -> () in
            self.loadRequest(url: url)
        }
        // 新页面加载网页
        model.opBlock = { (_ url: String) -> () in
            DispatchQueue.main.async {
                let sub:WebVC = WebVC.init(url)
                sub.addBackBtn()
                self.sPushViewController(viewController: sub, animated: true)
            }
        }
        
        // 微信支付
        model.wBlock = { (_ orderID: String, _ body:String, _ price:String, _ notification:Bool) -> () in
            
            
        }
        
        // 支付宝支付
        model.aBlock = { (_ orderID: String, _ subject:String, _ body:String, _ price:String, _ notification:Bool) -> () in
            
        }
        
        // 苹果支付
        model.pBlock = { [unowned self] (_ productsID: String) -> () in
            if self.isJailBreak() {
                let alert:UIAlertController = UIAlertController.init(title: "提醒", message: "您的手机已经越狱，购买存在风险，请进QQ群咨询！", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "好的", style: .default, handler: nil))
                let delegate:AppDelegate! = UIApplication.shared.delegate as? AppDelegate
                delegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
            } else {
                self.iapList(productsID)
            }
        }
        
        
        self.jsContext?.setObject(model, forKeyedSubscript: "android" as (NSCopying & NSObjectProtocol)!)
        self.jsContext?.exceptionHandler = {
            (context, exception) in
            //print("exception @", exception)
        }
    }
    
    
    func addBackBtn() {
        if self.isRootVC() == true {
            
            if self.webView?.canGoBack == true {
                self.createBarButtonItem("返回", self, #selector(self.backBtnClick), .NavBtn_Left, "123", "123")
            } else{
                self.createBarButtonItem("", self, #selector(self.backBtnClick), .NavBtn_Left, "123", "123")
            }
            
        } else{
            
            if self.webView?.canGoBack == true {
                self.createBarButtonItems(["返回","关闭"], self, [#selector(self.backBtnClick),#selector(self.popVc)], .NavBtn_Left, ["123","123"], ["123","123"])
            } else{
                self.createBarButtonItems(["返回"], self, [#selector(self.popVc)], .NavBtn_Left, ["123"], ["123"])
                
            }

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
