//
//  PravicyViewController.m
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/15/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "PravicyViewController.h"

@interface PravicyViewController ()

@end

@implementation PravicyViewController
@synthesize m_userBlocked;
- (void)viewDidLoad {
    m_userBlocked.layer.cornerRadius=20;
    m_userBlocked.layer.masksToBounds=YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
