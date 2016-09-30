//
//  StepViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 15/10/20.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import "StepViewController.h"
#import "StepCell.h"

@interface StepViewController ()<UITableViewDataSource,UITableViewDelegate,ZFGenericChartDataSource,ZFLineChartDelegate>
{
    ZFLineChart *_chart;
    int _countY;
}

@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *stepArray;

@property (nonatomic, strong) NSMutableArray *xAxisArray;
@property (nonatomic, strong) NSMutableArray *yAxisArray;
@property (nonatomic, strong) NSMutableArray *timeArray;

@end

@implementation StepViewController



- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)getStepData {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/data/getPersonStepList.do?t=%@&deviceId=%@", DNS, [userdefault valueForKey:@"token"], [userdefault objectForKey:@"deviceId"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
            self.stepArray = [responseObject objectForKey:@"content"];
            NSDateFormatter *dateFormtatter = [[NSDateFormatter alloc]init];
            [dateFormtatter setDateFormat:@"MM-dd"];
            for (NSDictionary *singleDic in self.stepArray) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[singleDic objectForKey:@"stepDatetime"] longLongValue]/1000];
                [self.xAxisArray addObject:[dateFormtatter stringFromDate:date]];
                [self.yAxisArray addObject:[NSString stringWithFormat:@"%@",[singleDic objectForKey:@"step"]]];
                int temp = [[singleDic objectForKey:@"step"] intValue] / 1000;
                _countY = _countY > temp ? _countY : temp;
            }
            [_chart strokePath];
        } else
            self.stepArray = nil;
        [self.tableView reloadData];
        
        for (NSDictionary *singleStepDic in self.stepArray) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[singleStepDic objectForKey:@"stepDatetime"] longLongValue]/1000];
            [self.timeArray addObject:[self compareDate:date]];
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

#pragma mark - 判断时间是否为今天昨天
-(NSString *)compareDate:(NSDate *)date{
//    NSDateFormatter *dateFormtatter = [[NSDateFormatter alloc]init];
//    [dateFormtatter setDateFormat:@"yyyy-MM-dd"];

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
        return NSLocalizedString(@"mineVC.today", @"");
    } else if ([dateString isEqualToString:yesterdayString]) {
        return NSLocalizedString(@"mineVC.yesterday", @"");;
    }else if ([dateString isEqualToString:tomorrowString]) {
        return @"明天";
    } else {
        return dateString;
    }
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.stepArray = [NSArray array];
    self.xAxisArray = [NSMutableArray array];
    self.yAxisArray = [NSMutableArray array];
    self.timeArray = [NSMutableArray array];
    _countY = 0;
    [self getStepData];
    [self initLineChart];
}

/*
- (void)drawLineChartViewWithPlotArray:(NSMutableArray *)plottingArray andxAxisArray:(NSMutableArray *)xAxisArray {
    // test line chart
//    NSArray* plottingDataValues1 =@[@22, @33, @12, @23,@43, @32,@53, @33, @54,@55, @43];
//    NSArray* plottingDataValues2 =@[@24, @23, @22, @20,@53, @22,@33, @33, @54,@58, @43];
    
//    float min = [[plottingArray firstObject] floatValue];
//    float max = [[plottingArray firstObject] floatValue];
    float min = 0;
    float max = 0;
    
    for (NSString *stepValue in plottingArray) {
        min = MIN(min, [stepValue floatValue]);
        max = MAX(max, [stepValue floatValue]);
    }
    
    self.lineChartView.max = max;
    self.lineChartView.min = min;
    
    
    self.lineChartView.interval = (self.lineChartView.max-self.lineChartView.min)/5;
    self.lineChartView.pointerInterval = 40;//X轴单位长度大小
    self.lineChartView.horizontalLineInterval = 20; //Y轴单位长度大小
    self.lineChartView.xAxisFontSize = 10;
    
    NSMutableArray* yAxisValues = [@[] mutableCopy];
    for (int i=0; i<6; i++) {
        NSString* str = [NSString stringWithFormat:@"%.2f", self.lineChartView.min+self.lineChartView.interval*i];
        [yAxisValues addObject:str];
    }
    
    
//    self.lineChartView.xAxisValues = @[@"1", @"2", @"3",@"4", @"5", @"6",@"7", @"8", @"9",@"10", @"11"];
    self.lineChartView.xAxisValues = xAxisArray;
    self.lineChartView.yAxisValues = yAxisValues;
    self.lineChartView.axisLeftLineWidth = 38;
    
    
    PNPlot *plot1 = [[PNPlot alloc] init];
    plot1.plottingValues = plottingArray;
//    plot1.plottingValues = plottingDataValues1;
    
    plot1.lineColor = [UIColor blueColor];
    plot1.lineWidth = 0.5;
    
    [self.lineChartView addPlot:plot1];
    
}
*/

- (void)initLineChart {
    _chart = [[ZFLineChart alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width - 20, 160)];
    _chart.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"green"]];
    _chart.dataSource = self;
    _chart.dataSource = self;
    _chart.delegate = self;
    _chart.unit = NSLocalizedString(@"StepVC.unit", @"");
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
    
    _chart.layer.cornerRadius = 5;
    _chart.layer.masksToBounds = YES;
    
    [self.view addSubview:_chart];
    [_chart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).with.offset(10);
        make.right.mas_equalTo(self.view.mas_right).with.offset(-10);
        make.top.mas_equalTo(self.stepLabel.mas_bottom).with.offset(10);
        make.height.mas_offset(160);
    }];
    //    [self getHeartData];
    
    //    [_chart strokePath];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.stepLabel.text = [NSString stringWithFormat:@"%@ %@",self.stepNum, NSLocalizedString(@"StepVC.unit", @"")];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stepArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"stepCell";
    StepCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[StepCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.stepLabel.text = [self.yAxisArray objectAtIndex:indexPath.row];
    cell.timeLabel.text = [self.timeArray objectAtIndex:indexPath.row];
    return cell;
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
    return 1000*(_countY+1);
}

- (CGFloat)axisLineMinValueInGenericChart:(ZFGenericChart *)chart{
    return 0;
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
