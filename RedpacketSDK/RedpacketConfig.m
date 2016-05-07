//
//  RedpacketConfig.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketConfig.h"

#import "GotyeOCAPI.h"

#import <objc/runtime.h>

#import "YZHRedpacketBridge.h"
#import "RedpacketMessageModel.h"

//	*此为演示地址* App需要修改为自己AppServer上的地址, 数据格式参考此地址给出的格式。
static NSString * const requestUrl = @"http://121.42.52.69:3001/api/sign?duid=";

@interface RedpacketConfig ()

@end

@implementation RedpacketConfig

+ (instancetype)sharedConfig
{
    static RedpacketConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[RedpacketConfig alloc] init];
        [[YZHRedpacketBridge sharedBridge] setDataSource:config];
    });
    return config;
}

+ (void)config
{
    [[self sharedConfig] config];
}

+ (void)logout
{
    [[YZHRedpacketBridge sharedBridge] redpacketUserLoginOut];
}

+ (void)reconfig
{
    [self logout];
    [[self sharedConfig] config];
}

- (void)configWithSignDict:(NSDictionary *)dict
{
    NSString *partner = [dict valueForKey:@"partner"];
    NSString *appUserId = [dict valueForKey:@"user_id"];
    unsigned long timeStamp = [[dict valueForKey:@"timestamp"] unsignedLongValue];
    NSString *sign = [dict valueForKey:@"sign"];
    
    
    [[YZHRedpacketBridge sharedBridge] configWithSign:sign
                                              partner:partner
                                            appUserId:appUserId
                                            timeStamp:timeStamp];
}

- (void)config
{
    if(![[YZHRedpacketBridge sharedBridge] isRedpacketTokenValidate]) {
        NSString *userId = [self userId];
        
        if (userId && ![userId isEqualToString:@""]) {
            
            // 获取应用自己的签名字段。实际应用中需要开发者自行提供相应在的签名计算服务
            
            NSString *urlStr = [NSString stringWithFormat:@"%@%@",requestUrl, userId];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSURLSession *s = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            NSURLSessionTask *t = [s dataTaskWithRequest:request
                                       completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                           if (data) {
                                               NSError *jsonErr = nil;
                                               NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                                              options:0
                                                                                                                error:&jsonErr];
                                               if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                                   [self configWithSignDict:responseObject];
                                               }
                                           }
                                           else {
                                               NSLog(@"request redpacket sign failed:%@", error);
                                           }
                                       }];
            [t resume];
        }
    }
}

- (RedpacketUserInfo *)redpacketUserInfo
{
    RedpacketUserInfo *user = [[RedpacketUserInfo alloc] init];
    
    GotyeOCUser *u = [GotyeOCAPI getLoginUser];
    user.userId = [u name];
    user.userNickname = [u name];
    user.userAvatar = u.icon.url;
    return user;
}

- (NSString *)userId
{
    return [GotyeOCAPI getLoginUser].name;
}

@end
