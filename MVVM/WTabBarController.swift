//
//  WTabBarController.swift
//  CProject
//
//  Created by wpf on 16/9/22.
//  Copyright © 2016年 alex. All rights reserved.
//

import UIKit
import SnapKit

class WTabBarController: UITabBarController {
    
    
    var tabView: UIView = UIView()
    let moveView: UIView = UIView()
    
    let titles: [String] = ["首页","订单查询","我的"]
    var btns: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tabBar.isHidden = true
        
        
        let homeVC: WebVC = WebVC(PD_RootVCURL(.home))
        let homeNav: UINavigationController = UINavigationController(rootViewController: homeVC)
        
        let orderVC: WebVC = WebVC(PD_RootVCURL(.order))
        let orderNav: UINavigationController = UINavigationController(rootViewController: orderVC)
        
        let myVC: WebVC = WebVC(PD_RootVCURL(.my))
        let myNav: UINavigationController = UINavigationController(rootViewController: myVC)
        
        self.setViewControllers([homeNav, orderNav, myNav], animated: false)
        
        
        
        // 自定义TabBar初始化
        self.view.addSubview(self.tabView)
        switch PD_CurrentTabBarType() {
        case .first_Bottom:
            self.initFirstBottom()
        case .second_Top:
            self.initSecondTop()
        }
        
    }
    
    // MARK: - 初始化Tab
    /// 初始化 *第一种* 底部类型 Tab
    func initFirstBottom() -> Void {
        
        self.tabView.backgroundColor = UIColor(white: 248.0/255.0, alpha: 1.0)
        self.tabView.snp.makeConstraints { [unowned self] (make) in
            make.left.equalTo(self.view.snp.left)
            make.bottom.equalTo(self.view)
            make.width.equalTo(PD_Width())
            make.height.equalTo(PD_TabbarHeigth())
        }
        
        let line: UIView = UIView()
        line.backgroundColor = UIColor(white: 150.0/255.0, alpha: 1.0)
        self.tabView.addSubview(line)
        line.snp.makeConstraints { [unowned self] (make) in
            make.left.top.right.equalTo(self.tabView)
            make.height.equalTo(0.5)
        }
        
        for i in 0..<3 {
            
            var name: String = String(format: "tab_%d_n", i)
            var textColor: UIColor = self.firstNormalColor()
            if i==0 {
                name = String(format: "tab_%d_h", i)
                textColor = self.firstHighLightColor()
            }
            
            let btn: UIButton = UIButton(type: .custom)
            btn.setImage(UIImage(named: name)!, for: .normal)
            btn.setTitle(self.titles[i], for: .normal)
            btn.setTitleColor(textColor, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            btn.tag = i
            btn.addTarget(self, action: #selector(self.firstBtnClick), for: .touchUpInside)
            self.tabView.addSubview(btn)
            
            btn.snp.makeConstraints({ [unowned self] (make) in
                make.top.equalTo(self.tabView)
                make.left.equalTo(self.tabView).offset(PD_Width()/3.0*CGFloat(i))
                make.width.equalTo(PD_Width()/3)
                make.height.equalTo(self.tabView)
                })
            self.btns.append(btn)
            
            //            let titleW: CGFloat = (btn.titleLabel?.frame.size.width)!
            let imageW: CGFloat = (btn.imageView?.frame.size.width)!
            
            //            if i == 0 {
            //                print((btn.titleLabel?.frame.size.width)!,(btn.imageView?.frame.size.width)!)
            //                print(titleW,imageW)
            //                print(type(of: titleW),type(of:(btn.titleLabel?.frame.size.width)!))
            //            }
            
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, (btn.titleLabel?.frame.size.width)!/2.0, 15, -(btn.titleLabel?.frame.size.width)!/2.0)
            btn.titleEdgeInsets = UIEdgeInsetsMake(34, -imageW/2.0, 0, imageW/2.0)
            
            
        }
        
        
    }
    
    func firstBtnClick(btn: UIButton) -> Void {
        guard self.btns.count == 3 else {
            return
        }
        
        for i in 0..<3 {
            let tbtn: UIButton = self.btns[i]
            let tname: String = String(format: "tab_%d_n", i)
            tbtn.setImage(UIImage(named: tname)!, for: .normal)
            tbtn.setTitleColor(self.firstNormalColor(), for: .normal)
        }
        let name: String = String(format: "tab_%d_h", btn.tag)
        btn.setImage(UIImage(named: name)!, for: .normal)
        btn.setTitleColor(self.firstHighLightColor(), for: .normal)
        self.selectedIndex = btn.tag
    }
    
    
    /// 初始化 顶部类型 Tab
    func initSecondTop() -> Void {
        self.tabView.backgroundColor = UIColor(white: 248.0/255.0, alpha: 1.0)
        self.tabView.snp.makeConstraints { [unowned self] (make) in
            make.left.equalTo(self.view.snp.left)
            make.top.equalTo(self.view).offset(44+20)
            make.width.equalTo(PD_Width())
            make.height.equalTo(PD_TabbarHeigth())
        }
        
        
        for i in 0..<3 {
            
            let btn: UIButton = UIButton(type: .custom)
            btn.setTitle(self.titles[i], for: .normal)
            btn.setTitleColor(UIColor.black, for: .normal)
            if i == 0 {
                btn.setTitleColor(self.secondHighLightColor(), for: .normal)
            }
            btn.tag = i
            btn.addTarget(self, action: #selector(self.secondBtnClick), for: .touchUpInside)
            self.tabView.addSubview(btn)
            
            btn.snp.makeConstraints({ [unowned self] (make) in
                make.top.equalTo(self.tabView)
                make.left.equalTo(self.tabView).offset(PD_Width()/3.0*CGFloat(i))
                make.width.equalTo(PD_Width()/3)
                make.height.equalTo(self.tabView)
                })
            self.btns.append(btn)
            
        }
        
        self.moveView.backgroundColor = self.secondHighLightColor()
        self.tabView.addSubview(self.moveView)
        self.moveView.snp.makeConstraints { [unowned self] (make) in
            make.left.bottom.equalTo(self.tabView)
            make.width.equalTo(PD_Width()/3.0)
            make.height.equalTo(1)
        }

        
    }
    
    func secondBtnClick(btn: UIButton) -> Void {
        guard self.btns.count == 3 else {
            return
        }
        
        UIView.animate(withDuration: 0.25) { 
            self.moveView.snp.updateConstraints({ [unowned self] (make) in
                make.left.equalTo(self.tabView).offset(PD_Width()/3.0*CGFloat(btn.tag))
                self.tabView.setNeedsLayout()
                self.tabView.layoutIfNeeded()
            })
        }
        
        for i in 0..<3 {
            let tbtn: UIButton = self.btns[i]
            tbtn.setTitleColor(UIColor.black, for: .normal)
        }
        btn.setTitleColor(self.secondHighLightColor(), for: .normal)
        self.selectedIndex = btn.tag
    }
    
    // MARK: - TabBarAnimate
    func showTapView() -> Void {
        
            UIView.animate(withDuration: 0.25) {
                
                self.tabView.snp.updateConstraints({ (make) in
                    make.left.equalTo(self.view).offset(0)
                })
                self.updateConstraint()
                
            }
            
    }
    func hideTapView() -> Void {
        
            UIView.animate(withDuration: 0.25) {
                
                self.tabView.snp.updateConstraints({ (make) in
                    make.left.equalTo(self.view).offset(-PD_Width())
                })
                self.updateConstraint()
            }
        
    }
    func updateConstraint() -> Void {
        self.tabBar.isHidden = true
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    
    // MARK: - ThisVCSetting
    func firstNormalColor() -> UIColor {
        return UIColor(white: 146.0/255.0, alpha: 1.0)
    }
    func firstHighLightColor() -> UIColor {
        return UIColor(red: 33.0/255.0, green: 139.0/255.0, blue: 251.0/255.0, alpha: 1.0)
    }
    func secondHighLightColor() -> UIColor {
        return UIColor(red: 58.0/255.0, green: 194.0/255.0, blue: 126.0/255.0, alpha: 1)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
