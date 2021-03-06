//
//  RedpacketConfig.h
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHRedpacketBridgeProtocol.h"

@interface RedpacketConfig : NSObject <YZHRedpacketBridgeDataSource>

+ (void)config;
+ (void)reconfig;
+ (void)logout;
@end
