//
//  PrivacyAgreementViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/28.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "PrivacyAgreementViewController.h"

@interface PrivacyAgreementViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation PrivacyAgreementViewController

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"agreement" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
