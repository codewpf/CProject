//
//  WechatHelper.h
//  PNeayBy
//
//  Created by wpf on 15/11/15.
//  Copyright © 2015年 wpf. All rights reserved.
//

#import <Foundation/Foundation.h>

/////////////////////// 微信支付参数 ///////////////////////
#define WeChatAppID             @"wx79e8f6b339936f25"
#define WeChatAppSecret         @"2ae23adffcd252bd39d63cb169b27d65"
// 商户号，填写商户对应参数
#define WeChatMCH_ID            @"1288989101"
// 商户API密钥，填写相应参数
#define WeChatPARTNER_ID        @"q1177833q1177833q1177833q1177833"
// 直接支付 回调地址
#define WeChatBackURL           @"http://pay.fujin.com/ashx/WeiXinPayNotify.ashx"


@interface WechatHelper : NSObject

+ (WechatHelper *)shared;

/**
 * 支付
 */
- (void)wechatPay:(NSString *)orderID body:(NSString *)body price:(NSString *)price notification:(BOOL)notification;
/**
 * 获取32为随机字符串
 */
+ (NSString *)getRandomString;
/**
 * 获取用户IP地址
 */
+ (NSString *)deviceIPAdress;
/**
 * 签名，并返回添加签名的完整字典
 */
+ (NSMutableDictionary *)partnerSignOrder:(NSDictionary*)paramDic;
/**
 * MD5 签名
 */
+ (NSString *)signString:(NSString*)origString;

@end
