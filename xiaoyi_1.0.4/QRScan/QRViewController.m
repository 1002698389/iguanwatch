//
//  QRViewController.m
//  QRWeiXinDemo
//
//  Created by lovelydd on 15/4/25.
//  Copyright (c) 2015年 lovelydd. All rights reserved.
//

#import "QRViewController.h"
#import "AppDelegate.h"
#import "QRView.h"
#import "PerfectInfoViewController.h"
//@class AppDelegate;

@interface QRViewController ()<AVCaptureMetadataOutputObjectsDelegate,QRViewDelegate,UIAlertViewDelegate>
{
    NSString *_result;
}
@property (strong, nonatomic) AVCaptureDevice * device;
@property (strong, nonatomic) AVCaptureDeviceInput * input;
@property (strong, nonatomic) AVCaptureMetadataOutput * output;
@property (strong, nonatomic) AVCaptureSession * session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * preview;


@property (nonatomic, strong) AppDelegate *myDelegate;

@end

@implementation QRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.myDelegate = [[UIApplication sharedApplication] delegate];
    self.myDelegate = [[UIApplication sharedApplication] delegate];
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    
    //增加条形码扫描
//    _output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
//                                    AVMetadataObjectTypeEAN8Code,
//                                    AVMetadataObjectTypeCode128Code,
//                                    AVMetadataObjectTypeQRCode];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity =AVLayerVideoGravityResize;
    _preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    
    
    [_session startRunning];
    
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    QRView *qrRectView = [[QRView alloc] initWithFrame:screenRect];
    qrRectView.transparentArea = CGSizeMake(screenRect.size.width - 40, screenRect.size.height - 300);
    qrRectView.backgroundColor = [UIColor clearColor];
    qrRectView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    qrRectView.delegate = self;
    [self.view addSubview:qrRectView];
    
    UIButton *pop = [UIButton buttonWithType:UIButtonTypeCustom];
    pop.frame = CGRectMake(20, 20, 50, 50);
    [pop setTitle:NSLocalizedString(@"QRVC.back", @"") forState:UIControlStateNormal];
//    [pop setImage:[UIImage imageNamed:@"back720"] forState:UIControlStateNormal];
    [pop addTarget:self action:@selector(pop:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pop];
    
    //修正扫描区域
    CGFloat screenHeight = self.view.frame.size.height;
    CGFloat screenWidth = self.view.frame.size.width;
    CGRect cropRect = CGRectMake((screenWidth - qrRectView.transparentArea.width) / 2,
                                 (screenHeight - qrRectView.transparentArea.height) / 2,
                                 qrRectView.transparentArea.width,
                                 qrRectView.transparentArea.height);

    [_output setRectOfInterest:CGRectMake(cropRect.origin.y / screenHeight,
                                          cropRect.origin.x / screenWidth,
                                          cropRect.size.height / screenHeight,
                                          cropRect.size.width / screenWidth)];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [_session startRunning];
}

- (void)pop:(UIButton *)button {
    
    switch (self.bindingFrom) {
        case 1:
        {
//            [self dismissViewControllerAnimated:YES completion:NULL];
//            return;
            
            if (self.delegate != nil) {
                [self.delegate doCancelScanQRcode];
            }
            [self dismissViewControllerAnimated:NO completion:nil];
//            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 2:
        {
            if (self.delegate != nil) {
                [self.delegate doCancelScanQRcode];
            }
//            [self dismissViewControllerAnimated:NO completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 3:
        {
            if (self.delegate != nil) {
                [self.delegate doCancelScanQRcode];
            }
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
        default:
            break;
    }
    
}

#pragma mark QRViewDelegate
-(void)scanTypeConfig:(QRItem *)item {
#warning 直接支持条形码扫描
//
//    if (item.type == QRItemTypeQRCode) {
//        _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
//        
//    } else if (item.type == QRItemTypeOther) {
//        
//    }
    _output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                    AVMetadataObjectTypeEAN8Code,
                                    AVMetadataObjectTypeCode128Code,
                                    AVMetadataObjectTypeQRCode];
    
    
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] >0)
    {
        //停止扫描
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    NSLog(@" %@",stringValue);
    
    //检验二维码
    [self chectQRcodeUrlWith:stringValue];
    
    if (self.qrUrlBlock) {
        self.qrUrlBlock(stringValue);
    }
    
}


- (void)chectQRcodeUrlWith:(NSString *)qurl {
    NSString *urlString = [NSString stringWithFormat:@"http://%@/share/concernQrcode.do?qurl=%@", DNS, qurl];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                _result = [[responseObject objectForKey:@"content"] objectForKey:@"deviceSn"];
                switch (self.bindingFrom) {
                    case 1:
                    {
                        if (self.delegate) {
                            [self.delegate scanCompleteWithWatchId:_result];
                        }
                        [self dismissViewControllerAnimated:NO completion:nil];
                    }
                        break;
                    case 2:
                    {
                        if (self.delegate) {
                            [self.delegate scanCompleteWithWatchId:_result];
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                        break;
                    case 3:
                    {
                        if (self.delegate) {
                            [self.delegate scanCompleteWithWatchId:_result];
                        }
                        [self dismissViewControllerAnimated:NO completion:nil];
                    }
                    default:
                        break;
                }
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"QRVC.noWatchData", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 1011;
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
        [_session startRunning];
    }];
}

#pragma mark - UIAlert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1011) {
        [_session startRunning];
    } else {
        switch (buttonIndex) {
            case 0:
                [self dismissViewControllerAnimated:NO completion:nil];
                break;
            case 1:
                [self dismiss];
                break;
            default:
                break;
        }
    }
    
}
- (void)dismiss
{
    [_session startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqual:@"scanComplete"]) {
        PerfectInfoViewController *perfectInfoVC = [segue destinationViewController];
        perfectInfoVC.qrcodeWatchId = _result;
        perfectInfoVC.bindingInWhere = 1;
    }
}


@end
