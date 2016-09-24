//
//  AlipayHelper.h
//  PNeayBy
//
//  Created by wpf on 15/11/21.
//  Copyright © 2015年 wpf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^AlipayResult)(NSDictionary *result);

/////////////////////// 支付宝支付参数 ///////////////////////
#define AlipayPARTNER           @"2088121410617894"
#define AlipaySELLER            @"c@fujin.com"
#define AlipayRSA_PRIVATE       @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAM2/QLZlFA32rBavU/5iM2HhuWphSyV5moC0IRgPyJKDQMylFczQ/XzOB7PZuFc674hcpMaWPe/uknJBFM38w0o+jdg8p/1kVj1JhrMO5MFFxcIjdqJ9uxEwLqy9FXFdcdnnpVrA/Pk65gCxjeHMHNdn4wDDvuPidt07a+qVhFnjAgMBAAECgYEAiQdXkiK/uI0REAq1ZjcBAa/UTYV/BvZ2cEGHyP66FtpTzfglDMQkD3soph/bJj2aSrdpBtoJZkL+RhoSQR6W8Snz1gmx1MjuQGdCd6Pw2Ya2gC3fol1/S2u/lkuMeZtNozHOkegKD7aabG2Ulvo9CrVygwFpopSmumGuxwMeJAECQQDqOTKQEYhD/1FkKb5ZM+na6urc6mB1wTl4rtooU59kBHQkrUiLNX3lTih8MH1589PTQvTTdFfr2HtLMmeN5c6NAkEA4OBImQXDO7k2d70+boJPlY15mJEK3nz7H8lh5+JyZd2kE2GHARBZ7D5NRqAuLmIKapm1rNa5BHPgw1CLvvSmLwJBAJJm1hf/HXGDMViuTvBq5o2TsOINDeYMtOOeR3ZVbpeRwRb7yRBaiyq9Q8j8djG4Gns+qtFRM3OTiN1j0B59ujECQFjiTc+uJ20D2DOb6YFkoHBMazOSoOkwHVKDFt/A8daxtJi0g9g3zlNCjOjNh3Nt7RAVkWmvtZG8+6o3vATOTqECQEi5wuYhDt7TfARauHDpgT35nVogynDnpSc6/8HNLDc437n6a2uMJdeIQIo+usfZhYzzuQ6piH0oU8frTqegU78="

// 直接支付 回调地址
#define AlipayBackPay           @"http://pay.fujin.com/aspx/alipayreturn_app1_qqyw_c.aspx"
// 充值微币 回调地址
#define AlipayBackCharge        @"http://pay.fujin.com/aspx/alipayreturn_app1_chongzhi_c.aspx"



//
//测试商品信息封装在Product中,外部商户可以根据自己商品实际情况定义
//
@interface Product : NSObject{
@private
    float     _price;
    NSString *_subject;
    NSString *_body;
    NSString *_orderId;
    bool _notification;
}

@property (nonatomic, assign) float price;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *orderId;
/**
 * 判断直接支付或者充值微币
 * notification ture直接支付 false充值
 */
@property (nonatomic, assign) bool notification;

@end


@interface AlipayHelper : NSObject

+ (AlipayHelper *)shared;
- (void)alipay:(Product *)product block:(AlipayResult)block;
- (void)aliPayResult:(NSDictionary *)result vc:(UIViewController *)vc;

@end
