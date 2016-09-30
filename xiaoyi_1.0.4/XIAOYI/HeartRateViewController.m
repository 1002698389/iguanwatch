//
//  HeartRateViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 15/10/20.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import "HeartRateViewController.h"
#import "HeartRateCell.h"

@interface HeartRateViewController ()<UITableViewDataSource,UITableViewDelegate,ZFGenericChartDataSource,ZFLineChartDelegate>
{
    ZFLineChart *_chart;
    double angle;
}
@property (weak, nonatomic) IBOutlet UILabel *heartLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *heartImage;

@property (nonatomic, strong) NSArray *heartRateArray;

@property (nonatomic, strong) NSTimer *heartRateTimer;
@property (nonatomic, strong) NSMutableArray *timeArray;
@property (nonatomic, strong) NSMutableArray *xAxisArray;
@property (nonatomic, strong) NSMutableArray *yAxisArray;

@end

@implementation HeartRateViewController

- (void)getLocalHeartData {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Heart" ofType:@"plist"];
    self.heartRateArray = [NSArray arrayWithContentsOfFile:plistPath];
    NSLog(@"%@",self.heartRateArray);
    [self.tableView reloadData];
}

- (IBAction)goBack:(id)sender {
    [self.heartRateTimer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)getHeartData {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/data/getPersonHeartRateList.do?t=%@&deviceId=%@", DNS, [userdefault valueForKey:@"token"], [userdefault objectForKey:@"deviceId"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
            self.heartRateArray = [responseObject objectForKey:@"content"];
            self.heartLabel.text = [NSString stringWithFormat:@"%@ %@", [[self.heartRateArray firstObject] objectForKey:@"heart"], NSLocalizedString(@"HeartRateVC.unit", @"")];
            
            NSDateFormatter *dateFormtatter = [[NSDateFormatter alloc]init];
            [dateFormtatter setDateFormat:@"YYYY-MM-dd HH:mm"];
            for (NSDictionary *singleDic in self.heartRateArray) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[singleDic objectForKey:@"heartRateDatetime"] longLongValue]/1000];
                [self.timeArray addObject:[self compareDate:date]];
                [self.yAxisArray addObject:[NSString stringWithFormat:@"%@",[singleDic objectForKey:@"heart"]]];
            }
            [dateFormtatter setDateFormat:@"HH:mm"];
            for (NSDictionary *dic in self.heartRateArray) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[dic objectForKey:@"heartRateDatetime"] longLongValue]/1000];
                [self.xAxisArray addObject:[dateFormtatter stringFromDate:date]];
            }
            [_chart strokePath];
        } else
            self.heartRateArray = nil;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
    }];
}

#pragma mark - 判断时间是否为今天昨天
-(NSString *)compareDate:(NSDate *)date{
    NSDateFormatter *dateFormtatter = [[NSDateFormatter alloc]init];
    [dateFormtatter setDateFormat:@"HH:mm"];
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow, *yesterday;
    
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    
    if ([dateString isEqualToString:todayString]) {
        return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"mineVC.today", @""), [dateFormtatter stringFromDate:date]];
    } else if ([dateString isEqualToString:yesterdayString]) {
        return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"mineVC.yesterday", @""), [dateFormtatter stringFromDate:date]];
    }else if ([dateString isEqualToString:tomorrowString]) {
        return @"明天";
    } else {
        return [NSString stringWithFormat:@"%@ %@", dateString, [dateFormtatter stringFromDate:date]];
    }
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.heartRateArray = [NSArray array];
    self.timeArray = [NSMutableArray array];
    self.xAxisArray = [NSMutableArray array];
    self.yAxisArray = [NSMutableArray array];
    [self initLineChart];
    [self getHeartData];
    
}


- (void)initLineChart {
    _chart = [[ZFLineChart alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width - 20, 160)];
    _chart.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
    _chart.dataSource = self;
    _chart.dataSource = self;
    _chart.delegate = self;
    _chart.unit = NSLocalizedString(@"HeartRateVC.unit", @"");
    _chart.axisLineValueColor = [UIColor whiteColor];
    _chart.axisLineNameColor = [UIColor whiteColor];
    _chart.unitColor = [UIColor whiteColor];
    _chart.axisColor = [UIColor clearColor];
    _chart.lineColor = [UIColor whiteColor];
    _chart.isResetAxisLineMinValue = YES;
    _chart.isShowSeparate = NO;
    _chart.isShadow = NO;
    _chart.isShowAxisLineValue = NO;
    _chart.layer.cornerRadius = 5;
    _chart.layer.masksToBounds = YES;
    
    [self.view addSubview:_chart];
    [_chart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).with.offset(10);
        make.right.mas_equalTo(self.view.mas_right).with.offset(-10);
        make.top.mas_equalTo(self.heartLabel.mas_bottom).with.offset(10);
        make.height.mas_offset(160);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)startHeartRate:(id)sender {
    [self openHeartRatePassiveGauging];
    self.heartImage.image = [UIImage imageNamed:@"heartimg3"];
    self.heartImage.userInteractionEnabled = NO;
    //    [self startAnimation];
    //添加动画
    
    CABasicAnimation *monkeyAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    monkeyAnimation.toValue = [NSNumber numberWithFloat:2.0 *M_PI];
    monkeyAnimation.duration = 1.0f;
    monkeyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    monkeyAnimation.cumulative = NO;
    monkeyAnimation.removedOnCompletion = NO; //No Remove
    monkeyAnimation.repeatCount = FLT_MAX;
    [self.heartImage.layer addAnimation:monkeyAnimation forKey:@"AnimatedKey"];
}

-(void) startAnimation
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.02];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endAnimation)];
    self.heartImage.transform = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
    [UIView commitAnimations];
}

-(void)endAnimation
{
    angle += 10;
    [self startAnimation];
    
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.heartRateArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier =@"heartCell";
    HeartRateCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[HeartRateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    cell.timeLabel.text = [self.timeArray objectAtIndex:indexPath.row];;
    cell.heartLabel.text = [NSString stringWithFormat:@"%@ %@",[self.yAxisArray objectAtIndex:indexPath.row], NSLocalizedString(@"HeartRateVC.unit", @"")];
    
    return cell;
}



- (void)openHeartRatePassiveGauging {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/data/passiveGaugingHeartOpen.do?t=%@&watchSN=%@", DNS, [userDefault valueForKey:@"token"], [userDefault valueForKey:@"watchSN"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSLog(@"%@",urlString);
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            self.heartRateTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(cometHeartRate) userInfo:nil repeats:YES];
            [self.heartRateTimer fire];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
        self.heartImage.userInteractionEnabled = YES;
    }];
}


- (void)cometHeartRate {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/data/passiveGaugingHeartComet.do?t=%@&watchSN=%@", DNS, [userDefault valueForKey:@"token"], [userDefault valueForKey:@"watchSN"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                NSDictionary *dic = [responseObject objectForKey:@"content"];
                NSLog(@"%@",[dic objectForKey:@"content"]);
                if ([[dic objectForKey:@"type"] intValue] == 1/*正在链接手表*/) {
                    self.stateLabel.text = NSLocalizedString(@"HeartRateVC.result_1", @"");
                    
                } else if ([[dic objectForKey:@"type"] intValue] == 2/*链接成功，正在检测*/) {
                    self.stateLabel.text = NSLocalizedString(@"HeartRateVC.result_2", @"");
                    
                } else if ([[dic objectForKey:@"type"] intValue] == 3/*监测成功*/) {
                    self.stateLabel.text = NSLocalizedString(@"HeartRateVC.result_3", @"");
                    
                    self.heartImage.userInteractionEnabled = YES;
                    self.heartImage.image = [UIImage imageNamed:@"heartimg2"];
                    [self.heartImage.layer removeAnimationForKey:@"AnimatedKey"];
                    self.heartLabel.text = [NSString stringWithFormat:@"%@ %@", [dic objectForKey:@"lastHeartRate"], NSLocalizedString(@"HeartRateVC.unit", @"")];
                    [self.heartRateTimer invalidate];
                    [self performSelector:@selector(resetStateLabel) withObject:nil afterDelay:2];
                } else if ([[dic objectForKey:@"type"] intValue] == 4 /*手表没有检测出心率*/) {
                    self.stateLabel.text = NSLocalizedString(@"HeartRateVC.result_4", @"");
                    
                    self.heartImage.userInteractionEnabled = YES;
                    self.heartImage.image = [UIImage imageNamed:@"heartimg2"];
                    [self.heartImage.layer removeAnimationForKey:@"AnimatedKey"];
                    [self.heartRateTimer invalidate];
                    [self performSelector:@selector(resetStateLabel) withObject:nil afterDelay:2];
                } else if ([[dic objectForKey:@"type"] intValue] == 5) { //监测失败
                    self.stateLabel.text = NSLocalizedString(@"HeartRateVC.result_4", @"");
                    
                    self.heartImage.userInteractionEnabled = YES;
                    self.heartImage.image = [UIImage imageNamed:@"heartimg2"];
                    [self.heartImage.layer removeAnimationForKey:@"AnimatedKey"];
                    [self.heartRateTimer invalidate];
                    [self performSelector:@selector(resetStateLabel) withObject:nil afterDelay:2];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
        [self.heartRateTimer invalidate];
    }];
}

- (void)resetStateLabel {
    self.stateLabel.text = NSLocalizedString(@"HeartRateVC.measure", @"");
}


#pragma mark - ZFGenericChartDataSource

- (NSArray *)valueArrayInGenericChart:(ZFGenericChart *)chart{
    return self.yAxisArray;
}

- (NSArray *)nameArrayInGenericChart:(ZFGenericChart *)chart{
    return self.xAxisArray;
}

- (NSArray *)colorArrayInGenericChart:(ZFGenericChart *)chart{
    return @[ZFMagenta];
}

- (CGFloat)axisLineMaxValueInGenericChart:(ZFGenericChart *)chart{
    return 130;
}

- (CGFloat)axisLineMinValueInGenericChart:(ZFGenericChart *)chart{
    return 50;
}

- (NSInteger)axisLineSectionCountInGenericChart:(ZFGenericChart *)chart{
    return 4;
}

#pragma mark - ZFLineChartDelegate

//- (CGFloat)groupWidthInLineChart:(ZFLineChart *)lineChart{
//    return 25.f;
//}
//
//- (CGFloat)paddingForGroupsInLineChart:(ZFLineChart *)lineChart{
//    return 20.f;
//}
//
//- (CGFloat)circleRadiusInLineChart:(ZFLineChart *)lineChart{
//    return 5.f;
//}
//
//- (CGFloat)lineWidthInLineChart:(ZFLineChart *)lineChart{
//    return 2.f;
//}

- (void)lineChart:(ZFLineChart *)lineChart didSelectCircleAtLineIndex:(NSInteger)lineIndex circleIndex:(NSInteger)circleIndex{
    NSLog(@"第%ld个", (long)circleIndex);
}

- (void)lineChart:(ZFLineChart *)lineChart didSelectPopoverLabelAtLineIndex:(NSInteger)lineIndex circleIndex:(NSInteger)circleIndex{
    NSLog(@"第%ld个" ,(long)circleIndex);
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
