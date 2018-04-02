//
//  NSData+AES128.h
//  AES_Demo
//
//  Created by wsk on 2017/8/10.
//  Copyright © 2017年 wsk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES128)
- (NSData *)AES128EncryptWithKey:(NSString *)key gIv:(NSString *)Iv;   //加密
- (NSData *)AES128DecryptWithKey:(NSString *)key gIv:(NSString *)Iv;   //解密
@end
