//
//  ChatCollectionViewCell.m
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/21/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "ChatCollectionViewCell.h"


@implementation ChatLable
-(instancetype)init{
      self=[super init];
    self.layer.masksToBounds=YES;
    self.layer.cornerRadius=5;
    [self setTextAlignment:NSTextAlignmentCenter];
    return self;
}
- (void)drawTextInRect:(CGRect)uiLabelRect {
    UIEdgeInsets myLabelInsets = {10, 10, 10, 10};

    [super drawTextInRect:UIEdgeInsetsInsetRect(uiLabelRect, myLabelInsets)];
}

@end
@implementation ChatCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
   
    self=[super initWithFrame:frame];
    
    m_containerView= [[UIView alloc] init];
    
    
    [self addSubview:m_containerView];
   
    m_msg=[[ChatLable alloc]init];
    [m_msg setTextColor:[UIColor whiteColor]];
    [m_msg setNumberOfLines:0];
    [m_msg setBackgroundColor:[UIColor colorNamed:@"subviews"]];
    [m_msg setFont:[UIFont fontWithName:@"Avenir" size:15]];
    
    m_imageView=[[UIImageView alloc] init];
    [m_imageView setBackgroundColor:[UIColor colorNamed:@"subviews"]];
    [m_imageView.layer setCornerRadius:10];
    [m_imageView.layer setMasksToBounds:YES];
    
    m_audioView=[[AudioPlayerViews alloc]init];
    [m_audioView setBackgroundColor:[UIColor colorNamed:@"subviews"]];
    
    
    m_time=[[UILabel alloc]init];
    [m_time setTextColor:[UIColor whiteColor]];
    [m_time setTextAlignment: NSTextAlignmentCenter];
    [m_time setFont:[UIFont fontWithName:@"Avenir" size:8]];
    [m_containerView addSubview:m_time];
    
    m_videoViewCon=[[MyAVPlayerViewController alloc]init];
    [m_videoViewCon.contentOverlayView setBackgroundColor:[UIColor colorNamed:@"subviews"]];
    [m_videoViewCon.contentOverlayView setUserInteractionEnabled:NO];
////
    m_msgEvent=[[UILabel alloc]init];
    [m_msgEvent setTextColor:[UIColor whiteColor]];
    [m_msgEvent setFont:[UIFont fontWithName:@"Avenir" size:10]];
    

////    m_webLinkView=[[WKWebView alloc]init];
////    m_downloadBtn=[[UIButton alloc] init];
////    [m_downloadBtn setTitle:@"Click To Download" forState:UIControlStateNormal];
////


        m_activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        [m_activityIndicator setColor:[UIColor blackColor]];
        [m_activityIndicator setHidesWhenStopped:YES];

//        m_longPreseGesture=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
//        [m_longPreseGesture setMinimumPressDuration:1.0];
//
//        [m_longPreseGesture setDelegate:self];
//        [self addGestureRecognizer:m_longPreseGesture];
//        m_formatter =[[NSDateFormatter alloc] init];
//        [m_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss yyyy"];
        return self;

    
}

-(void)handleGesture:(UILongPressGestureRecognizer*)ges{
   
    
    if(m_downloadDelegate && m_msgType!=AppData::MESSAGETYPE::DELETE)
       [m_downloadDelegate handleDelShr:ges];
}
-(void)setDownloadDelegate:(id)delegate indexPath:(NSIndexPath *)index{
    m_downloadDelegate=delegate;
    m_selfIndex=index;
}
-(void)setChat:(NSString*)msgId  msg:(NSString*)txt isMsgFromMe:(BOOL)fromMe eventType:(gloox::MessageEventType)event timeRec:(NSString*)time  msgType:(AppData::MESSAGETYPE) msgType{
    
   
//
//    NSDate *now = [m_formatter dateFromString:time];
//
      [m_time setText:time];
//
      [m_videoViewCon.contentOverlayView removeFromSuperview];
      [m_imageView  removeFromSuperview];
      [m_msg    removeFromSuperview];
      [m_audioView removeFromSuperview];
//    [m_msg setText:nil];
//    m_msg.font=nil;
//      [m_imageView setImage:nil];
//    m_image=nil;
      m_msgType=msgType;
      m_fileUrl=nil;
      m_fileID=nil;
      m_msgID=msgId;
      m_player=nil;
      m_videoViewCon.player=nil;
//      m_audioView=nil;
      m_event=event;
      m_isFromMe=fromMe;
    [m_activityIndicator stopAnimating];
    [m_activityIndicator removeFromSuperview];

//
    
   
    switch (msgType) {
        case AppData::MESSAGETYPE::TEXT:{
            [m_containerView addSubview:m_msg];
          
            NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingAllTypes error:nil];
            NSArray *matches = [detect matchesInString:txt options:0 range:NSMakeRange(0, [txt length])];
            NSMutableAttributedString *msgAttrib=[[NSMutableAttributedString alloc]initWithString:txt];
            for (NSTextCheckingResult *match in matches) {
                NSRange matchRange = [match range];
                if ([match resultType] == NSTextCheckingTypeLink) {
                    // NSURL *url = [match URL];
                    [msgAttrib addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:matchRange];
                } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
                    [msgAttrib addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:matchRange];
                }
            }
            
            m_msg.attributedText=msgAttrib;
           
           
            break;
        }
        case AppData::MESSAGETYPE::FILE_ASSET_ID:{
            m_fileID=txt;
            
            PHFetchResult *result;
            PHImageManager *imageMgr;
            PHAsset * asset;
            
            if([[m_fileID pathExtension] isEqualToString:@"caf"]){
                m_fileType=PHAssetMediaTypeAudio;
            }else{
                result=[PHAsset fetchAssetsWithLocalIdentifiers:@[m_fileID] options:nil];
                asset=[result firstObject];
                imageMgr=[PHImageManager defaultManager];
                m_fileType= [asset mediaType];

            }

            m_image=nil;
            switch (m_fileType) {
                case PHAssetMediaTypeImage:{
                    if([result count]){
                         [self addSubview:m_imageView];
                        PHImageRequestOptions * imgRqst =[[PHImageRequestOptions alloc]init];
                        [imgRqst setSynchronous:YES];
                        [imageMgr requestImageForAsset:asset targetSize:CGSizeMake(0, 0) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                            self->m_image=result;

                        }];

                        [m_imageView setImage:m_image];
                        [m_imageView setContentMode:UIViewContentModeScaleAspectFit];
                    }
                }
                    break;
                case PHAssetMediaTypeVideo:{
                    
                    [m_containerView addSubview:m_videoViewCon.contentOverlayView];
                    
                    NSLog(@"file fetch :%@",asset);
                    if([result count]){
                        dispatch_semaphore_t    semaphore = dispatch_semaphore_create(1);
                        PHVideoRequestOptions *vidRqst=[[PHVideoRequestOptions alloc] init];
                        [vidRqst setDeliveryMode:PHVideoRequestOptionsDeliveryModeHighQualityFormat];
                        [vidRqst setNetworkAccessAllowed:YES];
                        [imageMgr requestPlayerItemForVideo:asset options:vidRqst resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {

                            self->m_player=[AVPlayer playerWithPlayerItem:playerItem];
                            
                            dispatch_semaphore_signal(semaphore);
                        }];
                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        PHImageRequestOptions * imgRqst =[[PHImageRequestOptions alloc]init];
                        [imgRqst setSynchronous:YES];
                        [imageMgr requestImageForAsset:asset targetSize:CGSizeMake(700, 700) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                            self->m_image=result;

                        }];

                        [m_imageView setImage:m_image];
                        [m_imageView setContentMode:UIViewContentModeScaleAspectFit];
                        //[m_player setAutomaticallyWaitsToMinimizeStalling:YES];
                        [m_videoViewCon setPlayer:m_player];
                    
                        UIImageView *thumbnail=[[UIImageView alloc] initWithImage:m_image];
                       
                        [thumbnail setFrame:CGRectMake(0, 0, 70, 76)];
                        [thumbnail.layer setCornerRadius:10];
                        [thumbnail.layer setMasksToBounds:YES];
                         [m_videoViewCon.contentOverlayView addSubview:thumbnail];
                        [m_videoViewCon.contentOverlayView sendSubviewToBack:thumbnail];
                        [m_videoViewCon setDelegate:self];


                    }

                }
                    break;
                case PHAssetMediaTypeAudio:{
                  
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
                    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/records"];
                    dataPath=[dataPath stringByAppendingPathComponent:m_fileID];
                    [m_audioView setfilePath:dataPath];
                    [m_containerView addSubview:m_audioView];
                    break;
                }
                case PHAssetMediaTypeUnknown:

                    break;
                default:
                    break;
            }

            
            break;
        }
        case AppData::MESSAGETYPE::DELETE:{
            [m_msg setText:txt];
            [self addSubview:m_msg];
            break;
        }
        case AppData::MESSAGETYPE::FILE_URL:{
            m_fileUrl=txt;
            // NSString*extension= [m_fileUrl  pathExtension];
            [m_downloadDelegate  downloadDownloadFile:m_selfIndex url:m_fileUrl msgID:m_msgID];
            [m_containerView addSubview:m_activityIndicator];
            [m_containerView bringSubviewToFront:m_activityIndicator];
            [m_activityIndicator startAnimating];

           
            break;
        }
        case AppData::MESSAGETYPE::WEB_LINK:{
           
            break;
        }
       default:
            break;
    }
     
    [m_msgEvent setText:@""];
    if(m_isFromMe && msgType!=AppData::MESSAGETYPE::DELETE){
        [m_msgEvent setText:@""];
        if(event==gloox::MessageEventCancel){
            [m_msgEvent setText:@"X"];
        }else if(event==gloox::MessageEventOffline){
            [m_msgEvent setText:@"⁄"];
        }
        else if(event==gloox::MessageEventDelivered){

            [m_msgEvent setText:@"⁄⁄"];
        }
        else if(event==gloox::MessageEventDisplayed){
            [m_msgEvent setText:@"⁄⁄⁄"];

        }

   }

    
}
-(void)layoutSubviews{
    [self setConstraints:m_isFromMe];
}

-(void)setConstraints:(BOOL)myMsg{
    
  
//    m_webLinkView.translatesAutoresizingMaskIntoConstraints=NO;

    
    m_containerView.translatesAutoresizingMaskIntoConstraints=NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:m_containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:   0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:m_containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:   0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:m_containerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:   0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:m_containerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:   0]];
    switch (m_msgType) {
         case AppData::MESSAGETYPE::FILE_ASSET_ID:{
             


             switch (m_fileType) {
                 case PHAssetMediaTypeImage:{
                 
                     CGRect frame=CGRectMake(0, 0, 70, 65);
                     if(m_isFromMe){
                         frame.origin.x=self.frame.size.width-75;
                         [m_imageView addSubview:m_msgEvent];
                         m_msgEvent.translatesAutoresizingMaskIntoConstraints=NO;
                         [[[m_msgEvent  bottomAnchor]constraintEqualToAnchor:m_imageView.bottomAnchor constant:-5] setActive:YES];
                         [[[m_msgEvent rightAnchor]constraintEqualToAnchor:m_imageView.rightAnchor constant:-5] setActive:YES];
                      
                     }
                     else
                         frame.origin.x+=5;
                   
                     [m_imageView setFrame:frame ];
             
                     break;
                 }
                 case PHAssetMediaTypeVideo:{
                     
                         CGRect frame=CGRectMake(0, 0, 70, 65);
                         if(m_isFromMe){
                             frame.origin.x=self.frame.size.width-75;
                             [m_videoViewCon.contentOverlayView addSubview:m_msgEvent];
                             m_msgEvent.translatesAutoresizingMaskIntoConstraints=NO;
                             [[[m_msgEvent  bottomAnchor]constraintEqualToAnchor:m_videoViewCon.contentOverlayView.bottomAnchor constant:-5] setActive:YES];
                             [[[m_msgEvent rightAnchor]constraintEqualToAnchor:m_videoViewCon.contentOverlayView.rightAnchor constant:-5] setActive:YES];
                             
                         }
                         else{
                             frame.origin.x+=5;
                         }
                        // [m_videoViewCon.view setFrame:frame ];
                         [m_videoViewCon.contentOverlayView setFrame:frame ];
                 
              
                     break;
                 }
                 case PHAssetMediaTypeAudio:{
                   
                    
                     CGRect frame=CGRectMake(0, 0, 250, 60);
                     
                     if(m_isFromMe){
                        frame.origin.x=self.frame.size.width-255;
                         [m_audioView addSubview:m_msgEvent];
                         m_msgEvent.translatesAutoresizingMaskIntoConstraints=NO;
                         [[[m_msgEvent  bottomAnchor]constraintEqualToAnchor:m_audioView.bottomAnchor constant:-5] setActive:YES];
                         [[[m_msgEvent rightAnchor]constraintEqualToAnchor:m_audioView.rightAnchor constant:-5] setActive:YES];
                      
                     }else
                        frame.origin.x+=5;
                     [m_audioView setFrame:frame ];
                 
                     
                     break;
                 }
                 case PHAssetMediaTypeUnknown:{

                     break;
                 }
                 default:
                     break;
             }
          
             
        }
            break;
        case AppData::MESSAGETYPE::FILE_URL:{

            [m_activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
            [[[m_activityIndicator centerYAnchor]constraintEqualToAnchor:self.centerYAnchor constant:0] setActive:YES];
            [[[m_activityIndicator centerXAnchor]constraintEqualToAnchor:self.centerXAnchor constant:0] setActive:YES];


            
            
            
        }
            break;
        case AppData::MESSAGETYPE::WEB_LINK:{
//            m_webLinkView.translatesAutoresizingMaskIntoConstraints=NO;
//            [[[m_webLinkView topAnchor]constraintEqualToAnchor:self.topAnchor constant:40] setActive:YES];
//            [[[m_webLinkView bottomAnchor]constraintEqualToAnchor:self.bottomAnchor constant:-40] setActive:YES];
//            [[[m_webLinkView leadingAnchor]constraintEqualToAnchor:self.leadingAnchor constant:32] setActive:YES];
//            [[[m_webLinkView trailingAnchor] constraintEqualToAnchor:self.trailingAnchor constant:-32] setActive:YES];
        
        }
            
            break;
        case AppData::MESSAGETYPE::TEXT:{
           ///self add
           
            CGRect msgRect = [m_msg.text boundingRectWithSize:CGSizeMake(255, CGFLOAT_MAX)
                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                        attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Avenir" size:15]}
                                                                        context:nil];

            msgRect.size.width = ceil(msgRect.size.width+20);
            msgRect.size.height = ceil(msgRect.size.height+20);
         
            if(m_isFromMe){
                msgRect.origin.x= self.frame.size.width-(msgRect.size.width+5);
                [m_msg addSubview:m_msgEvent];
                m_msgEvent.translatesAutoresizingMaskIntoConstraints=NO;
                [[[m_msgEvent  bottomAnchor]constraintEqualToAnchor:m_msg.bottomAnchor constant:-3] setActive:YES];
                [[[m_msgEvent rightAnchor]constraintEqualToAnchor:m_msg.rightAnchor constant:-5] setActive:YES];
             
            }else{
                msgRect.origin.x+=5;
            }
            [m_msg setFrame:msgRect];
            
        }
           break;
        case AppData::MESSAGETYPE::DELETE:{
            [m_msg setFrame:CGRectMake((self.frame.size.width/2)-75, 5, 150, 15)];
            [m_msg setText:@"this message was deleted"];
            m_msg.font = [UIFont fontWithName:@"avenir" size:12];

        }break;
            
        case AppData::MESSAGETYPE::REPLY:{
            
        }break;
        default:
            
            break;
    }
    
    
    
    if(m_msgType==AppData::MESSAGETYPE::DELETE)
        return;
   
    
    
    
    [m_time setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[[m_time bottomAnchor]constraintEqualToAnchor:m_containerView.bottomAnchor constant:3] setActive:YES];
    [[[m_time leadingAnchor]constraintEqualToAnchor:m_containerView.leadingAnchor constant:10] setActive:YES];
    [[[m_time trailingAnchor]constraintEqualToAnchor:m_containerView.trailingAnchor constant:-10] setActive:YES];
    
    
    
    
    
}

@end
