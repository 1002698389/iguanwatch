//
//  ChangeBirthdayViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/22.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "ChangeBirthdayViewController.h"

@interface ChangeBirthdayViewController ()

@property (weak, nonatomic) IBOutlet UILabel *Introductions;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthdayPicker;
@property (nonatomic, strong) NSDateFormatter *formatter;

//@property (nonatomic, strong) UIDatePicker *birthdayPicker;


@end

@implementation ChangeBirthdayViewController

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateFormat = @"YYYY-MM-DD";
    NSLog(@"%@",self.birthString);
    if (![self.birthString isEqual:@""]) {
        NSDate *date = [self.formatter dateFromString:self.birthString];
        [self.birthdayPicker setDate:date];
    }
    
    self.birthdayPicker.maximumDate = [NSDate date];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
//    self.birthdayPicker.date = date;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectDate:(id)sender {
    NSString *dateString = [self.formatter stringFromDate:self.birthdayPicker.date];
    
    if (self.delegate != nil) {
        [self.delegate changeBirthdayWith:dateString];
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
