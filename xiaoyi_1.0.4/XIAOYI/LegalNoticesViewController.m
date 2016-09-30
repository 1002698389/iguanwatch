//
//  LegalNoticesViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/9/13.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "LegalNoticesViewController.h"

@interface LegalNoticesViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *legalWeb;
@end

@implementation LegalNoticesViewController


- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"secret" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    [self.legalWeb loadRequest:request];
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
