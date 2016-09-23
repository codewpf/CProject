//
//  RootViewController.swift
//  CProject
//
//  Created by wpf on 16/9/20.
//  Copyright © 2016年 alex. All rights reserved.
//

import UIKit

enum NavbtnType {
    case NavBtn_Left
    case NavBtn_Right
}

class RootViewController: UIViewController, UIGestureRecognizerDelegate {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isRoot() == false &&
            self.navigationController!.interactivePopGestureRecognizer != nil &&
            self.navigationController!.viewControllers.count > 1{
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.isRoot() == true &&
            self.navigationController!.interactivePopGestureRecognizer != nil {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.setNavigationBarBackgroundImage()
    }
    
    func setNavigationBarBackgroundImage() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = NSDictionary(objects: [UIFont.boldSystemFont(ofSize: 20), UIColor.white], forKeys: [NSFontAttributeName as NSCopying, NSForegroundColorAttributeName as NSCopying]) as? [String : AnyObject]
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = PD_NavbarColor()
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func createBack(pre: String) {
        var backStr: String = ""
        if pre.isEmpty != false {
            backStr = "返回"
        }
        
        self.createBarButtonItem(backStr, self, #selector(self.leftAciton), .NavBtn_Left, "", "")
    }

    /// 返回上一层动作
    func leftAciton() {
        let _ = self.navigationController?.popViewController(animated: true)
    }

    /// 自定义Push方法
    func sPushViewController(viewController: UIViewController, animated: Bool) {
        if self.isKind(of: WebVC.self){
            viewController.hidesBottomBarWhenPushed = true
        }
        self.navigationController?.pushViewController(viewController, animated: animated)
    }

    
    
    /// 添加多个按钮
    func createBarButtonItems(_ titles: [String], _ target: AnyObject, _ actions: [Selector], _ type: NavbtnType, _ nImages: [String], _ hImages: [String]) {
        
        if titles.count != nImages.count || titles.count != hImages.count || nImages.count != hImages.count{
            return
        }
        
        var bbis:[UIBarButtonItem] = []
        for (index,title) in titles.enumerated(){
            let nImage: String = nImages[index]
            let hImage: String = hImages[index]
            let action: Selector = actions[index]
            // 图片大小
            var imageSize: CGSize
            let nimage: UIImage? = UIImage(named: nImage)
            let himage: UIImage? = UIImage(named: hImage)
            
            if (nimage != nil) {
                imageSize = (nimage?.size)!
            }else{
                imageSize = CGSize.init(width: 0, height: 0)
            }
            // 文字大小
            let textSize: CGSize = self.textSize(title, self.textFont())
            
            // 初始化按钮
            let button: UIButton? = UIButton(type: .custom)
            button?.frame = CGRect(x: 0, y: 0, width: imageSize.width+textSize.width+10, height: 30)
            button?.setImage(nimage, for: .normal)
            button?.setImage(himage, for: .highlighted)
            button?.setTitle(title, for: .normal)
            button?.titleLabel?.font = self.textFont()
            button?.setTitleColor(UIColor.white, for: .normal)
            button?.addTarget(target, action: action, for: .touchUpInside)
            
            let bbi: UIBarButtonItem? = UIBarButtonItem(customView: button!)
            
            bbis.append(bbi!)
            
        }
        if type == .NavBtn_Left{
            self.navigationItem.leftBarButtonItems = bbis
        }else{
            self.navigationItem.rightBarButtonItems = bbis
        }
        
        
    }

    
    /// 添加单个按钮
    func createBarButtonItem(_ title: String, _ target: AnyObject, _ action: Selector, _ type: NavbtnType, _ nImage: String, _ hImage: String) {
        
        // 图片大小
        var imageSize: CGSize
        let nimage: UIImage? = UIImage(named: nImage)
        let himage: UIImage? = UIImage(named: hImage)
        
        if (nimage != nil) {
            imageSize = (nimage?.size)!
        }else{
            imageSize = CGSize.init(width: 0, height: 0)
        }
        // 文字大小
        let textSize: CGSize = self.textSize(title, self.textFont())
        
        // 初始化按钮
        let button: UIButton? = UIButton(type: .custom)
        button?.frame = CGRect(x: 0, y: 0, width: imageSize.width+textSize.width+10, height: 30)
        button?.setImage(nimage, for: .normal)
        button?.setImage(himage, for: .highlighted)
        button?.setTitle(title, for: .normal)
        button?.titleLabel?.font = self.textFont()
        button?.setTitleColor(UIColor.white, for: .normal)
        button?.addTarget(target, action: action, for: .touchUpInside)
        
        let bbi: UIBarButtonItem? = UIBarButtonItem(customView: button!)
        if type == .NavBtn_Left{
            self.navigationItem.leftBarButtonItem = bbi
        }else{
            self.navigationItem.rightBarButtonItem = bbi
        }
    }
    
    /// 计算按钮宽度
    func textSize(_ text: String, _ font: UIFont) -> CGSize {
        let nstext: NSString? = NSString(cString: text, encoding: String.Encoding.utf8.rawValue)
        return (nstext!.boundingRect(with: CGSize(width: UIScreen().bounds.width, height: 1000), options: .usesFontLeading, attributes: NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying) as? [String : AnyObject], context: nil).size)
    }
    
    /// 按钮文字大小
    func textFont() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 18)
    }
    
    /// 判断是不是跟VC
    func isRoot() -> Bool {
        var isRoot: Bool = false
        if self.isKind(of: WebVC.self) {
            isRoot = true
        }
        return isRoot
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
