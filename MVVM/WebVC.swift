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

class WebVC: RootViewController, UIWebViewDelegate, NJKWebViewProgressDelegate, URLSessionDelegate{
    
    // MARK: - Property
    var jsContext: JSContext? = nil
    var webUrl: String?
    
    var webView: UIWebView? = nil
    var progressView: NJKWebViewProgressView? = nil
    var progressProxy: NJKWebViewProgress? = nil
    

    
    
    // MARK: - Methods -
    init(_ webUrl: String) {
        self.webUrl = webUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.addSubview(self.progressView!)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.progressView?.removeFromSuperview()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.createBarButtonItem("刷新", self, #selector(self.refresh), .NavBtn_Right, "123", "123")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.resultRefresh), name: NSNotification.Name(rawValue: "Pay_Success"), object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "Tab_Refresh"), object: nil)
        
        self.webView = UIWebView()
        //        self.webView?.delegate = self
        self.webView?.scrollView.keyboardDismissMode = .onDrag
        self.view.addSubview(self.webView!)
        self.webView?.snp.makeConstraints({ [unowned self] (make) in
            switch PD_CurrentTabBarType() {
            case .first_Bottom:
                make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, -PD_TabbarHeigth(), 0))
            case .second_Top:
                make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(PD_TabbarHeigth(), 0, -49, 0))
                
            }
            })
        
        self.progressProxy = NJKWebViewProgress()
        self.webView?.delegate = self.progressProxy
        self.progressProxy?.webViewProxyDelegate = self
        self.progressProxy?.progressDelegate = self;
        
        let size: CGSize = (self.navigationController?.navigationBar.bounds.size)!
        self.progressView = NJKWebViewProgressView(frame: CGRectFromString( String(format: "{{0, %f}, {%f, 2}}", size.height-2, size.width)))
        self.progressView?.progress = 0.0
        
        let request: URLRequest = URLRequest(url: URL(string: self.webUrl!)!)
        self.webView?.loadRequest(request)
        
        //self.loadRequest(url: self.webUrl!)
    }
    
    
    // MARK: - PrivateMethods
    /// 加载网页
    func loadRequest(url: String)  {
        let request: URLRequest = URLRequest(url: URL(string: url)!)
        self.webView?.loadRequest(request)
    }
    /// 刷新网页
    func refresh() {
        
        if self.webView != nil {
            self.webView?.reload()
        }
    }
    
    /// 如果当前是订单页面 收到通知进行刷新
    func resultRefresh() {
        if self.webView != nil && self.webUrl == PD_RootVCURL(.order) {
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
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /// 判断是不是一级页面
    func isRootVC() -> Bool{
        if self.webUrl == PD_RootVCURL(.home) ||
            self.webUrl == PD_RootVCURL(.order) ||
            self.webUrl == PD_RootVCURL(.my) {
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
                array.append(String(format: "%@.%@", PD_BunldeProjectName(),temp[0]))
                temp.removeFirst()
            }
        }
        
        DispatchQueue.main.async {
            var message: String = "微币余额不足，请充值~"
            if self.isRootVC() {
                message = "确认充值微币？"
            }
            let alert: UIAlertController = UIAlertController.init(title: "提醒", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "充值", style: .default , handler: { (action) in
                let list: AppStoreListVC = AppStoreListVC(productsIDArray: array)
                self.sPushViewController(list, animated: true)
            }))
            alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
    // MARK: - UIWebViewDelegate
    func webViewProgress(_ webViewProgress: NJKWebViewProgress!, updateProgress progress: Float) {
        self.progressView?.setProgress(progress, animated: true)
        self.navigationItem.title = self.webView?.stringByEvaluatingJavaScript(from: "document.title")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // 增加返回或者关闭按钮
        self.addBackBtn()
        
        // 开始JS注入
        let context: JSContext? = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        let model: JSModel = JSModel()
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
                let sub: WebVC = WebVC.init(url)
                sub.addBackBtn()
                self.sPushViewController(sub, animated: true)
            }
        }
        
        // 微信支付
        model.wBlock = { (_ orderID: String, _ body:String, _ price:String, _ notification:Bool) -> () in
            
            if WXApi.isWXAppInstalled() {
                SVProgressHUD.show(withStatus: "正在准备跳转微信...")
                WechatHelper.shared().wechatPay(orderID, body: body, price: price, notification: notification)
            } else {
                DispatchQueue.main.async {
                    let alert: UIAlertController = UIAlertController.init(title: "提醒", message: "检测未安装微信，是前往AppStore下载？", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "安装", style: .default, handler: { (action) in
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(URL(string: WXApi.getWXAppInstallUrl())!, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(URL(string: WXApi.getWXAppInstallUrl())!)
                        }
                    }))
                    alert.addAction(UIAlertAction.init(title: "下次", style: .cancel, handler: nil))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
            
        }
        
        // 支付宝支付
        model.aBlock = { (_ orderID: String, _ subject:String, _ body:String, _ price:String, _ notification:Bool) -> () in
            let product: Product = Product()
            product.orderId = orderID;
            product.subject = subject;
            product.body = body;
            product.price = Float(price)!;
            product.notification = notification;
            
            SVProgressHUD.show(withStatus: "正在准备跳转支付宝...")
            AlipayHelper.shared().alipay(product, block: { (dict) in
                AlipayHelper.shared().aliPayResult(dict, vc: self.navigationController?.topViewController)
            })
            
            
        }
        
        // 苹果支付
        model.pBlock = { [unowned self] (_ productsID: String) -> () in
            if self.isJailBreak() {
                DispatchQueue.main.async {
                    let alert: UIAlertController = UIAlertController.init(title: "提醒", message: "您的手机已经越狱，购买存在风险，请进QQ群咨询！", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "好的", style: .default, handler: nil))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }
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
    
    
    
    
//    //MARK: - 处理UIWebView不信任证书问题
//    var authenticated = false
//    
//    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        if self.authenticated == false {
//            let urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
//            let task: URLSessionDataTask =  urlSession.dataTask(with: request, completionHandler: { (data, response, error) in
//                
//                
//                
//                print(data,response,error)
//                if error == nil {
//                    if self.authenticated == false{
//                        self.authenticated = true
//                        let pageData :String = String(data: data!, encoding: .utf8)!
//                        self.webView?.loadHTMLString(pageData, baseURL: request.url!)
//                    } else {
//                        self.webView?.loadRequest(request)
//                    }
//                }
//            })
//            task.resume()
//            return false
//        }
//        
//        return true
//    }
//    
//    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        completionHandler(.useCredential,URLCredential(trust: challenge.protectionSpace.serverTrust!))
//    }
    
    
    
    
    //MARK: - Other
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
