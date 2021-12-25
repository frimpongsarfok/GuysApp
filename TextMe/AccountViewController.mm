//
//  AccountViewController.m
//  Guys!
//
//  Created by SARFO KANTANKA FRIMPONG on 7/22/18.
//  Copyright © 2018 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "AccountViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController{
    UIViewController *tmpViewController;
    UIImage *m_seleetedImageForDP,*m_realSelectedImg;
    UIImageView *m_selectedImageForDPView;
    UIImageView *m_selectedImgBlurView;
    UIView * p1,*p2,*p3,*p4;
    UIPanGestureRecognizer *ges_p1,*ges_p2,*ges_p3,*ges_p4;
    CGPoint m_gesStartpoint;

}
@synthesize m_usrDP;
@synthesize m_name;
@synthesize m_privacyBtn;
@synthesize m_accountBtn;
@synthesize m_phoneNum;


@synthesize m_deleteAcount;
- (void)viewDidLoad {

    [super viewDidLoad];
    //if image from camera set it to true
    m_fromCamera=false;
    // Do any additional setup after loading the view.
    [m_usrDP setUserInteractionEnabled:YES];
   m_usrDPGesture= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(setUserDP)];
    m_usrDPGesture.numberOfTapsRequired=1;
    m_usrDPGesture.numberOfTouchesRequired=1;
    [m_usrDPGesture setDelegate:self];
    [m_usrDP addGestureRecognizer:m_usrDPGesture];
    m_usrDP.contentMode=UIViewContentModeScaleToFill;
    m_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    m_indicator.hidesWhenStopped = YES;
    m_indicator.frame = CGRectMake((m_usrDP.frame.size.width/2)-100, (m_usrDP.frame.size.height/2)-100, 200, 200);
    [m_usrDP addSubview:m_indicator];
    //[m_bigImage setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:.65 alpha:1]];

 
    tmpViewController=[[UIViewController alloc]init];
    
    m_appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    m_data=(AppData*)m_appDelegate->m_data;
    m_xmppEngine=(XmppEgine*)m_appDelegate->m_xmppEngine;
   
 
    
    NSString *number=[NSString stringWithUTF8String:gloox::JID(std::get<0>(m_data->getUserInfo())).username().c_str()];
    
    if([number length]>0){
        [m_phoneNum setText:[@"+" stringByAppendingString:number]];
    }
    else{
        [self setAccount];
        
    }
    
    if(m_data){
        try {
           
            std::string imgData=std::get<2>(m_data->getUserInfo());
            if(std::get<0>(m_data->getUserInfo()).size())
                imgData= std::get<2>(m_data->getUserInfo());
            NSString *photoString=[NSString stringWithFormat:@"%s", imgData.c_str()];
            
            NSData *photoData=[[NSData alloc]initWithBase64EncodedString:photoString options:0];
            
            std::cout<<" user dp size :"<<imgData.size()<<std::endl;
            UIImage *img=[UIImage imageWithData:photoData];
            if(img.size.height){
               [m_usrDP setImage:img];
          
              
           }
           
            std::cout<<"DP was set"<<std::endl;
        } catch (std::exception etc) {
            
        }
        
    }
   
}

- (IBAction)inviteFriends:(id)sender {
    //very with email
    //save to vcard
    //save to db
    
   
    
    
}
- (IBAction)saveProfile:(id)sender {
}

-(void)viewWillAppear:(BOOL)animated{

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
 
 
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    m_realSelectedImg=[[UIImage alloc]init];
    m_realSelectedImg=[info objectForKey:UIImagePickerControllerOriginalImage];
    std::cout<<"h "<<m_realSelectedImg.size.height<<" w "<<m_realSelectedImg.size.width<<std::endl;

    [picker dismissViewControllerAnimated:YES completion:^{
    }];
   
    //cancel btn
    UIButton *cancelBtn=[[UIButton alloc]initWithFrame:CGRectMake(70, self.view.frame.size.height-150, 70, 70)];
    [cancelBtn setTitle:@"X" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(closeTmpViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //Ok Btn
    UIButton *done=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-150, self.view.frame.size.height-150, 70, 70)];
    [done addTarget:self action:@selector(setDisplayPicture:) forControlEvents:UIControlEventTouchUpInside];
    [done setTitle:@"Done" forState:UIControlStateNormal];
    
    
   
    //crop selected image
   
    
    // m_selectedImgBlurView=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width*.1, self.view.frame.size.height*.1, self.view.frame.size.width*.8, self.view.frame.size.height*.6)];
    //[m_selectedImgBlurView setUserInteractionEnabled:YES];
    
      //[self->tmpViewController.view addSubview:m_selectedImgBlurView];
    
   // UIVisualEffectView *blur=[[UIVisualEffectView alloc]initWithFrame:CGRectMake(0, 0, m_selectedImgBlurView.frame.size.width, m_selectedImgBlurView.frame.size.height)];
  //  [blur setEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
   // [blur setUserInteractionEnabled:YES];
  //  [m_selectedImgBlurView setImage:m_realSelectedImg];
   // [m_selectedImgBlurView addSubview:blur];
   
    
    m_selectedImageForDPView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*.7)];
    
   // if((m_realSelectedImg.size.height<600 && m_realSelectedImg.size.width<600 ))
        
    
    //[m_selectedImageForDPView setUserInteractionEnabled:YES];
   // [m_selectedImgBlurView addSubview:m_selectedImageForDPView];
    

    
  //  p1=[[UIView alloc]initWithFrame:CGRectMake(45,45, 30, 30)];
   
    
  /*  p2=[[UIView alloc]initWithFrame:CGRectMake(m_selectedImageForDPView.frame.size.width-45,45, 30, 30)];
    p3=[[UIView alloc]initWithFrame:CGRectMake(45, m_selectedImageForDPView.frame.size.height-45, 30,30)];
     p4=[[UIView alloc]initWithFrame:CGRectMake(m_selectedImageForDPView.frame.size.width-45,m_selectedImageForDPView.frame.size.height-45, 30, 30)];
    
    ges_p1=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(p1_func:)];
    [ges_p1 setMaximumNumberOfTouches:1];
    [ges_p1 setMinimumNumberOfTouches:1];
    
    
    ges_p2=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(p2_func:)];
    [ges_p2 setMaximumNumberOfTouches:1];
    [ges_p2 setMinimumNumberOfTouches:1];
    ges_p3=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(p3_func:)];
    [ges_p3 setMaximumNumberOfTouches:1];
    [ges_p3 setMinimumNumberOfTouches:1];
    ges_p4=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(p4_func:)];
    [ges_p4 setMaximumNumberOfTouches:1];
    [ges_p4 setMinimumNumberOfTouches:1];
    
    
    
    [m_selectedImageForDPView addSubview:p1];
    [m_selectedImageForDPView addSubview:p2];
    [m_selectedImageForDPView addSubview:p3];
    [m_selectedImageForDPView addSubview:p4];
   

    
    [p1 addGestureRecognizer:ges_p1];
    [p2 addGestureRecognizer:ges_p2];
    [p3 addGestureRecognizer:ges_p3];
    [p4 addGestureRecognizer:ges_p4];
    [m_selectedImageForDPView setBackgroundColor:[UIColor whiteColor]];
    p1.tintColor=p2.tintColor=p3.tintColor=p4.tintColor=[UIColor whiteColor];
    [p1 addSubview:[[UIImageView alloc]initWithImage:[UIImage systemImageNamed:@"arrow.down.right"]]];
    [p2 addSubview:[[UIImageView alloc]initWithImage:[UIImage systemImageNamed:@"arrow.down.left"]]];
    [p3 addSubview:[[UIImageView alloc]initWithImage:[UIImage systemImageNamed:@"arrow.up.right"]]];
    [p4 addSubview:[[UIImageView alloc]initWithImage:[UIImage systemImageNamed:@"arrow.up.left"]]];
    p1.layer.cornerRadius=p2.layer.cornerRadius=p3.layer.cornerRadius=p4.layer.cornerRadius=10;
    p1.layer.masksToBounds=p2.layer.masksToBounds=p3.layer.masksToBounds=p4.layer.masksToBounds=YES;

    */
   
    
     //[selectedImg drawInRect:cropedImgView.frame];
   // CGImageRef imgRef=CGImageCreateWithImageInRect([selectedImg CGImage],cropedImgView.frame);
   // UIImage *tmpImg=[UIImage imageWithCGImage: imgRef];
     // CGImageRelease(imgRef);
   // m_realSelectedImg=[self rotate:CGRectMake(0, 0, m_realSelectedImg.size.width, m_realSelectedImg.size.height) viewRect:m_realSelectedImg];
   // m_seleetedImageForDP=[self cropImage:m_selectedImageForDPView.frame :m_realSelectedImg];
 
    [m_selectedImageForDPView setImage:m_realSelectedImg];
    [m_selectedImageForDPView setBackgroundColor:[UIColor darkGrayColor]];
    [m_selectedImageForDPView setContentMode:UIViewContentModeScaleAspectFit];
   
    [self->tmpViewController.view addSubview:cancelBtn];
    [self->tmpViewController.view addSubview:done];
    [self->tmpViewController.view addSubview:m_selectedImageForDPView];
    [self->tmpViewController.view setBackgroundColor:[UIColor blackColor]];
    [self presentViewController:self->tmpViewController animated:YES completion:nil];
    
  
    
}

-(void)p1_func:(UIPanGestureRecognizer*)gesture{
    
    if(gesture.state==UIGestureRecognizerStateBegan){
        
        
        m_gesStartpoint=gesture.view.center;//CGPointMake(gesture.view.center.x+translation.x, gesture.view.center.y+translation.y);

    }else if(gesture.state==UIGestureRecognizerStateChanged){
        CGPoint translation=[gesture translationInView:m_selectedImgBlurView];
        if(gesture.state==UIGestureRecognizerStateBegan){
            
            
            m_gesStartpoint=gesture.view.center;//CGPointMake(gesture.view.center.x+translation.x, gesture.view.center.y+translation.y);
            
        }else if(gesture.state==UIGestureRecognizerStateChanged){
            
    
            gesture.view.center=CGPointMake(gesture.view.center.x+translation.x, gesture.view.center.y+translation.y);
            CGPoint distance=CGPointMake(gesture.view.center.x-m_gesStartpoint.x,  gesture.view.center.y-m_gesStartpoint.y);
            CGRect p1TmpRect=CGRectMake(45,45, gesture.view.frame.size.width,gesture.view.frame.size.height);
       
            
            if(m_selectedImageForDPView.frame.origin.y<1){
                
              
                distance.y=1;
                [gesture setTranslation:CGPointMake(0, 0) inView:m_selectedImgBlurView];
                
            }
            if( m_selectedImageForDPView.frame.origin.x<1){
                distance.x=1;
                [gesture setTranslation:CGPointMake(0, 0) inView:m_selectedImgBlurView];
                
            }

            [gesture.view setFrame:p1TmpRect];
            
            [m_selectedImageForDPView setFrame:CGRectMake(m_selectedImageForDPView.frame.origin.x+distance.x,m_selectedImageForDPView.frame.origin.y+distance.y, m_selectedImageForDPView.frame.size.width-distance.x, m_selectedImageForDPView.frame.size.height-distance.y)];
            m_gesStartpoint=gesture.view.center;
            
             [p2 setFrame:CGRectMake(m_selectedImageForDPView.frame.size.width-45, p1.frame.origin.y, p2.frame.size.width, p2.frame.size.height)];
            [p3 setFrame:CGRectMake(p1.frame.origin.x, m_selectedImageForDPView.frame.size.height-45, p3.frame.size.width, p3.frame.size.height)];
            [p4 setFrame:CGRectMake(m_selectedImageForDPView.frame.size.width-45, m_selectedImageForDPView.frame.size.height-45, p4.frame.size.width, p4.frame.size.height)];
            
            
            m_seleetedImageForDP=[self cropImage:m_selectedImageForDPView.frame :m_realSelectedImg];
            [m_selectedImageForDPView setImage:m_seleetedImageForDP];
            [gesture setTranslation:CGPointMake(0, 0) inView:m_selectedImgBlurView];
           
            
            
        }
        

    }
   
}
-(void)p2_func:(UIPanGestureRecognizer*)gesture{
    
    if(gesture.state==UIGestureRecognizerStateBegan){
        
        
        m_gesStartpoint=gesture.view.center;//CGPointMake(gesture.view.center.x+translation.x, gesture.view.center.y+translation.y);
        
    }else if(gesture.state==UIGestureRecognizerStateChanged){
        CGPoint translation=[gesture translationInView:m_selectedImgBlurView];
        if(gesture.state==UIGestureRecognizerStateBegan){
            
            
            m_gesStartpoint=gesture.view.center;//CGPointMake(gesture.view.center.x+translation.x, gesture.view.center.y+translation.y);
            
        }else if(gesture.state==UIGestureRecognizerStateChanged){
            
            
            gesture.view.center=CGPointMake(gesture.view.center.x+translation.x, gesture.view.center.y+translation.y);
            CGPoint distance=CGPointMake(gesture.view.center.x-m_gesStartpoint.x,  gesture.view.center.y-m_gesStartpoint.y);
            CGRect p2TmpRect=CGRectMake(m_selectedImageForDPView.frame.size.width-45,45, gesture.view.frame.size.width,gesture.view.frame.size.height);
            
            if( m_selectedImageForDPView.frame.origin.y<1){
                
                
                distance.y=1;
                [gesture setTranslation:CGPointMake(0, 0) inView:m_selectedImgBlurView];
                
            }
            if((m_selectedImageForDPView.frame.size.width+m_selectedImageForDPView.frame.origin.x) >(m_selectedImgBlurView.frame.size.width)){
                distance.x=-1;
                [gesture setTranslation:CGPointMake(0, 0) inView:m_selectedImgBlurView];
                
            }
            
            [gesture.view setFrame:p2TmpRect];
            
            [m_selectedImageForDPView setFrame:CGRectMake(m_selectedImageForDPView.frame.origin.x,m_selectedImageForDPView.frame.origin.y+distance.y, m_selectedImageForDPView.frame.size.width+distance.x, m_selectedImageForDPView.frame.size.height-distance.y)];
            m_gesStartpoint=gesture.view.center;
            
       
             m_seleetedImageForDP=[self cropImage:m_selectedImageForDPView.frame :m_realSelectedImg];
            [m_selectedImageForDPView setImage:m_seleetedImageForDP];
            [gesture setTranslation:CGPointMake(0, 0) inView:m_selectedImgBlurView];
            
            [p1 setFrame:CGRectMake(p1.frame.origin.x, p2.frame.origin.y, p1.frame.size.width, p1.frame.size.height)];
            [p4 setFrame:CGRectMake(m_selectedImageForDPView.frame.size.width-45, m_selectedImageForDPView.frame.size.height-45, p4.frame.size.width, p4.frame.size.height)];
            [p3 setFrame:CGRectMake(45, m_selectedImageForDPView.frame.size.height-45, p3.frame.size.width, p3.frame.size.height)];
            
            
            
        }
        
        
    }
    
}

-(void)p3_func:(UIPanGestureRecognizer*)gesture{
    CGPoint translation=[gesture translationInView:m_selectedImgBlurView];
    if(gesture.state==UIGestureRecognizerStateBegan){
        
        
        m_gesStartpoint=gesture.view.center;
        
    }else if(gesture.state==UIGestureRecognizerStateChanged){
        
        
        gesture.view.center=CGPointMake(gesture.view.center.x+translation.x, gesture.view.center.y+translation.y);
        CGPoint distance=CGPointMake(gesture.view.center.x-m_gesStartpoint.x,  gesture.view.center.y-m_gesStartpoint.y);
        CGRect p3TmpRect=CGRectMake(45, m_selectedImageForDPView.frame.size.height-45, gesture.view.frame.size.width,gesture.view.frame.size.height);
        if((m_selectedImageForDPView.frame.size.height +m_selectedImageForDPView.frame.origin.y)>(m_selectedImgBlurView.frame.size.height)){
            
           // [gesture.view setFrame:p3TmpRect];
            distance.y=-1;
            [gesture setTranslation:CGPointMake(0, 0) inView:m_selectedImgBlurView];
            
        }
        if(m_selectedImageForDPView.frame.origin.x<1){
            distance.x=1;
           
            [gesture setTranslation:CGPointMake(0, 0) inView:m_selectedImgBlurView];
            
        }
        [gesture.view setFrame:p3TmpRect];
        [m_selectedImageForDPView setFrame:CGRectMake(m_selectedImageForDPView.frame.origin.x+distance.x,m_selectedImageForDPView.frame.origin.y, m_selectedImageForDPView.frame.size.width-distance.x, m_selectedImageForDPView.frame.size.height+distance.y)];
        m_gesStartpoint=gesture.view.center;
        
        m_seleetedImageForDP=[self cropImage:m_selectedImageForDPView.frame :m_realSelectedImg];
        [m_selectedImageForDPView setImage:m_seleetedImageForDP];
        
        [gesture setTranslation:CGPointMake(0, 0) inView:m_selectedImgBlurView];
        [p1 setFrame:CGRectMake(p3.frame.origin.x, p1.frame.origin.y, p1.frame.size.width, p1.frame.size.height)];
        [p2 setFrame:CGRectMake(m_selectedImageForDPView.frame.size.width-45, 45, p2.frame.size.width, p2.frame.size.height)];
        [p4 setFrame:CGRectMake(m_selectedImageForDPView.frame.size.width-45, m_selectedImageForDPView.frame.size.height-45, p4.frame.size.width, p4.frame.size.height)];

        
    }
    
    
}

-(void)p4_func:(UIPanGestureRecognizer*)gesture{
    
    CGPoint translation=[gesture translationInView:m_selectedImgBlurView];
    if(gesture.state==UIGestureRecognizerStateBegan){
        
        
        m_gesStartpoint=gesture.view.center;//CGPointMake(gesture.view.center.x+translation.x, gesture.view.center.y+translation.y);
        
    }else if(gesture.state==UIGestureRecognizerStateChanged){
        
        
        gesture.view.center=CGPointMake(gesture.view.center.x+translation.x, gesture.view.center.y+translation.y);
        CGPoint distance=CGPointMake(gesture.view.center.x-m_gesStartpoint.x,  gesture.view.center.y-m_gesStartpoint.y);
        CGRect p4TmpRect=CGRectMake(m_selectedImageForDPView.frame.size.width-45, m_selectedImageForDPView.frame.size.height-45, gesture.view.frame.size.width,gesture.view.frame.size.height);
        if((m_selectedImageForDPView.frame.size.height +m_selectedImageForDPView.frame.origin.y)>(m_selectedImgBlurView.frame.size.height)){

            [gesture.view setFrame:p4TmpRect];
            distance.y=-1;
            [gesture setTranslation:CGPointMake(0, 0) inView:m_selectedImgBlurView];
            
        }
        if((m_selectedImageForDPView.frame.size.width+m_selectedImageForDPView.frame.origin.x) >(m_selectedImgBlurView.frame.size.width)){
            distance.x=-1;
            [gesture.view setFrame:p4TmpRect];
             [gesture setTranslation:CGPointMake(0, 0) inView:m_selectedImgBlurView];
 
         }
        [m_selectedImageForDPView setFrame:CGRectMake(m_selectedImageForDPView.frame.origin.x,m_selectedImageForDPView.frame.origin.y, m_selectedImageForDPView.frame.size.width+distance.x, m_selectedImageForDPView.frame.size.height+distance.y)];
        m_gesStartpoint=gesture.view.center;
        
        [p2 setFrame:CGRectMake(p4.frame.origin.x, p2.frame.origin.y, p2.frame.size.width, p2.frame.size.height)];
        [p3 setFrame:CGRectMake(p3.frame.origin.x, p4.frame.origin.y, p3.frame.size.width, p3.frame.size.height)];
        
    
        m_seleetedImageForDP=[self cropImage:m_selectedImageForDPView.frame :m_realSelectedImg];
        [m_selectedImageForDPView setImage:m_seleetedImageForDP];
        
            
        
      
        [gesture setTranslation:CGPointMake(0, 0) inView:m_selectedImgBlurView];
       
        
    }
    
}
-(UIImage*)cropImage:(CGRect) viewRect :(UIImage*)sourceImg  /*:(SIDES) side*/ {
    UIImage *tmpImg;
    CGSize ratio=CGSizeMake(sourceImg.size.width/m_selectedImgBlurView.frame.size.width,sourceImg.size.height/m_selectedImgBlurView.frame.size.height);
    CGRect newRect=CGRectMake(viewRect.origin.x*ratio.width,viewRect.origin.y*ratio.height,viewRect.size.width*ratio.width, viewRect.size.height*ratio.height);
    CGImageRef imgRef=CGImageCreateWithImageInRect([sourceImg CGImage],newRect);
    tmpImg=[UIImage imageWithCGImage: imgRef];
    CGImageRelease(imgRef);
    return tmpImg;


}

static inline double radians (double degrees) {return degrees * M_PI/180;}

-(UIImage*)rotate:(CGRect)rect viewRect:(UIImage*)originalImage {
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], rect);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    CGContextRef bitmap = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    
    if (originalImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -rect.size.height);
        
    } else if (originalImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -rect.size.width, 0);
        
    } else if (originalImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (originalImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, rect.size.width, rect.size.height);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, rect.size.width, rect.size.height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    
    UIImage *resultImage=[UIImage imageWithCGImage:ref];
    CGImageRelease(imageRef);
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return resultImage;
}


-(void)closeTmpViewController:(id)sender{
    
    [tmpViewController dismissViewControllerAnimated:YES completion:nil];
    [tmpViewController removeFromParentViewController];
}
-(void)setUserDP{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:{
                NSLog(@"PHAuthorizationStatusAuthorized");
                return;
            }
                break;
            case PHAuthorizationStatusDenied:
                NSLog(@"PHAuthorizationStatusDenied");
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    
                }];
                break;
            case PHAuthorizationStatusNotDetermined:{
                NSLog(@"PHAuthorizationStatusNotDetermined");
                return;
            }
                break;
            case PHAuthorizationStatusRestricted:{
                NSLog(@"PHAuthorizationStatusRestricted");
                return;
            }
                break;
        }
    }];
    UIImagePickerController * imagePicker=[[UIImagePickerController alloc]init];
    [imagePicker setDelegate:self];
    
    UIAlertController *photOption=[UIAlertController alertControllerWithTitle:@"Change DP" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [photOption addAction:[UIAlertAction actionWithTitle:@"From Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [imagePicker setMediaTypes:[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] ];
    
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }] ];
    /*[photOption addAction:[UIAlertAction actionWithTitle:@"From Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [imagePicker setSourceType: UIImagePickerControllerSourceTypeCamera];
        [imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
        [imagePicker setShowsCameraControls:YES];
        self->m_fromCamera=true;
        std::cout<<"close"<<std::endl;
        [self presentViewController:imagePicker animated:YES completion:^{
       
        }];
    }] ];
    */
    [photOption addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:photOption animated:YES completion:nil];
    
    
   
}
-(void)setDisplayPicture:(id)sender{
    
    try {

        UIGraphicsBeginImageContext(m_realSelectedImg.size);
 
        
          UIGraphicsBeginImageContext(CGSizeMake(320, 380));
          [m_realSelectedImg drawInRect:CGRectMake(0, 0, 320   , 380)];
          UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
          UIGraphicsEndImageContext();
        
        NSData *imgData=UIImageJPEGRepresentation(newImage, .5);
       
        NSLog(@"%lu",(unsigned long)[imgData length]);
        NSString *tmDataString= [imgData base64EncodedStringWithOptions:0];
        std::string cppImgString=std::string([tmDataString UTF8String]);
       
       
        [m_usrDP setImage:[UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:tmDataString options:0 ]]]; ;
        m_data->setAccount(m_xmppEngine->getMyJID().bare(),std::get<1>(m_data->m_userInfo),cppImgString);
        
        
//        m_usrDP.layer.cornerRadius=50;
//        m_usrDP.layer.masksToBounds=YES;
        
        
        gloox::VCard *tmpVC=new gloox::VCard() ;
        tmpVC->setJabberid(std::get<0>(m_data->getUserInfo()));
        tmpVC->setMailer(std::get<1>(m_data->getUserInfo()));
        tmpVC->setPhoto("image/jpeg",cppImgString);
         
        
        [m_indicator startAnimating];
        std::thread t([self](gloox::VCard *v){
            m_xmppEngine->storeVCard(v);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->m_indicator stopAnimating];
            });
         
        },tmpVC);
        t.detach();
       

        [tmpViewController dismissViewControllerAnimated:YES completion:nil];
        
    } catch (NSException * ex) {
        
    }
   
    
}

-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)textChanged:(UITextField *)textField{
    if([textField.text UTF8String]==self->m_xmppEngine->getMyJID().username()){
        m_deleteAccountVerified=true;
    }else{
        m_deleteAccountVerified=false;
    }
    
}
- (IBAction)deleteAccount:(id)sender {
    
    UIAlertController *cont=[UIAlertController alertControllerWithTitle:@"Delete Account" message:@"Verify By Entering Your Phone Number.." preferredStyle:UIAlertControllerStyleAlert];
    [cont addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setPlaceholder:@"Your Phone Num: ...."];
        [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventValueChanged];
        
        
    }];
    [cont addAction:[UIAlertAction actionWithTitle:@"Continue..." style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //add phone number extension to the textfield before delete
        //[cont textFields][0].text
        
        if(self->m_xmppEngine &&  self->m_deleteAccountVerified){
            self->m_xmppEngine->deleteAccount();
            self->m_data->dropUserData();
            delete self->m_xmppEngine;
            self->m_xmppEngine=nullptr;
        }
        if(self->m_appDelegate)
            self->m_appDelegate->m_xmppEngine=nullptr;
        
        [self setAccount];
        
    }]];
    [cont addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [cont dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:cont animated:YES completion:nil];
    
    
    
    
    
}

-(void)setAccount{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard * tmpStoryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* m_createAccountViewController=(UIViewController*) [tmpStoryBoard instantiateViewControllerWithIdentifier:@"CreateAccount"];
        ///[self.tabBarController setHidesBottomBarWhenPushed:YES];
        //[self.navigationController setNavigationBarHidden:YES animated:YES];
        [self presentViewController:m_createAccountViewController animated:YES completion:nil];
    });
    
}
@end
