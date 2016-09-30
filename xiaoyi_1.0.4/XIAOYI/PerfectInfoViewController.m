//
//  PerfectInfoViewController.m
//  XIAOYI
//
//  Created by 王帅 on 15/11/1.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import "PerfectInfoViewController.h"

#import "QRViewController.h"

#define ORIGINAL_MAX_WIDTH 640.0f



@interface PerfectInfoViewController ()<VPImageCropperDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,QRcodeDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) NSString *photoName;
//@property (weak, nonatomic) IBOutlet UIImageView *headImage;



@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UITextField *watchIdTF;
@property (weak, nonatomic) IBOutlet UITextField *selfName;

@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@end

@implementation PerfectInfoViewController

- (IBAction)dismissKeyboard:(id)sender {
    [self.watchIdTF resignFirstResponder];
//    [self.watchUserName resignFirstResponder];
    [self.selfName resignFirstResponder];
    [self doDismissKeyboardAnimation];
}

#pragma mark - UITextField Delegate
//UITextField的协议方法，当开始编辑时监听
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + frame.size.height - (self.view.frame.size.height - 258.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self doDismissKeyboardAnimation];
    
    return YES;
}

#pragma mark -
- (void)doDismissKeyboardAnimation {
    [UIView beginAnimations:@"ruturnForKeyboard" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}



- (IBAction)goBack:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];

    if (self.bindingInWhere == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.parentViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)presentQRcodeVC {
    
    switch (self.bindingInWhere) {
        case 1: //在登录sb进行绑定
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
            QRViewController *one = [storyboard instantiateViewControllerWithIdentifier:@"BindingByQRCode"];
            one.delegate = self;
            one.bindingFrom = 1;
            [self presentViewController:one animated:NO completion:NULL];
        }
            break;
        case 2: //在主页sb进行绑定
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            QRViewController *one = [storyboard instantiateViewControllerWithIdentifier:@"QRcodeScan"];
            one.delegate = self;
            one.bindingFrom = 2;
            [self.navigationController pushViewController:one animated:NO];
//            PP_RELEASE(one);
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.submitBtn.layer.cornerRadius = 15;
    self.submitBtn.layer.borderWidth = 2;
    self.submitBtn.layer.borderColor = [[UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:101.0/255.0 alpha:1.0] CGColor];
    [self.backBtn setImage:[UIImage imageNamed:NSLocalizedString(@"perfectInfoVC.back", @"")] forState:UIControlStateNormal];
    
    if (self.bindingInWhere == 2) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    if (self.selectedQRcode == 1) {
        [self presentQRcodeVC];
    }

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.qrcodeWatchId) {
        self.watchIdTF.text = self.qrcodeWatchId;
    }
    
    NSLog(@"%d",self.selectedQRcode);
}



- (void)doCancelScanQRcode {
//    [self.navigationController popViewControllerAnimated:NO];
    switch (self.bindingInWhere) {
        case 1:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 2:
        {
            [self.parentViewController dismissViewControllerAnimated:NO completion:NULL];

        }
            break;
            
        default:
            break;
    }
}

- (void)scanCompleteWithWatchId:(NSString *)resultValue {
    self.watchIdTF.text = resultValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)chooseHeadImage:(UITapGestureRecognizer *)sender {
    
    [self.watchIdTF resignFirstResponder];
//    [self.watchUserName resignFirstResponder];
    [self.selfName resignFirstResponder];
    [self doDismissKeyboardAnimation];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选取", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - 扫一扫
- (IBAction)doScan:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
    QRViewController *one = [storyboard instantiateViewControllerWithIdentifier:@"BindingByQRCode"];
    one.delegate = self;
    one.bindingFrom = 1;
    [self presentViewController:one animated:NO completion:NULL];
}

#pragma mark - OSS上传照片
- (void)uploadImageToOSSWithImageData:(NSData *)imageData andImageName:(NSString *)imageName
{
    
    NSString *endpoint = @"http://oss-cn-qingdao.aliyuncs.com";
    // 由阿里云颁发的AccessKeyId/AccessKeySecret构造一个CredentialProvider。
    // 明文设置secret的方式建议只在测试时使用，更多鉴权模式请参考后面的访问控制章节。
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:@"lp1oxG2LClmluY8o" secretKey:@"275pq9UTN172i0UmUIDsquIDYIo0ke"];
    
    OSSClient *client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
    //    client
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    
    put.bucketName = @"ig-user-photo";
    put.objectKey = [imageName stringByAppendingString:@".png"];
    
    put.uploadingData = imageData; // 直接上传NSData
    
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    
    OSSTask * putTask = [client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"upload object success!");
            
//            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            NSString *urlString = [NSString stringWithFormat:@"http://%@/file/addUploadInfo.do?v=1&uuid=%@&bizName=%@&bizType=%@&size=%@&extension=%@",DNS,imageName,@"",@"4",[NSString stringWithFormat:@"%lu",(unsigned long)[imageData length]],@"png"];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                NSLog(@"%@",responseObject);
                NSLog(@"%@",[responseObject objectForKey:@"devMessage"]);
                NSLog(@"%@",[responseObject objectForKey:@"showToUI"]);
                
            } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                NSLog(@"%@",error);
//                [Hint showAlertIn:self.view WithMessage:@"头像上传失败"];
            }];
            
            
        } else {
            NSLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
    
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
//    self.headImage.image = editedImage;
    
    NSData *imageData = UIImagePNGRepresentation(editedImage);
    NSString *uuid = [[NSUUID UUID] UUIDString];
    self.photoName = uuid;
    [self uploadImageToOSSWithImageData:imageData andImageName:uuid];
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}



- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    //    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    //    }];
    [cropperViewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"拍照");
            
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                
                if ([self isFrontCameraAvailable]) {
//                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;//前置摄像头
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;//后置摄像头
                }
                controller.delegate = self;
                [controller setAllowsEditing:YES];
                if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
                    self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
                }
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }
            break;
        case 1:
        {
            NSLog(@"从相册选择");
            if ([self isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    portraitImg = [self imageByScalingToMaxSize:portraitImg];
    // present the cropper view controller
    VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
    imgCropperVC.delegate = self;
    [picker pushViewController:imgCropperVC animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}


#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}


#pragma mark -
- (IBAction)doComplete:(id)sender {
    
//    [self presentQRcodeVC];
//    return;
    
    if ([self.selfName.text isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.nickname", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    } /*else if ([self.watchUserName.text isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:@"请输入手表佩戴者名称" delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
    }*/
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/userAddWatch.do?t=%@&watchSN=%@&careName=%@&photo=%@&showName=%@",DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], self.watchIdTF.text, /*self.watchUserName.text*/@"", self.photoName, self.selfName.text];
    
//    NSLog(@"%@",urlStr);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"perfectInfoVC.bindingSuccess", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 1010;
            [alertView show];
            
            
            
        } else if ([[responseObject objectForKey:@"code"] intValue] == 1005) {
            NSLog(@"%@",[responseObject objectForKey:@"devMessage"]);
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[[[responseObject objectForKey:@"devMessage"] componentsSeparatedByString:@"。"] lastObject] message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([[responseObject objectForKey:@"code"] intValue] == -1006 || [[responseObject objectForKey:@"code"] intValue] == -1007) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
//            alertView.tag = 999;
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert.bindFails", @"") message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

    }];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1010) {
        switch (self.bindingInWhere) {
            case 1: //登陆界面进绑定
            {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hadLogged"];
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
                break;
            case 2: //主页面进绑定
            {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
                break;
            default:
                break;
        }
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqual:@"showQRScanInLoginSB"]) {
        QRViewController *qrVC = [segue destinationViewController];
        qrVC.bindingFrom = self.bindingInWhere;
        qrVC.delegate = self;
    }
    
}


@end
