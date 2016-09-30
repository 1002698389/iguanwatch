//
//  MapLoctionViewController.m
//  XIAOYI
//
//  Created by 冠一 科技 on 15/10/23.
//  Copyright © 2015年 冠一 科技. All rights reserved.
//

#import "MapLoctionViewController.h"
#import "RouteViewController.h"

@interface MapLoctionViewController ()<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapLoctionViewController

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *newAnnotation=[[MKAnnotationView alloc] init];
    newAnnotation.image = [UIImage imageNamed:@"point_1"];
    newAnnotation.canShowCallout=YES;
    return newAnnotation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after  loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
    annotation.coordinate = CLLocationCoordinate2DMake(self.lat, self.lon);
    [self.mapView addAnnotation:annotation];
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(self.lat, self.lon);
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.lat, self.lon), 1000, 1000)];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqual:@"showRoute"]) {
        RouteViewController *routeVC = [segue destinationViewController];
        routeVC.watchSN = [[NSUserDefaults standardUserDefaults] valueForKey:@"pathId"];
    }
}


@end
