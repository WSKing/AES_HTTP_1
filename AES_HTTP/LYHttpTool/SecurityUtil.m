//
//  SecurityUtil.m
//  AES_Demo
//
//  Created by wsk on 2017/8/10.
//  Copyright © 2017年 wsk. All rights reserved.
//

#import "SecurityUtil.h"
#import "NSData+AES128.h"
#define Iv          @"9686565389854618" //偏移量,可自行修改
#define KEY         @"ig2BTzDbz86fge5t" //key，可自行修改
@implementation SecurityUtil
//加密
+(NSString*)encryptAESData:(NSString*)string
{
    //将nsstring转化为nsdata
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //使用密码对nsdata进行加密
    NSData *encryptedData = [data AES128EncryptWithKey:KEY gIv:Iv];
    //进行base64进行转码的加密字符串
    NSString *base64String = [encryptedData base64EncodedStringWithOptions:0];
    return base64String;
}

//解密
+(NSString*)decryptAESData:(NSString *)string
{
    //base64解密
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:0];
    //使用密码对data进行解密
    NSData *decryData = [data AES128DecryptWithKey:KEY gIv:Iv];
    //将解了密码的nsdata转化为nsstring
    NSString *str = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
    return str;
}

@end
