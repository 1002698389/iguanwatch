//
//  UserInfoViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/5.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "UserInfoViewController.h"
#import "AppDelegate.h"
#import "Hint.h"

#import "UserHeadCell.h"
#import "UserContentCell.h"

#import "WatchChangeCustomViewController.h"
#import "SexSelectViewController.h"

#define ORIGINAL_MAX_WIDTH 640.0f


@interface UserInfoViewController ()<VPImageCropperDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate,ChangeCustomInfoDelegate,ChangeSexDelegate>
{
    BOOL _doChange;
    NSInteger _selecedImageFormWhere; //1：相机 2：相册
    NSString *_photoUrl;
    NSString *_sexIndex;
    NSArray *_pickerArray;
    NSInteger _selectedSexRow;
    NSString *_nickName;
    NSString *_genderIndex;
    NSString *_age;
    NSInteger _selectedRow;
    
}

//@property (weak, nonatomic) IBOutlet UIImageView *headImage;
//@property (weak, nonatomic) IBOutlet UITextField *nameTF;
//@property (weak, nonatomic) IBOutlet UITextField *sexTF;
//@property (weak, nonatomic) IBOutlet UITextField *ageTF;
//@property (strong, nonatomic) IBOutlet UIPickerView *sexPicker;
//@property (strong, nonatomic) IBOutlet UIToolbar *sexTool;

@property (nonatomic, strong) NSString *photoUrl;

@property (nonatomic, strong) AppDelegate *myDelegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation UserInfoViewController


- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)changeUserInfo:(UIButton *)sender {
    /*
    _doChange = !_doChange;
    if (_doChange) {
        [sender setTitle:NSLocalizedString(@"save", @"") forState:UIControlStateNormal];
        self.nameTF.userInteractionEnabled = YES;
        self.sexTF.userInteractionEnabled = YES;
        self.ageTF.userInteractionEnabled = YES;
        self.headImage.userInteractionEnabled = YES;
    } else {
        [sender setTitle:NSLocalizedString(@"appUserInfoVC.modify", @"") forState:UIControlStateNormal];
        self.nameTF.userInteractionEnabled = NO;
        self.sexTF.userInteractionEnabled = NO;
        self.ageTF.userInteractionEnabled = NO;
        self.headImage.userInteractionEnabled = NO;
        [self doChangeUserInfo];
    }
    */
    
    [self doChangeUserInfo];

}
#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pickerArray = [NSArray arrayWithObjects:NSLocalizedString(@"sexSelectVC.man", @""), NSLocalizedString(@"sexSelectVC.weman", @""), nil];
    _photoUrl = @"";
//    self.sexTF.inputView = self.sexPicker;
//    self.sexTF.inputAccessoryView = self.sexTool;
//    self.nameTF.userInteractionEnabled = NO;
//    self.sexTF.userInteractionEnabled = NO;
//    self.ageTF.userInteractionEnabled = NO;

    self.myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    self.myDelegate = [[UIApplication sharedApplication] delegate];
    
    _nickName = [self.userInfo objectForKey:@"nickname"];
    NSInteger sexIndex = [[self.userInfo objectForKey:@"gender"] integerValue];
    switch (sexIndex) {
        case 0:
        {
            _sexIndex = @"0";
        }
            break;
        case 1:
        {
            _sexIndex = @"1";
        }
            break;
            
        default:
            break;
    }
    _age = [NSString stringWithFormat:@"%@",[self.userInfo objectForKey:@"age"]];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
    
    
    
    NSString *str = [[[self.userInfo objectForKey:@"photo"] componentsSeparatedByString:@"/"] lastObject];
    _photoUrl = [[str componentsSeparatedByString:@"."] firstObject];
    
    /*
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:[self.userInfo objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"headImageDefault"]];
    self.nameTF.text = [self.userInfo objectForKey:@"nickname"];
    NSInteger sexIndex = [[self.userInfo objectForKey:@"gender"] integerValue];
    switch (sexIndex) {
        case 0:
        {
            self.sexTF.text = NSLocalizedString(@"sexSelectVC.weman", @"");
            _sexIndex = @"0";
            [self.sexPicker selectRow:1 inComponent:0 animated:NO];
        }
            break;
        case 1:
        {
            self.sexTF.text = NSLocalizedString(@"sexSelectVC.man", @"");
            _sexIndex = @"1";
            [self.sexPicker selectRow:0 inComponent:0 animated:NO];
        }
            break;
            
        default:
            break;
    }
    self.ageTF.text = [NSString stringWithFormat:@"%@",[self.userInfo objectForKey:@"age"]];
    */
//    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 保存
- (void)doChangeUserInfo {
    NSString *urlString = [NSString stringWithFormat:@"http://%@/user/setUserDetail.do?t=%@&nickname=%@&gender=%@&photo=%@&age=%@", DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], _nickName, _sexIndex, _photoUrl, _age];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@", responseObject);
        NSLog(@"%@", [responseObject objectForKey:@"showToUI"]);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"setting.saveSuccess", @"")];
            
            NSNotification *notification = [NSNotification notificationWithName:@"refreshWatchData" object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            [self performSelector:@selector(goBack) withObject:nil afterDelay:1.0];
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
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
    }];
    
}


#pragma mark - UITextFeild Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIPickerView Delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _pickerArray.count;
}
-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [_pickerArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selectedSexRow = row;
    
}

/*
#pragma mark - Choose Sex
- (IBAction)chooseSex:(id)sender {
    [self.sexTF resignFirstResponder];
    self.sexTF.text = [_pickerArray objectAtIndex:_selectedSexRow];
    switch (_selectedSexRow) {
        case 0:
            _sexIndex = @"1";
            break;
        case 1:
            _sexIndex = @"0";
            break;
        default:
            break;
    }
}


- (IBAction)chooseImage:(id)sender {
    [self.sexTF resignFirstResponder];
    [self.ageTF resignFirstResponder];
    [self.nameTF resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"actsheet.photo", @""), NSLocalizedString(@"actsheet.images", @""), nil];
    [actionSheet showInView:self.view];
}
 */

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
            
//            [self.headImage sd_setImageWithURL:nil placeholderImage:[UIImage imageWithData:imageData]];

            NSString *urlString = [NSString stringWithFormat:@"http://%@/file/addUploadInfo.do?v=1&uuid=%@&bizName=%@&bizType=%@&size=%@&extension=%@",DNS,imageName,@"",@"4",[NSString stringWithFormat:@"%lu",(unsigned long)[imageData length]],@"png"];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                NSLog(@"%@",responseObject);
                NSLog(@"%@",[responseObject objectForKey:@"devMessage"]);
                NSLog(@"%@",[responseObject objectForKey:@"showToUI"]);
                _photoUrl = imageName;
                
                
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
    
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:10001];
    imageView.image = editedImage;
    
    NSData *imageData = UIImagePNGRepresentation(editedImage);
//    NSData *imageData = UIImageJPEGRepresentation(editedImage, 0.6); //压缩图片
    NSString *uuid = [[NSUUID UUID] UUIDString];
    //    self.photoName = uuid;
    [self uploadImageToOSSWithImageData:imageData andImageName:uuid];
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
    
}



- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    
    switch (_selecedImageFormWhere) {
        case 1:
            [cropperViewController dismissViewControllerAnimated:YES completion:^{
            }];
            break;
        case 2:
            [cropperViewController.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
    //    [cropperViewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"拍照");
            _selecedImageFormWhere = 1;
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([self isFrontCameraAvailable]) {
                    //                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;//前置摄像头
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;//后置摄像头
                    
                }
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
        case 1:
        {
            NSLog(@"从相册选择");
            _selecedImageFormWhere = 2;
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



- (void)doLogout {
//    EMError *error = nil;
//    NSDictionary *info = [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:YES error:&error];
//    if (!error && info) {
//        NSLog(@"退出成功");
//    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hadLogged"];
    UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    [self presentViewController:[loginSB instantiateInitialViewController] animated:NO completion:^{
        [self.revealSideViewController popViewControllerWithNewCenterController:self.myDelegate.navc animated:NO];
    }];
    
}

#pragma mark - UITable View Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            return 1;
        }
            break;
        case 1:
        {
            return 3;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"userHeadcell";
        UserHeadCell *headCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!headCell) {
            headCell = [[UserHeadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
        }
        headCell.headImage.tag = 10001;
        headCell.typeLabel.text = NSLocalizedString(@"setting.personalInfoUpload", @"头像");
        [headCell.headImage sd_setImageWithURL:[NSURL URLWithString:[self.userInfo objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"headImageDefault"]];
        return headCell;
    } else {
        static NSString *cellIdentifier = @"userContentCell";
        UserContentCell *contentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!contentCell) {
            contentCell = [[UserContentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        contentCell.contentLabel.tag = 1000*indexPath.section + indexPath.row;

        switch (indexPath.row) {
            case 0:
            {
                contentCell.typeLabel.text = NSLocalizedString(@"setting.profileNickname", @"");
                contentCell.contentLabel.text = [self.userInfo objectForKey:@"nickname"];
            }
                break;
            case 1:
            {
                contentCell.typeLabel.text = NSLocalizedString(@"sexSelectVC.gender", @"");
                NSInteger sexIndex = [[self.userInfo objectForKey:@"gender"] integerValue];
                switch (sexIndex) {
                    case 0:
                    {
                        contentCell.contentLabel.text = NSLocalizedString(@"sexSelectVC.weman", @"");
                        _sexIndex = @"0";
                    }
                        break;
                    case 1:
                    {
                        contentCell.contentLabel.text = NSLocalizedString(@"sexSelectVC.man", @"");
                        _sexIndex = @"1";
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
            case 2:
            {
                contentCell.typeLabel.text = NSLocalizedString(@"watchUserInfoVC.age", @"");
                contentCell.contentLabel.text = [NSString stringWithFormat:@"%@",[self.userInfo objectForKey:@"age"]];
            }
                break;
                
            default:
                break;
        }
        return contentCell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 72;
    } else
        return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 16;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"actsheet.photo", @""), NSLocalizedString(@"actsheet.images", @""), nil];
            [actionSheet showInView:self.view];
        }
            break;
        case 1:
        {
            _selectedRow = 1000+indexPath.row;
            switch (indexPath.row) {
                case 0:
                {
                    UIStoryboard *storybaord = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                    WatchChangeCustomViewController *customVC = [storybaord instantiateViewControllerWithIdentifier:@"changeCustomInfo"];
                    customVC.delegate = self;
                    customVC.content = [self.userInfo objectForKey:@"nickname"];
                    [self.navigationController pushViewController:customVC animated:YES];
                }
                    break;
                case 1:
                {
                    UIStoryboard *storybaord = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                    SexSelectViewController *sexVC = [storybaord instantiateViewControllerWithIdentifier:@"changeSexVC"];
                    sexVC.sexIndex = _sexIndex;
                    sexVC.delegate = self;
                    [self.navigationController pushViewController:sexVC animated:YES];
                    
                }
                    break;
                case 2:
                {
                    UIStoryboard *storybaord = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                    WatchChangeCustomViewController *customVC = [storybaord instantiateViewControllerWithIdentifier:@"changeCustomInfo"];
                    customVC.delegate = self;
                    customVC.selectIndex = 1001;
                    customVC.content = [NSString stringWithFormat:@"%@",[self.userInfo objectForKey:@"age"]];
                    [self.navigationController pushViewController:customVC animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - ChangeCustomInfo Delegate
- (void)changeContentWith:(NSString *)content {
    UILabel *label = (UILabel *)[self.view viewWithTag:_selectedRow];
    label.text = content;
    switch (_selectedRow) {
        case 1000: //昵称
        {
            _nickName = content;
        }
            break;
        case 1002: //年龄
        {
            _age = content;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Change Sex Delegate
- (void)changeSexWith:(NSString *)content {
    UILabel *label = (UILabel *)[self.view viewWithTag:_selectedRow];
    _sexIndex = content;
    NSInteger sex = [content intValue];
    switch (sex) {
        case 0:
            label.text = NSLocalizedString(@"sexSelectVC.weman", @"");
            break;
        case 1:
            label.text = NSLocalizedString(@"sexSelectVC.man", @"");;
            break;
        default:
            break;
    }
    
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
