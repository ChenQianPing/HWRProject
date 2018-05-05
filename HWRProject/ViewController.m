//
//  ViewController.m
//  HWRProject
//
//  Created by ChenQianPing on 16/4/27.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

#import "ViewController.h"
#import "SXPickPhoto.h"
#import "RequestPostUploadHelper.h"
#import "UrlDefine.h"

@interface ViewController ()
{

}

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
- (IBAction)cameraButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblResult;

@property (nonatomic,strong)  SXPickPhoto * pickPhoto;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
     _pickPhoto = [[SXPickPhoto alloc]init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 提示框
- (void)aleShowView
{
    UIAlertAction * act1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    
    // 拍照
    UIAlertAction * act2 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 打开相机
        [_pickPhoto ShowTakePhotoWithController:self andWithBlock:^(NSObject *Data) {
            if ([Data isKindOfClass:[UIImage class]])
            {
                UIImage *image = (UIImage *)Data;
                [self.cameraButton setImage:image forState:UIControlStateNormal];
                self.lblResult.text = [self postUpload:image];
            }
        }];
    }];
    
    // 相册
    UIAlertAction * act3 = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 打开相册
        [_pickPhoto SHowLocalPhotoWithController:self andWithBlock:^(NSObject *Data) {
            if ([Data isKindOfClass:[UIImage class]])
            {
                UIImage *image = (UIImage *)Data;
                [self.cameraButton setImage:image forState:UIControlStateNormal];
                self.lblResult.text = [self postUpload:image];
            }
        }];
        
    }];
    
    UIAlertController * aleVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"选择图片" preferredStyle:UIAlertControllerStyleActionSheet];
    [aleVC addAction:act1];
    [aleVC addAction:act2];
    [aleVC addAction:act3];
    
    [self presentViewController:aleVC animated:YES completion:nil];
}

- (NSString *)postUpload:(UIImage*)image
{
    // 存储图像 120*120 210*210 98k 440*440 359k
    UIImage *newImg = [RequestPostUploadHelper imageWithImageSimple:image scaledToSize:CGSizeMake(210, 210)];
    
    NSString *picFilePath = [RequestPostUploadHelper saveImage:newImg WithName:[NSString stringWithFormat:@"%@%@",[RequestPostUploadHelper generateUuidString],@".jpg"]];
    
    // 将字符串切割成数组
    NSArray *nameAry = [picFilePath componentsSeparatedByString:@"/"];
    NSString *picFileName = [nameAry objectAtIndex:[nameAry count]-1];
    
    NSString *url = HWR_API;
    
    // 上传图像
    return [RequestPostUploadHelper postRequestWithURL:url postParems:nil picFilePath:picFilePath picFileName:picFileName];
}


- (IBAction)cameraButtonClick:(id)sender {
    [self aleShowView];
}
@end
