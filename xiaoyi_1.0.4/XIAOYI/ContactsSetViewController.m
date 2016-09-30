//
//  ContactsSetViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 15/11/2.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import "ContactsSetViewController.h"
#import "AddContactsViewController.h"
#import "ContactCell.h"


@interface ContactsSetViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,ABPeoplePickerNavigationControllerDelegate,ReloadContactsDelegate>
{
    BOOL _doAdd;
    NSInteger _selectedIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *contactsArray;
@end

@implementation ContactsSetViewController

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)getContacts {
    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:@"数据加载中"];
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/contact/getContactListWithDeviceId.do?t=%@&v=1&deviceId=%@", DNS, [userdefault valueForKey:@"token"], [userdefault valueForKey:@"deviceId"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [HUD hide:YES];
        NSLog(@"%@",responseObject);
        if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
            self.contactsArray = [responseObject objectForKey:@"content"];
        } else
            self.contactsArray = nil;
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        [HUD hide:YES];
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;
    
    self.contactsArray = [NSArray array];

    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self getContacts];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doAdd:(id)sender {
    if (self.contactsArray.count == 10) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:@"添加联系人数量达到上限" delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        _doAdd = YES;
        [self performSegueWithIdentifier:@"addContacts" sender:self];
//        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") destructiveButtonTitle:nil otherButtonTitles:@"从通讯录选取", @"手动输入", nil];
//        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
            peoplePicker.peoplePickerDelegate = self;
            
            [self presentViewController:peoplePicker animated:YES completion:nil];
            
        }
            break;
        case 1:
        {
            [self performSegueWithIdentifier:@"addContacts" sender:self];
        }
            break;
        default:
            break;
    }
}

#pragma mark -- ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    ABMultiValueRef valuesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex index = ABMultiValueGetIndexForIdentifier(valuesRef,identifier);
    if (index < 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:@"请选择一个电话" delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    CFStringRef value = ABMultiValueCopyValueAtIndex(valuesRef,index);
    
    NSString *firstName, *lastName, *fullName;
    firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    firstName = [firstName stringByAppendingFormat:@" "];
    
    lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
//    fullName = [lastName stringByAppendingFormat:@"%@",firstName];
    CFStringRef anFullName = ABRecordCopyCompositeName(person);
    fullName = (__bridge NSString *)anFullName;
    
    for (NSDictionary *dic in self.contactsArray) {
        NSString *singleTel = [NSString stringWithFormat:@"%@",[dic objectForKey:@"telNum"]];
        NSString *selectedTel = [(__bridge NSString*)value stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if ([selectedTel isEqual:singleTel]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:@"此号码已经通讯录中已存在" delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
    }
    
    NSLog(@"%@  %@", fullName, (__bridge NSString*)value);
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/contact/addContactWithDeviceId.do?t=%@&v=1&deviceId=%@&name=%@&telNum=%@&index=%lu&internationalCode=86", DNS, [userdefault valueForKey:@"token"], [userdefault valueForKey:@"deviceId"], fullName, [(__bridge NSString*)value stringByReplacingOccurrencesOfString:@"-" withString:@""], (unsigned long)self.contactsArray.count];
    NSLog(@"%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            [self getContacts];
            [peoplePicker dismissViewControllerAnimated:YES completion:^{
                
            }];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"devMessage"] delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

        [self dismissViewControllerAnimated:YES completion:^{
//        self.textField.text = (__bridge NSString*)value;
        }];
    }];
    
}



#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contactsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"contactsCell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ContactCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:[[self.contactsArray objectAtIndex:indexPath.row] objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"contactDefaultHeadImg"]];
    cell.nameLabel.text = [[self.contactsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.telNum.text = [[self.contactsArray objectAtIndex:indexPath.row] objectForKey:@"telNum"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteContactsBySingleDic:[self.contactsArray objectAtIndex:indexPath.row]];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _doAdd = NO;
    _selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"addContacts" sender:self];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 2;
//}

#pragma mark - 删除联系人
- (void)deleteContactsBySingleDic:(NSDictionary *) singleDic {
    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:NSLocalizedString(@"MBProgressHUD.delete", @"")];

    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/contact/delContactWithDeviceId.do?t=%@&v=1&deviceId=%@&index=%@", DNS, [userdefault valueForKey:@"token"], [userdefault valueForKey:@"deviceId"], [singleDic objectForKey:@"index"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        [self getContacts];
        [HUD hide:YES];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        [HUD hide:YES];
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

    }];
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqual:@"addContacts"]) {
        AddContactsViewController *addVC = [segue destinationViewController];
        addVC.contactsIndex = self.contactsArray.count;
        addVC.delegate = self;
        addVC.allContactAry = self.contactsArray;
        addVC.isAdding = _doAdd;
        addVC.selectedIndex = _selectedIndex;
    }
}

- (void)reloadContacts {
    [self getContacts];
}

@end
