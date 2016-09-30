//
//  AboutWatchInfoViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/2/19.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "AboutWatchInfoViewController.h"
#import "HardwareCell.h"


@interface AboutWatchInfoViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *qrImage;
@property (nonatomic, strong) NSDictionary *resultDic;

@end

@implementation AboutWatchInfoViewController

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getWatchInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/watchInfo.do?t=%@&watchSN=%@", DNS, [defaults valueForKey:@"token"], [defaults valueForKey:@"watchSN"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            self.resultDic = [responseObject objectForKey:@"content"];
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    
    [self setExtraCellLineHidden:self.tableView];
    self.resultDic = [NSDictionary dictionary];
    [self getWatchInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@",[userDefaults valueForKey:@"watchSN"]);
    self.qrImage.image = [self createNonInterpolatedUIImageFormCIImage:[self createQRForString:[NSString stringWithFormat:@"http://api.i-guan.com/qr.do?sn=%@",[userDefaults valueForKey:@"watchSN"]]] withSize:200];
}

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [[UIView alloc]init];
    
    view.backgroundColor = [UIColor clearColor];
    
    [tableView setTableFooterView:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITable View DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"hardwareCell";
    HardwareCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[HardwareCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    switch (indexPath.row) {
        case 0:
        {
            cell.typeLabel.text = NSLocalizedString(@"aboutWatchVC.index0", @"");
            cell.contentLabel.text = [userDefaults valueForKey:@"watchSN"];
        }
            break;
        case 1:
        {
            cell.typeLabel.text = NSLocalizedString(@"aboutWatchVC.index1", @"");
            cell.contentLabel.text = [NSString stringWithFormat:@"%@", [self.resultDic objectForKey:@"versionCode"]];
        }
            break;
        case 2:
        {
            cell.typeLabel.text = NSLocalizedString(@"aboutWatchVC.index2", @"");
            cell.contentLabel.text = [NSString stringWithFormat:@"%@", [self.resultDic objectForKey:@"createDatetime"]];
        }
            break;
        case 3:
        {
            cell.typeLabel.text = NSLocalizedString(@"aboutWatchVC.index3", @"");
            cell.contentLabel.text = [NSString stringWithFormat:@"%@", [self.resultDic objectForKey:@"deviceImei"]];
        }
            break;
        default:
            break;
    }
    return cell;
}


#pragma mark -
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
