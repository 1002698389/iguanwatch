//
//  AddContactsViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 15/11/2.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import "AddContactsViewController.h"

#define ORIGINAL_MAX_WIDTH 640.0f



@interface AddContactsViewController ()<UIAlertViewDelegate,VPImageCropperDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,ABPeoplePickerNavigationControllerDelegate,UITextFieldDelegate>
{
    NSString *_photoName;
}
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *telTF;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UIButton *upView;
@property (weak, nonatomic) IBOutlet UIView *downView;


@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionContent;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContraint;

@end

@implementation AddContactsViewController

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    
    self.headImage.layer.cornerRadius = 19;
    self.headImage.layer.masksToBounds = YES;
    
    self.upView.layer.borderColor = RGBACOLOR(185, 185, 185, 1.0).CGColor;
    self.upView.layer.borderWidth = 1;
    
    self.downView.layer.borderColor = RGBACOLOR(185, 185, 185, 1.0).CGColor;
    self.downView.layer.borderWidth = 1;
    
    self.instructionLabel.text = NSLocalizedString(@"addContacts.instruction", @"");
    self.instructionContent.text = NSLocalizedString(@"addContacts.instructionContent", @"");
    
    if (!self.isAdding) {
        [self.instructionLabel removeFromSuperview];
        [self.instructionContent removeFromSuperview];
        [self.view removeConstraint:self.topContraint];
        self.topContraint  = [NSLayoutConstraint constraintWithItem:self.upView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:84];
        [self.view addConstraint:self.topContraint];
    }
    _photoName = @"";

    if (self.isAdding) {
        self.navigationItem.title = NSLocalizedString(@"addContacts.add", @"");
    } else {
        self.navigationItem.title = NSLocalizedString(@"addContacts.modify", @"");
        NSDictionary *singleDic = [self.allContactAry objectAtIndex:self.selectedIndex];
        self.nameTF.text = [singleDic objectForKey:@"name"];
        self.telTF.text = [singleDic objectForKey:@"telNum"];
        [self.headImage sd_setImageWithURL:[NSURL URLWithString:[singleDic objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"contactDefaultHeadImg"]];
        _photoName = [[[[[singleDic objectForKey:@"photo"] componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] firstObject];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)tapToAddHeadImage:(id)sender {
    [self.nameTF resignFirstResponder];
    [self.telTF resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"actsheet.photo", @""), NSLocalizedString(@"actsheet.images", @""), nil];
    [actionSheet showInView:self.view];
}


- (IBAction)showContact:(id)sender {
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    
    [self presentViewController:peoplePicker animated:YES completion:nil];
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.nameTF resignFirstResponder];
    [self.telTF resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -- ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    NSLog(@"%@",person);
    NSLog(@"%d",property);
    NSLog(@"%d",identifier);
    ABMultiValueRef valuesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex index = ABMultiValueGetIndexForIdentifier(valuesRef,identifier);
    if (index < 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"addContacts.addTel", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    CFStringRef value = ABMultiValueCopyValueAtIndex(valuesRef,index);
    
    NSLog(@"%@",value);
    
    NSString *firstName, *lastName, *fullName;
    firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    firstName = [firstName stringByAppendingFormat:@" "];
    
    lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    //    fullName = [lastName stringByAppendingFormat:@"%@",firstName];
    CFStringRef anFullName = ABRecordCopyCompositeName(person);
    fullName = (__bridge NSString *)anFullName;
    NSString *selectedTel = [(__bridge NSString*)value stringByReplacingOccurrencesOfString:@"-" withString:@""];
    BOOL exit = NO;
    for (NSDictionary *dic in self.allContactAry) {
        NSString *singleTel = [NSString stringWithFormat:@"%@",[dic objectForKey:@"telNum"]];
        if ([selectedTel isEqual:singleTel]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"addContacts.telExit", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
            exit = YES;
            break;
        }
    }
    if (!exit) {
        self.telTF.text = selectedTel;
    }
    
    NSLog(@"%@",self.telTF.text);
    
    NSLog(@"%@  %@", fullName, (__bridge NSString*)value);
    
    /*
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/contact/addContactWithDeviceId.do?t=%@&v=1&deviceId=%@&name=%@&telNum=%@&index=%ld&internationalCode=86", DNS, [userdefault valueForKey:@"token"], [userdefault valueForKey:@"deviceId"], fullName, [(__bridge NSString*)value stringByReplacingOccurrencesOfString:@"-" withString:@""], (long)self.contactsIndex];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
//            [self getContacts];
            [peoplePicker dismissViewControllerAnimated:YES completion:^{
                
            }];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"devMessage"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [self dismissViewControllerAnimated:YES completion:^{
            //        self.textField.text = (__bridge NSString*)value;
        }];
    }];
    */
}

#pragma mark -  添加/修改
- (IBAction)addContacts:(id)sender {
    if ([self.nameTF.text isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"addContacts.contactName", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
    } else if ([self.telTF.text isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"addContacts.contactTel", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
    }
    self.submitBtn.userInteractionEnabled = NO;
    
    if (self.isAdding) {
        [self addContact];
    } else {
        [self modifyContact];
    }
}

- (void)addContact {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/contact/addContactWithDeviceId.do?t=%@&v=1&deviceId=%@&name=%@&telNum=%@&index=%lu&internationalCode=86&photo=%@", DNS, [userdefault valueForKey:@"token"], [userdefault valueForKey:@"deviceId"], self.nameTF.text, self.telTF.text, (long)self.contactsIndex, _photoName];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        self.submitBtn.userInteractionEnabled = YES;
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (self.delegate) {
                [self.delegate reloadContacts];
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([[responseObject objectForKey:@"code"] intValue] == -1006) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.expired", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 999;
            [alertView show];
        } else if ([[responseObject objectForKey:@"code"] intValue] == -1007) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.invalid", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 999;
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
        self.submitBtn.userInteractionEnabled = YES;
    }];
}


- (void)modifyContact {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/contact/addContactWithDeviceId.do?t=%@&v=1&deviceId=%@&name=%@&telNum=%@&index=%lu&internationalCode=86&photo=%@", DNS, [userdefault valueForKey:@"token"], [userdefault valueForKey:@"deviceId"], self.nameTF.text, self.telTF.text, (long)self.selectedIndex, _photoName];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        self.submitBtn.userInteractionEnabled = YES;
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (self.delegate) {
                [self.delegate reloadContacts];
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([[responseObject objectForKey:@"code"] intValue] == -1006) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.expired", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 999;
            [alertView show];
        } else if ([[responseObject objectForKey:@"code"] intValue] == -1007) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.invalid", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 999;
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"showToUI"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        }
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
        self.submitBtn.userInteractionEnabled = YES;
    }];
}


#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999) {
        if (buttonIndex == 0) {
//            EMError *error = nil;
//            NSDictionary *info = [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:YES error:&error];
//            if (!error && info) {
//                NSLog(@"退出成功");
//            }
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hadLogged"];
            UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            [self presentViewController:[loginSB instantiateInitialViewController] animated:NO completion:NULL];
            
        }
    }
    
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
            [self.headImage sd_setImageWithURL:nil placeholderImage:[UIImage imageWithData:imageData]];

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
    [self.headImage sd_setImageWithURL:nil placeholderImage:editedImage];
    
    
    NSData *imageData = UIImagePNGRepresentation(editedImage);
//    NSData *imageData = UIImageJPEGRepresentation(editedImage, 0.5);
//    NSLog(@"%lu",(unsigned long)[imageData length]/1024);
    NSString *uuid = [[NSUUID UUID] UUIDString];
    _photoName = uuid;
    [self uploadImageToOSSWithImageData:imageData andImageName:uuid];
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}



- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController  {
    //    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    //    }];
    [cropperViewController.navigationController popViewControllerAnimated:YES];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
