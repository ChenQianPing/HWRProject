//
//  SXPickPhoto.m
//  SXPickphotos
//
//  Created by ShaoPro on 15/12/25.
//  Copyright © 2015年 ShaoPro. All rights reserved.
//

#import "SXPickPhoto.h"
#import "UIImage+FixOrientation.h"

@implementation SXPickPhoto

- (instancetype)init
{
    if ([super init])
    {
      _picker = [[UIImagePickerController alloc] init];
    }
    return self;
}
/**
 *  打开相机:
 *
 *  @param object 控制器对象
 */
- (void)ShowTakePhotoWithController: (UIViewController *)Controller
                       andWithBlock: (myblock)block
{
    // 回调
    _myblock = block;
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
  
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
   
    {
        _picker.delegate = self;
        // 设置拍照后的图片可被编辑
        _picker.allowsEditing = YES;
        _picker.sourceType = sourceType;
        [Controller presentViewController:_picker animated:YES completion:nil];
    }
    else
    {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
   
}

/**
 *  选择相册
 *
 *  @param Controller 控制器对象
 */
- (void)SHowLocalPhotoWithController: (UIViewController *)Controller
                        andWithBlock: (myblock)block
{
    _myblock = block;
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _picker.delegate = self;
    // 设置选择后的图片可被编辑
    _picker.allowsEditing = YES;
    [Controller presentViewController:_picker animated:YES completion:nil];
}


// 当一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    [_picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    // 当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
     {
         // 图片可编辑
          UIImage *newHeaderImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
          newHeaderImage = [newHeaderImage fixOrientation];
         
         if (_myblock)
         {
             _myblock(newHeaderImage);
             [_picker dismissViewControllerAnimated:YES completion:nil];
         }
     }
    
}

// 取消选择照片:
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:nil];
   
}
@end
