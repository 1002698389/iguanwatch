//
//  SettingsListTableViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 16/4/18.
//  Copyright © 2016年 冠一 科技. All rights reserved.
//

#import "SettingsListTableViewController.h"

@interface SettingsListTableViewController ()
{
    
}
@property (nonatomic, strong) NSArray *settingsListArray;
@property (nonatomic, strong) NSArray *settingsImageArray;
@property (weak, nonatomic) IBOutlet UIButton *cleanBtn;
@end

@implementation SettingsListTableViewController


- (IBAction)goBack {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)clean {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/watch/clearWatchData.do?t=%@&watchSN=%@",DNS ,[userDefaults valueForKey:@"token"], [userDefaults valueForKey:@"watchSN"]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
//    self.settingsListArray = [NSArray arrayWithObjects:NSLocalizedString(@"settingsListVC.aboutUs", @""), NSLocalizedString(@"settingsListVC.locationFrequency", @""), NSLocalizedString(@"settingsListVC.addContacts", @""), NSLocalizedString(@"settingsListVC.watchInfo", @""), NSLocalizedString(@"settingsListVC.emergency", @""), NSLocalizedString(@"settingsListVC.followers", @""), nil];
    
    NSArray *section0 = [NSArray arrayWithObjects:NSLocalizedString(@"settingsListVC.aboutUs", @""), NSLocalizedString(@"settingsListVC.locationFrequency", @""), /*NSLocalizedString(@"settingsListVC.watchInfo", @""),*/ nil];
    NSArray *section1 = [NSArray arrayWithObjects:NSLocalizedString(@"settingsListVC.addContacts", @""), NSLocalizedString(@"settingsListVC.emergency", @""), nil];
    NSArray *section2 = [NSArray arrayWithObjects:NSLocalizedString(@"settingsListVC.followers", @""), NSLocalizedString(@"settingsListVC.Notices", @""), nil];
    
    self.settingsListArray = [NSArray arrayWithObjects:section0, section1, section2, nil];
    
    NSArray *image0 = [NSArray arrayWithObjects:@"setList_0", @"setList_1", @"setList_3", nil];
    NSArray *image1 = [NSArray arrayWithObjects:@"setList_2", @"setList_4", nil];
    NSArray *image2 = [NSArray arrayWithObjects:@"setList_5", nil];
    self.settingsImageArray = [NSArray arrayWithObjects:image0, image1, image2, nil];
    
    self.cleanBtn.layer.cornerRadius = 18;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
//    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.settingsListArray objectAtIndex:section] count];
    return self.settingsListArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"adminCell" forIndexPath:indexPath];
    // Configure the cell...

    NSArray *singleSection = [self.settingsListArray objectAtIndex:indexPath.section];
//    NSArray *singleImage = [self.setting.sImageArray objectAtIndex:indexPath.section];
    cell.textLabel.text = [singleSection objectAtIndex:indexPath.row];
    cell.textLabel.textColor = RGBACOLOR(54, 54, 54, 1);
//    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[singleImage objectAtIndex:indexPath.row]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [NSString stringWithFormat:@"showSettingDetails_%ld_%ld",(long)indexPath.section ,(long)indexPath.row];
    [self performSegueWithIdentifier:identifier sender:self];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



- (IBAction)cleanAllData:(id)sender {
    [self clean];
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
