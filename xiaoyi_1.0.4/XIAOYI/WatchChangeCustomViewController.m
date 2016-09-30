//
//  WatchChangeCustomViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/22.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "WatchChangeCustomViewController.h"

@interface WatchChangeCustomViewController ()

@property (weak, nonatomic) IBOutlet UITextField *contentTF;
@end

@implementation WatchChangeCustomViewController


- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.contentTF.text = self.content;
    switch (self.selectIndex) {
        case 1001:
            self.contentTF.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case 1003:
            self.contentTF.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case 1004:
            self.contentTF.keyboardType = UIKeyboardTypeNumberPad;
            break;
            
        default:
            break;
    }
    [self.contentTF becomeFirstResponder];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.contentTF resignFirstResponder];
}


- (IBAction)doChange:(id)sender {
    if (self.delegate != nil) {
        [self.delegate changeContentWith:self.contentTF.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
