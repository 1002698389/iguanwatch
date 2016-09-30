//
//  WatchUserInfoViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 15/11/9.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import "WatchUserInfoViewController.h"
#import "WatchInfoHeadCell.h"
#import "WatchInfoCustomCell.h"
#import "WatchChangeCustomViewController.h"
#import "SexSelectViewController.h"
#import "ChangeBirthdayViewController.h"

#define ORIGINAL_MAX_WIDTH 640.0f


@interface WatchUserInfoViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,VPImageCropperDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,ChangeCustomInfoDelegate,ChangeSexDelegate,ChangeBirthdayDelegate>
{
//    NSArray *_pickerArray;
    NSInteger _selectedSexRow;
    NSString *_sexText;

    NSDate *_selectedBirthday;
    
    NSDate *_birthDate;
    
    NSInteger _selecedImageFormWhere; //1：相机 2：相册

    NSInteger _selectedRow;
}

@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) NSString *photoUUID;
@property (nonatomic, strong) NSString *nameString;
@property (nonatomic, strong) NSString *sexIndex;
@property (nonatomic, strong) NSString *ageString;
@property (nonatomic, strong) NSString *birthdayString;
@property (nonatomic, strong) NSString *heightString;
@property (nonatomic, strong) NSString *telString;

//@property (strong, nonatomic) IBOutlet UIToolbar *userTool;
//@property (strong, nonatomic) IBOutlet UIPickerView *sexPicker;
//
//
//@property (strong, nonatomic) IBOutlet UIDatePicker *birthdayPicker;
//@property (strong, nonatomic) IBOutlet UIToolbar *birthdayTool;


@property (weak, nonatomic) IBOutlet UITableView *infoTableView;

@property (nonatomic, strong) NSDictionary *resultDic;
@end

@implementation WatchUserInfoViewController

- (void)getWatchDetails {
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/getWatchDetail.do?t=%@&deviceId=%@", DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceId"]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                self.resultDic = [responseObject objectForKey:@"content"];
                self.nameString = [self.resultDic objectForKey:@"nickName"];
                self.ageString = [NSString stringWithFormat:@"%@",[self.resultDic objectForKey:@"age"]];
                self.sexIndex = [NSString stringWithFormat:@"%@",[self.resultDic objectForKey:@"gender"]];
                self.birthdayString =  [NSString stringWithFormat:@"%@",[self.resultDic objectForKey:@"birthday"]];
                self.heightString = [NSString stringWithFormat:@"%@",[self.resultDic objectForKey:@"height"]];
                self.telString = [NSString stringWithFormat:@"%@",[self.resultDic objectForKey:@"phoneNum"]];
                
                [self.infoTableView reloadData];
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

    }];
}


#pragma mark - submit Info

- (IBAction)submitToChange:(id)sender {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/upWatchDetail.do?t=%@&deviceId=%@&name=%@&age=%@&backPhoto=%@&birthday=%@&gender=%@&height=%@&photo=%@&phone=%@", DNS, [userdefault valueForKey:@"token"], [userdefault valueForKey:@"deviceId"], [self.nameString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.ageString, @"", self.birthdayString, self.sexIndex, self.heightString, self.photoUUID, self.telString];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:urlString/*[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]*/ parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            NSNotification *notification = [NSNotification notificationWithName:@"refreshWatchData" object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
    }];
}



- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
//    if (textField == self.sexTF) {
////        textField.inputView = self.sexPicker;
//    } else if (textField == self.birthayTF) {
//        self.birthdayPicker.date = _selectedBirthday;
//    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


/*
#pragma mark - GET Info
- (void)getWatchUserInfo {
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/userGetWatchInfo.do?t=%@&deviceId=%@&deviceUserRefId=%@", DNS, [userdefault valueForKey:@"token"], [userdefault valueForKey:@"deviceId"], [userdefault valueForKey:@"deviceUserRefId"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
            self.nameTF.text = [[responseObject objectForKey:@"content"] objectForKey:@"name"];
            int sexindex = [[[responseObject objectForKey:@"content"] objectForKey:@"gender"] intValue];
            switch (sexindex) {
                case 1://男
                {
                    self.sexTF.text = @"男";
                    _sexText = @"1";
                    [self.sexPicker selectRow:0 inComponent:0 animated:NO];
                }
                    break;
                case 0://女
                {
                    self.sexTF.text = @"女";
                    _sexText = @"0";
                    [self.sexPicker selectRow:1 inComponent:0 animated:NO];
                }
                    break;
                default:
                    self.sexTF.text = @"";
                    break;
            }
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *birthday;
            if (([[[responseObject objectForKey:@"content"] objectForKey:@"birthday"] longLongValue]/1000) == 0) {
                birthday = @"";
            } else {
                _selectedBirthday = [NSDate dateWithTimeIntervalSince1970:[[[responseObject objectForKey:@"content"] objectForKey:@"birthday"] longLongValue]/1000];
                
                birthday = [dateFormatter stringFromDate:_selectedBirthday];
            }
            self.birthayTF.text = birthday;
            
            
            NSNumber *weight = (NSNumber *)[[responseObject objectForKey:@"content"] objectForKey:@"weight"];
            self.weightTF.text = [NSString stringWithFormat:@"%@",weight];
            NSNumber *height = (NSNumber *)[[responseObject objectForKey:@"content"] objectForKey:@"height"];
            self.heightTF.text = [NSString stringWithFormat:@"%@",height];
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}
*/


#pragma mark - ViewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;
    self.resultDic = [NSDictionary dictionary];
//    _pickerArray = [NSArray arrayWithObjects:@"男",@"女", nil];
    
    _selectedBirthday = [[NSDate alloc]init];
    _birthDate = [[NSDate alloc]init];
    
    self.photoUUID = @"";
//    self.infoTableView.delegate = self;
//    self.infoTableView.dataSource = self;
    self.infoTableView.footer.frame = CGRectZero;
    [self getWatchDetails];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
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
*/
/*
#pragma mark - Choose Sex
- (IBAction)chooseSex:(id)sender {
//    [self.sexTF resignFirstResponder];
//    self.sexTF.text = [_pickerArray objectAtIndex:_selectedSexRow];
    switch (_selectedSexRow) {
        case 0:
            _sexText = @"1";
            break;
        case 1:
            _sexText = @"0";
            break;
        default:
            break;
    }
}

- (IBAction)chooseBirthday:(id)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
//    NSString *dateString = [formatter stringFromDate:self.birthdayPicker.date];
//    _selectedBirthday = self.birthdayPicker.date;
//    self.birthayTF.text = dateString;
//    [self.birthayTF resignFirstResponder];
}

*/



#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            return 2;
        }
            break;
        case 1:
        {
            return 5;
        }
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *cellIdentifier = @"infoHeadCell";
            WatchInfoHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[WatchInfoHeadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            if (!self.selectedImage) {
                cell.headImage.tag = 10001;
                [cell.headImage sd_setImageWithURL:[NSURL URLWithString:[self.resultDic objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"contactDefaultHeadImg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    self.selectedImage = image;
                }];
            } else
                cell.headImage.image = self.selectedImage;
            
            return cell;
        } else {
            static NSString *cellIdentifier = @"infoCustomCell";
            WatchInfoCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[WatchInfoCustomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            cell.typeLabel.text = NSLocalizedString(@"watchUserInfoVC.name", @"");
            cell.contenLabel.text = self.nameString;
            cell.contenLabel.tag = 10002;
            return cell;
        }
    } else if (indexPath.section == 1){
        static NSString *cellIdentifier = @"infoCustomCell";
        WatchInfoCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[WatchInfoCustomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.contenLabel.tag = 1000*indexPath.section + indexPath.row;
        switch (indexPath.row) {
            case 0:
            {
                cell.typeLabel.text = NSLocalizedString(@"sexSelectVC.gender", @"");
                if ([self.sexIndex isEqual:@""]) {
                    cell.contenLabel.text = @"";
                } else {
                    NSInteger sex = [self.sexIndex intValue];
                    switch (sex) {
                        case 0:
                            cell.contenLabel.text = NSLocalizedString(@"sexSelectVC.weman", @"");
                            break;
                        case 1:
                            cell.contenLabel.text = NSLocalizedString(@"sexSelectVC.man", @"");
                            break;
                        default:
                            break;
                    }
                }
            }
                break;
            case 1:
            {
                cell.typeLabel.text = NSLocalizedString(@"watchUserInfoVC.age", @"");
                cell.contenLabel.text = self.ageString;

            }
                break;
            case 2:
            {
                cell.typeLabel.text = NSLocalizedString(@"watchUserInfoVC.birthday", @"");
                cell.contenLabel.text = [NSString stringWithFormat:@"%@",[self.resultDic objectForKey:@"birthday"]];
            }
                break;
            case 3:
            {
                cell.typeLabel.text = NSLocalizedString(@"watchUserInfoVC.height", @"");
                cell.contenLabel.text = self.heightString;
            }
                break;
            case 4:
            {
                cell.typeLabel.text = NSLocalizedString(@"watchUserInfoVC.tel", @"");
                cell.contenLabel.text = self.telString;
//                cell.accessoryType = UITableViewCellAccessoryNone;
            }
                break;
                
            default:
                break;
        }
        return cell;
    } else
        return nil;
}


#pragma mark - UITableView Delegate 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                return 80;
            } else {
                return 44;
            }
        }
            break;
        case 1:
        {
            return 44;
        }
            
        default:
            return 44;
            break; 
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 16;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.infoTableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"actsheet.photo", @""), NSLocalizedString(@"actsheet.images", @""), nil];
                [actionSheet showInView:self.view];
            }
                break;
            case 1:
            {
                _selectedRow = 10002;
                [self performSegueWithIdentifier:@"changeCustomInfo" sender:self];
            }
                break;
                
            default:
                break;
        }
    } else {
        _selectedRow = 1000+indexPath.row;
        switch (indexPath.row) {
            case 0:
            {
                [self performSegueWithIdentifier:@"changeSex" sender:self];
            }
                break;
            case 1:
            {
                [self performSegueWithIdentifier:@"changeCustomInfo" sender:self];
            }
                break;
            case 2:
            {
                [self performSegueWithIdentifier:@"changeBirthday" sender:self];
            }
                break;
            case 3:
            {
                [self performSegueWithIdentifier:@"changeCustomInfo" sender:self];
            }
                break;
            case 4:
            {
                [self performSegueWithIdentifier:@"changeCustomInfo" sender:self];
                
            }
                break;
            default:
                break;
        }
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
            self.photoUUID = imageName;
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/userModifyWatchPhoto.do?t=%@&deviceId=%@&deviceUserRefId=%@&uuid=%@&bizName=%@&bizType=%@&size=%@&extension=%@",DNS, [userDefault valueForKey:@"token"], [userDefault valueForKey:@"deviceId"], [userDefault valueForKey:@"deviceUserRefId"], imageName, @"", @"4", [NSString stringWithFormat:@"%lu",(unsigned long)[imageData length]], @"png"];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                NSLog(@"%@",responseObject);
                if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
                    
                }
            } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                NSLog(@"%@",error);
                
            }];
        } else {
            NSLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
    
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
//    self.selectedImage = editedImage;
//    [self.infoTableView reloadData];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want todo a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqual:@"changeCustomInfo"]) {
        WatchChangeCustomViewController *changeCustomVC = [segue destinationViewController];
        changeCustomVC.delegate = self;
        changeCustomVC.selectIndex = _selectedRow;
        switch (_selectedRow) {
            case 10002: //昵称
            {
                changeCustomVC.content = self.nameString;
                changeCustomVC.navigationItem.title = NSLocalizedString(@"setting.profileNickname", @"");
            }
                break;
            case 1001: //年龄
            {
                changeCustomVC.content = self.ageString;
                changeCustomVC.navigationItem.title = NSLocalizedString(@"watchUserInfoVC.age", @"");
            }
                break;
            case 1003: //身高
            {
                changeCustomVC.content = self.heightString;
                changeCustomVC.navigationItem.title = NSLocalizedString(@"watchUserInfoVC.height", @"");
            }
                break;
            case 1004: //电话
            {
                changeCustomVC.content = self.telString;
                changeCustomVC.navigationItem.title = NSLocalizedString(@"watchUserInfoVC.tel", @"");
            }
                break;
                
            default:
                break;
        }
        
    } else if ([[segue identifier] isEqual:@"changeSex"]) {
        SexSelectViewController *sexVC = [segue destinationViewController];
        sexVC.sexIndex = self.sexIndex;
        sexVC.delegate = self;
    } else if ([[segue identifier] isEqual:@"changeBirthday"]) {
        ChangeBirthdayViewController *changeBirthVC = [segue destinationViewController];
        changeBirthVC.delegate = self;
        changeBirthVC.birthString = self.birthdayString;
    }
}


#pragma mark - ChangeCustomInfo Delegate
- (void)changeContentWith:(NSString *)content {
    UILabel *label = (UILabel *)[self.view viewWithTag:_selectedRow];
    label.text = content;
    switch (_selectedRow) {
        case 10002: //昵称
        {
            self.nameString = content;
        }
            break;
        case 1001: //年龄
        {
            self.ageString = content;
        }
            break;
        case 1003: //身高
        {
            self.heightString = content;
        }
            break;
        case 1004: //电话
        {
            self.telString = content;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Change Sex Delegate
- (void)changeSexWith:(NSString *)content {
    UILabel *label = (UILabel *)[self.view viewWithTag:_selectedRow];
    self.sexIndex = content;
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

#pragma mark - Change Birthday Delegate
- (void)changeBirthdayWith:(NSString *)content {
    UILabel *label = (UILabel *)[self.view viewWithTag:_selectedRow];
    label.text = content;
    self.birthdayString = content;
}


@end
