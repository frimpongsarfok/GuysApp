//
//  ChatCollectionViewController.h
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/22/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatCollectionViewCell.h"
#import "ChateDelegate.h"
#import "ViewController.h"
#import "ShareTableViewController.h"
#import "AudioRecord.h"
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN
@class ChatSendView;
@interface ChatCollectionViewController : UICollectionViewController<AVAudioRecorderDelegate,ChatViewDelegate,NSURLSessionDelegate,PHPhotoLibraryChangeObserver,UINavigationControllerDelegate,UIPickerViewDataSource,UIImagePickerControllerDelegate,NSURLSessionDownloadDelegate,ChatDownloadFileDeleagate,UIPickerViewDataSource,AVAudioRecorderDelegate,AVAudioPlayerDelegate,NSURLConnectionDelegate,UITextViewDelegate>{
    gloox::ChatStateType m_chatState;
    UIBarButtonItem *m_partnerPresenceBarItem;
    gloox::JID m_toJid;
    bool m_currentView;
    WKWebView *m_webView;
    CGRect m_keybTextFFirtPoint;
    NSMutableDictionary *m_downloadingDic;
    UIImagePickerController * m_imagePicker;
    UIViewController *m_cellImageViewCont;
    CGRect m_audioSourceBtnFirtPoint;
    CGRect m_phtoSourceBtnFirstPoint;
    XmppEgine* m_xmppEngine;
    AppDelegate* m_appDelegate;
    AppData* m_data;
    std::vector<AppData::ChatInfo>* m_chat;
    bool m_scrolled;
    NSString* currenctPartnerName;
    AudioRecord * m_recorder;
    BOOL m_recording;
    NSString *m_myJID;

    ChatSendView * m_sendView;
    
    
    
    //menu
    UITextView *m_textVW;
    UIButton *m_sendBTN;
    UIButton *m_hideKeyBTN;
    UIButton *m_photoBTN;
    UIButton *m_micBTN;
    UIView* m_menuView;
    CGRect m_parentViewFullRect;
    
    std::thread m_clockThread;
    BOOL m_isPartnerOnline;
   
     int m_composeTimeSec;
    
}
-(void)handleLastActivityResult:(const gloox::JID &)jid timeInSec:(long)seconds statusMsg:(const std::string &)status;

//-(instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout;
@end

NS_ASSUME_NONNULL_END
