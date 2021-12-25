//
//  ChatCollectionViewCell.m
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/21/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "ChatCollectionViewCell.h"

@implementation ChatCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
   
        self=[super initWithFrame:frame];
        m_msg=[[UILabel alloc]init];
        m_time=[[UILabel alloc]init];
        [m_time setTextColor:[UIColor darkGrayColor]];
        [m_time setFont:[UIFont fontWithName:@"GillSans-LightItalic" size:12]];
        m_videoViewCon=[[MyAVPlayerViewController alloc]init];
        [m_videoViewCon.view setUserInteractionEnabled:NO];
    
        m_msgEvent=[[UILabel alloc]init];
        [m_msgEvent setTextColor:[UIColor darkGrayColor]];
        [m_msg setTextColor:[UIColor blackColor]];
        m_imageView=[[UIImageView alloc] init];
        [m_imageView setBackgroundColor:[UIColor whiteColor]];
    
        m_youtubeView=[[UIWebView alloc]init];
        m_downloadBtn=[[UIButton alloc] init];
        [m_downloadBtn setTitle:@"Click To Download" forState:UIControlStateNormal];
        
        [self addSubview:m_time];
        [self addSubview:m_msgEvent];
        [self setBackgroundColor:[UIColor whiteColor]];
        [m_msg setBackgroundColor:[UIColor whiteColor]];
        [m_msg setNumberOfLines:0];
         m_msg.font = [UIFont fontWithName:@"GillSans" size:12];
        m_activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [m_activityIndicator setColor:[UIColor blackColor]];
        [m_activityIndicator setHidesWhenStopped:YES];
    
        m_longPreseGesture=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
        [m_longPreseGesture setMinimumPressDuration:1.0];
    
        [m_longPreseGesture setDelegate:self];
        [self addGestureRecognizer:m_longPreseGesture];
        m_formatter =[[NSDateFormatter alloc] init];
        [m_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss yyyy"];
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
    //time
   
    
    NSDate *now = [m_formatter dateFromString:time];

    [m_time setText:time];

    [m_videoViewCon.view removeFromSuperview];
    [m_imageView  removeFromSuperview];
    [m_msg    removeFromSuperview];
    [m_audioView removeFromSuperview];
    [m_msg setText:nil];
    m_msg.font=nil;
    [m_imageView setImage:nil];
    m_image=nil;
    m_msgType=msgType;
    m_fileUrl=nil;
    m_fileID=nil;
    m_msgID=msgId;
    m_player=nil;
    m_videoViewCon.player=nil;
    m_audioView=nil;
    m_event=event;
    m_isFromMe=fromMe;
    [m_activityIndicator stopAnimating];
    [m_activityIndicator removeFromSuperview];
    
   
   
    switch (msgType) {
        case AppData::MESSAGETYPE::TEXT:{
            
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
            if(m_isFromMe)
               [m_msg setTextAlignment:NSTextAlignmentRight];
            else
                [m_msg setTextAlignment:NSTextAlignmentLeft];
            [self addSubview:m_msg];

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
                    [self addSubview:m_videoViewCon.view ];
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
                        [thumbnail setFrame:m_videoViewCon.view.frame];
                        [m_videoViewCon.contentOverlayView addSubview:thumbnail];
                        
                        
                       
                       
                    }
                    
                }
                    break;
                case PHAssetMediaTypeAudio:{
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
                    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/records"];
                    dataPath=[dataPath stringByAppendingPathComponent:m_fileID];
                    m_audioView=[[AudioPlayerViews alloc]initWithFrame:self.bounds filePath:dataPath];
                    [self addSubview:m_audioView];
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
            [self addSubview:m_activityIndicator];
            [m_activityIndicator startAnimating];

           
            break;
        }
        case AppData::MESSAGETYPE::YOUTUBE_LINK:{
           
            break;
        }
       default:
            break;
    }
     
    [m_msgEvent setText:@""];
   
   
    if(m_isFromMe && msgType!=AppData::MESSAGETYPE::DELETE){
        [m_msg setTextAlignment:NSTextAlignmentRight];
        [m_msg setTextColor:[UIColor blackColor]];
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
        
    } else{
        [m_msg setTextAlignment:NSTextAlignmentLeft];
        [m_msg setTextColor:[UIColor grayColor]];
    }

    [self setConstraints:m_isFromMe];
}

-(void)setConstraints:(BOOL)myMsg{
    
  
    m_youtubeView.translatesAutoresizingMaskIntoConstraints=NO;
    m_imageView.translatesAutoresizingMaskIntoConstraints=NO;
  
    m_time.translatesAutoresizingMaskIntoConstraints=NO;
    [m_time setTextAlignment: NSTextAlignmentCenter];
    m_time.font=[UIFont fontWithName:[m_time font].fontName  size:10];
    m_msgEvent.translatesAutoresizingMaskIntoConstraints=NO;
    
    switch (m_msgType) {
         case AppData::MESSAGETYPE::FILE_ASSET_ID:{
             
             
             
             switch (m_fileType) {
                 case PHAssetMediaTypeImage:{
                     [m_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
                     [[[m_imageView topAnchor]constraintEqualToAnchor:self.topAnchor constant:0] setActive:YES];
                     [[[m_imageView bottomAnchor]constraintEqualToAnchor:self.bottomAnchor constant:00] setActive:YES];
                     
                     [[[m_imageView leadingAnchor]constraintEqualToAnchor:self.leadingAnchor constant:55] setActive:YES];
                     [[[m_imageView trailingAnchor] constraintEqualToAnchor:self.trailingAnchor constant:-55] setActive:YES];
                     break;
                 }
                 case PHAssetMediaTypeVideo:{
                     [m_videoViewCon.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    
                     [[[m_videoViewCon.view topAnchor]constraintEqualToAnchor:self.topAnchor constant:0] setActive:YES];
                     [[[m_videoViewCon.view bottomAnchor]constraintEqualToAnchor:self.bottomAnchor constant:0] setActive:YES];
                     [[[m_videoViewCon.view centerXAnchor]constraintEqualToAnchor:self.centerXAnchor constant:0] setActive:YES];
                     [[[m_videoViewCon.view leadingAnchor]constraintEqualToAnchor:self.leadingAnchor constant:0] setActive:YES];
                     [[[m_videoViewCon.view trailingAnchor] constraintEqualToAnchor:self.trailingAnchor constant:0] setActive:YES];
                     break;
                 }
                 case PHAssetMediaTypeAudio:{
                     [m_audioView setTranslatesAutoresizingMaskIntoConstraints:NO];
                     [[[m_audioView topAnchor]constraintEqualToAnchor:self.topAnchor constant:0] setActive:YES];
                     [[[m_audioView bottomAnchor]constraintEqualToAnchor:self.bottomAnchor constant:0] setActive:YES];
                     
                     [[[m_audioView leadingAnchor]constraintEqualToAnchor:self.leadingAnchor constant:0] setActive:YES];
                     [[[m_audioView trailingAnchor] constraintEqualToAnchor:self.trailingAnchor constant:0] setActive:YES];
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
        case AppData::MESSAGETYPE::YOUTUBE_LINK:{
            m_youtubeView.translatesAutoresizingMaskIntoConstraints=NO;
            [[[m_youtubeView topAnchor]constraintEqualToAnchor:self.topAnchor constant:40] setActive:YES];
            [[[m_youtubeView bottomAnchor]constraintEqualToAnchor:self.bottomAnchor constant:-40] setActive:YES];
            [[[m_youtubeView leadingAnchor]constraintEqualToAnchor:self.leadingAnchor constant:32] setActive:YES];
            [[[m_youtubeView trailingAnchor] constraintEqualToAnchor:self.trailingAnchor constant:-32] setActive:YES];
        
        }
            
            break;
        case AppData::MESSAGETYPE::TEXT:{
           
            m_msg.translatesAutoresizingMaskIntoConstraints=NO;
            [[[m_msg topAnchor]constraintEqualToAnchor:self.topAnchor constant:0] setActive:YES];
            [[[m_msg bottomAnchor]constraintEqualToAnchor:self.bottomAnchor constant:0] setActive:YES];
  
            [[[m_msg leadingAnchor]constraintEqualToAnchor:self.leadingAnchor constant:32] setActive:YES];
            [[[m_msg trailingAnchor] constraintEqualToAnchor:self.trailingAnchor constant:-32] setActive:YES];
            
    
        }
           break;
        case AppData::MESSAGETYPE::DELETE:{
            
            m_msg.translatesAutoresizingMaskIntoConstraints=NO;
            [[[m_msg topAnchor]constraintEqualToAnchor:self.topAnchor constant:0] setActive:YES];
            [[[m_msg bottomAnchor]constraintEqualToAnchor:self.bottomAnchor constant:0] setActive:YES];
            
            [[[m_msg leadingAnchor]constraintEqualToAnchor:self.leadingAnchor constant:-32] setActive:YES];
            [[[m_msg trailingAnchor] constraintEqualToAnchor:self.trailingAnchor constant:-32] setActive:YES];
            [m_msg setText:@"this message was deleted"];
            m_msg.font = [UIFont fontWithName:@"GillSans-LightItalic" size:12];
            [m_msg setTextAlignment:NSTextAlignmentCenter];
            //self.layer.cornerRadius=10;
            //[self.layer setMasksToBounds:YES];
        }break;
            
        case AppData::MESSAGETYPE::REPLY:{
            
        }break;
        default:
            
            break;
    }
    
    
    
    if(m_msgType==AppData::MESSAGETYPE::DELETE)
        return;
   
    
    
    
    [self bringSubviewToFront:m_time];
     [self bringSubviewToFront:m_msgEvent];
    [[[m_time bottomAnchor]constraintEqualToAnchor:self.bottomAnchor constant:-10] setActive:YES];
    [[[m_time leadingAnchor]constraintEqualToAnchor:self.leadingAnchor constant:10] setActive:YES];
    [[[m_time trailingAnchor]constraintEqualToAnchor:self.trailingAnchor constant:-10] setActive:YES];
    [[[m_msgEvent bottomAnchor]constraintEqualToAnchor:self.bottomAnchor constant:-10] setActive:YES];
    [[[m_msgEvent leadingAnchor]constraintEqualToAnchor:self.leadingAnchor constant:10] setActive:YES];
    [[[m_msgEvent trailingAnchor]constraintEqualToAnchor:self.trailingAnchor constant:-10] setActive:YES];
    [m_msgEvent setTextAlignment:NSTextAlignmentRight];
    
    
    
    
}

@end
