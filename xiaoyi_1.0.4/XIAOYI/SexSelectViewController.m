//
//  SexSelectViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/22.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "SexSelectViewController.h"

@interface SexSelectViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SexSelectViewController

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"sexCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"sexSelectVC.man", @"");
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"sexSelectVC.weman", @"");
            break;
            
        default:
            break;
    }
    
    if (![self.sexIndex isEqual:@""]) {
        NSInteger sex = [self.sexIndex intValue];
        switch (sex) {
            case 0:
            {
                if (indexPath.row == 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
                break;
            case 1:
            {
                if (indexPath.row == 0) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
                break;
            default:
                break;
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sex;
    if (indexPath.row == 0) {
        sex = @"1";
    } else {
        sex = @"0";
    }
    if (self.delegate != nil) {
        [self.delegate changeSexWith:sex];
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
