//
//  SecurityUtil.h
//  AES_Demo
//
//  Created by wsk on 2017/8/10.
//  Copyright © 2017年 wsk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityUtil : NSObject
+(NSString*)encryptAESData:(NSString*)string;
+(NSString*)decryptAESData:(NSString *)string;
@end
