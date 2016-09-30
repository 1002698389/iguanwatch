#import "CustomeViewController.h"
#import <Masonry/Masonry.h>
#import "QRViewController.h"

@interface CustomeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtPwd;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@end

@implementation CustomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    
    [self.txtName mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view.mas_top).offset(80);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.txtPwd.mas_top).offset(-15);
        
        make.width.equalTo(@120);
    }];
    [self.txtPwd mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.txtName.mas_bottom).offset(15);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.btnLogin.mas_top).offset(-30);
        
         make.width.equalTo(@120);
    }];
    [self.btnLogin mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.txtPwd.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
         make.width.equalTo(@160);
      
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    QRViewController *one = [storyboard instantiateViewControllerWithIdentifier:@"QRcodeScan"];
//    one.delegate = self;
    one.bindingFrom = 1;
//    [self.navigationController pushViewController:one animated:NO];
    [self presentViewController:one animated:YES completion:NULL];
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
