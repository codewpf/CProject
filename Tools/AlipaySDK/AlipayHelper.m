//
//  AlipayHelper.m
//  PNeayBy
//
//  Created by wpf on 15/11/21.
//  Copyright © 2015年 wpf. All rights reserved.
//

#import "AlipayHelper.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import <SVProgressHUD/SVProgressHUD.h>

/////////////////////// 支付宝支付参数 ///////////////////////
#define AlipayPARTNER           @"2088121410617894"
#define AlipaySELLER            @"c@fujin.com"
#define AlipayRSA_PRIVATE       @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAM2/QLZlFA32rBavU/5iM2HhuWphSyV5moC0IRgPyJKDQMylFczQ/XzOB7PZuFc674hcpMaWPe/uknJBFM38w0o+jdg8p/1kVj1JhrMO5MFFxcIjdqJ9uxEwLqy9FXFdcdnnpVrA/Pk65gCxjeHMHNdn4wDDvuPidt07a+qVhFnjAgMBAAECgYEAiQdXkiK/uI0REAq1ZjcBAa/UTYV/BvZ2cEGHyP66FtpTzfglDMQkD3soph/bJj2aSrdpBtoJZkL+RhoSQR6W8Snz1gmx1MjuQGdCd6Pw2Ya2gC3fol1/S2u/lkuMeZtNozHOkegKD7aabG2Ulvo9CrVygwFpopSmumGuxwMeJAECQQDqOTKQEYhD/1FkKb5ZM+na6urc6mB1wTl4rtooU59kBHQkrUiLNX3lTih8MH1589PTQvTTdFfr2HtLMmeN5c6NAkEA4OBImQXDO7k2d70+boJPlY15mJEK3nz7H8lh5+JyZd2kE2GHARBZ7D5NRqAuLmIKapm1rNa5BHPgw1CLvvSmLwJBAJJm1hf/HXGDMViuTvBq5o2TsOINDeYMtOOeR3ZVbpeRwRb7yRBaiyq9Q8j8djG4Gns+qtFRM3OTiN1j0B59ujECQFjiTc+uJ20D2DOb6YFkoHBMazOSoOkwHVKDFt/A8daxtJi0g9g3zlNCjOjNh3Nt7RAVkWmvtZG8+6o3vATOTqECQEi5wuYhDt7TfARauHDpgT35nVogynDnpSc6/8HNLDc437n6a2uMJdeIQIo+usfZhYzzuQ6piH0oU8frTqegU78="

// 直接支付 回调地址
#define AlipayBackPay           @"http://pay.fujin.com/aspx/alipayreturn_app1_qqyw_c.aspx"
// 充值微币 回调地址
#define AlipayBackCharge        @"http://pay.fujin.com/aspx/alipayreturn_app1_chongzhi_c.aspx"


@implementation Product


@end

@implementation AlipayHelper

+ (AlipayHelper *)shared
{
    static AlipayHelper *_alipay;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _alipay = [[AlipayHelper alloc]init];
    });
    return _alipay;
}


- (void)alipay:(Product *)product block:(AlipayResult)block
{
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = AlipayPARTNER;
    NSString *seller = AlipaySELLER;
    NSString *privateKey = AlipayRSA_PRIVATE;
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"缺少partner或者seller或者私钥。" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = product.orderId; //订单ID（由商家自行制定）
    order.productName =  product.subject; //商品标题
    order.productDescription = product.body; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",product.price]; //商品价格
    order.notifyURL = (product.notification)?AlipayBackPay:AlipayBackCharge; //回调URL ture直接支付 false充值
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSLog(@"scheme=%@",appScheme);
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            
            
            
            NSLog(@"reslut = %@",resultDic);
            block(resultDic);
        }];
        
    }

}

- (void)aliPayResult:(NSDictionary *)result vc:(UIViewController *)vc
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"result = %@",result);

        NSString *message = @"";
        switch([[result objectForKey:@"resultStatus"] integerValue])
        {
            case 9000:message = @"订单支付成功";break;
            case 8000:message = @"正在处理中";break;
            case 4000:message = @"订单支付失败";break;
            case 6001:message = @"用户中途取消";break;
            case 6002:message = @"网络连接错误";break;
            default:message = @"未知错误";
        }
        [SVProgressHUD dismiss];
        UIAlertController *aalert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [aalert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc presentViewController:aalert animated:YES completion:nil];
        });
        
        

    });
    

}


#pragma mark - 产生随机订单号


- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

@end
