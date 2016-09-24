//
//  WechatHelper.m
//  PNeayBy
//
//  Created by wpf on 15/11/15.
//  Copyright © 2015年 wpf. All rights reserved.
//

#import "WechatHelper.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <CommonCrypto/CommonDigest.h>
#import <AFNetworking/AFNetworking.h>
#import "XMLDictionary/XMLDictionary.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "WXApi.h"

@implementation WechatHelper

+ (WechatHelper *)shared
{
    static WechatHelper *_share;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _share = [[WechatHelper alloc]init];
    });
    return _share;
}

- (void)wechatPay:(NSString *)orderID body:(NSString *)body price:(NSString *)price notification:(BOOL)notification
{
    
//    NSLog(@"orderid=%@,body=%@,price=%@,notification=%d",orderID,body,price,notification);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:WeChatAppID forKey:@"appid"];
    [dict setObject:body forKey:@"body"];
    [dict setObject:WeChatMCH_ID forKey:@"mch_id"];
    [dict setObject:[WechatHelper getRandomString] forKey:@"nonce_str"];
    [dict setObject:WeChatBackURL forKey:@"notify_url"];
    [dict setObject:orderID forKey:@"out_trade_no"];
    [dict setObject:[WechatHelper deviceIPAdress] forKey:@"spbill_create_ip"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)(price.floatValue*100)] forKey:@"total_fee"];
    [dict setObject:@"APP" forKey:@"trade_type"];
    
    NSDictionary *params = [WechatHelper partnerSignOrder:dict];
    NSString *postStr = [params XMLString];
    
//    NSLog(@"post=%@",postStr);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.mch.weixin.qq.com/pay/unifiedorder"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
//        NSLog(@"error=%@,responseObject=%@",error,responseObject);
        if(error == nil)
        {
            NSDictionary *dict = [NSDictionary dictionaryWithXMLData:responseObject];
            if(dict != nil)
            {
                PayReq* req             = [[PayReq alloc] init];
                req.partnerId           = WeChatMCH_ID;
                req.prepayId            = [dict objectForKey:@"prepay_id"];
                req.nonceStr            = [dict objectForKey:@"nonce_str"];
                req.timeStamp           = [[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]] intValue];
                req.package             = @"Sign=WXPay";
                
                NSMutableDictionary *rdict = [NSMutableDictionary dictionary];
                [rdict setObject:WeChatAppID forKey:@"appid"];
                [rdict setObject:req.partnerId forKey:@"partnerid"];
                [rdict setObject:req.prepayId forKey:@"prepayid"];
                [rdict setObject:req.nonceStr forKey:@"noncestr"];
                [rdict setObject:[NSString stringWithFormat:@"%u",(unsigned int)req.timeStamp] forKey:@"timestamp"];
                [rdict setObject:req.package forKey:@"package"];
                NSDictionary *result = [WechatHelper partnerSignOrder:rdict];
                
                
                req.sign                = [result objectForKey:@"sign"];
                BOOL wx = [WXApi sendReq:req];
                if(wx) [SVProgressHUD dismiss];
                else [SVProgressHUD showErrorWithStatus:@"跳转微信支付失败！"];
            }
            
        }
        else
        {
            NSLog(@"Error: %@", error);
            [SVProgressHUD showErrorWithStatus:error.domain];
        }
        
    }];
    [dataTask resume];
    

}

+ (NSString *)getRandomString
{
    NSString *str = [NSString stringWithFormat:@"%s",genRandomString(32)];
    return str;
}

char* genRandomString(int length)
{
    int flag, i;
    char* string;
    srand((unsigned) time(NULL ));
    if ((string = (char*) malloc(length)) == NULL )
    {
        //NSLog(@"Malloc failed!flag:14\n");
        return NULL ;
    }
    
    for (i = 0; i < length - 1; i++)
    {
        flag = rand() % 3;
        switch (flag)
        {
            case 0:
                string[i] = 'A' + rand() % 26;
                break;
            case 1:
                string[i] = 'a' + rand() % 26;
                break;
            case 2:
                string[i] = '0' + rand() % 10;
                break;
            default:
                string[i] = 'x';
                break;
        }
    }
    string[length - 1] = '\0';
    return string;
}

+ (NSString *)deviceIPAdress
{
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}

+ (NSMutableDictionary *)partnerSignOrder:(NSDictionary*)paramDic
{
    NSArray *keyArray = [paramDic allKeys];
    // 对字段进行字母序排序
    NSMutableArray *sortedKeyArray = [NSMutableArray arrayWithArray:keyArray];
    [sortedKeyArray sortUsingComparator:^NSComparisonResult(NSString* key1, NSString* key2) {
        return [key1 compare:key2];
    }];
    
    NSMutableString *paramString = [NSMutableString stringWithString:@""];
    // 拼接成 A=B&X=Y
    for (NSString *key in sortedKeyArray)
    {
        if ([paramDic[key] length] != 0)
        {
            [paramString appendFormat:@"&%@=%@", key, paramDic[key]];
        }
    }
    
    if ([paramString length] > 1)
    {
        [paramString deleteCharactersInRange:NSMakeRange(0, 1)];    // remove first '&'
    }
    
    [paramString appendFormat:@"&key=%@", WeChatPARTNER_ID];
    NSString *signString = [[WechatHelper signString:paramString] uppercaseString];
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:paramDic];
    [dict setObject:signString forKey:@"sign"];
    return dict;
}


+ (NSString *)signString:(NSString*)origString
{
    const char *original_str = [origString UTF8String];
    unsigned char result[32];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);//调用md5
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++){
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}


@end
