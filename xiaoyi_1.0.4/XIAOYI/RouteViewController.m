//
//  RouteViewController.m
//  TravelConcomitant
//
//  Created by 冠一 科技 on 15/7/15.
//  Copyright (c) 2015年 冠一 科技. All rights reserved.
//

#import "RouteViewController.h"
#import "RouteCell.h"
#import "NodataRouteCell.h"
#import "IGPointAnnotation.h"


@interface RouteViewController ()<MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UMSocialUIDelegate,THDatePickerDelegate>
{
    float _minLat;
    float _maxLat;
    float _minLon;
    float _maxLon;
    MKMapRect _routeRect;
    
    float _alpha;
    float _singleAlpha;
    
    BOOL _showTableView;
    
    BOOL _noData;
    
    NSInteger _deleteIndex;
}

//@property (weak, nonatomic) IBOutlet UIImageView *locusImage;
//@property (weak, nonatomic) IBOutlet UIImageView *tripImage;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *downImg;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *infoDic;

@property (nonatomic, strong) MJRefreshBackNormalFooter *footer;
//@property (nonatomic, strong) MJRefreshAutoNormalFooter *footer;

@property (nonatomic, strong) NSMutableArray *locusArray;
@property (nonatomic, strong) NSMutableDictionary *tripDic;
@property (nonatomic, strong) NSArray *sectionArray;
@property (nonatomic, assign) int pageNum;

@property (nonatomic, assign) int dayOffset;


@property (nonatomic, assign) MKPolyline *routeLine;
@property (nonatomic, strong) MKPolylineView *routeLineView;


//轨迹线颜色渐变
@property (nonatomic, strong) MKPolyline *polyLine1;
@property (nonatomic, strong) MKPolyline *polyLine2;
@property (nonatomic, strong) MKPolyline *polyLine3;
@property (nonatomic, strong) MKPolyline *polyLine4;


@property (nonatomic, strong) NSMutableArray *headerArray;
@property (nonatomic, strong) NSMutableDictionary *headerDic; //
@property (nonatomic, strong) NSMutableDictionary *dic1;


@property (nonatomic, strong) NSMutableArray *polyLineArray;
@property (nonatomic, strong) MKPointAnnotation *singleAnnotation;


@property (nonatomic, strong) NSMutableArray *resultArray;

@property (nonatomic, retain) NSDate * curDate;
@property (nonatomic, retain) NSDateFormatter * formatter;





@end

@implementation RouteViewController



-(void) loadRouteWithPoints:(NSArray *)points
{
//    NSString* filePath = [[NSBundle mainBundle] pathForResource:@”route” ofType:@”csv”];
//    NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    NSArray* pointStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray* pointStrings = points;
    
    // while we create the route points, we will also be calculating the bounding box of our route
    // so we can easily zoom in on it.
    MKMapPoint northEastPoint;
    MKMapPoint southWestPoint;
    
    // create a c array of points.
    MKMapPoint* pointArr = malloc(sizeof(CLLocationCoordinate2D) * pointStrings.count);
    
    for(int idx = 0; idx < pointStrings.count; idx++)
    {
        // break the string down even further to latitude and longitude fields.
        NSString* currentPointString = [pointStrings objectAtIndex:idx];
        NSArray* latLonArr = [currentPointString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
        CLLocationDegrees latitude = [[latLonArr objectAtIndex:0] doubleValue];
        CLLocationDegrees longitude = [[latLonArr objectAtIndex:1] doubleValue];
        
        // create our coordinate and add it to the correct spot in the array
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        MKMapPoint point = MKMapPointForCoordinate(coordinate);
        
        //
        // adjust the bounding box
        //
        
        // if it is the first point, just use them, since we have nothing to compare to yet.
        if (idx == 0) {
            northEastPoint = point;
            southWestPoint = point;
        }
        else
        {
            if (point.x > northEastPoint.x)
                northEastPoint.x = point.x;
            if(point.y > northEastPoint.y)
                northEastPoint.y = point.y;
            if (point.x < southWestPoint.x)
                southWestPoint.x = point.x;
            if (point.y < southWestPoint.y)
                southWestPoint.y = point.y;
        }
        
        pointArr[idx] = point;
        
    }
    
    // create the polyline based on the array of points.
    self.routeLine = [MKPolyline polylineWithPoints:pointArr count:pointStrings.count];
    
    _routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
    
    [self.mapView addOverlay:self.routeLine];
    
    // clear the memory allocated earlier for the points
    free(pointArr);
    
}



- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
- (IBAction)showLocus:(UITapGestureRecognizer *)sender {
    [self.locusImage setImage:[UIImage imageNamed:@"line2.png"]];
    [self.tripImage setImage:[UIImage imageNamed:@"trip.png"]];
    self.mapView.hidden = NO;
    self.tableView.hidden = YES;
}

- (IBAction)showTrip:(UITapGestureRecognizer *)sender {
    [self.locusImage setImage:[UIImage imageNamed:@"line.png"]];
    [self.tripImage setImage:[UIImage imageNamed:@"trip2.png"]];
    self.mapView.hidden = YES;
    self.tableView.hidden = NO;
}
 */

#pragma mark - 友盟分享
- (IBAction)shareRoute:(id)sender {
    NSLog(@"share");
    
    [UMSocialData openLog:YES];
    [UMSocialData defaultData].extConfig.title = @"小伊伴行";
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"5694a2b867e58eea2a00063c"
                                      shareText:@"小伊伴行，乐享生活"
                                     shareImage:[UIImage imageNamed:@"logoImage.png"]
                                shareToSnsNames:@[UMShareToSina, UMShareToTencent,UMShareToWechatSession, UMShareToWechatTimeline, UMShareToQQ, UMShareToQzone/*, UMShareToEmail, UMShareToSms, UMShareToFacebook, UMShareToTwitter*/]
                                       delegate:self];
    
}


- (IBAction)showCalendar:(id)sender {
    if(!self.datePicker)
        self.datePicker = [THDatePickerViewController datePicker];
    self.datePicker.date = self.curDate;
    self.datePicker.delegate = self;
    [self.datePicker setAllowClearDate:NO];
    [self.datePicker setAutoCloseOnSelectDate:YES];
//    [self.datePicker setSelectedBackgroundColor:[UIColor colorWithRed:125/255.0 green:208/255.0 blue:0/255.0 alpha:1.0]];
    [self.datePicker setSelectedBackgroundColor:RGBACOLOR(242, 151, 163, 1)];
    [self.datePicker setCurrentDateColor:[UIColor colorWithRed:242/255.0 green:121/255.0 blue:53/255.0 alpha:1.0]];
    
    [self.datePicker setDateHasItemsCallback:^BOOL(NSDate *date) {
        int tmp = (arc4random() % 30)+1;
        if(tmp % 5 == 0)
            return YES;
        return NO;
    }];
    [self presentSemiViewController:self.datePicker withOptions:@{
                                                                  KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                  KNSemiModalOptionKeys.animationDuration : @(0.5),
                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                                  }];
}

#pragma mark - THDatePickerDelegate
-(void)datePickerDonePressed:(THDatePickerViewController *)datePicker{
    self.curDate = datePicker.date;
    NSDate *nowdate = [NSDate date];
    if ([datePicker.date earlierDate:nowdate] == nowdate) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"routeVC.selectDate", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        NSString *date1Str = [self.formatter stringFromDate:datePicker.date];
        NSString *date2Str = [self.formatter stringFromDate:nowdate];
        
        NSDate *date1 = [self.formatter dateFromString:date1Str];
        NSDate *date2 = [self.formatter dateFromString:date2Str];
        NSTimeInterval early = [date1 timeIntervalSince1970];
        NSTimeInterval now = [date2 timeIntervalSince1970];
        NSTimeInterval cha = now - early;
        
        int day = cha / 86400;
        self.dayOffset = day;
        [self getRouteInfoFollowDayoffsetWithPathId:self.watchSN];
        [self dismissSemiModalView];
    }
}

-(void)datePickerCancelPressed:(THDatePickerViewController *)datePicker{
    //[self.datePicker slideDownAndOut];
    [self dismissSemiModalView];
}

#pragma mark -
- (void)getRouteInfoFollowDayoffsetWithPathId:(NSString *)pathId {
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-(self.dayOffset * 24*60*60)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateTime = [dateFormatter stringFromDate:date];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:dateTime forKey:@"dateTime"];
    NSNumber *select = [NSNumber numberWithBool:NO];
    [dic setObject:select forKey:@"selected"];
    [self.headerArray addObject:dic];

//    [self.headerArray addObject:dateTime];
    
    
    
    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:kBWMMBProgressHUDMsgLoading];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/place/getWatchPathMapViaIgPathId.do?t=%@&igPathId=%@&pageNum=%@&pageSize=&dayOffset=%@",DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], pathId,@""/*[NSString stringWithFormat:@"%d",self.pageNum]*/, [NSString stringWithFormat:@"%d",self.dayOffset]];
    NSLog(@"%@",urlString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int a = [[responseObject objectForKey:@"code"] intValue];
        [HUD hide:YES];
        if (a == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                NSArray *array = [responseObject objectForKey:@"content"];
                NSLog(@"%@",array);
                [self.resultArray addObjectsFromArray:array];
//                self.resultArray = [responseObject objectForKey:@"content"];
                NSLog(@"%@",self.resultArray);
                _singleAlpha = 0.5/self.resultArray.count;
                [self drawLocusInMapWithArray:self.resultArray];
//                [self.dic1 setObject:self.resultArray forKey:dateTime];
            } else {
//                self.resultArray = nil;
                [self.resultArray removeAllObjects];
                [self drawLocusInMapWithArray:self.resultArray];

//                NSArray *array = [NSArray array];
//                [self.dic1 setObject:array forKey:dateTime];
            }
            NSLog(@"%@",self.dic1);
            [self.tableView reloadData];
//            [self.tableView.footer endRefreshing];
        } else if (a == -1006 || a == -1007) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:[responseObject objectForKey:@"showToUI"] delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 999;
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [HUD hide:YES];
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];
    }];
}

#pragma mark - 获取线路、绘制轨迹
- (void)getRouteInfoByPathID:(NSString *)pathID {
    //http://%@/place/getWatchPathMapViaIgPathId.do?t=%@&igPathId=%@&pageNum=%@&pageSize=30&dayOffset=%@
    MBProgressHUD *HUD = [MBProgressHUD bwm_showHUDAddedTo:self.view title:NSLocalizedString(@"MBProgressHUD.loading", @"")];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/place/getWatchPathMapViaIgPathId.do?t=%@&igPathId=%@&pageNum=%@&pageSize=&dayOffset=%@",DNS, [[NSUserDefaults standardUserDefaults] valueForKey:@"token"], pathID,@""/*[NSString stringWithFormat:@"%d",self.pageNum]*/, [NSString stringWithFormat:@"%d",self.dayOffset]];
    NSLog(@"%@",urlString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int a = [[responseObject objectForKey:@"code"] intValue];
        [HUD hide:YES];
        if (a == 1000) {
            if (![[responseObject objectForKey:@"content"] isEqual:[NSNull null]]) {
                NSArray *array = [responseObject objectForKey:@"content"];
//                [self.locusArray addObjectsFromArray:array];
                
                [self drawLocusInMapWithArray:array];
                NSMutableArray *tempArray = [NSMutableArray array];
                NSMutableSet *set = [NSMutableSet set];
                for (NSDictionary *dic in array) {
                    NSNumber *showInTimeLine = [dic objectForKey:@"showInTimeLine"];
                    if ([showInTimeLine boolValue]) {
                        [set addObject:[dic objectForKey:@"deviceRecordDate"]];
                        NSLog(@"%@",[dic objectForKey:@"deviceRecordDate"]);
                        NSLog(@"%@",[dic objectForKey:@"deviceRecordTime"]);
                        [tempArray addObject:dic];
                    }
                }
                NSMutableDictionary *singleResultDic = [NSMutableDictionary dictionary];
                for (NSString *date in set) {
                    NSLog(@"date = %@",date);
                    NSMutableArray *singleDayArray = [NSMutableArray array];
                    for (int i = 0; i < tempArray.count; i++) {
                        if ([date isEqual:[[tempArray objectAtIndex:i] objectForKey:@"deviceRecordDate"]]) {
                            NSLog(@"date2 = %@",[[tempArray objectAtIndex:i] objectForKey:@"deviceRecordDate"]);
                            [singleDayArray addObject:[tempArray objectAtIndex:i]];
                        }
                    }
                    [tempArray removeObjectsInArray:singleDayArray];
                    [singleResultDic setObject:singleDayArray forKey:date];
                }
                
                if (self.tripDic.count == 0) {
                    self.tripDic = singleResultDic;
                } else {
                    for (NSString *date1 in [singleResultDic allKeys]) {
                        BOOL same = NO;
                        for (NSString *date2 in [self.tripDic allKeys]) {
                            if ([date1 isEqual:date2]) {
                                NSMutableArray *array = [self.tripDic objectForKey:date2];
                                [array addObjectsFromArray:[singleResultDic objectForKey:date1]];
                                same = YES;
                            }
                        }
                        if (!same) {
                            [self.tripDic setObject:[singleResultDic objectForKey:date1] forKey:date1];
                        }
                    }
                }
                NSLog(@"%@",self.tripDic);
                self.sectionArray = [[self.tripDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
                    NSDate *date1 = [dateFormatter dateFromString:obj1];
                    NSDate *date2 = [dateFormatter dateFromString:obj2];
                    [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
                    if ([[date1 earlierDate:date2] isEqual:date2]) {
                        return NSOrderedAscending;
                    } else {
                        return NSOrderedDescending;
                    }
                }];
                [self.tableView reloadData];
                
                NSNumber *hasNextPage = [[responseObject objectForKey:@"dataInfo"] objectForKey:@"hasNextPage"];
                if ([hasNextPage boolValue]) {
                    [self.tableView.footer endRefreshing];
                } else {
                    [self.tableView.footer endRefreshingWithNoMoreData];
                }
            } else {
                [self.tableView.footer endRefreshingWithNoMoreData];
            }
        } else if ([[responseObject objectForKey:@"code"] intValue] == -1006) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.expired", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 999;
            [alertView show];
        } else if ([[responseObject objectForKey:@"code"] intValue] == -1007) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"prompt", @"") message:NSLocalizedString(@"Alert.invalid", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            alertView.tag = 999;
            [alertView show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [HUD hide:YES];
        [Hint showAlertIn:self.view WithMessage:NSLocalizedString(@"Alert.serverFailed", @"")];

    }];
}

- (void)drawLocusInMapWithArray:(NSArray *) pointArray {
    _alpha = 1;
    //删除标注和轨迹线
    [self.mapView removeOverlays:self.polyLineArray];
    [self.polyLineArray removeAllObjects];
    [self.mapView removeAnnotation:self.singleAnnotation];
    [self.mapView removeAnnotations:self.locusArray];
    [self.locusArray removeAllObjects];
    
    //
    NSInteger count = [pointArray count];
    CLLocationCoordinate2D pathCoords[count];
    for (int i = 0; i < count; i++) {
        NSDictionary *dic = [pointArray objectAtIndex:i];
        float lat = [[dic objectForKey:@"latitude"] floatValue];
        float lon = [[dic objectForKey:@"longitude"] floatValue];
        pathCoords[i] = CLLocationCoordinate2DMake(lat, lon);
        
        if (i == 0) {
            _minLat = lat;
            _maxLat = lat;
            _minLon = lon;
            _maxLon = lon;
        }
        if (lat >= _maxLat) {
            _maxLat = lat;
        } else if (lat <= _minLat) {
            _minLat = lat;
        }
        if (lon >= _maxLon) {
            _maxLon = lon;
        } else if (lon <= _minLon) {
            _minLon = lon;
        }
        
        //每个点都加标注
//        IGPointAnnotation *annotation = [[IGPointAnnotation alloc]init];
//        annotation.coordinate = pathCoords[i];
//        annotation.title = [[pointArray objectAtIndex:i] objectForKey:@"addressSimpleName"];
//        annotation.annotationId = [[pointArray objectAtIndex:i] objectForKey:@"id"];
//        [self.locusArray addObject:annotation];
//        [self.mapView addAnnotations:self.locusArray];
//        [self.mapView addAnnotation:annotation];
        
        //添加停留定位点标注
        int recordCount = [[dic objectForKey:@"gpsRecordCount"] intValue];
        if (recordCount > 1) {
            MKPointAnnotation *anno = [[MKPointAnnotation alloc]init];
            anno.coordinate = CLLocationCoordinate2DMake(lat, lon);
            [self.mapView addAnnotation:anno];
            [self.locusArray addObject:anno];
        }
    }
    
    //添加最后定位点标注
    float lat = [[[pointArray firstObject] objectForKey:@"latitude"] floatValue];
    float lon = [[[pointArray firstObject] objectForKey:@"longitude"] floatValue];
    self.singleAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lon);
    [self.mapView addAnnotation:self.singleAnnotation];
    
    
    //画轨迹线
    for (int i = 0; i < count-1; i++) {
        CLLocationCoordinate2D points[2];
        float lat1 = [[[pointArray objectAtIndex:i] objectForKey:@"latitude"] floatValue];
        float lon1 = [[[pointArray objectAtIndex:i] objectForKey:@"longitude"] floatValue];
        float lat2 = [[[pointArray objectAtIndex:i+1] objectForKey:@"latitude"] floatValue];
        float lon2 = [[[pointArray objectAtIndex:i+1] objectForKey:@"longitude"] floatValue];
        points[0] = CLLocationCoordinate2DMake(lat1, lon1);
        points[1] = CLLocationCoordinate2DMake(lat2, lon2);
        
        MKPolyline *singlePolyLine = [MKPolyline polylineWithCoordinates:points count:2];
        [self.polyLineArray addObject:singlePolyLine];
        
    }
    [self.mapView addOverlays:self.polyLineArray];
    
    
    //设置地图显示范围
    float centerLat = (_minLat + _maxLat ) / 2;
    float centerLon = (_minLon + _maxLon ) / 2;
    CLLocation *minLatLocation = [[CLLocation alloc]initWithLatitude:_minLat longitude:centerLon];
    CLLocation *maxLatLocation = [[CLLocation alloc]initWithLatitude:_maxLat longitude:centerLon];
    CLLocation *minLonLocation = [[CLLocation alloc]initWithLatitude:centerLat longitude:_minLon];
    CLLocation *maxLonLocation = [[CLLocation alloc]initWithLatitude:centerLat longitude:_maxLon];
    CLLocationDistance latDistance = [minLatLocation distanceFromLocation:maxLatLocation];
    CLLocationDistance lonDistance = [minLonLocation distanceFromLocation:maxLonLocation];
    float latDegrees = latDistance / 111000;
    float lonDegrees = lonDistance / 111000;
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(centerLat, centerLon), MKCoordinateSpanMake(latDegrees, lonDegrees*2))];
    
}



#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.headerArray = [NSMutableArray array];
    self.dic1 = [NSMutableDictionary dictionary];
    self.headerDic = [NSMutableDictionary dictionary];
    
    _alpha = 1;
    
    self.polyLineArray = [NSMutableArray array];
    self.singleAnnotation = [[MKPointAnnotation alloc]init];
    
    self.resultArray = [[NSMutableArray alloc]init];
    
    self.showTripOrLocus = 1;
    
    self.navigationController.navigationBarHidden = NO;
    
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(36.071883, 120.433722), MKCoordinateSpanMake(0.08, 0.08))];
    self.mapView.delegate = self;
    
    self.pageNum = 1;
    self.dayOffset = 0;
    
    self.infoDic = [NSDictionary dictionary];
    self.locusArray = [NSMutableArray array];
    self.tripDic = [NSMutableDictionary dictionary];
    self.sectionArray = [NSArray array];
    
//    self.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
//    self.tableView.footer = self.footer;
//    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    self.curDate = [NSDate date];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy-MM-dd"];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
//    [self getRouteInfoByPathID:self.watchSN];
    [self getRouteInfoFollowDayoffsetWithPathId:self.watchSN];
    self.navigationItem.title = [NSString stringWithFormat:@"%@%@",self.watchUserName ,NSLocalizedString(@"routeVC.trip", @"")];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 上拉加载数据
- (void)loadMoreData {
    self.pageNum++;
    self.dayOffset++;
//    [self getRouteInfoByPathID:self.watchSN];
    [self getRouteInfoFollowDayoffsetWithPathId:self.watchSN];
}


#pragma mark - UITableView DataSource
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return self.headerArray.count;
    return 1;
} */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.resultArray.count == 0) {
        return 1;
    } else {
        return self.resultArray.count;
    }
    return 0;
    /*
    NSInteger count = [[self.dic1 objectForKey:[[self.headerArray objectAtIndex:section] objectForKey:@"dateTime"]] count];
    BOOL selected = [[[self.headerArray objectAtIndex:section] objectForKey:@"selected"] boolValue];
    if (count == 0) {
        return 1;
    } else {
        if (selected) {
            return count;
        } else {
            return 1;
        }
    }
     */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    static NSString *cellIdentifier = @"routeCell";
    RouteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[RouteCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSMutableArray *singleDay = [self.tripDic objectForKey:[self.sectionArray objectAtIndex:indexPath.section]];
    
    NSDictionary *dic = [singleDay objectAtIndex:indexPath.row];
    NSLog(@"%@",dic);
    
    cell.titleLabel.text = [dic objectForKey:@"addressSimpleName"];
//    cell.timeLabel.text = [dateFormtatter stringFromDate:date];
    cell.timeLabel.text = [dic objectForKey:@"deviceRecordTime"];
    cell.addressLabel.text = [dic objectForKey:@"address"];
    int typeIndex = [[dic objectForKey:@"igPlaceCodeTypeId"] intValue];
    
    switch (typeIndex) {
        case 633:
            cell.typeImage.image = [UIImage imageNamed:@"icon2"];
            break;
        case 634:
            cell.typeImage.image = [UIImage imageNamed:@"icon4"];
            break;
        case 635:
            cell.typeImage.image = [UIImage imageNamed:@"icon3"];
            break;
        case 636:
            cell.typeImage.image = [UIImage imageNamed:@"icon5"];
            break;
        default:
            cell.typeImage.image = [UIImage imageNamed:@"icon1"];
            break;
    }
    return cell;
     */
    
    if (self.resultArray.count == 0) {
        static NSString *cellIdentifier = @"noDataCell";
        NodataRouteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[NodataRouteCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
//        cell.textLabel.text = @"查询当天无定位数据";
        return cell;
    } else {
        
        static NSString *cellIdentifier = @"routeCell";
        RouteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[RouteCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        NSDictionary *dic = [self.resultArray objectAtIndex:indexPath.row];
//        NSLog(@"%@",dic);
        
        cell.titleLabel.text = [dic objectForKey:@"addressSimpleName"];
        cell.timeLabel.text = [dic objectForKey:@"deviceRecordTime"];
        cell.addressLabel.text = [dic objectForKey:@"address"];
        NSString *type = [dic objectForKey:@"igIconFileName"];
        if ([type isEqual:@""]) {
            cell.typeImage.image = [UIImage imageNamed:@"touristAttractions"];
        } else {
            cell.typeImage.image = [UIImage imageNamed:type];
        }
        //停留30分钟以上显示
        int recordCount = [[dic objectForKey:@"gpsRecordCount"] intValue];
        if (recordCount > 1) {
            long timeInterval = ([[dic objectForKey:@"deviceRecordDatetime"] longLongValue] - [[dic objectForKey:@"deviceRecordDatetimeFront"] longLongValue]) / 1000;
            
            int hour = (int)(timeInterval / 3600);
            int minute = (int)(timeInterval - hour*3600)/60;
            if (hour == 0) {
                if (minute >= 30) {
                    cell.stayTimeLabel.text = [NSString stringWithFormat:@"在此停留%d分", minute];
                } else {
                    cell.stayTimeLabel.text = @"";
                }
            } else {
                cell.stayTimeLabel.text = [NSString stringWithFormat:@"在此停留%d时%d分", hour, minute];
            }
        } else {
            cell.stayTimeLabel.text = @"";
        }
        return cell;
        /*
        //单条定位点信息
        BOOL selected = [[[self.headerArray objectAtIndex:indexPath.section] objectForKey:@"selected"] boolValue];
        if (selected) {
            
        } else {
            //未展开时，显示起始点信息
            static NSString *cellIdentifier = @"headerCell";
            HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[HeaderCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            NSDictionary *dic = [singleAry objectAtIndex:indexPath.row];
            NSLog(@"%@",dic);
            cell.fromLabel.text = [[singleAry lastObject] objectForKey:@"addressSimpleName"];
            cell.toLabel.text = [[singleAry firstObject] objectForKey:@"addressSimpleName"];
            
            return cell;
        }
         */
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.resultArray.count == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"      ";
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _deleteIndex = indexPath.row;
        [self deleteWatchLocusWith:[[self.resultArray objectAtIndex:_deleteIndex] objectForKey:@"id"]];
    }
}

/*
#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger count = [[self.dic1 objectForKey:[[self.headerArray objectAtIndex:indexPath.section] objectForKey:@"dateTime"]] count];
    BOOL selected = [[[self.headerArray objectAtIndex:indexPath.section] objectForKey:@"selected"] boolValue];
    if (count == 0) {
        return 44;
    } else {
        if (selected) {
            return 120;
        } else {
            return 80;
        }
        
    }
    
}

*/

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    view.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:184.0/255.0 blue:186.0/255.0 alpha:1];
    UILabel *label = [[UILabel alloc]init];
    label.frame = CGRectMake(20, 6, 120, 20);
    NSString *dateTime = [[self.headerArray objectAtIndex:section] objectForKey:@"dateTime"];
    label.text = dateTime;
    [view addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:0];
    button.tag = 1000+section;
    button.frame = view.frame;
    [button addTarget:self action:@selector(showSingleSetionData:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    NSInteger count = [[self.dic1 objectForKey:dateTime] count];
    if (count != 0) {
        UIButton *btn = [UIButton buttonWithType:0];
        
        [btn setTitle:@"显示轨迹" forState:UIControlStateNormal];
        btn.tag = section;
        [btn addTarget:self action:@selector(showLocusInSection:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(view.mas_trailing).offset(0);
            make.top.equalTo(view.mas_top).offset(0);
            make.bottom.equalTo(view.mas_bottom).offset(0);
            make.width.equalTo(@100);
        }];
    }
    
    
    return view;
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    /*
    NSMutableArray *singleDay = [self.dic1 objectForKey:[self.headerArray objectAtIndex:indexPath.section]];
    NSDictionary *dic = [singleDay objectAtIndex:indexPath.row];
    
    for (IGPointAnnotation *annotation in self.locusArray) {
        if ([annotation.annotationId isEqual:[dic objectForKey:@"id"]]) {
            [self.mapView selectAnnotation:annotation animated:YES];
            break;
        }
    }
    [self.locusImage setImage:[UIImage imageNamed:@"line2.png"]];
    [self.tripImage setImage:[UIImage imageNamed:@"trip.png"]];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([[dic objectForKey:@"latitude"] floatValue], [[dic objectForKey:@"longitude"] floatValue])];
    self.mapView.hidden = NO;
    self.tableView.hidden = YES;
    */
    
    BOOL selected = [[[self.headerArray objectAtIndex:indexPath.section] objectForKey:@"selected"] boolValue];
    if (selected) {
        return;
    }
    selected = !selected;
    NSNumber *num = [NSNumber numberWithBool:selected];
    [[self.headerArray objectAtIndex:indexPath.section] setObject:num forKey:@"selected"];
    
    [self.tableView reloadData];
}


#pragma mark -
- (void)showLocusInSection:(UIButton *)sender {
    NSInteger index = sender.tag;

//    [self.locusImage setImage:[UIImage imageNamed:@"line2.png"]];
//    [self.tripImage setImage:[UIImage imageNamed:@"trip.png"]];
    NSArray *singleAry = [self.dic1 objectForKey:[[self.headerArray objectAtIndex:index] objectForKey:@"dateTime"]];
    [self drawLocusInMapWithArray:singleAry];
    self.mapView.hidden = NO;
    self.tableView.hidden = YES;
}

- (void)showSingleSetionData:(UIButton *) sender {
    NSInteger index = sender.tag - 1000;
    BOOL selected = [[[self.headerArray objectAtIndex:index] objectForKey:@"selected"] boolValue];
    selected = !selected;
    NSNumber *num = [NSNumber numberWithBool:selected];
    [[self.headerArray objectAtIndex:index] setObject:num forKey:@"selected"];
    
    [self.tableView reloadData];
}


#pragma mark - 删除点位
- (void)deleteWatchLocusWith:(NSString *)pathCode {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/place/delWatchPathIgCodeId.do?t=%@&igPathCodeRefId=%@", DNS, [userDefault valueForKey:@"token"], pathCode];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@", responseObject);
        if ([[responseObject objectForKey:@"code"] intValue] == 1000) {
            [self.resultArray removeObjectAtIndex:_deleteIndex];
            
            [self.tableView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
    
}

#pragma mark - MKMapKit Delegate

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *renderer=[[MKPolylineRenderer alloc]initWithOverlay:overlay];
        renderer.strokeColor=[[UIColor colorWithRed:2.0/255.0 green:136.0/255.0 blue:209.0/255.0 alpha:1.0] colorWithAlphaComponent:_alpha];
        renderer.lineWidth = 3.0;
        _alpha-=_singleAlpha;
        return renderer;
    }
    if([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleRenderer *circle = [[MKCircleRenderer alloc]initWithOverlay:overlay];
        circle.lineWidth = 5.0;
        circle.strokeColor = [UIColor blueColor];
        circle.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        return circle;
    }
    if([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonRenderer *polygon = [[MKPolygonRenderer alloc]initWithOverlay:overlay];
        polygon.lineWidth = 5.0;
        polygon.strokeColor = [UIColor yellowColor];
        polygon.fillColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
        return polygon;
    }
    return nil;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    MKAnnotationView *newAnnotation = [[MKAnnotationView alloc] init];
    
    newAnnotation.canShowCallout=YES;
    if ([annotation isEqual:self.singleAnnotation]) {
        newAnnotation.image = [UIImage imageNamed:@"point_1"];
    } else {
        newAnnotation.image = [UIImage imageNamed:@"point_2"];
    }
    return newAnnotation;
    
}


#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999) {
        if (buttonIndex == 0) {
            
//            EMError *error = nil;
//            NSDictionary *info = [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:YES error:&error];
//            if (!error && info) {
//                NSLog(@"退出成功");
//            }
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hadLogged"];
            UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            [self presentViewController:[loginSB instantiateInitialViewController] animated:NO completion:^{
//                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            /*
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hadLogin"];
            NSString *rootType = [[NSUserDefaults standardUserDefaults] valueForKey:@"rootVCType"];
            if ([rootType isEqual:@"login"]) {
                [self dismissViewControllerAnimated:YES completion:NULL];
            } else if ([rootType isEqual:@"main"]) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                [self presentViewController:[storyboard instantiateInitialViewController] animated:YES completion:NULL];
            }
//            [self dismissViewControllerAnimated:YES completion:NULL];
             */
        }
    }
}



#pragma mark - 显示轨迹列表
- (IBAction)showTableView:(UIButton *)sender {
    _showTableView = !_showTableView;
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [self.view removeConstraint:self.downViewTopConstraint];
        if (_showTableView) {
            self.downViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.downView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.mapView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-400];
            self.downImg.image = [UIImage imageNamed:@"routeDown"];
            
            self.downView.frame = CGRectMake(0, self.view.frame.size.height - 44 - 356, self.view.frame.size.width, 44);
            self.tableView.frame = CGRectMake(0, self.view.frame.size.height - 356, self.view.frame.size.width, 356);
        } else {
            self.downViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.downView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.mapView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-44];
            self.downImg.image = [UIImage imageNamed:@"routeUp"];
            self.downView.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
            self.tableView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 356);
        }
        [self.view addConstraint:self.downViewTopConstraint];
    } completion:^(BOOL finished) {
//        [self.downView setNeedsUpdateConstraints];
    }];
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
