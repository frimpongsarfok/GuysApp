//
//  MainCameraViewController.m
//  Guys!
//
//  Created by SARFO KANTANKA FRIMPONG on 12/9/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "MainCameraViewController.h"

@interface MainCameraViewController ()

@end

@implementation MainCameraViewController
@synthesize m_stillImageOutput;
@synthesize m_captureBtn;
@synthesize m_exit;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    m_session=[[AVCaptureSession alloc]init];
    [m_session canSetSessionPreset:AVCaptureSessionPresetPhoto];
    
    m_captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:m_session];
    [m_captureVideoPreviewLayer setFrame:self.view.bounds];
    [m_captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.view.layer addSublayer:m_captureVideoPreviewLayer];
   
    m_tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exit)];
    [self.view addGestureRecognizer:m_tapGesture];
    
    //check if err occures
    m_device=[AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInTrueDepthCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    NSError*err;
    m_input=[AVCaptureDeviceInput deviceInputWithDevice:m_device error:&err];
    
    if(err){
        NSLog(@"Camera Error : %@",err);
        return;
        
    }
    [m_session addInput:m_input];
    [m_session startRunning];
    
    m_stillImageOutput=[[AVCapturePhotoOutput alloc]init];
    
    [self.view bringSubviewToFront:m_exit];
    [self.view bringSubviewToFront:m_captureBtn];
    
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
     [[[self tabBarController] tabBar] setHidden:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
 [[[self tabBarController] tabBar] setHidden:NO];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    
}
/*
 
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)exit {

    [UIView animateWithDuration:2 animations:^{
        if([[[self tabBarController] tabBar] isHidden]){
            [[[self tabBarController] tabBar] setHidden:NO];
        }else{
            
            [[[self tabBarController] tabBar] setHidden:YES];
        }
    }];

    
}
@end
