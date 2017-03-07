//
//  do_Alipay1_SM.m
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_Alipay1_SM.h"

#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import "doJsonHelper.h"
#import "do_Alipay1_App.h"
#import "doServiceContainer.h"
#import "doIModuleExtManage.h"
#import <AlipaySDK/AlipaySDK.h>
#import "doServiceContainer.h"
#import "doILogEngine.h"

@implementation do_Alipay1_SM
{
    id<doIScriptEngine> _scritEngine;
    NSString *_callbackName;
}
#pragma mark - 方法
#pragma mark - 同步异步方法的实现
//同步
//异步
- (void)pay:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    _callbackName = [parms objectAtIndex:2];
    //回调函数名_callbackName
    
    //_invokeResult设置返回值
    
    NSString *orderString = [doJsonHelper GetOneText:_dictParas :@"orderStr" :@""];
    
    NSString *appID = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"doAlipay.plist" :@"APPID"];
    NSString *appScheme = [NSString stringWithFormat:@"alipay%@",appID];;
    do_Alipay1_App *alipay = [do_Alipay1_App Instance];
    alipay.OpenURLScheme = appScheme;
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        
        doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
        [_invokeResult SetResultNode:resultDic];
        [_scritEngine Callback:_callbackName :_invokeResult];
    }];
    
}

- (void)auth:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    _callbackName = [parms objectAtIndex:2];
    NSString *authInfo = [doJsonHelper GetOneText:_dictParas :@"authInfo" :@""];
    
    
    NSString *appID = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"doAlipay.plist" :@"APPID"];
    NSString *appScheme = [NSString stringWithFormat:@"alipay%@",appID];;
    do_Alipay1_App *alipay = [do_Alipay1_App Instance];
    alipay.OpenURLScheme = appScheme;
    
    if (authInfo.length > 0) {
        [[AlipaySDK defaultService] auth_V2WithInfo:authInfo fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            if (!result) {
                result = @"";
            }
            NSString *authCode = @"";
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }

            NSDictionary *dict = @{@"resultStatus":authCode,@"result":result,@"memo":@""};
            doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
            [_invokeResult SetResultNode:dict];
            [_scritEngine Callback:_callbackName :_invokeResult];
        }];

    }
}
- (void)callback:(NSDictionary *)dict
{
    if(_scritEngine)
    {
        doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
        [_invokeResult SetResultNode:dict];
        [_scritEngine Callback:_callbackName :_invokeResult];
    }
}
@end