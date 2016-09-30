//
//  QRcodeViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 15/10/28.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import "QRcodeViewController.h"
#import "BoxView.h"

#import "PerfectInfoViewController.h"

//#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
//#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface QRcodeViewController ()
{
    BoxView *_boxView;
}

@property (nonatomic, strong) NSString *scanResult;
@property (nonatomic, strong) NSDictionary *scanDic;

@end

@implementation QRcodeViewController

- (void)dealloc {
    self.capture = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scanDic = [NSDictionary dictionary];
    
    
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.capture = [[ZXCapture alloc] init];
    self.capture.camera = self.capture.back;
    self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    self.capture.rotation = 90.0f;
    
    self.capture.layer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.capture.layer];
    
    _boxView = [[BoxView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:_boxView];
    
    UIButton *backButton = [UIButton buttonWithFrame:CGRectMake(10, 30, 44, 30) title:nil normalImage:[UIImage imageNamed:@"zBar_book"] highlightImage:nil selectedImage:nil font:[UIFont systemFontOfSize:16.0] target:self action:@selector(goCancel) controlEvent:UIControlEventTouchUpInside tag:0];
    backButton.userInteractionEnabled = NO;
    [self.view addSubview:backButton];
    [self performSelector:@selector(goBackButtonEnabled:) withObject:backButton afterDelay:2];

    
    
    
    self.capture.delegate = self;
    //self.capture.layer.frame = self.view.bounds;
    
    CGAffineTransform captureSizeTransform = CGAffineTransformMakeScale(SCREEN_WIDTH / self.view.frame.size.width, SCREEN_HEIGHT / self.view.frame.size.height);
    self.capture.scanRect = CGRectApplyAffineTransform(_boxView.rimView.frame, captureSizeTransform);//扫描区域
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)goBackButtonEnabled:(UIButton *)backButton
{
    backButton.userInteractionEnabled = YES;
}

#pragma mark - Private Methods

- (NSString *)barcodeFormatToString:(ZXBarcodeFormat)format {
    switch (format) {
        case kBarcodeFormatAztec:
            return @"Aztec";
            
        case kBarcodeFormatCodabar:
            return @"CODABAR";
            
        case kBarcodeFormatCode39:
            return @"Code 39";
            
        case kBarcodeFormatCode93:
            return @"Code 93";
            
        case kBarcodeFormatCode128:
            return @"Code 128";
            
        case kBarcodeFormatDataMatrix:
            return @"Data Matrix";
            
        case kBarcodeFormatEan8:
            return @"EAN-8";
            
        case kBarcodeFormatEan13:
            return @"EAN-13";
            
        case kBarcodeFormatITF:
            return @"ITF";
            
        case kBarcodeFormatPDF417:
            return @"PDF417";
            
        case kBarcodeFormatQRCode:
            return @"QR Code";
            
        case kBarcodeFormatRSS14:
            return @"RSS 14";
            
        case kBarcodeFormatRSSExpanded:
            return @"RSS Expanded";
            
        case kBarcodeFormatUPCA:
            return @"UPCA";
            
        case kBarcodeFormatUPCE:
            return @"UPCE";
            
        case kBarcodeFormatUPCEANExtension:
            return @"UPC/EAN extension";
            
        default:
            return @"Unknown";
    }
}

#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
    if (!result) return;
    self.capture.delegate = nil;
    // We got a result. Display information about the result onscreen.
    NSString *formatString = [self barcodeFormatToString:result.barcodeFormat];
    
    NSString *symbolStr = result.text;
    if ([result.text canBeConvertedToEncoding:NSShiftJISStringEncoding])
    {
        symbolStr = [NSString stringWithCString:[result.text cStringUsingEncoding:NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
    }

    self.scanResult = [[symbolStr componentsSeparatedByString:@"="] lastObject];
    NSLog(@"扫描结果:%@",symbolStr);
    NSLog(@"扫描结果:%@",self.scanResult);
    
    NSString *display = [NSString stringWithFormat:@"Scanned!\n\nFormat: %@\n\nContents:\n%@", formatString, result.text];
    NSLog(@"扫描结果:%@",display);
    
    _boxView.contentLabel.text = @"扫描完成";
    
    [self performSegueWithIdentifier:@"scanComplete" sender:self];
    
}


- (void)goCancel {
    switch (self.bindingInWhere) {
        case 1:
//            [self.navigationController popViewControllerAnimated:YES];
            [self.parentViewController dismissViewControllerAnimated:YES completion:NULL];
            break;
        case 2:
//            [self dismissViewControllerAnimated:YES completion:NULL];
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }
//    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkWithWatchSN:(NSString *)deviceSN {
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/checkDeviceSN.do?deviceSN=%@", DNS, deviceSN];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            self.scanDic = [responseObject objectForKey:@"content"];
            [self performSegueWithIdentifier:@"scanComplete" sender:self];
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

    }];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([[segue identifier] isEqual:@"scanComplete"]) {        
        
        PerfectInfoViewController *perfectVC = [segue destinationViewController];
        perfectVC.qrcodeWatchId = self.scanResult;
        perfectVC.bindingInWhere = 1;
    }
}


@end
