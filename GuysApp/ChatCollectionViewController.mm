//
//  ChatCollectionViewController.m
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/22/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "ChatCollectionViewController.h"

@interface ChatCollectionViewController ()
@end
@implementation ChatCollectionViewController{
    
    CGRect overViewStartPosition;
    BOOL messageSent;
    UITapGestureRecognizer *m_tableGesture;
}

static NSString * const reuseIdentifier = @"Cell";

-(void)viewWillLayoutSubviews{
    [[[self tabBarController] tabBar] setHidden:YES];
    
}


-(void)startCompose{
    //if user start typing send composing start

 //when user start typing start count down from 5 seconds to 0,
// if any interraption from user keyboard/typing reset time to 5 seconds
// if count down reach 0 send paused chatsate to partner

    if(m_composeTimeSec==0 && m_xmppEngine->clientIsconnected() && [self getToCurrentPresence]){ //when start typing
       // //std::cout<<"thread ended"<<std::endl;
        XmppEgine::MessageSessionInfoType ss=self->m_xmppEngine->getMessageSessionChatState(self->m_toJid);
        gloox::ChatStateFilter *chatState=std::get<2>(ss);
        if(chatState){
            chatState->setChatState(gloox::ChatStateComposing);
            
        }else{
            return;
            //ss=m_xmppEngine->createMessageSessionChatState(m_toJid);
           // chatState=std::get<2>(ss);
           // chatState->setChatState(gloox::ChatStateComposing);
           // //std::cout<<"typing..."<<std::endl;
        }
        m_composeTimeSec=10;
        std::thread tmpThread([self,chatState](){ //init thread
            while(m_composeTimeSec){
                std::this_thread::sleep_for(std::chrono::seconds(1));
               // //std::cout<<"waiting... :"<<m_composeTimeSec<<std::endl;
                if(m_composeTimeSec==5){
                        if(chatState){
                            chatState->setChatState(gloox::ChatStatePaused);
                            
                        }
                       // //std::cout<<"paused typing..."<<std::endl;
                }else if(m_composeTimeSec==1){
                    chatState->setChatState(gloox::ChatStateActive);
                }
                --m_composeTimeSec;
            }
           
        });
        tmpThread.detach();
    }else{
        m_composeTimeSec=0;
        
    }
    
    m_composeTimeSec=10;

}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
   // //std::cout<<"composing..."<<std::endl;
    
    
    [self startCompose];
    return true;
}
-(void)viewWillAppear:(BOOL)animated{
   // dispatch_async(dispatch_get_main_queue(), ^{
        
    
    //self->m_chat=&m_data->getChats(m_toJid.bare());

  
   
        self->m_chat=&self->m_data->getChats(self->m_toJid.bare());
        self->m_scrolled=false;
        if(self->m_xmppEngine){
            
            [self getToCurrentPresence];
            int unread=self->m_data->getUnreadMsgCount(self->m_xmppEngine->getToJID().bare());
            if(unread){
                if(self->m_appDelegate->m_toJid)
                self->m_data->setMsgStatus(gloox::JID(self->m_appDelegate->m_toJid.UTF8String).bare(),"" , gloox::MessageEventType::MessageEventDisplayed,true);
             

            }
            //m_xmppEngine->m_client

        }
        if(self->m_xmppEngine->clientIsconnected() && [self getToCurrentPresence]){
            XmppEgine::MessageSessionInfoType ss=self->m_xmppEngine->getMessageSessionChatState(self->m_toJid);
            gloox::ChatStateFilter *chatState=std::get<2>(ss);
            if(chatState){
               chatState->setChatState(gloox::ChatStateActive);
            }
        }
   
    m_composeTimeSec=0;
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    m_composeTimeSec=0;
    //[((ViewController*) m_appDelegate->m_viewControllar) setChatDelegate:nil];
    // m_chatState=gloox::ChatStateGone;
    // m_appDelegate->m_toJid=nil;
    // m_xmppEngine->setToJId(gloox::JID());
    // m_currentView=false;
    if(m_xmppEngine->clientIsconnected() &&  [self getToCurrentPresence]){
        XmppEgine::MessageSessionInfoType ss=self->m_xmppEngine->getMessageSessionChatState(self->m_toJid);
        gloox::ChatStateFilter *chatState=std::get<2>(ss);
        if(chatState){
            chatState->setChatState(gloox::ChatStateGone);
        }else{
            //std::cout<<"chatstate null :"<<m_toJid.bare()<<std::endl;
        }
    }
 
    [super viewDidDisappear:YES];
   
}
-(void)viewDidAppear:(BOOL)animated{
    if(!m_xmppEngine ||!m_appDelegate || !m_xmppEngine->clientIsconnected())
        return;
   
//    //m_chatState=gloox::ChatStateActive;
//   // std::async(std::launch::async,[self](){
//
//
//        auto partner=m_xmppEngine->getRoster()->roster()->find(m_xmppEngine->getToJID().full());
//        if(!partner->second)
//            return;
//        if( gloox::JID(partner->first).bare()==gloox::JID(m_appDelegate->m_toJid.UTF8String).bare()){
//
//            if(partner->second->online()){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    self->m_partnerPresenceBarItem.title=@"online";;
//                });
//
//
//
//            }else{
//
//     //           dispatch_async(dispatch_get_main_queue(), ^{
//                    AppData::PartnerInfoType part=self->m_data->isPartnerExisting(self->m_xmppEngine->getToJID().bare());
//                    NSString *time=[NSString string];
//                    time=[NSString stringWithUTF8String:part.presence_time.c_str()];
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    self->m_partnerPresenceBarItem.title=time;
//                });
//
//       //         });
//
//
//
//            }
//
//        }
//
//
//
    //});
    [super viewDidAppear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    


    [self setUpMenu];
    [self setChatMenuConstrains];
    [self.collectionView setBackgroundColor: [UIColor whiteColor]];
    
    //if(m_xmppEngine)
    //  return;

 
    m_recording=NO;
    m_recorder=[[AudioRecord alloc]initWithDelegate:self];
    m_appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    [((ViewController*)m_appDelegate->m_viewControllar) setChatDelegate: self];
    m_appDelegate->m_chatControllar=self;
    m_xmppEngine=(XmppEgine*)m_appDelegate->m_xmppEngine;
    m_data=(AppData*)m_appDelegate->m_data;
    m_toJid=gloox::JID(m_appDelegate->m_toJid.UTF8String);
    
    m_chat=&m_data->getChats(m_appDelegate->m_toJid.UTF8String);
    std::string _name=std::string(m_data->isPartnerExisting(m_appDelegate->m_toJid.UTF8String).name.c_str());
    NSString * name=[NSString stringWithUTF8String:_name.empty()?m_appDelegate->m_toJid.UTF8String:_name.c_str()];
    [self.navigationItem setTitle:name];
   
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
     m_myJID=[NSString stringWithUTF8String:m_data->getUserInfo().JID.bare().c_str()];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor darkTextColor],NSFontAttributeName:[UIFont fontWithName:@"GillSans-Semibold" size:25]}];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem* closeItem=[[UIBarButtonItem alloc]initWithTitle:@"X" style:UIBarButtonItemStyleDone target:self action:@selector(closeMe)];
    [closeItem setTintColor: [UIColor blackColor]];
    [self.navigationItem setRightBarButtonItem:closeItem];

    
    
    
    //m_keybTextFFirtPoint=m_keybTextF.frame;
    //m_audioSourceBtnFirtPoint=m_audioSourceBtn.frame;
   // m_phtoSourceBtnFirstPoint=m_phtoSourceBtn.frame;
    //[m_audioSourceBtn.layer setCornerRadius:5];
   // [m_audioSourceBtn.layer setMasksToBounds:YES];
    
    //m_fileBtn.layer.cornerRadius=15;
    //[m_fileBtn.layer setMasksToBounds:YES];
    //overViewStartPosition=m_overView.frame;
    
    //m_tableGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tableTapGesture:)];

    // m_topImg.layer.cornerRadius=25;
    //m_topImg.layer.masksToBounds=YES;
    //[m_topImg setImage:m_xmppEngine->m_topImage];
    //[m_topImg setBackgroundColor:[UIColor whiteColor]];
    m_partnerPresenceBarItem=[[UIBarButtonItem alloc]init];
    NSUInteger fontSize = 10;
    [m_partnerPresenceBarItem setTintColor:[UIColor blackColor]];
    UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    [m_partnerPresenceBarItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem=m_partnerPresenceBarItem;
    
    
   
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
  
    [self.collectionView registerClass:[ChatCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    //UITapGestureRecognizer *tapGest=[[UITapGestureRecognizer alloc]initWithTarget:self action: @selector(handleRemoveKeybTab)];
    //[tapGest setNumberOfTapsRequired:0];
    //[m_chatTableView addGestureRecognizer:tapGest];
    
    // Do any additional setup after loading the view.
    
    if([self  getToCurrentPresence]){
        //std::cout<<"ahey ahey this "<<std::endl;
    }else{
        //std::cout<<"aheyii aheyii this "<<std::endl;
    }
    if(self->m_xmppEngine->clientIsconnected() && [self getToCurrentPresence]){
        XmppEgine::MessageSessionInfoType ss=self->m_xmppEngine->getMessageSessionChatState(self->m_toJid);
        gloox::ChatStateFilter *chatState=std::get<2>(ss);
        if(chatState){
           chatState->setChatState(gloox::ChatStateActive);
        }
    }
    m_composeTimeSec=0;
}

-(bool)getToCurrentPresence{
       auto part=m_data->isPartnerExisting(m_appDelegate->m_toJid.UTF8String);
        if (part.presence==gloox::Presence::Available) {
            m_isPartnerOnline=YES;
            self->m_partnerPresenceBarItem.title=@"Online";
        }else{
            m_isPartnerOnline=NO;
            if(part.lastTimeOnline.empty()){
                self->m_partnerPresenceBarItem.title=@"Offline";
                self->m_xmppEngine->m_lastActivityManager->query(gloox::JID(m_appDelegate->m_toJid.UTF8String));
            }else{
                self->m_partnerPresenceBarItem.title=[NSString stringWithUTF8String:part.lastTimeOnline.c_str()];
            }
            //std::cout<<"hey hey this "<<m_appDelegate->m_toJid.UTF8String<<std::endl;
        }
    return m_isPartnerOnline;
}
-(void)closeMe{
    if(!m_recording){

        [self dismissViewControllerAnimated:YES completion:^{
//            [((ViewController*) self->m_appDelegate->m_viewControllar) setChatDelegate:nil];
//            self->m_chatState=gloox::ChatStateGone;
//            self->m_appDelegate->m_toJid=nil;
//            self->m_xmppEngine->setToJId(gloox::JID());
//            self->m_currentView=false;
        }];
    }
    else{
        UIAlertController * Alert=[UIAlertController alertControllerWithTitle:@"You are still recording" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [Alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:Alert animated:YES completion:nil];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

   
    return  m_chat->size();
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
 
    ChatCollectionViewCell *chat = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    //if(!m_chat)
      //  return chat;
    // Configure the cell
   
    const AppData::ChatInfo& info =(*m_chat)[indexPath.row];
   
    BOOL isMyMsg=[m_myJID isEqualToString:info.from]?true:false;
    [chat setDownloadDelegate:self indexPath:indexPath];
    //xmpp MESSAGEEVENT is deprecated
    //gloox::MESSAGEEVNETTYPE enum is used for just chat state on db
    //chatstate and receipt is used to handle message event
    [chat setChat:info.msg_ID msg:info.msg isMsgFromMe:isMyMsg eventType:info.msg_event timeRec:info.date msgType:info.type];
    
    return chat;
   
}



#pragma mark <UICollectionViewDelegate>
-(CGSize)collectionView:(UICollectionView*) collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
  
    
    AppData::ChatInfo&info=(*m_chat)[indexPath.row];

    switch (info.type) {
        case AppData::MESSAGETYPE::TEXT:{
          
            CGRect lines=[info.msg boundingRectWithSize:CGSizeMake(self.collectionView.frame.size.width, 5000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]} context:nil];
            
             return CGSizeMake(self.collectionView.frame.size.width*.9, lines.size.height+50);
        
            break;
        }
        case AppData::MESSAGETYPE::FILE_ASSET_ID:{
            
            return CGSizeMake(self.collectionView.frame.size.width*.5, 150);
            break;
        }
        case AppData::MESSAGETYPE::FILE_URL:{
            
            return  CGSizeMake(self.collectionView.frame.size.width*.5, 150);
            break;
        }
        case AppData::MESSAGETYPE::DELETE:{
            
            return CGSizeMake(self.collectionView.frame.size.width*.6, 20);
            break;
        }
        case AppData::MESSAGETYPE::WEB_LINK:{
            
            return CGSizeMake(self.collectionView.frame.size.width, 100);
            break;
        }
        default:
            break;
    }
    return CGSizeZero;
   

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //if(m_webView)
    //    [m_webView removeFromSuperview];
   // //std::cout<<"cell selected"<<std::endl;
    if([m_textVW isFirstResponder])
        [m_textVW resignFirstResponder];
    
    ChatCollectionViewCell*chat=(ChatCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if(!chat)
        return;
    switch(chat->m_msgType){
        case AppData::MESSAGETYPE::TEXT:{
           // [self selectedCellLink:chat];
        }break;
        case  AppData::MESSAGETYPE::FILE_URL:{
            //[self selectedCellImage:chat];
            
            
            
        }break;
        case AppData::MESSAGETYPE::FILE_ASSET_ID:{
            [self selectedCellFile:chat];
            
        }break;
        case AppData::MESSAGETYPE::WEB_LINK:{
            
        }
            
        case AppData::MESSAGETYPE::REPLY: {
            
            break;
        }
        case AppData::MESSAGETYPE::DELETE: {
            
            break;
        }
    }

    
}

-(void)handleDelShr:(UILongPressGestureRecognizer*)gester{
    
    ChatCollectionViewCell *cell=(ChatCollectionViewCell*)gester.view;
    if(!cell)
        return;
    UIAlertController *cont=[UIAlertController alertControllerWithTitle:@"" message:@"Select Action" preferredStyle:UIAlertControllerStyleActionSheet];
    [cont.view setBackgroundColor:[UIColor blackColor]];
    UIAlertAction* share=[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSArray *data=nil;
        switch (cell->m_msgType) {
            case AppData::MESSAGETYPE::FILE_ASSET_ID:{
                if(cell->m_fileID)
                    data=@[cell->m_msgID,[NSString stringWithFormat:@"%i",cell->m_msgType],cell->m_fileID];
            }
                break;
            case AppData::MESSAGETYPE::FILE_URL:{
                if(cell->m_fileID)
                    data=@[cell->m_msgID,[NSString stringWithFormat:@"%i",cell->m_msgType],cell->m_fileID];
            }
                break;
            case AppData::MESSAGETYPE::TEXT:{
                if(cell->m_msg.text)
                    data=@[cell->m_msgID,[NSString stringWithFormat:@"%i",cell->m_msgType],cell->m_msg.text];
            }
                break;
                
            default:
                break;
        }
        if([self->m_textVW isFirstResponder])
            [self->m_textVW resignFirstResponder];
        
        
        ShareTableViewController *tmpShare=[[ShareTableViewController alloc]initWithDataArray:data];
        
        [tmpShare setPartnerSharingDataJID:gloox::JID(self->m_appDelegate->m_toJid.UTF8String)];
        [self.navigationController pushViewController:tmpShare
                                             animated: YES];
    }];
    
    UIAlertAction* delet=[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        if([self->m_textVW isFirstResponder])
            [self->m_textVW resignFirstResponder];
        self->m_xmppEngine->sendMessage(XmppEgine::MESSAGETYPE::DELETE,cell->m_msgID.UTF8String, cell->m_msgID.UTF8String,self->m_toJid.bare());
        self->m_data->deleteMessage(gloox::JID(self->m_appDelegate->m_toJid.UTF8String),cell->m_msgID.UTF8String);
       
        cell->m_msgType=AppData::MESSAGETYPE::DELETE;
        [cell setChat:cell->m_msgID msg:cell->m_fileID isMsgFromMe:YES eventType:cell->m_event timeRec:nil msgType:AppData::MESSAGETYPE::DELETE];
        [self.collectionView reloadItemsAtIndexPaths:@[cell->m_selfIndex]];
       
    }];

     UIAlertAction* canecl=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            
     }];
   
    [cont addAction:share];
    if(cell->m_isFromMe)
        [cont addAction:delet];
    [cont addAction:canecl];
    //for (UIView *v in cont.view.subviews)
     [cont.view.subviews.lastObject setBackgroundColor:[UIColor blackColor]];
    [self presentViewController:cont animated:YES completion:nil];
        
    

}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/


// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ChatCollectionViewCell *cell=(ChatCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if(!cell)
        return NO;
    if(cell->m_msgType==AppData::MESSAGETYPE::DELETE)
        return NO;
    
    return YES;
}


/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/
-(void)selectedCellFile:(ChatCollectionViewCell*)chat{
    
    
    if(!chat->m_fileID)
        return;
    
    
    PHFetchResult *result=[PHAsset fetchAssetsWithLocalIdentifiers:@[chat->m_fileID] options:nil];
    PHAsset *asset=[result firstObject];
    if(chat->m_fileType==PHAssetMediaTypeVideo){
        
        MyAVPlayerViewController *tmp=[[MyAVPlayerViewController alloc]init];
        [tmp setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [tmp setView:chat->m_videoViewCon.view];
        [tmp setPlayer:chat->m_player];
        
        
        [self presentViewController:tmp animated:YES completion:^{
            [tmp.view setBackgroundColor:[UIColor  whiteColor]];
            
        }];
        
        
        
    }else if(chat->m_fileType==PHAssetMediaTypeImage){
        PHImageManager *imageMgr=[PHImageManager defaultManager];
        PHImageRequestOptions * imgRqst =[[PHImageRequestOptions alloc]init];
        [imgRqst setSynchronous:YES];
        [imgRqst setResizeMode:PHImageRequestOptionsResizeModeExact];
        [imgRqst setNetworkAccessAllowed:YES];
        [imgRqst   setDeliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat];
        [imageMgr requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:imgRqst resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            ImageViewController *imageViewCon=[[ImageViewController alloc]init];
            [imageViewCon setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
            [imageViewCon setImage:result data:@[chat->m_msgID,[NSString stringWithFormat:@"%i",chat->m_msgType],chat->m_fileID]];
            [imageViewCon setToJID:[NSString stringWithUTF8String:m_appDelegate->m_toJid.UTF8String]];
            [self.navigationController pushViewController:imageViewCon animated:YES];
            
            
        }];
        //m_appDelegate->m_toJid=[NSString stringWithUTF8String:m_xmppEngine->getToJID().bare().c_str()];
        
        
    }
    
    
}
/*

-(void)handleRemoveKeybTab{
    if([m_keybTextF isFirstResponder])
        [m_keybTextF resignFirstResponder];
}

*/

/*

 
 -(void)selectedCellLink:(ChatTableViewCell*)chat{
 NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingAllTypes error:nil];
 NSArray *matches = [detect matchesInString:chat->m_msg.text options:0 range:NSMakeRange(0, [chat->m_msg.text length])];
 NSMutableArray<UIAlertAction*> *actions=[[NSMutableArray<UIAlertAction*> alloc] init];
 for (NSTextCheckingResult *match in matches) {
 if ([match resultType] == NSTextCheckingTypeLink) {
 NSURL *url = [match URL];
 
 [actions addObject:[UIAlertAction actionWithTitle:url.absoluteString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
 dispatch_async(dispatch_get_main_queue(), ^{
 /*    self->m_webView=[[UIWebView alloc]initWithFrame:CGRectMake(self.view.frame.size.width*.05, self.view.frame.size.height*.1, self.view.frame.size.width*.8, self.view.frame.size.height*.5)];
 NSURLRequest *request=[NSURLRequest requestWithURL:url];
 // [self->m_webView loadRequest:request];
 self->m_webView.layer.cornerRadius=25;
 self->m_webView.allowsInlineMediaPlayback=YES;
 self->m_webView.scalesPageToFit=true;
 self->m_webView.mediaPlaybackRequiresUserAction=NO;
 self->m_webView.mediaPlaybackAllowsAirPlay=YES;
 [self->m_webView.layer setMasksToBounds:YES];
 NSString* embededHTML =[NSString stringWithUTF8String:("<!DOCTYPE html><html><head><style type=\"text/css\"> body { margin: 0; padding: 0; } body, html { height: 100%; width: 100%; } </style> </head> <body> <iframe id=\"player\" type=\"text/html\" width=\"100%\" height=\"100%\" src=\"http://www.youtube.com/embed/"+std::string("_2XlfQGPMSA")+"?enablejsapi=1&playsinline=1\" frameborder=\"0\"></iframe> <script> var tag = document.createElement('script'); tag.src = \"https://www.youtube.com/iframe_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubeIframeAPIReady() { player = new YT.Player('player', { events: { 'onReady': onPlayerReady } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body></html>").c_str()];
 [self->m_webView loadHTMLString:embededHTML baseURL: [[NSBundle mainBundle]bundleURL]];
 
// [self.view addSubview:self->m_webView];
// AVPlayer* player=[AVPlayer playerWithURL:url];
// AVPlayerViewController *playerViewController=[[AVPlayerViewController alloc]init];
// [playerViewController setPlayer:player];
// [self presentViewController:playerViewController animated:YES completion:nil];
UIViewController *tmpViewCon=[[UIViewController alloc]init];

self->m_webView=[[UIWebView alloc]initWithFrame:self.view.frame];
NSURLRequest *request=[NSURLRequest requestWithURL:url];
[self->m_webView loadRequest:request];
self->m_webView.layer.cornerRadius=25;
self->m_webView.allowsInlineMediaPlayback=YES;
self->m_webView.scalesPageToFit=true;
self->m_webView.mediaPlaybackRequiresUserAction=NO;
self->m_webView.mediaPlaybackAllowsAirPlay=YES;
[self->m_webView.layer setMasksToBounds:YES];
[tmpViewCon.view addSubview:self->m_webView];
[self presentViewController:tmpViewCon animated:(BOOL)YES completion:nil];

}) ;


}]];


} else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
    NSString *number=[match phoneNumber];
    [actions addObject:   [UIAlertAction actionWithTitle:number style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
    }]];
}

}

UIAlertController *cont=[UIAlertController alertControllerWithTitle:@"Select Action" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];

if([actions count]){
    [actions addObject:   [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        
    }]];
    for(UIAlertAction* action in actions){
        [cont addAction:action];
    }
    [self presentViewController:cont animated:YES completion:nil];
    
}
}

-

  */

-(void)handleChatMessageEvent:(const gloox::JID &)from state:(gloox::MessageEventType)event _msgiID:(NSString *)_id{
    
    if(event==gloox::MessageEventDisplayed ){
        
        
        
        for(int i=(int)m_chat->size()-1;i>-1;i--){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                ChatCollectionViewCell *tmpCell=(ChatCollectionViewCell*)[self.collectionView  cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                
                if(tmpCell){
                    if(![tmpCell->m_msgEvent.text isEqualToString:@""] && ![tmpCell->m_msgEvent.text isEqualToString:@"X"]){
            
                        [tmpCell->m_msgEvent setText:@"⁄⁄⁄"];
                       
                    }
                     [self.collectionView reloadItemsAtIndexPaths:@[tmpCell->m_selfIndex]];
                }
                
            });
            
        }
        
    }else{
        
        
        
        for(int i=(int)m_chat->size()-1;i>-1;--i){
            AppData::ChatInfo& tmpMsg=(*m_chat)[i];
            
            if( ([_id isEqualToString:tmpMsg.msg_ID] && event>=16) || (  [_id isEqualToString:tmpMsg.msg_ID]  && tmpMsg.msg_event<=event) ){
                
                //tmpMsg.msg_event=event;
                //send notification
                
                
                if(event==gloox::MessageEventOffline){
                  
                    //since file file_asset_id is stored copy file url from FILE_URL_INFO
                    // and send it to partner as noti
                    if(tmpMsg.type==AppData::MESSAGETYPE::FILE_ASSET_ID){
                        
                        NSString *fileURL=[NSString stringWithUTF8String:m_data->getFileURLInfo(tmpMsg.msg_ID.UTF8String).c_str()];
                        //[self sendNotification:fileURL messageID:tmpMsg.msg_ID subscriberPushID:[NSString stringWithUTF8String:self->m_xmppEngine->getToJID().username().c_str()]  userJID:[NSString stringWithUTF8String:self->m_xmppEngine->getMyJID().bare().c_str()] msgType:AppData::MESSAGETYPE::FILE_URL];

                    }else{
            
                    }


                }
                dispatch_async(dispatch_get_main_queue(), ^{
                   // [s
                    ChatCollectionViewCell *tmpCell=(ChatCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    if(!tmpCell){
                    
                        return;
                    }
                    if([tmpCell->m_msgEvent.text isEqualToString:@""] || [tmpCell->m_msgEvent.text isEqualToString:@"X"])
                        AudioServicesPlaySystemSound(1004);
                    
                    if(!tmpCell)
                        return;// [self->m_chatTableView endUpdates];
                    [tmpCell->m_msgEvent setText:@""];
                    if(event==gloox::MessageEventCancel){
                        [tmpCell->m_msgEvent setText:@"X"];
                    }else if(event==gloox::MessageEventOffline){
                        [tmpCell->m_msgEvent setText:@"⁄"];
                       
                        
                    }else if(event==gloox::MessageEventDelivered){
                        [tmpCell->m_msgEvent setText:@"⁄⁄"];
                    }else if(event==gloox::MessageEventComposing){
                        
                    }else if(event==gloox::MessageEventInvalid){
                        [tmpCell->m_msgEvent setText:@"X"];
                    }
                    [self.collectionView reloadItemsAtIndexPaths:@[tmpCell->m_selfIndex]];
                });
                break;
            }
            
            
            
        }
        
        
        
    }
    
    
    
}
- (void)photoLibraryDidChange:(PHChange *)changeInfo {
    
    
}


- (IBAction)m_showKeyboard:(id)sender {
    //m_xmppEngine->sendMessage(XmppEgine::MESSAGETYPE::CHAT,[[m_keybTextF text]UTF8String]);
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        //end of loading
        //for example [activityIndicator stopAnimating];
        if(!m_scrolled){
            auto tmp=m_data->getChats(m_appDelegate->m_toJid.UTF8String);
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(*m_chat).size()-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
            m_scrolled=true;
        }
    }
}


- (IBAction)closeViewCon:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self removeFromParentViewController];
    }];
    
}
- (IBAction)showMenuItem:(id)sender {
    //if([m_keybTextF isFirstResponder])
      //  [m_keybTextF resignFirstResponder];
    
}

-(void)handleChatRosterPresence:(const gloox::RosterItem &)item resource:(const std::string &)resource presence:(const gloox::Presence::PresenceType)presence message:(const std::string &)msg{
    if(item.jidJID().bareJID()==m_toJid.bareJID() ){

        
    }
    
}


-(void)handlePresence:(gloox::JID )from pres:(const gloox::Presence::PresenceType )presence{
    if(presence==gloox::Presence::Available){
        m_isPartnerOnline=YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self->m_partnerPresenceBarItem.title=@"Online";;
        });
      
    }else{
        m_isPartnerOnline=NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            self->m_partnerPresenceBarItem.title=@"Offline";;
        });
        
        m_xmppEngine->m_lastActivityManager->query(from);
        
    }
}
-(void)handleChatState:(const gloox::JID &)from state:(gloox::ChatStateType)state{
    switch (state) {
        case gloox::ChatStateType::ChatStateComposing:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:1 animations:^{
                    self->m_partnerPresenceBarItem.title=@"typing";
                }];
               
            });
        }break;
        case gloox::ChatStateType::ChatStatePaused:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:1 animations:^{
                    self->m_partnerPresenceBarItem.title=@"...";;
                   
                    [self->m_partnerPresenceBarItem setTintColor: [UIColor blackColor]];
                    //[self->m_partnerPresenceBarItem setBackgroundImage:[UIImage systemImageNamed:@"eyes"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
                    
                }];
            });
        }break;
        case gloox::ChatStateType::ChatStateActive:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:1 animations:^{
                    self->m_partnerPresenceBarItem.title=@"Online";;
                    //[self->m_partnerPresenceBarItem setBackgroundImage:[UIImage systemImageNamed:@""] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
                }];
            });
        }break;
        case gloox::ChatStateType::ChatStateGone:{
            [UIView animateWithDuration:1 animations:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->m_partnerPresenceBarItem.title=@"Online";;
                    //[self->m_partnerPresenceBarItem setBackgroundImage:[UIImage systemImageNamed:@""] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
                });
            }];
        }break;
        default:
            break;
    }
     
}

-(void)handleChatMessage:(const gloox::Message &)msg session:(gloox::MessageSession *)session{
    
  
    int chatSize=(int)m_chat->size()-1;
    AppData::MESSAGETYPE chat_txt_type=(AppData::MESSAGETYPE)std::atoi(msg.subject().c_str());
    
    if(AppData::MESSAGETYPE::DELETE ==chat_txt_type){
            if(!m_appDelegate->m_toJid.UTF8String)
                return;
            for(int i=chatSize;i>-1;i--){
                
                
                ChatCollectionViewCell *tmpCell=(ChatCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                if(!tmpCell)
                    break;
                if([tmpCell->m_msgID isEqualToString:[NSString stringWithUTF8String:msg.body().c_str()]]){
                   
                    [tmpCell setChat:tmpCell->m_msgID msg:@"" isMsgFromMe:NO eventType:tmpCell->m_event timeRec:tmpCell->m_time.text msgType:AppData::MESSAGETYPE::DELETE];
                    [self.collectionView reloadItemsAtIndexPaths:@[tmpCell->m_selfIndex]];
                    return;
                }
                
                
                
            }
        }else if(chat_txt_type==AppData::MESSAGETYPE::RECEIPT){
            for(int i=chatSize;i>-1;i--){
                
               
                    
                    ChatCollectionViewCell *tmpCell=(ChatCollectionViewCell*)[self.collectionView  cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
               
                    if(tmpCell){
                      
                        if(tmpCell->m_msgID.UTF8String==msg.subject().substr(2,msg.subject().size()-1)){
                        
                            [tmpCell->m_msgEvent setText:@"⁄⁄"];
                            break;
                        }
                        
                    }
                    
                
                
            }
        }else if(chat_txt_type==AppData::MESSAGETYPE::FILE_URL){
           // [self downloadDownloadFile: [NSIndexPath indexPathWithIndex:
           //                      chatSize]url:[NSString stringWithUTF8String:msg.body().c_str()]
           //                      msgID:[NSString stringWithUTF8String:msg.id().c_str()]];
        }
        
        // m_xmppEngine->m_myevent->raiseMessageEvent(msg.from(), gloox::MessageEventDisplayed, msg.id());
         [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:chatSize inSection:0]]];
         [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:chatSize inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
           auto part=m_data->isPartnerExisting(m_toJid.bare());
           if(part.pushID.size() && chat_txt_type!=AppData::MESSAGETYPE::FILE_ASSET_ID &&
                                    chat_txt_type!=AppData::MESSAGETYPE::DELETE &&
                                    chat_txt_type!=AppData::MESSAGETYPE::RECEIPT &&
                                    msg.from().bare()==m_xmppEngine->getMyJID().bare())
           {
               AppData::ChatInfo& tmpMsg=(*m_chat)[m_chat->size()-1];
               [self sendNotification:@"Message" messageID:tmpMsg.msg_ID subscriberPushID:[NSString stringWithUTF8String:part.pushID.c_str()]  userJID:[NSString stringWithUTF8String:self->m_xmppEngine->getMyJID().bare().c_str()] msgType:tmpMsg.type];
           
          }
         

 
}
-(void)sendNotification:(nonnull NSString *)msg  messageID:(nonnull NSString*) msgID subscriberPushID:(nonnull NSString*) pushID userJID:(nonnull NSString*)jid msgType:(AppData::MESSAGETYPE)type{
    //if(![token UTF8String] || ![number UTF8String])
    // return;
    NSString* number=[NSString stringWithUTF8String: gloox::JID(jid.UTF8String).username().c_str()];
    NSURLComponents * comp=[[NSURLComponents alloc]init];
    [comp setScheme:@"https"];
    [comp setHost:@"api.sandbox.push.apple.com"];
    [comp setPath:[@"/3/device/" stringByAppendingString:pushID]];
    [comp setPort:@443];
    

    NSString *apnsStr=[NSString stringWithFormat:@"{\"aps\":{\"alert\":{\"body\":\"You Have A New %@ From Your Partner...\",\"title\" : \"GuysApp\"},\"sound\":\"default\"},\"jid\":\"%@\",\"msgID\":\"%@\",\"msgType\":%d}",msg,jid,msgID,type];
    NSLog(@"\n\n\n%@",apnsStr);
     
    //[comp setQueryItems:@[apns]];
 
    
    NSMutableURLRequest* request=[NSMutableURLRequest requestWithURL:comp.URL];
    
   // [request setValue:[@"bearer " stringByAppendingString: @""] forHTTPHeaderField: @"authorization"];
    [request setValue: @"GuysApp-11-10-21" forHTTPHeaderField:@"apns-topic"];
    [request setValue:@"0" forHTTPHeaderField:@"apns-expiration"];
    [request setValue:@"10" forHTTPHeaderField:@"apns-priority"];
    [request setValue:@"alert" forHTTPHeaderField:@"apns-push-type"];
    [request setValue:number forHTTPHeaderField:@"apns-collapse-id"];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:[apnsStr dataUsingEncoding:NSUTF8StringEncoding]];


    
    NSURLSessionConfiguration *config=[NSURLSessionConfiguration  defaultSessionConfiguration];

    NSURLSession *sesson=[NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionTask *task=[sesson dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            NSLog(@"Fail to register Device Error :%@",error);
            return;
        }
        NSLog(@"Notification ResponSe : %@ ", response);
    }];
    [task setTaskDescription:@"APNS"];
    [task resume];
    
}
-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    NSLog(@"noti Error :%@",error);
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    
 
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
       if([challenge.protectionSpace.host isEqualToString:@"api.sandbox.push.apple.com"]){
           NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
           completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
       }else if([challenge.protectionSpace.host isEqualToString:@"www.guysapp.net"]){
           NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
           completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
          
     }

    }else  if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]){
           if([challenge.protectionSpace.host isEqualToString:@"api.sandbox.push.apple.com"]){
               @autoreleasepool {
            
                   NSURLCredential *cred=  [self myURLCredential];
                   try {
                
                       completionHandler(NSURLSessionAuthChallengeUseCredential,cred);;
                          NSLog(@"NOW COMPLETE");

                   
                      
                       
                   } catch (NSException * ex) {
                 
                       NSLog(@"push errr :%@",ex);
                   }
               

               }
          


           }

        }
    

}
-(void)downloadDownloadFile:(NSIndexPath*) index url:(NSString*)urlStr msgID:(NSString*)_id {
    if(!m_downloadingDic)
        m_downloadingDic=[[NSMutableDictionary alloc ]init];
    [m_downloadingDic setObject:@[index,urlStr] forKey:_id];
   
    NSArray * tmpArray=[m_downloadingDic objectForKey:_id];
    
    if(tmpArray){
      

       
        NSURL*url=[NSURL URLWithString:urlStr];
        NSMutableURLRequest * request= [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"GET"];
        NSURLSessionConfiguration *config=[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:_id];
        NSURLSession *session=[NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDownloadTask*task=[session downloadTaskWithRequest:request];
        [task resume];
    }
}



-(void)URLSession:(NSURLSession *)session  downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location{
    
    NSString* sessionID=session.configuration.identifier;
    __block NSArray* tmpArray=[m_downloadingDic objectForKey:sessionID];
    if(!tmpArray)
        return;
    ChatCollectionViewCell *chat=(ChatCollectionViewCell*)[self.collectionView cellForItemAtIndexPath: tmpArray.firstObject];
    if(!chat)
        return;
    
    __block PHObjectPlaceholder *assetPlaceholder=nil;
    NSString *fileExtension=[[[m_downloadingDic objectForKey:sessionID] lastObject] pathExtension];
    __block   NSString *fileID=[NSString string];
    __block NSURL* saveToUrl=nil;
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    dispatch_semaphore_t sema=dispatch_semaphore_create(0);
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // Create a change request from the asset to be modified.
        PHAssetChangeRequest *createAssetRequest=nil;
        NSError *error = nil;
        
        if([fileExtension isEqualToString:@"jpg"] ||[fileExtension isEqualToString:@"jpeg"] || [fileExtension isEqualToString:@"png"] || [fileExtension isEqualToString:@"tif"]){
            saveToUrl= [[location URLByDeletingPathExtension] URLByAppendingPathExtension:[[tmpArray lastObject] pathExtension]];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:saveToUrl error:&error];
            
            if(error){
                NSLog(@"File Rename Error :%@",error);
                
            }
            createAssetRequest =[PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:saveToUrl];
        }else  if([fileExtension isEqualToString:@"mp4"] || [fileExtension isEqualToString:@"mp3"] || [fileExtension isEqualToString:@"MOV"]||[fileExtension isEqualToString:@"m4a"]){
            saveToUrl= [[location URLByDeletingPathExtension] URLByAppendingPathExtension:[[tmpArray lastObject] pathExtension]];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:saveToUrl error:&error];
            if(error){
                NSLog(@"File Rename Error :%@",error);
                
            }
            createAssetRequest =[PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:saveToUrl];
            
            
        }else if([fileExtension isEqualToString:@"caf"]){
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/records"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
            NSString *fileNameWithExt=[[[self->m_downloadingDic objectForKey:sessionID] lastObject] lastPathComponent];
            dataPath=[dataPath stringByAppendingPathComponent:fileNameWithExt];
            [[NSFileManager defaultManager] moveItemAtPath:[location path] toPath:dataPath error:&error];
            fileID=[dataPath lastPathComponent];
            NSLog(@"audio save at :%@",dataPath);
            
        }
        if(createAssetRequest){
            assetPlaceholder = createAssetRequest.placeholderForCreatedAsset;
            fileID=[assetPlaceholder localIdentifier];
            
        }
        dispatch_semaphore_signal(sema);
        
        
    } completionHandler:^(BOOL success, NSError *error) {
        NSLog(@"Finished updating asset. %@\t%@" , (success ? @"Succesaas." : error),fileID);
        fileID=[NSString stringWithString:fileID];
        if(success && fileID)
            self->m_data->saveDownloadFileID(session.configuration.identifier.UTF8String, fileID.UTF8String);
        dispatch_semaphore_signal(sema);
        
    }   ];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    if(m_xmppEngine){
        auto &tmp=m_data->getChats(m_appDelegate->m_toJid.UTF8String);
        for (int idx=(int)tmp.size()-1;idx>0;--idx) {
            AppData::ChatInfo& chatTmp=tmp[idx];
            if([chatTmp.msg_ID isEqualToString:sessionID]){
                chatTmp.msg=[NSString stringWithString: fileID];
                chatTmp.type=AppData::MESSAGETYPE::FILE_ASSET_ID;
            }
        }
        //wait to file finish save
        using namespace std::chrono_literals;
        std::this_thread::sleep_for(1s);
        //[self->m_chatTableView beginUpdates];
        [chat setChat:chat->m_msgID msg:fileID isMsgFromMe:NO eventType:gloox::MessageEventDisplayed timeRec:chat->m_time.text msgType:AppData::MESSAGETYPE::FILE_ASSET_ID];
       
    }
     [chat->m_activityIndicator stopAnimating];
  
    
}
-(void)handleChatDeleted{
    if(m_appDelegate->m_toJid.UTF8String)
       m_data->getChats(m_appDelegate->m_toJid.UTF8String).clear();
    [self.collectionView reloadData];
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if(!m_scrolled){
        
        if([indexPath row]==((NSIndexPath*)[[collectionView indexPathsForVisibleItems] lastObject]).row){
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:m_chat->size()-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
            
            m_scrolled=true;
        }
    }


}

/*
 -(void)URLSession:(NSURLSession *)session  downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
 
 }
 
 - (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
 completionHandler(NSURLSessionResponseAllow);
 if([((NSHTTPURLResponse*)response) statusCode]==201){
 NSLog(@"task identifier 2 %@",session.configuration.identifier);
 
 }
 
 }
 
 -(void)URLSession:(NSURLSession *)session  downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{}
 
 - (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
 NSLog(@"session%% %@",error);
 
 }
 - (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
 NSLog(@"finish %% %@",session);
 }
 
 */

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
   
    if(m_recorder->m_cancel)
        return;
    NSString *path=[NSString stringWithString:m_recorder->recorderFilePath];
    m_xmppEngine->m_fileTransferManager->sendFile(path.UTF8String, [path lastPathComponent].UTF8String, [path lastPathComponent].UTF8String, [path pathExtension].UTF8String);
    
}



-(void)setUpMenu{
    
    [self.collectionView setFrame:CGRectMake(0,0 , self.view.frame.size.width,self.view.frame.size.height-70)];
    m_menuView=[[UIView alloc]init];
    
    [m_menuView setBackgroundColor:[UIColor blackColor]];
    m_sendBTN=[UIButton buttonWithType:UIButtonTypeCustom];
    m_photoBTN=[UIButton buttonWithType:UIButtonTypeCustom];
    m_micBTN=[UIButton buttonWithType:UIButtonTypeCustom];
    [m_sendBTN setImage:[UIImage systemImageNamed:@"arrow.forward"] forState:UIControlStateNormal];
    [m_sendBTN setTintColor:[UIColor whiteColor]];

    [m_micBTN setImage:[UIImage systemImageNamed:@"mic"] forState:UIControlStateNormal];
    [m_micBTN setTintColor:[UIColor whiteColor]];
  
    [m_photoBTN setImage:[UIImage systemImageNamed:@"photo"] forState:UIControlStateNormal];
    [m_photoBTN setTintColor:[UIColor whiteColor]];
    
    m_textVW=[[UITextView alloc]init];
    [m_textVW setDelegate:self];
    [m_textVW setTextColor:[UIColor darkGrayColor]];
    [m_textVW setBackgroundColor: [UIColor whiteColor]];
    [m_textVW setFont:[UIFont fontWithName:@"GillSans" size:18]];
 
    [m_menuView addSubview:m_micBTN];
    [m_menuView addSubview:m_photoBTN];
    [m_menuView addSubview:m_textVW];
    [m_menuView addSubview:m_sendBTN];
    
    
    [m_photoBTN addTarget:self action:@selector(handlePhotos) forControlEvents:UIControlEventTouchUpInside];
    [m_sendBTN addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [m_micBTN addTarget:self action:@selector(makeRecording:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:m_menuView];
    [m_menuView updateConstraints];
}

-(void)sendMessage:(id)sender{
    
    char queueName[]="apnsQueue";
  
    //dispatch_async(dispatch_get_main_queue(), ^{
        
    
    if(self->m_recording){
        if([self->m_recorder cancel]){
           
            [self->m_sendBTN setImage:[UIImage systemImageNamed:@"arrow.forward"] forState:UIControlStateNormal];
            [self->m_micBTN setImage:[UIImage systemImageNamed:@"mic"] forState:UIControlStateNormal];
            [self.navigationItem setTitle:self->currenctPartnerName];
            self->m_recording=NO;
        }
       
        return;
    }
    if([[self->m_textVW text] length]==0){
        return;
    }
    bool allCharIsSpace=true;
    std::string msg=self->m_textVW.text.UTF8String;
    for(char c:msg){
        if(c!=*(" ")){
            allCharIsSpace=false;
            break;
        }
        
    }
    if(allCharIsSpace)
        return;
    if(!self->m_xmppEngine ){
        
        return;
    }
    
    
   
        self->m_xmppEngine->sendMessage(XmppEgine::MESSAGETYPE::TEXT,std::string([m_textVW.text UTF8String]),m_xmppEngine->getID(),m_toJid.bare());
        self->m_textVW.text=@"";
        self->m_composeTimeSec=0;
    if(self->m_xmppEngine->clientIsconnected() && [self getToCurrentPresence]){
        XmppEgine::MessageSessionInfoType ss=self->m_xmppEngine->getMessageSessionChatState(self->m_toJid);
        gloox::ChatStateFilter *chatState=std::get<2>(ss);
        if(chatState){
           chatState->setChatState(gloox::ChatStateActive);
        }
    }
  

}
                   
- (void)makeRecording:(id)sender {
    
    
   
    
    
    if(m_recording){
        [m_recorder stopRecording];
        m_recording=NO;
        [m_micBTN setImage:[UIImage systemImageNamed:@"mic"] forState:UIControlStateNormal];
        [self.navigationItem setTitle:currenctPartnerName];
        [m_sendBTN setImage:[UIImage systemImageNamed:@"arrow.forward"] forState:UIControlStateNormal];
        
    }
    else{
        [m_recorder startRecording];
        m_recording=YES;
        currenctPartnerName=[NSString stringWithString:self.navigationItem.title ];
        [m_micBTN setImage:[UIImage systemImageNamed:@"mic.fill"] forState:UIControlStateNormal];
        [self.navigationItem setTitle:@"Recording..."];
        [m_sendBTN setImage:[UIImage systemImageNamed:@"xmark"] forState:UIControlStateNormal];
    }
}


-(void)handlePhotos{
    

    
    
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
    m_imagePicker=[[UIImagePickerController alloc]init];
    /*
     [m_imagePicker setDelegate:self];
     
     [m_imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
     [m_imagePicker setShowsCameraControls:YES];
     [m_imagePicker setVideoQuality:UIImagePickerControllerQualityTypeHigh];
     [m_imagePicker setVideoExportPreset: AVAssetExportPresetPassthrough];
     [self presentViewController:m_imagePicker animated:YES completion:^{
     self->m_appDelegate->m_toJid=[NSString stringWithUTF8String:self->m_xmppEngine->getToJID().bare().c_str()];
     }];
     */
    
    [m_imagePicker setDelegate:self];
    [m_imagePicker setSourceType: UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    [m_imagePicker setMediaTypes:[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] ];
    [self presentViewController:m_imagePicker animated:YES completion:^{
        
       
        
    }];
}
-(void)setChatMenuConstrains{
    [m_menuView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[m_menuView.heightAnchor constraintEqualToConstant:70] setActive:YES];
     [[m_menuView.widthAnchor constraintEqualToConstant:self.view.frame.size.width] setActive:YES];
    [[m_menuView.topAnchor constraintEqualToAnchor:self.collectionView.bottomAnchor constant:0]setActive:YES];
    [[m_menuView.trailingAnchor constraintEqualToAnchor:self.collectionView.trailingAnchor constant:0]setActive:YES];
    [[m_menuView.leadingAnchor constraintEqualToAnchor:self.collectionView.leadingAnchor constant:0]setActive:YES];
    
    [m_sendBTN setTranslatesAutoresizingMaskIntoConstraints:NO];
     [[m_sendBTN.widthAnchor constraintEqualToConstant:30] setActive:YES];
    [[m_sendBTN.trailingAnchor constraintEqualToAnchor:m_menuView.trailingAnchor constant:-10]setActive:YES];
    [[m_sendBTN.bottomAnchor constraintEqualToAnchor:m_menuView.bottomAnchor constant:-20]setActive:YES];
    [[m_sendBTN.topAnchor constraintEqualToAnchor:m_menuView.topAnchor constant:20]setActive:YES];
    [m_photoBTN setTranslatesAutoresizingMaskIntoConstraints:NO];
   
    [m_micBTN setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[m_micBTN.widthAnchor constraintEqualToConstant:30] setActive:YES];
    [[m_micBTN.leftAnchor constraintEqualToAnchor:m_menuView.leftAnchor constant:10]setActive:YES];
    [[m_micBTN.topAnchor constraintEqualToAnchor:m_menuView.topAnchor constant:20]setActive:YES];
    [[m_micBTN.bottomAnchor constraintEqualToAnchor:m_menuView.bottomAnchor constant:-20]setActive:YES];
    
    [m_photoBTN setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[m_photoBTN.widthAnchor constraintEqualToConstant:30] setActive:YES];
    [[m_photoBTN.leadingAnchor constraintEqualToAnchor:m_micBTN.trailingAnchor constant:10]setActive:YES];
    [[m_photoBTN.topAnchor constraintEqualToAnchor:m_menuView.topAnchor constant:20]setActive:YES];
    [[m_photoBTN.bottomAnchor constraintEqualToAnchor:m_menuView.bottomAnchor constant:-20]setActive:YES];
    
    
    [m_textVW setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[m_textVW.topAnchor constraintEqualToAnchor:m_menuView.topAnchor constant:10]setActive:YES];
    [[m_textVW.bottomAnchor constraintEqualToAnchor:m_menuView.bottomAnchor constant:-10]setActive:YES];
    [[m_textVW.trailingAnchor constraintEqualToAnchor:m_sendBTN.leadingAnchor constant:-10]setActive:YES];
    [[m_textVW.leadingAnchor constraintEqualToAnchor:m_photoBTN.trailingAnchor constant:10]setActive:YES];
    
    //[[self.collectionView.widthAnchor constraintEqualToAnchor:m_menuView.widthAnchor constant:60]setActive:YES];
    //[[self.collectionView.heightAnchor constraintEqualToAnchor:m_menuView.heightAnchor constant:60]setActive:YES];
   // [[self.collectionView.heightAnchor constraintEqualToConstant:80] setActive:YES];
    
   
}
-(void)keyboardShown:(NSNotification*)notification{
    
    //[m_menuItem setHidden:NO];
    NSDictionary * keyboardDic=[notification userInfo];
    NSValue* keyboardFrameBegin=[keyboardDic objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect=[keyboardFrameBegin CGRectValue];
 
   // [UIView animateWithDuration:1 animations:^{
        
        [self.collectionView setFrame:CGRectMake(0,0 , self.view.frame.size.width,self.view.frame.size.height-(keyboardFrameBeginRect.size.height+70))];
        //is not needed but for animation to speed up with keyboardShowning speed
        [self->m_menuView setFrame:CGRectMake(0,self.collectionView.frame.size.height , self->m_menuView.frame.size.width, self->m_menuView.frame.size.height)];
        
    //}];
//    if(m_xmppEngine->clientIsconnected() && [self getToCurrentPresence]){
//        XmppEgine::MessageSessionInfoType ss=self->m_xmppEngine->getMessageSessionChatState(self->m_toJid);
//        gloox::ChatStateFilter *chatState=std::get<2>(ss);
//        if(chatState){
//            chatState->setChatState(gloox::ChatStateComposing);
//        }
//    }
 
    
}

-(void)keyboardHide:(NSNotification*)notification{
//    if(self->m_xmppEngine->clientIsconnected() && [self getToCurrentPresence]){
//        XmppEgine::MessageSessionInfoType ss=self->m_xmppEngine->getMessageSessionChatState(self->m_toJid);
//        gloox::ChatStateFilter *chatState=std::get<2>(ss);
//        if(chatState){
//            chatState->setChatState(gloox::ChatStatePaused);
//        }
//    }
    // [m_menuItem setHidden:YES];
    [UIView animateWithDuration:1 animations:^{
        
        [self.collectionView setFrame:CGRectMake(0,0 , self.view.frame.size.width,self.view.frame.size.height-70)];
        //is not needed but for animation to speed up with keyboardHiding speed
        [self->m_menuView setFrame:CGRectMake(0, self.view.frame.size.height-70, self.view.frame.size.width, 70)];
        //   [self->m_overView setFrame:self->overViewStartPosition];
        // [self->m_keybTextF setFrame:self->m_keybTextFFirtPoint];
        
        //self->m_audioSourceBtn.frame= self->m_audioSourceBtnFirtPoint;
        // self->m_phtoSourceBtn.frame=self->m_phtoSourceBtnFirstPoint;
    
    }];
 
 
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSURL *filePath=info[UIImagePickerControllerImageURL];
        if(!filePath)
            filePath=info[UIImagePickerControllerMediaURL];
        PHAsset *asset=info[UIImagePickerControllerPHAsset];
        NSString *fileName=[filePath lastPathComponent];
        NSLog(@" filee name  and id %@",info);
        if(self->m_xmppEngine->clientIsconnected())
            self->m_xmppEngine->m_fileTransferManager->sendFile([filePath path].UTF8String,[asset localIdentifier].UTF8String, fileName.UTF8String, [fileName pathExtension].UTF8String);
        
    }];
    
    
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ChatCollectionViewCell* chtCell=(ChatCollectionViewCell*)cell;
    if(chtCell->m_audioView)
    if(chtCell->m_audioView->m_playing){
        [chtCell->m_audioView stop];
    }

}
-(void)handleLastActivityResult:(const gloox::JID &)jid timeInSec:(long)seconds statusMsg:(const std::string &)status{
    
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:-1*seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.doesRelativeDateFormatting = YES;
    
    if(seconds==0){
        dispatch_async(dispatch_get_main_queue(), ^{
            self->m_partnerPresenceBarItem.title=@"Online";
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self->m_partnerPresenceBarItem.title=[dateFormatter stringFromDate:now];
        });
    }
 
   
    //std::cout<<"last activity  from : "<<jid.full()<<" time :  "<<seconds<<" status : "<<status<<std::endl;
}
- (SecKeyRef)getPublicKeyRef {

    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"rsaCert" ofType:@"der"];
    NSData *certData = [NSData dataWithContentsOfFile:resourcePath];
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (CFDataRef)certData);
    SecKeyRef key = NULL;
    SecTrustRef trust = NULL;
    SecPolicyRef policy = NULL;

    if (cert != NULL) {
        policy = SecPolicyCreateBasicX509();
        if (policy) {
            if (SecTrustCreateWithCertificates((CFTypeRef)cert, policy, &trust) == noErr) {
                CFErrorRef result;
               bool re=SecTrustEvaluateWithError(trust, &result);
                
                if (result && re) {
                    key = SecTrustCopyPublicKey(trust);
                }else{
                    CFDictionaryRef dic=CFErrorCopyUserInfo(result);
                    NSDictionary *nsDic=(__bridge  NSDictionary*)dic;
                    NSLog(@"certificate trust fail :%@",nsDic);
                    if(dic)
                        CFRelease(dic);
                }
            }
        }
    }
    if (policy) CFRelease(policy);
    if (trust) CFRelease(trust);
    if (cert) CFRelease(cert);
    return key;
}


- (NSURLCredential *)myURLCredential {


    NSString *certificatePath = [[NSBundle mainBundle] pathForResource:@"GuysAppPushCert" ofType:@"p12"];
    NSData *certificateData = [NSData dataWithContentsOfFile:certificatePath];

    CFArrayRef keyRef;
    OSStatus status = SecPKCS12Import((__bridge CFDataRef)certificateData, (__bridge CFDictionaryRef)@{(NSString *)CFBridgingRelease(kSecImportExportPassphrase): @"GuysApp"}, &keyRef);

    if (status != noErr) {
        NSLog(@"PKCS12 import error %i", status);
        return nil;
    }
   
    CFDictionaryRef identityDict = (CFDictionaryRef)CFArrayGetValueAtIndex(keyRef, 0);
    SecIdentityRef identityRef = (SecIdentityRef)CFDictionaryGetValue(identityDict, kSecImportItemIdentity);
    SecCertificateRef certificate;
    status = SecIdentityCopyCertificate(identityRef, &certificate);

    if (status != noErr) {
        NSLog(@"sec identity copy failed: %i", status);
        return nil;
    }


    const void *certs[] = {certificate};
    CFArrayRef cerArray = CFArrayCreate(kCFAllocatorMalloc, certs, 1, NULL);
    return [NSURLCredential credentialWithIdentity:identityRef certificates: (NSArray *)CFBridgingRelease(cerArray) persistence:NSURLCredentialPersistencePermanent];


}
@end

