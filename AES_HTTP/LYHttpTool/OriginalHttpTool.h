//
//  OriginalHttpTool.h
//  AES_Demo
//
//  Created by wsk on 2017/8/14.
//  Copyright © 2017年 wsk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface OriginalHttpTool : NSObject

/**
 普通的POST数据请求

 @param params 参数
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)POSTWithParams:(NSDictionary *)params success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;
@end
