//
//  OriginalHttpTool.m
//  AES_Demo
//
//  Created by wsk on 2017/8/14.
//  Copyright © 2017年 wsk. All rights reserved.
//

#import "OriginalHttpTool.h"
#import "SecurityUtil.h"
#import <CoreFoundation/CoreFoundation.h>
@implementation OriginalHttpTool


+ (void)POSTWithParams:(NSDictionary *)params success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure {
    //异步请求
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HTTP_HOST,@"?appinterface"]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        request.HTTPMethod = @"POST";
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSLog(@"%@",params);
        //字典转data
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        //data转字符串
        NSString *jsonstr =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //字符串加密
        NSString *securityStr = [SecurityUtil encryptAESData:jsonstr];
        //转data作为body
        request.HTTPBody = [securityStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //返回主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    failure(error);
                }else{
                    NSString *text = [[NSString alloc]initWithData:data encoding:   NSUTF8StringEncoding];
                    //去掉空格和换行
                    text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    NSString *result = [SecurityUtil decryptAESData:text];
                    NSDictionary *dic = [OriginalHttpTool dictionaryWithJsonString:result];
                    success(dic);
                }
            });

        }];
        [task resume];
    });
}

//字符串转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


-(NSString *)PostImagesToServer:(NSString *) strUrl dicPostParams:(NSMutableDictionary *)params dicImages:(NSMutableArray *) dicImages{
    
    NSString * res;
    
    //分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    
    //根据url初始化request
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    
    //要上传的图片
    UIImage *image;
    
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    
    //参数的集合的所有key的集合
    NSArray *keys= [params allKeys];
    
    //遍历keys
    for(int i=0;i<[keys count];i++) {
        
        //得到当前key
        NSString *key=[keys objectAtIndex:i];
        
        //如果key不是pic，说明value是字符类型，比如name：Boris
        //添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        
        //添加字段名称，换2行
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        
        //添加字段的值
        [body appendFormat:@"%@\r\n",[params objectForKey:key]];
        
    }
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    //循环加入上传图片
    for(int i = 0; i< [dicImages count] ; i++){
        
        //要上传的图片
        image = [dicImages objectAtIndex:i];
        
        //得到图片的data
        NSData *data =UIImageJPEGRepresentation(image, 0.3);
        NSMutableString *imgbody = [[NSMutableString alloc] init];
        
        //此处循环添加图片文件
        //添加分界线，换行
        [imgbody appendFormat:@"%@\r\n",MPboundary];
        [imgbody appendFormat:@"Content-Disposition: form-data; name=\"file[]\"; filename=\"%@.jpg\"\r\n",[dicImages objectAtIndex:i]];
        
        //声明上传文件的格式
        [imgbody appendFormat:@"Content-Type: image/jpeg; charset=utf-8\r\n\r\n"];
        NSLog(@"上传的图片：%d  %@", i, [dicImages objectAtIndex:i]);
        
        //将body字符串转化为UTF8格式的二进制
        [myRequestData appendData:[imgbody dataUsingEncoding:NSUTF8StringEncoding]];
        
        //将image的data加入
        [myRequestData appendData:data];
        [myRequestData appendData:[ @"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"%@\r\n",endMPboundary];
    
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    
    //设置http body
    [request setHTTPBody:myRequestData];
    
    //http method
    [request setHTTPMethod:@"POST"];
    
    //设置接受response的data
    NSData *mResponseData;
    NSError *err = nil;
    mResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
    if(mResponseData == nil){
        NSLog(@"err code : %@", [err localizedDescription]);
    }
    res = [[NSString alloc] initWithData:mResponseData encoding:NSUTF8StringEncoding];
    NSLog(@"服务器返回：%@", res);
    return res;
}

@end
