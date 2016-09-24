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
