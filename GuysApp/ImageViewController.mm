//
//  ImageViewController.m
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/3/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "ImageViewController.h"
#import "ShareTableViewController.h"
@interface ImageViewController ()

@end

@implementation ImageViewController

-(void)viewDidDisappear:(BOOL)animated{
  m_appDelegate->m_toJid=m_to;
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    m_appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //m_closeBtn=[UIButton buttonWithType: UIButtonTypeCustom];
   // [m_closeBtn setTitle:@"X" forState:UIControlStateNormal];
   // [m_closeBtn setFont:[ UIFont fontWithName:@"Arial" size:25]];
    
    //[m_closeBtn setFrame:CGRectMake(self.view.frame.size.width*.8,40, 50, 50)];
    //[m_closeBtn addTarget:self action:@selector(closeMe) forControlEvents:UIControlEventTouchUpInside];
    m_shareBarItem=[[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleDone target:self action:@selector(shareImage)];
    self.navigationItem.rightBarButtonItem=m_shareBarItem;
   
    
    
    // Do any additional setup after loading the view.
}
-(void)setToJID:(NSString*)jid{
    m_to=jid;
}
-(void)shareImage{

    
    ShareTableViewController *tmpShare=[[ShareTableViewController alloc]initWithDataArray:m_data];
    
    if(!m_data)
        return;
    [self.navigationController pushViewController:tmpShare
                                         animated: YES];
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(void)setImage:(UIImage*)image data:(NSArray*) data{
    
    m_data=data;
    m_imageView=[[UIImageView alloc]initWithFrame:self.view.frame];
    m_blureImageView=[[UIImageView alloc]initWithFrame:m_imageView.frame];
    
    [self.view addSubview:m_blureImageView];
    
    m_blur=[[UIVisualEffectView alloc]initWithFrame:m_imageView.frame];
    [m_blur setEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
    
    [self.view addSubview:m_blur];
    
    
    [m_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [[m_blur contentView] addSubview:m_imageView];
    //[m_imageView addSubview:m_closeBtn];
    [m_imageView setUserInteractionEnabled:YES];
    [m_imageView setImage:image];
    [m_blureImageView setImage:image];
}

-(void)closeMe{
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
