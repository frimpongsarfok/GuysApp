//
//  AVPlayerViewController.m
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 5/20/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "MyAVPlayerViewController.h"

@interface MyAVPlayerViewController ()

@end

@implementation MyAVPlayerViewController

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(void)viewWillAppear:(BOOL)animated{
   [self.view setBackgroundColor:[UIColor  clearColor]];
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
     [self.view setBackgroundColor:[UIColor whiteColor]];
    [super viewWillDisappear:animated];;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[self player] setVolume:.2];
    //[[self player] setPreventsDisplaySleepDuringVideoPlayback:YES];
    //self.view.layer.cornerRadius=20;
   
    [[self player]play];

   
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
