//
//  WatchInfoInquiryViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/21.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "WatchInfoInquiryViewController.h"
#import "InquiryHeadCell.h"
#import "InquiryCustomCell.h"
#import "ChangeRemarkNameViewController.h"

@interface WatchInfoInquiryViewController ()</*UITableViewDataSource,UITableViewDelegate,*/ChangeRemarkDelegate,UIAlertViewDelegate>

{
    UIView *_tempview;
    UIImageView *_qrImage;
    UILabel *_watchSNLabel;
}

//@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *resultDic;
@property (weak, nonatomic) IBOutlet UIImageView *upImage;
//@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImg;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *telLabel;

@property (weak, nonatomic) IBOutlet UIButton *changeInfoBtn;

@property (weak, nonatomic) IBOutlet UIButton *unbindingBtn;

@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UILabel *roleContent;

@end



@implementation WatchInfoInquiryViewController


- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getWatchUserInfo {
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/getWatchDetail.do?t=%@&deviceId=%@", DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceId"]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                self.resultDic = [responseObject objectForKey:@"content"];
                //                [self.tableView reloadData];
                [self setWatchInfoWithResult:self.resultDic];
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)setWatchInfoWithResult:(NSDictionary *)dic {
    NSString *photoUrl = [self.resultDic objectForKey:@"photo"];
    if ([photoUrl isEqual:@""]) {
        self.headImage.image = [UIImage imageNamed:@"contactDefaultHeadImg"];
    } else {
        [self.headImage sd_setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"contactDefaultHeadImg"]];
    }
    
    [self.nameLabel removeConstraint:self.nameWidthConstraint];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    CGSize titleSize = [self.remarkString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 150, 21) options:NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.nameLabel.font, NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil] context:nil].size;
    NSLog(@"%lf",titleSize.width);
    self.nameWidthConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:titleSize.width + 5];
    [self.nameLabel addConstraint:self.nameWidthConstraint];
    self.nameLabel.text = self.remarkString;
    
    self.ageLabel.text = [NSString stringWithFormat:@"%@",[self.resultDic objectForKey:@"age"]];
    
    
//    CGSize ageSize = [self.remarkString boundingRectWithSize:CGSizeMake(MAXFLOAT, 21) options:NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.nameLabel.font, NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil] context:nil].size;
    
    
    NSString *sexIndex = [NSString stringWithFormat:@"%@",[self.resultDic objectForKey:@"gender"]];
    if ([sexIndex isEqual:@""]) {
        self.genderImg.hidden = YES;
    } else {
        NSInteger sex = [sexIndex intValue];
        switch (sex) {
            case 0:
                self.genderImg.image = [UIImage imageNamed:@"fbg.png"];
                break;
            case 1:
                self.genderImg.image = [UIImage imageNamed:@"nbg.png"];
                break;
            default:
                break;
        }
    }
    
    self.locationLabel.text = self.locationDetail;
    self.telLabel.text = [NSString stringWithFormat:@"%@",[self.resultDic objectForKey:@"phoneNum"]];
    
    self.roleLabel.text = NSLocalizedString(@"WatchInfoInquiryVC.managers", @"");
    self.roleContent.text = [NSString stringWithFormat:@"%@",[self.resultDic objectForKey:@"roleName"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;
    self.resultDic = [NSDictionary dictionary];
    
    self.unbindingBtn.layer.cornerRadius = 18;
    [self.unbindingBtn setTitle:NSLocalizedString(@"WatchInfoInquiryVC.unbindingBtn", @"") forState:UIControlStateNormal];
    
    self.changeInfoBtn.layer.cornerRadius = 18;
    self.headImage.layer.cornerRadius = 40;
    self.headImage.layer.masksToBounds = YES;
    self.headImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headImage.layer.borderWidth = 2;
    
    self.upImage.image = [UIImage imageNamed:@"userbg"];
    
    switch (self.managedIndex) {
        case 1:
            self.changeInfoBtn.hidden = YES;
            break;
        case 2:
            self.changeInfoBtn.hidden = NO;
            break;
        default:
            break;
    }
    [self initTempview];
    
}

- (void)initTempview {
    _tempview = [[UIView alloc]initWithFrame:self.view.frame];
    _tempview.backgroundColor = [UIColor blackColor];
    _tempview.alpha = 0.9;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissQrImage)];
    [_tempview addGestureRecognizer:tap];
    
    _qrImage = [[UIImageView alloc]init];
    _qrImage.layer.borderColor = [UIColor whiteColor].CGColor;
    _qrImage.layer.borderWidth = 2;
    [_tempview addSubview:_qrImage];
    _qrImage.image = [self createNonInterpolatedUIImageFormCIImage:[self createQRForString:[NSString stringWithFormat:@"http://api.i-guan.com/qr.do?sn=%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"watchSN"]]] withSize:180];
    
    _watchSNLabel = [[UILabel alloc]init];
    [_tempview addSubview:_watchSNLabel];
    _watchSNLabel.textAlignment = NSTextAlignmentCenter;
    _watchSNLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"watchSN"];
    [_watchSNLabel setTextColor:[UIColor whiteColor]];
    _watchSNLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    _watchSNLabel.layer.borderWidth = 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self getWatchUserInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CIImage *)createQRForString:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // 返回CIImage
    return qrFilter.outputImage;
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
    
}




/*
#pragma mark - UITableView DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 6;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"inquiryHeadCell";
        InquiryHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[InquiryHeadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        NSString *photoUrl = [self.resultDic objectForKey:@"photo"];
        if ([photoUrl isEqual:@""]) {
            cell.headImage.image = [UIImage imageNamed:@"contactDefaultHeadImg"];
        } else {
            [cell.headImage sd_setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"contactDefaultHeadImg"]];
        }
        if ([[self.resultDic objectForKey:@"nickName"] isEqual:@""]) {
            cell.nameLabel.text = @"";
        } else {
            cell.nameLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"watchInquiryVC.userName", @""),[self.resultDic objectForKey:@"nickName"]];
        }
        cell.remarkName.text = self.remarkString;
        cell.remarkName.tag = 10101;
        return cell;
    } else if (indexPath.section == 1) {
        static NSString *cellIdentifier = @"inquiryCustomCell";
        InquiryCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[InquiryCustomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        switch (indexPath.row) {
            case 0:
            {
                cell.typeLabel.text = NSLocalizedString(@"sexSelectVC.gender", @"");
                NSString *sexIndex = [NSString stringWithFormat:@"%@",[self.resultDic objectForKey:@"gender"]];
                if ([sexIndex isEqual:@""]) {
                    cell.contentLabel.text = @"";
                } else {
                    NSInteger sex = [sexIndex intValue];
                    switch (sex) {
                        case 0:
                            cell.contentLabel.text = NSLocalizedString(@"sexSelectVC.weman", @"");
                            break;
                        case 1:
                            cell.contentLabel.text = NSLocalizedString(@"sexSelectVC.man", @"");
                            break;
                        default:
                            break;
                    }
                }
            }
                break;
            case 1:
            {
                cell.typeLabel.text = NSLocalizedString(@"watchUserInfoVC.tel", @"");
                cell.contentLabel.text = [NSString stringWithFormat:@"%@",[self.resultDic objectForKey:@"phoneNum"]];
            }
                break;
            case 2:
            {
                cell.typeLabel.text = NSLocalizedString(@"watchUserInfoVC.age", @"");
                cell.contentLabel.text = [NSString stringWithFormat:@"%@",[self.resultDic objectForKey:@"age"]];
            }
                break;
            case 3:
            {
                cell.typeLabel.text = NSLocalizedString(@"watchUserInfoVC.height", @"");
                cell.contentLabel.text = [NSString stringWithFormat:@"%@",[self.resultDic objectForKey:@"height"]];
            }
                break;
            case 4:
            {
                cell.typeLabel.text = NSLocalizedString(@"watchInquiryVC.location", @"");
                cell.contentLabel.text = self.locationDetail;
            }
                break;
            case 5:
            {
                cell.typeLabel.text = NSLocalizedString(@"watchInquiryVC.watchSN", @"");
                cell.contentLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"watchSN"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
                
            default:
                break;
        }
        
        return cell;
    } else {
        return nil;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 16;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 90;
    } else {
        return 44;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"changeRemarkName" sender:self];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 5) {
            [self performSegueWithIdentifier:@"showWatchSN" sender:self];
        }
    }
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqual:@"changeRemarkName"]) {
        ChangeRemarkNameViewController *remarkVC = [segue destinationViewController];
        remarkVC.delegate = self;
        remarkVC.remarkNameString = self.remarkString;
    }
}

#pragma mark - Change Remark Delegate
- (void)changeRemarkNameWith:(NSString *)content {
    self.remarkString = content;
    UILabel *remarkName = (UILabel *)[self.view viewWithTag:10101];
    remarkName.text = content;
}


#pragma mark - 修改备注
- (IBAction)changeRemarkName:(id)sender {
    [self performSegueWithIdentifier:@"changeRemarkName" sender:self];

}


#pragma mark - 显示二维码
- (IBAction)showQR:(id)sender {
    [[UIApplication sharedApplication].keyWindow addSubview:_tempview];
    
    [_qrImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.view.mas_top).with.offset(80);
        make.size.mas_equalTo(CGSizeMake(180, 180));
    }];
    [_watchSNLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(_qrImage.mas_bottom).with.offset(16);
        make.size.mas_equalTo(CGSizeMake(180, 20));
    }];
}

- (void)dismissQrImage {
    //    UIView *view = [self.view viewWithTag:10101];
    //    [_qrImage removeFromSuperview];
    [_tempview removeFromSuperview];
    
}


#pragma mark - 打电话
- (IBAction)makePhoneCall:(id)sender {
    if (![self.telLabel.text isEqual:@""]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",self.telLabel.text]]];
    }
}

#pragma mark - 修改个人信息
- (IBAction)changeWatchUserInfo:(id)sender {
    [self performSegueWithIdentifier:@"changeWatchInfo" sender:self];

}


#pragma mark - 解除绑定

- (IBAction)removeBindingWatch:(id)sender {
    
    switch (self.managedIndex) {
        case 1: //非管理员
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"是否确认解除绑定" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = 1234;
            [alertView show];
        }
            break;
        case 2: //管理员
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"是否解除绑定，解除绑定将不会清除手表数据" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = 1234;
            [alertView show];
        }
            break;
            
        default:
            break;
    }
    
//    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"如果不点击，清除所有数据将会保留以前的信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    alertView.tag = 1234;
//    [alertView show];
    
    
}

- (void)unbindingWatch {
    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:@"系统删除中..."];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/userDelWatch.do?t=%@&deviceUserRefId=%@", DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], self.deviceRefId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        [HUD hide:YES];
        NSLog(@"%@",[responseObject objectForKey:@"devMessage"]);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (self.delegate != nil) {
                [self.delegate removeBindingWatch];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [HUD hide:YES];
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
    }];
}


#pragma mark - UIAlert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1234) {
        if (buttonIndex == 1) {
            [self unbindingWatch];
        }
    }
}

@end
