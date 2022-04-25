//
//  ChatCollectionViewCell.h
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/21/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "XmppEngine.h"
#import "ReadData.h"
NS_ASSUME_NONNULL_BEGIN
@protocol ChatDownloadFileDeleagate <NSObject>

-(void)downloadDownloadFile:(NSIndexPath*) index url:(NSString*)urlStr msgID:(NSString*)_id;
-(void)handleDelShr:(UILongPressGestureRecognizer*)gester;
@end

@interface ChatLable:UILabel
@end;
@interface ChatCollectionViewCell : UICollectionViewCell<ChatDownloadFileDeleagate,UIGestureRecognizerDelegate,AVPlayerViewControllerDelegate>{
  @public
    UIView* m_containerView;
    UIImageView* m_incomingTextBuble;
    ChatLable *m_msg;
    UILabel* m_time;
    UILabel* m_msgEvent;
    UIImageView* m_imageView;
    UIImage * m_image;
    WKWebView *m_webLinkView;
    MyAVPlayerViewController *m_videoViewCon;
    UIButton *m_downloadBtn;
   
    NSString *m_fileUrl;
    NSString *m_fileID;
    PHAssetMediaType m_fileType;
    NSString *m_msgID;
    id<ChatDownloadFileDeleagate> m_downloadDelegate;
    NSIndexPath *m_selfIndex;
    AVPlayer *m_player;
    UIActivityIndicatorView * m_activityIndicator;
    AudioPlayerViews *m_audioView;
    BOOL m_isFromMe;
    gloox::MessageEventType m_event;
    
    UILongPressGestureRecognizer *m_longPreseGesture;
     AppData::MESSAGETYPE m_msgType;
    
    NSDateFormatter * m_formatter;
   
    
    
}
-(void)setDownloadDelegate:(id)delegate indexPath:(NSIndexPath *)index;
-(void)setChat:(NSString*)msgId  msg:(NSString*)txt isMsgFromMe:(BOOL)fromMe eventType:(gloox::MessageEventType)event timeRec:(NSString*)time  msgType:(AppData::MESSAGETYPE) msgType;
@end

NS_ASSUME_NONNULL_END
