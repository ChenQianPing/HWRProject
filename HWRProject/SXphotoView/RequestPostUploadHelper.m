//
//  RequestPostUploadHelper.m
//  BoerMobile
//
//  Created by ChenQianPing on 16/3/9.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

#import "RequestPostUploadHelper.h"

@implementation RequestPostUploadHelper

static NSString * const FORM_FLE_INPUT = @"file";

+ (NSString *)postRequestWithURL:(NSString *)url postParems:(NSMutableDictionary *)postParems picFilePath:(NSString *)picFilePath picFileName:(NSString *)picFileName
{
    NSString *TWITTERFON_FORM_BOUNDARY = @"0xKhTmLbOuNdArY";
    // 根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    // 分界线 --AaB03x
    NSString *MPboundary = [[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    // 结束符 AaB03x--
    NSString *endMPboundary = [[NSString alloc]initWithFormat:@"%@--",MPboundary];
    // 得到图片的data
    NSData* data;
    if(picFilePath){
        UIImage *image = [UIImage imageWithContentsOfFile:picFilePath];
        // 判断图片是不是png格式的文件
        if (UIImagePNGRepresentation(image)) {
            // 返回为png图像
            data = UIImagePNGRepresentation(image);
        }else {
            // 返回为JPEG图像
            data = UIImageJPEGRepresentation(image, 1.0);
        }
    }
    // http body的字符串
    NSMutableString *body = [[NSMutableString alloc] init];
    // 参数的集合的所有key的集合
    NSArray *keys = [postParems allKeys];
    // 遍历keys
    for(int i=0;i<[keys count];i++)
    {
        // 得到当前key
        NSString *key=[keys objectAtIndex:i];
        
        // 添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        // 添加字段名称，换2行
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        // 添加字段的值
        [body appendFormat:@"%@\r\n",[postParems objectForKey:key]];
        
        NSLog(@"添加字段的值==%@",[postParems objectForKey:key]);
    }
    
    if(picFilePath){
        // 添加分界线,换行
        [body appendFormat:@"%@\r\n",MPboundary];
        
        // 声明pic字段,文件名为boris.png
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",FORM_FLE_INPUT,picFileName];
        // 声明上传文件的格式
        [body appendFormat:@"Content-Type: image/jpge,image/gif, image/jpeg, image/pjpeg, image/pjpeg\r\n\r\n"];
    }
    
    // 声明结束符：--AaB03x--
    NSString *end = [[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    // 声明myRequestData,用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    
    // 将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    if(picFilePath){
        // 将image的data加入
        [myRequestData appendData:data];
    }
    // 加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 设置HTTPHeader中Content-Type的值
    NSString *content = [[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    // 设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    // 设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    // 设置http body
    [request setHTTPBody:myRequestData];
    // http method
    [request setHTTPMethod:@"POST"];
    
    
    NSHTTPURLResponse *urlResponese = nil;
    NSError *error = [[NSError alloc]init];
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request   returningResponse:&urlResponese error:&error];
    NSString* result= [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    if([urlResponese statusCode] >=200&&[urlResponese statusCode]<300){
        NSLog(@"返回结果=====%@",result);
        return result;
    }
    return nil;
    
}

/**
 * 压缩图片,其实特别简单就是把图片重画了而已
 *
 */
+ (UIImage *)imageWithImageSimple:(UIImage *)image scaledToSize:(CGSize)newSize
{
    // 创建一个bitmap的context,并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(newSize);
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return newImage;
}

/**
 * 保存图片,将图片存入沙盒中的Documents目录下
 *
 */
+ (NSString *)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
{
    NSData* imageData;
    // 判断图片是不是png格式的文件
    if (UIImagePNGRepresentation(tempImage)) {
        // 返回为png图像。
        imageData = UIImagePNGRepresentation(tempImage);
    }else {
        // 返回为JPEG图像。
        imageData = UIImageJPEGRepresentation(tempImage, 1.0);
    }
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    
//    NSArray *nameAry=[fullPathToFile componentsSeparatedByString:@"/"];
//    NSLog(@"===fullPathToFile===%@",fullPathToFile);
//    NSLog(@"===FileName===%@",[nameAry objectAtIndex:[nameAry count]-1]);
    
    [imageData writeToFile:fullPathToFile atomically:NO];
    return fullPathToFile;
}

/**
 * 生成GUID
 */
+ (NSString *)generateUuidString
{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));

    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}
@end
