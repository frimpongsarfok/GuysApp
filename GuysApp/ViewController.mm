//
//  ViewController.m
//  GuysApp
//
//  Created by SARFO KANTANKA FRIMPONG on 5/6/18.
//  Copyright © 2018 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "ViewController.h"

//PARTNERS CELLVIEW

@implementation PartnerTableViewCell


- (void)awakeFromNib {
   [super awakeFromNib];
   // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
   [super setSelected:selected animated:animated];
   
   // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
   self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
   if(!self)
	  return self;
 
   m_backgroundView=[[UIView alloc]init];
   [self addSubview:m_backgroundView];
   self->m_photos=[[UIImageView alloc] init];
   m_photos.layer.masksToBounds=YES;
   [m_photos setImage:[UIImage systemImageNamed:@"person.fill"]];
   m_photos.layer.cornerRadius=45;
   m_photos.contentMode=UIViewContentModeScaleAspectFill;
   [m_photos setTintColor: [UIColor colorWithRed:0.07 green:0.07 blue:.15 alpha:1]];
   [m_photos setBackgroundColor: [UIColor darkGrayColor]];
   self->m_name=[[UILabel alloc]init];
   m_msgeBadge=[[UILabel alloc]init];
   // [self->m_photos setUserInteractionEnabled:YES];
   [m_msgeBadge setBackgroundColor:[UIColor redColor]];
   [m_msgeBadge setTextColor:[ UIColor whiteColor]];

   [m_msgeBadge  setFont:[UIFont boldSystemFontOfSize:15]];
   
   self.layer.masksToBounds = NO;
   self.layer.shadowOffset = CGSizeZero;
   self.layer.shadowRadius = 5;
   self.layer.shadowOpacity =1;
   
    
   self->m_photos.translatesAutoresizingMaskIntoConstraints=NO;
   
   self->m_name.translatesAutoresizingMaskIntoConstraints=NO;
   m_backgroundView.translatesAutoresizingMaskIntoConstraints=NO;
   self->m_msgeBadge.translatesAutoresizingMaskIntoConstraints=NO;
   
   [m_backgroundView addSubview:m_photos];
   [m_backgroundView addSubview:m_name];
   [m_backgroundView addSubview:m_msgeBadge];

//[self addSubview:m_comment];
   [[m_backgroundView.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:10] setActive:YES];
   [[m_backgroundView.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor constant:-10] setActive:YES];
   [[m_backgroundView.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor constant:10] setActive:YES];
   [[m_backgroundView.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10] setActive:YES];
   
   [[m_photos.rightAnchor constraintEqualToAnchor:m_backgroundView.rightAnchor constant:-25] setActive:YES];
   [[m_photos.heightAnchor constraintEqualToConstant:90] setActive:YES];
   [[m_photos.widthAnchor constraintEqualToConstant:90] setActive:YES];
   [[m_photos.centerYAnchor constraintEqualToAnchor:m_backgroundView.centerYAnchor ] setActive:YES];
 
 
   
   NSArray<NSLayoutConstraint*> * nameConstrains=[[NSArray<NSLayoutConstraint*> alloc]initWithObjects:
												  [m_name.topAnchor constraintEqualToAnchor:m_backgroundView.topAnchor constant:20],
												  [m_name.leadingAnchor constraintEqualToAnchor:m_backgroundView.leadingAnchor constant:15],
						   
												  [ m_name.trailingAnchor constraintEqualToAnchor:m_backgroundView.trailingAnchor constant:-120],
												 
												  nil];
    [NSLayoutConstraint activateConstraints:nameConstrains];


   NSArray<NSLayoutConstraint*> * msgbadgeConstrains=[[NSArray<NSLayoutConstraint*> alloc]initWithObjects:
													  [m_msgeBadge.bottomAnchor constraintEqualToAnchor:m_backgroundView.bottomAnchor constant:-10],
													  [m_msgeBadge.leftAnchor constraintEqualToAnchor:m_backgroundView.leftAnchor constant:30],
													  nil];



  [NSLayoutConstraint activateConstraints:msgbadgeConstrains];
//  // m_photos add

   //[m_name setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.8]];
  /// [self setBackgroundColor:[UIColor clearColor]];
   
	
   

   

  // [m_photos setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.7]];
 
   [m_name setTextAlignment:NSTextAlignmentLeft];
   [m_name  setTextColor:[UIColor whiteColor]];
   [m_name   setFont:[UIFont fontWithName:@"Avenir-Medium" size:30]];
   m_msgeBadge.layer.cornerRadius=5;
   m_msgeBadge.layer.masksToBounds=YES;
  
   self.selectionStyle=UITableViewCellSelectionStyleNone;
   [self setBackgroundColor:[UIColor clearColor]];
   m_backgroundView.backgroundColor=[UIColor colorNamed:@"main_view"];

    //m_photos.contentMode = UIViewContentModeScaleAspectFit;
  
   
   
   return self;
}




@end





@interface ViewController (){
   gloox::Presence::PresenceType m_presence;
}


@end

@implementation ViewController
@synthesize m_timer;
@synthesize m_rosterTableView;
@synthesize m_newContNumber;
@synthesize m_newContactName;
@synthesize m_presenceView;

-(void)viewWillAppear:(BOOL)animated{
  
   std::cout<<"view appeeearrr"<<std::endl;

   
	  [[[self tabBarController] tabBar] setHidden:NO];
      // m_chatDelegate=nil;
   if(m_data->getUserInfo().JID==gloox::JID()){
	  [self setAccount];
	  return;
   }
   [m_rosterTableView reloadData];
  
		 [self displayChatIcon];
  

}
-(void)displayChatIcon{
  
   if(!m_chatIcon){
	  m_chatIcon=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chatIcon"]];
	  [self.view addSubview:m_chatIcon];
	  [m_chatIcon setTranslatesAutoresizingMaskIntoConstraints:NO];
	  [[[m_chatIcon centerXAnchor] constraintEqualToAnchor:self.view.centerXAnchor] setActive:YES];
	  [[[m_chatIcon centerYAnchor] constraintEqualToAnchor:self.view.centerYAnchor] setActive:YES];
	  [[[m_chatIcon widthAnchor] constraintEqualToConstant:300] setActive:YES];
	  [[[m_chatIcon heightAnchor] constraintEqualToConstant:300] setActive:YES];
   }
   long size=m_data->chatRoster().size();
   if(!size){
	  [self.view bringSubviewToFront:m_chatIcon];
	  [m_chatIcon setHidden:NO];
   }else {
	  std::cout<<self.restorationIdentifier.UTF8String<<" chats sizee :: "<<size<<std::endl;
	  [m_chatIcon setHidden:YES];
   }
 
   
}

-(void)scanContact{

	  CNEntityType entityType=CNEntityTypeContacts;
	  if([CNContactStore authorizationStatusForEntityType:entityType]!=CNAuthorizationStatusAuthorized){
		 CNContactStore *contactStore=[[CNContactStore alloc]init];
		 [contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
			if(error){
			   NSLog(@"contact access request error %@", [error localizedDescription]);
			   return;
			}
			if(granted){
				  [self getPhoneNumberName];
			   if(self->m_appDelegate->m_contactViewController){
				  ContactViewController*c=(ContactViewController*)self->m_appDelegate->m_contactViewController;
				  [c.m_emailTableView reloadData];
			   }
			  
			}
		 }];
	  }else if([CNContactStore authorizationStatusForEntityType:entityType]==CNAuthorizationStatusAuthorized){
	
		 
		
			[self getPhoneNumberName];
		
		
	  }

   
}
-(void)getPhoneNumberName{
  // std::thread([self]{
	  
	  CNContactStore * contactStore=[[CNContactStore alloc]init];

	NSArray *keyToFetch=[NSArray arrayWithObjects:[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactGivenNameKey,CNContactPhoneNumbersKey,nil];
   
   NSArray<CNContainer*> *containers=[[NSArray<CNContainer*> alloc] init];
   NSArray<CNContact*>* contacts=[[NSArray<CNContact*> alloc]init];
   containers=[contactStore containersMatchingPredicate:nil error:nil];
   NSMutableArray * nameNNumber=[[NSMutableArray alloc]init];
   for (CNContainer *container in containers) {
	  //get Contact Containers
	  NSPredicate *predicate=[CNContact predicateForContactsInContainerWithIdentifier:container.identifier];
	  contacts=[contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:keyToFetch error:nil];
	 //add contact numbers to partners
	 for (CNContact *contact in contacts) {
	  
	  //get contact numbers
	  for (CNLabeledValue *num in contact.phoneNumbers) {
		 NSString *tmpNum= [num.value stringValue];
		 NSString *number=[[NSString alloc]init]; //number
		 for(int i=0;i<[tmpNum length];i++){
			if(((int)[tmpNum characterAtIndex:i])>=48 && ((int)[tmpNum characterAtIndex:i])<=57){
			   number=[number stringByAppendingString:[NSString stringWithFormat:@"%c",[tmpNum characterAtIndex:i]]];
			}
		 }

		 
		 [nameNNumber addObject:[@[[NSString stringWithString:number],[NSString stringWithString:[contact givenName]]] copy]];
		
  
		}
	  }
   }

		 [self updateContactNPartnerInfo:nameNNumber ];

	  

  
	  
  //}).join();

}
-(void)handleSlot:(NSString *)_id fileGetUrl:(NSString *)get filePutUrl:(NSString *)put filePath:(NSString *)path fileIdentifier:(NSString *)identifier fileType:(NSString *)type{
   if(!m_sendingFileInfos)
	  m_sendingFileInfos=[NSMutableArray array];
   [m_sendingFileInfos addObject:@[_id,get,put,path,identifier]];
   
   [self uploadFileToServerURL:put filePath:path name: [[path pathComponents]lastObject] msgID:_id];
}


-(void)handleSlotForPathOnly:(NSString *)_id filePath:(NSString *)path fileIdentifier:(NSString *)identifier fileType:(NSString *)type{
  
  
	  m_xmppEngine->sendMessage(XmppEgine::MESSAGETYPE::FILE_ASSET_ID,[identifier UTF8String],_id.UTF8String,m_xmppEngine->getToJID().bare());
  //
	 // for (NSArray* shareTo in m_appDelegate->shareToArray) {
	//		m_xmppEngine->sendMessage(XmppEgine::MESSAGETYPE::FILE_ASSET_ID,identifier.UTF8String,_id.UTF8String,((NSString*)shareTo[1]).UTF8String);
		 
	 // }
	  if(m_chatShareDelegate)
		 [m_chatShareDelegate doneShare];
   
}
-(void)uploadFileToServerURL:(NSString *)urlStr  filePath:(NSString*)path name:(NSString*)name msgID:(NSString*)_id{
   
   NSLog(@"uuuuu %@",path);
 
   NSMutableData *body = [NSMutableData data];
   NSURL*url=[NSURL URLWithString:urlStr];
   NSMutableURLRequest * request= [NSMutableURLRequest requestWithURL:url];
   
   [request setHTTPMethod:@"PUT"];
   [body appendData:[NSData dataWithContentsOfFile:path]];
   [request setHTTPBody:body];
   NSURLSessionConfiguration *config=[NSURLSessionConfiguration defaultSessionConfiguration];
  
   NSURLSession *session=[NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
   NSURLSessionUploadTask*task=[session uploadTaskWithStreamedRequest:request];
   [task resume];
   

}



-(void)downloadDownloadFile:(NSString *)urlStr{
   
   
   NSURL*url=[NSURL URLWithString:urlStr];
   NSMutableURLRequest * request= [NSMutableURLRequest requestWithURL:url];
   [request setHTTPMethod:@"GET"];
   NSURLSessionConfiguration *config=[NSURLSessionConfiguration defaultSessionConfiguration];
   NSURLSession *session=[NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
   NSURLSessionDownloadTask*task=[session downloadTaskWithRequest:request];
   [task resume];
   
   UIImage *tmpImg;
   UIImageWriteToSavedPhotosAlbum(tmpImg, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
  
}

/*
-(void)URLSession:(NSURLSession *)session  downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location{
   
}
-(void)URLSession:(NSURLSession *)session  downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
   
}
-(void)URLSession:(NSURLSession *)session  downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
   NSLog(@"session%% %@",error);

}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    NSLog(@"finish %% %@",session);
   
 

}
*/

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
  
   if([m_appDelegate->shareToArray count]){
	  for (NSArray* shareTo in m_appDelegate->shareToArray) {
		 for(NSArray* fileSendingInfo in m_sendingFileInfos){
			m_xmppEngine->sendMessage(XmppEgine::MESSAGETYPE::FILE_URL,[fileSendingInfo[1] UTF8String],[fileSendingInfo[0] UTF8String],((NSString*)shareTo[1]).UTF8String);
			
			
		 }
		 
	  }
	  
	
	  [m_appDelegate->shareToArray removeAllObjects];
	  
   }
   for(NSArray* fileSendingInfo in m_sendingFileInfos){
		 auto fromTo=m_data->getToAndFrom4FileUrlSend([fileSendingInfo[0] UTF8String]);
		 NSLog(@"finish to:%@| %s - -- -- \t%@",fileSendingInfo[0],fromTo.second.c_str(), fileSendingInfo);
		 m_data->setFileURLInfo([fileSendingInfo[0] UTF8String],[fileSendingInfo[1] UTF8String]);
	     m_xmppEngine->sendMessage(XmppEgine::MESSAGETYPE::FILE_URL,[fileSendingInfo[1] UTF8String],[fileSendingInfo[0] UTF8String],m_xmppEngine->getToJID().bare());
   }
   //}
   if([m_sendingFileInfos count])
     [m_sendingFileInfos removeAllObjects];
   
}
- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
   if(error)NSLog(@"eerrrrrrrrr %@\n\n\n\n",error);
   [task resume];
}

- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didReceiveChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{

   if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
	  if([challenge.protectionSpace.host isEqualToString:m_server]){
		 NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
		 NSLog(@" didreceivesessionssssssssss challenge %@", challenge.protectionSpace.host);
		 completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
		
	  }else{
		 NSLog(@" didreceivesession challenge %@", challenge.protectionSpace.host);
	  }
	  
   }
   
   
      //SecTrustRef trus
  // SecTrustRef truc=SecTrustRef
   //if(challenge )

}
- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didBecomeStreamTask:(nonnull NSURLSessionStreamTask *)streamTask{
    NSLog(@" didBecomeStreamTask %% %@",streamTask );

}
//-(void)registerDevice:(NSString *)token subscriber:(NSString*) number{
//   if(![token UTF8String] || ![number UTF8String])
//	  return;
//
//   NSLog(@"^^^^^^^^^^ %@",token);
//   NSString *param=[NSString stringWithFormat:@"?pushservicetype=apns&service=GuysApp&devtoken=%@&subscriber=%@",token,number];
//   NSURL *url=[NSURL URLWithString:[@"http://104.154.81.77:9898/subscribe" stringByAppendingString:param]];
//   NSMutableURLRequest* request=[NSMutableURLRequest requestWithURL:url];
//   [request setHTTPMethod:@"POST"];
//   [request	setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//   [request setCachePolicy:NSURLRequestReloadIgnoringCacheData ];
//
//   NSURLSessionConfiguration *config=[NSURLSessionConfiguration defaultSessionConfiguration];
//   NSURLSession *sesson=[NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//   NSURLSessionTask *task=[sesson dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//	  if(error){
//		 NSLog(@"Fail to register Device Error :%@",error);
//		 return;
//	  }
//	  NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//   }];
//   [task resume];
//
//}
//
//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
//   completionHandler(NSURLSessionResponseAllow);
//   if([((NSHTTPURLResponse*)response) statusCode]==201){
//	  NSLog(@"task identifier 2 %@",session.configuration.identifier);
//
//   }
//
//}
//
//
//
//-(void)unregisterDevice:(NSString *)token subscriber:(NSString*) number{
//   //if(![token UTF8String] || ![number UTF8String])
//   // return;
//   NSString *param=[NSString stringWithFormat:@"?pushservicetype=apns&service=GuysApp&devtoken=%@&subscriber=%@",token,number];
//   NSURL *url=[NSURL URLWithString:[@"http://104.154.81.77:9898/unsubscribe" stringByAppendingString:param]];
//   NSMutableURLRequest* request=[NSMutableURLRequest requestWithURL:url];
//   [request setHTTPMethod:@"POST"];
//   [request	setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//
//   NSURLSessionConfiguration *config=[NSURLSessionConfiguration defaultSessionConfiguration];
//   NSURLSession *sesson=[NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//   NSURLSessionTask *task=[sesson dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//	  if(error){
//		 NSLog(@"Fail to register Device Error :%@",error);
//		 return;
//	  }
//	  NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//   }];
//   [task resume];
//
//}
-(void)updateContactNPartnerInfo:(NSArray*)data{
   try {
	 
		 
	  
	  //add contact to partner if not exist or update if exist but name is different
	  std::string cc=m_data->getUserInfo().extCODE;
	  std::string server=m_xmppEngine->getServer();
	  NSArray*tmpData=[data copy];
	  if(cc.empty() ||server.empty()||!m_data)
		 return;

	  NSMutableDictionary *groupDic=[NSMutableDictionary dictionary];
	  for (int n=0;n< [tmpData count];n++) {

		 NSString *intNum=[self getInternationalNumber:((NSArray*)tmpData[n]).firstObject callingCode:  [NSString stringWithUTF8String:cc.c_str()]];
		 //add to partners and set inContact if contact not exist in partners;
		 const std::string jid=(std::string(intNum.UTF8String)+"@"+server);
		 const std::string name1=((NSString*)tmpData[n][1]).UTF8String;
		 [groupDic setValue:tmpData[n][1] forKey:[NSString stringWithUTF8String:jid.c_str()]];
		 auto tmpPart=m_data->isPartnerExisting(jid);
		 BOOL contactAddedOrUpdate=NO;
		 if(tmpPart.jid.size()){
			   std::string name2=tmpPart.name;
			   //update user name if not the same
			
			   if(name1!=name2){
				  std::cout<<name1<<"\t"<<name2<<std::endl;
				  [self updateNameInTableViewRoster:name1 target:jid];
			   }
			   if(!tmpPart.inContact){
				   m_data->setPartnerInContact(jid, true);
			   }
			  contactAddedOrUpdate=YES;
			
		 }else{
			
			   AppData::PartnerInfoType part;
			   part.jid=jid;
			   part.name=((NSString*)tmpData[n][1]).UTF8String;
			   part.photo=std::string();
			   part.chat_priority=std::string();;
			   part.inroster=false;
			   part.inContact=true;
			   part.registered=false;
			   m_data->addPartner(part);
			
			 
		   
	  }

	}
   
//			//std::thread([self,data]{
//
//				  dispatch_queue_t t=dispatch_queue_create("fectVcardQues", nullptr);
//				  dispatch_async( t, ^{
//					 try{
//						auto partners=self->m_data->getPartners();
//
//						auto part=partners.begin();
//						while(part!=partners.end() &&
//							  self->m_xmppEngine &&
//							  self->m_xmppEngine->clientIsconnected()){
//
//						   if(self->m_xmppEngine && self->m_xmppEngine->clientIsconnected()){
//							  if(self->m_isSearchForVCard==std::tuple<BOOL,std::string>(false,{})){
//							    self->m_isSearchForVCard={true,part->first};
//								 //std::cout<<"fectVcardQues\t"<<part->first<<std::endl;
//								self->m_xmppEngine->fetchVCard(gloox::JID(part->first));
//								 std::this_thread::sleep_for(std::chrono::milliseconds(300));
//								 //return;
//								 ++part;
//							  }
//
//
//						   }else{
//
//							  part=partners.end();
//							  self->m_isSearchForVCard={false,{}};
//						   }
//						}
//						self->m_isSearchForVCard={false,{}};
//					  }catch(NSException *ex){
//						 NSLog(@"fetch err : %@",[ex  reason] );
//					  }
//				  });
//
//
//			//}).detach();
//
		 
	  
	 
   } catch (std::exception ex) {
	  std::cout<<ex.what()<<std::endl;
	//  m_xmppEngine->disconnect();
   }
   
}


-(void)updateNameInTableViewRoster:(const std::string)name target:(const std::string)jid{
   //upate names in db
   m_data->updatePartnerName(jid, name);
   //update names in roster
   if([NSThread isMainThread]){
	  for (int idx=0;idx<[m_rosterTableView numberOfRowsInSection:0]; idx++) {
		 PartnerTableViewCell * tmpCell=[self->m_rosterTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
		 if(tmpCell){
			   if(jid == tmpCell->m_jid){
				  [self->m_rosterTableView beginUpdates];
				  tmpCell->m_name.text=[NSString stringWithUTF8String: name.c_str()];
				  [self->m_rosterTableView endUpdates];
			   }
		 }
	  }
	  
   }else{
	  dispatch_sync(dispatch_get_main_queue(), ^{
		 for (int idx=0;idx<[self->m_rosterTableView numberOfRowsInSection:0]; idx++) {
			PartnerTableViewCell * tmpCell=[self->m_rosterTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
			if(tmpCell){
			   if(jid == tmpCell->m_jid){
				  [self->m_rosterTableView beginUpdates];
				  tmpCell->m_name.text=[NSString stringWithUTF8String: name.c_str()];
				  [self->m_rosterTableView endUpdates];
			   }
			}
		 }
	  });
   }
}
-(void)viewDidAppear:(BOOL)animated{
//   AppDelegate*delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
//   [delegate setDelegate:self];
//   if([[self restorationIdentifier] isEqualToString:@"ViewController"]){
//	  dispatch_async(dispatch_get_main_queue(), ^{
//		// [self->m_rosterTableView reloadData];
//	  });
//   }else if([[self restorationIdentifier] isEqualToString:@"NewPartner"]){
//
//
//
//   }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
   return UIStatusBarStyleLightContent;
}

-(void)viewDidLoad {
    //set up audio
   //dispatch_async(dispatch_get_main_queue(), ^{
   [self groupPath];
   
  
  
   
   NSLog(@"parent identifiers : %@",self.restorationIdentifier);
   NSLog(@"App is is on active12");

   
   m_server=@"www.guysapp.net";
   m_resource=@"iphone";
   m_serverNResource=@"www.guysapp.net/iphone";
   m_activityIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
   [m_activityIndicator setHidesWhenStopped: YES];
   m_activityIndicator.center=m_rosterTableView.center;
   m_rosterTableView.backgroundColor=[UIColor colorNamed:@"main_background"];
   [self.view addSubview:m_activityIndicator];
   [self.view bringSubviewToFront:m_activityIndicator];

   self->m_isSearchForVCard={false,{}};
   
   [self.navigationController.navigationBar setTitleTextAttributes:
	@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"GillSans-Semibold" size:25]}];
   
   [[self.navigationController.navigationBar topItem]setTitle:self.restorationIdentifier];
  

   
   try {
	  
	  
	 
	  //Request Contact list presence toggle
	  ContListPresRequest=false;
	  ContListPresRequestUnvaliable=false;
	  
	  ///if(!m_appDelegate){
		 m_appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
	  //}
	  
	  m_appDelegate->m_viewControllar=self;
	  [m_appDelegate setDelegate: self];
   if(!m_appDelegate->m_data){
	  m_data=new AppData();
	  m_data->getChatData();
	  m_appDelegate->m_data=(void*)m_data;
   }
	
	
   [self getGroupMessage];
   //IF NO JID FOUND SET ACCOUNT
   if(!m_data->getUserInfo().JID.bare().size()){
	  //m_xmppEngine=nullptr
	 // m_appDelegate->m_xmppEngine=(void*)m_xmppEngine;
	  [self setAccount];
	  
   }else{
	  [m_appDelegate registerPushNotification];
   }
	  
	  std::cout<<"let start agin"<<std::endl;
		 
   //@autoreleasepool {
	  m_presence=gloox::Presence::Unavailable;
	  m_xmppEngine=new XmppEgine(self, m_data->getUserInfo().JID.bare() +"/iphone",m_data->getUserInfo().JID.username(),m_server.UTF8String,false);
	  if(m_appDelegate->m_toJid)
		 m_xmppEngine->setToJId(gloox::JID(m_appDelegate->m_toJid.UTF8String));
	  m_xmppEngine->setDelegate(self);
	  m_appDelegate->m_xmppEngine=(void*)m_xmppEngine;
  // }
	 
   if(m_appDelegate->m_chatControllar){
	  [m_appDelegate->m_chatControllar viewDidLoad];
	  }
	  
		 [m_rosterTableView setDelegate:self];
		 [m_rosterTableView setDataSource:self];
		 [m_rosterTableView setAllowsMultipleSelection:NO];
		 [m_rosterTableView setRowHeight:130];
		 [m_rosterTableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
		 [m_rosterTableView registerClass:[PartnerTableViewCell self] forCellReuseIdentifier:@"PartnersCell"];
	 
	  
	
	     
   } catch (std::exception ex) {
	  std::cout<<"c++ Exception occurs in viewcontroller : "<<ex.what()<<std::endl;
   }catch(NSException* objex){
	  NSLog(@"Objct c Exception occurs in viewcontroller : %@",[objex description]);
   }
   
   
   
   
   [self displayChatIcon];
   [super viewDidLoad];
   
}
-(void) getGroupMessage{
   NSString *appGroupDirectoryPath = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.guys"].path stringByAppendingPathComponent:@"Messages"] stringByAppendingPathExtension:@"txt"];
   NSError *error;
   
   if (![[NSFileManager defaultManager] fileExistsAtPath:appGroupDirectoryPath])
	  [[NSFileManager defaultManager] createFileAtPath:appGroupDirectoryPath contents:nil attributes:@{NSFileAppendOnly:@"NO",NSFileImmutable:@"NO"}]; //Create folder
   if(error){
	  NSLog(@" Fail to Create Message File Error : %@",error);
	  return;
   }
   NSMutableDictionary *msgD=[NSMutableDictionary dictionaryWithContentsOfFile:appGroupDirectoryPath];
   if(!msgD)
	  return;
    if(!m_msgID4TagNotifRef)
	   m_msgID4TagNotifRef=[[NSMutableArray alloc]init];
   for (NSString *tmpID in msgD) {
	  NSString* _id=tmpID;
      NSString* msg=msgD[tmpID][@"msg"];
	  NSString* from=msgD[tmpID][@"from"];
	  NSString* to=msgD[tmpID][@"to"];
	  NSString* type=msgD[tmpID][@"msgType"];
	  //NSString* event=msgD[tmpID][@"event"];
	  NSString* time=msgD[tmpID][@"time"];
	  gloox::Message m(gloox::Message::Chat,gloox::JID(to.UTF8String),msg.UTF8String,type.UTF8String);
	  m.setID(_id.UTF8String);
	  m.setFrom(gloox::JID(from.UTF8String));
	 
	  
	  m_data->insertNewMessage(_id.UTF8String, from.UTF8String, to.UTF8String, msg.UTF8String,(AppData::MESSAGETYPE)type.integerValue,[NSString stringWithFormat:@"%@",time ].UTF8String);
	  [m_msgID4TagNotifRef addObject:[NSString stringWithString:_id]];
	  m_xmppEngine->sendMessage(XmppEgine::MESSAGETYPE::RECEIPT, tmpID.UTF8String, tmpID.UTF8String,from.UTF8String);
   }
   
   [@{} writeToFile:appGroupDirectoryPath atomically:YES];
   
}
-(void)handleDeletePartner:(UILongPressGestureRecognizer*)recognizer{
   CGPoint p=[recognizer locationInView:m_rosterTableView];
   NSIndexPath *index=[m_rosterTableView indexPathForRowAtPoint:p];
   PartnerTableViewCell * tmpCell=(PartnerTableViewCell*)recognizer.view;
   auto tmpPart=self->m_data->isPartnerExisting(tmpCell->m_jid);
  
   if(index!=nil){
	  if(recognizer.state==UIGestureRecognizerStateBegan){
		 //delete partner here...
		 UIAlertController * deleteAlert=[UIAlertController alertControllerWithTitle:@"Select Action" message:nil preferredStyle:UIAlertControllerStyleAlert];
		 [deleteAlert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			
			self->m_xmppEngine->removeContact(tmpCell->m_jid);   //delete from online roster
			self->m_data->deletePartnerFromChat(tmpCell->m_jid);  //delete from chat table
			self->m_data->setPartnerInRoster(tmpCell->m_jid, NO); //delete from db roster
			
			
			[self->m_rosterTableView beginUpdates];
			[self->m_rosterTableView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationRight];
			[self->m_rosterTableView endUpdates];
			if(self->m_appDelegate->m_toJid)
			  if(gloox::JID(tmpCell->m_jid).bare()==gloox::JID(self->m_appDelegate->m_toJid.UTF8String).bare()){
			   if(self->m_chatDelegate)
				  [self->m_chatDelegate handleChatDeleted];
			  }
			[self displayChatIcon];
		 }]];
		
		 [deleteAlert addAction:[UIAlertAction actionWithTitle:tmpPart.blocked?@"Unlock":@"Block" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
			tmpPart.blocked? self->m_xmppEngine->unblockPartner(tmpPart.jid): self->m_xmppEngine->blockPartner(tmpPart.jid);;
			
			
			
		 }]];
		 [deleteAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
			
		 }]];
		 [self presentViewController:deleteAlert animated:YES completion:nil];
	  }
	  
   }
}



- (IBAction)deleteContact:(id)sender {
   if([m_rosterTableView isEditing]){
	  [m_rosterTableView setEditing:NO];
   }else{
	  [m_rosterTableView setEditing:YES];
   }
}



-(void)setChatDelegate:(id<ChatViewDelegate>)delegate{
  
	  m_chatDelegate=delegate;
   
}



- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
   switch (result) {
	  case MessageComposeResultCancelled:
		 break;
		 
	  case MessageComposeResultFailed:
	  {
		 
		 UIAlertController *warning=[UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to send SMS!" preferredStyle:UIAlertControllerStyleActionSheet];
		 [warning addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
			 
		 }]];
		 break;
	  }
		 
	  case MessageComposeResultSent:
		 break;
		 
	  default:
		 break;
   }
   
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
   //Dispose of any resources that can be recreated.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   NSInteger size=m_data->chatRoster().size();
   
   std::cout<<" size now "<<size<<std::endl;
	  return  size;
   
  
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     
	  PartnerTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"PartnersCell" forIndexPath:indexPath];
	  [cell setAutoresizingMask:UIViewAutoresizingNone];
	  auto ros=m_data->chatRoster();
	  NSString *name=[NSString stringWithUTF8String:ros[indexPath.row].name.c_str()];;
	 // NSString *number=[NSString stringWithUTF8String:gloox::JID(ros[indexPath.row].jid).username().c_str()];;
	  cell->m_jid=ros[indexPath.row].jid;
	  std::cout<<"%%%%% "<<ros[indexPath.row].name<<" : "<<ros[indexPath.row].jid<<std::endl;
   
	  if(m_data->isPartnerExisting(cell->m_jid).blocked){
		 NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:name];
		 [attributeString addAttribute:NSStrikethroughStyleAttributeName
								 value:@3
								 range:NSMakeRange(0, [attributeString length])];
		 [cell->m_name setAttributedText:attributeString];
	  }else{
		
		 [self->m_rosterTableView beginUpdates];
			NSMutableAttributedString *originalMutableAttributedString =[[NSMutableAttributedString alloc] initWithString:name];
			[originalMutableAttributedString removeAttribute:NSStrikethroughStyleAttributeName range:NSMakeRange(0, name.length)];
			cell->m_name.attributedText=originalMutableAttributedString;
		 [self->m_rosterTableView endUpdates];
	  }
	 
	  m_deletePartnerGest=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleDeletePartner:)];
	  [m_deletePartnerGest setMinimumPressDuration:1];
	  [cell addGestureRecognizer:m_deletePartnerGest];

	  NSString *p=[NSString stringWithUTF8String:ros[indexPath.row].photo.c_str()];;
	  if(p){
		 NSData *photo=[[NSData alloc]initWithBase64EncodedString:p options:0];
		 
		
		 if(!ros[indexPath.row].photo.empty()){
			   [cell->m_photos setImage:[UIImage imageWithData:photo]];
			
		 }else{
			   [cell->m_photos setImage:[UIImage systemImageNamed:@"person.fill"]];
			
		 }
	  }
		 
	
	  int numUnread=m_data->getUnreadMsgCount(gloox::JID(ros[indexPath.row].jid));
	  [cell->m_msgeBadge setText: numUnread?[NSString stringWithFormat:@" %i ",numUnread]:@""];
     return cell;
		 
   

}

-(void)handleLog:(NSString *)message{
   NSLog(@"%@",message);

}


-(void)connected{
 
 
   
   
}

//HANDLE SELF VCARD;
-(void)handleSelfVCard:(const gloox::VCard *)card{
   
   gloox::VCard *tmpVC=new gloox::VCard();
   const std::string code=m_data->getUserInfo().extCODE;
   const std::string token= m_data->getUserInfo().PUSH_ID;
   tmpVC->setMailer(code);
   tmpVC->setJabberid(m_xmppEngine->getMyJID().bare());
   tmpVC->setUid(token);
   
   //when not set, may be first time run

   std::string photo=m_data->getUserInfo().PHOTO;
   bool newDP=false;
   if(photo.size()){
	  std::string vcardFirstline=std::string(card->photo().binval.begin(),card->photo().binval.begin()+255);
	  std::string dbFirstline=std::string(photo.begin(),photo.begin()+255);
	  if(vcardFirstline!=dbFirstline && dbFirstline.size()){
		 
		 //register device token on server
		 newDP=true;
		 tmpVC->setPhoto("image/jpeg",photo);
	  }else{
		
	  }
   }
	 
   std::cout<<"\nself vcard received 2  "<<token<<std::endl;
   if((card->uid().c_str()!=token) || newDP ||card->jabberid().empty() ){
	  
	  m_xmppEngine->storeVCard(tmpVC);
	  return;
   }
}

//HANDLE VCARD FROM OTHER PATHERS
//steps
//1 get phone number
//2  check  if it number exist in roster if not add to roster
-(void)handleVCard:(gloox::JID)jid Card:(const gloox::VCard *)vcard{

 
   if(self->m_appDelegate->m_contactViewController){
	  ContactViewController *cvc=((ContactViewController*)self->m_appDelegate->m_contactViewController);
	  if(std::get<1>(cvc->m_currentRequestedVCardJID)==jid){
		 [cvc handleVCard:jid fetchResult:const_cast<gloox::VCard*>(vcard)];
	  }
   }
 	
    if(!vcard->jabberid().size()){
	   if(std::get<1>(m_isSearchForVCard)==jid.bare()){
		  self->m_isSearchForVCard={false,{}};
			//std::cout<<"fectVcardQues+++"<<std::endl;
	   }
	   return;
	}
   
   std::cout<<jid.bare()<<"\tuid : "<<vcard->uid()<<std::endl;
   self-> m_data->setPartnerRegistered(jid.bare(), true);
   self->m_data->setPartnerPhoto(jid.bare(), vcard->photo().binval);
   if(vcard->uid().size())
		 self->m_data->setPartnerPushID(jid.bare(), vcard->uid());
   if(!m_xmppEngine->getRoster()->getRosterItem(jid.bareJID())){
	
	  m_xmppEngine->addPartnerToRoster(jid);
   }
   
   int i=0;
	 __block int nPartner=0;
	  __block  PartnerTableViewCell *partnerCell=nullptr;
	 // dispatch_sync(dispatch_get_main_queue(), ^{
		 nPartner=(int)[self->m_rosterTableView numberOfRowsInSection:0];
//	  });
   
 for(i=0;i<nPartner;++i){
	
	partnerCell=[self->m_rosterTableView  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
	//});
	  if(!partnerCell)
		 break;
	  if(gloox::JID(partnerCell->m_jid).bare()==jid.bare()){
		 
		 std::string photoStr=std::string(vcard->photo().binval);
		 self->m_data->chatRoster()[i].photo=photoStr;
		 NSString *p=[NSString stringWithUTF8String:photoStr.c_str()];;
		 NSData *photo=[[NSData alloc]initWithBase64EncodedString:p options:0];
		
		 [self->m_rosterTableView beginUpdates];
			if(photo){
			   [partnerCell->m_photos setImage:[UIImage imageWithData:photo]];
			}else{
			   [partnerCell->m_photos setImage:[UIImage systemImageNamed:@""]];
			}
		 [self->m_rosterTableView endUpdates];
		// });
		 break;;
		
	  }
	   
	  
   }
 
   //});
   //}).detach();
   if(std::get<1>(m_isSearchForVCard)==jid.bare()){
	  self->m_isSearchForVCard={false,{}};
		//std::cout<<"fectVcardQues+++"<<std::endl;
   }
}
-(void)handleSelfStoreVCardResult:(gloox::StanzaError)error{
   std::cout<<"self store result"<<std::endl;
}

-(void)handleSelfFetchVCardResult:(gloox::StanzaError)error{
    std::cout<<"\nself vcard fetched result :"<<error<<std::endl;

}
-(void)handleFetchVCardResult:(gloox::JID)jid StanzaErr:(gloox::StanzaError)se{
    std::cout<<"\n vcard fetched result :"<<se<<std::endl;
  
}

//last activity
-(void)handleLastActivityError:(const gloox::JID &)jid errorMsg:(gloox::StanzaError)error{
   
   
   std::cout<<"last activity error"<<error<<std::endl;
   
   
}
-(void)handleLastActivityResult:(const gloox::JID &)jid timeInSec:(long)seconds statusMsg:(const std::string &)status{
   
   NSDate *now = [NSDate dateWithTimeIntervalSinceNow:-1*seconds];
   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   dateFormatter.timeStyle = NSDateFormatterMediumStyle;
   dateFormatter.dateStyle = NSDateFormatterShortStyle;
   dateFormatter.doesRelativeDateFormatting = YES;
  // std::cout<<"last activity :: "<<jid.bare()<<" - : "<<seconds<<" : "<<status<<std::endl;
   if(!seconds){
	  m_data->setPresence(jid.bare(), gloox::Presence::PresenceType::Available,"0");
   }else{
	  m_data->setPresence(jid.bare(), gloox::Presence::PresenceType::Unavailable,[dateFormatter stringFromDate:now].UTF8String);
   }
  
   
   if(m_chatDelegate && jid.bare()==m_xmppEngine->getToJID().bare()){
	  [m_chatDelegate handleLastActivityResult:jid timeInSec:seconds statusMsg:status];
		
   }
}
//roster

-(void)handleRoster:(const gloox::Roster &)roster{
   dispatch_queue_t rt=dispatch_queue_create("rosterQueue", nullptr);
   dispatch_async(rt, ^{
	  
	  if(!self->m_data)
			return;
    //dispatch_async(dispatch_get_main_queue(), ^{
   for (auto &ros : roster) {
	  bool addRos=false;
	  
	  gloox::JID jid=gloox::JID(ros.first);;
	  AppData::AppData::PartnerInfoType  part=self->m_data->isPartnerExisting(jid.bare());
	  if(part.jid.empty()){
		 part.jid=jid.full();
		 part.name=jid.username();
		 part.photo=std::string();
		 part.chat_priority=std::string();;
		 part.pushID=std::string();;
		 part.inroster=true;
		 part.inContact=false;
		 part.registered=true;
		 part.presence=ros.second->online()?gloox::Presence::Available:gloox::Presence::Unavailable;
		 self->m_data->addPartner(part);
		
		 
	  }else{
		 if(!part.inroster){
			dispatch_async(dispatch_get_main_queue(), ^{
			   self->m_data->setPartnerInRoster(jid.bare(), true);
			   
			});
			
			
			
		 }
		
	  }
	  
    
   }
	  
 // });
   });
   

}



-(void)updateRosterData:(const gloox::RosterItem *)item{
//
//   //std::thread t([self,item]{
//	  int idx=0;
//	  for (gloox::Roster::iterator it=m_xmppEngine->getRoster()->roster()->begin();it!=m_xmppEngine->getRoster()->roster()->end();++it,++idx) {
//		 if(gloox::JID(it->first).bareJID()==item->jidJID().bareJID()){
//			it->second=new gloox::RosterItem(*item);
//			dispatch_async(dispatch_get_main_queue(), ^{
//			PartnerTableViewCell *cell;
//
//
//			   if([self->m_rosterTableView numberOfRowsInSection:0])
//				  cell=[self->m_rosterTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
//			else
//			   cell=[self->m_rosterTableView dequeueReusableCellWithIdentifier:@"PartnersCell" forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//			   std::map<const std::string,gloox::RosterItem*>::iterator it=self->m_xmppEngine->getRoster()->roster()->begin();
//			BOOL online=it->second->online();
//			   [self->m_rosterTableView beginUpdates];
//		   // std::cout<<"presence from "<<item->jidJID().bare()<<" online :"<<item->online()<<std::endl;
//			if(online){
//			   //[cell.m_presenceImg setBackgroundColor:[UIColor redColor]];
//			    [self->m_presenceView setTitle:@"Online"];
//			}else{
//			   //[cell.m_presenceImg setBackgroundColor:[UIColor colorWithRed:255 green:50 blue:201 alpha:1.f]];
//			    [self->m_presenceView setTitle:@"Offline"];
//			}
//			   [self->m_rosterTableView endUpdates];
//			});
//		 }
//	  }
//  // });
  
  // t.detach();
   
   
   
}




-(void)setPresenceColor:(UIImage*)img online:(BOOL)online{
   NSLog(@"presence color %i",online);
   UIColor *color=online?([UIColor redColor]):[UIColor grayColor];
   
   UIGraphicsBeginImageContextWithOptions(img.size, NO, 0);
   [color setFill];
   UIImage *_img=UIGraphicsGetImageFromCurrentImageContext();
   img=_img;
   
   UIGraphicsEndImageContext();
   
   
   
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
   //if([self.view is]){
   
   //}
}
-(void)handleItemSubscribed:(const gloox::JID &)jid{

}
-(void)handleItemUpdated:(const gloox::JID &)jid{
   /* self->m_actionSheet=[UIAlertController alertControllerWithTitle:@"Contact" message:@"Added successfully" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *OkAction=[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
	}];
	[m_actionSheet addAction:OkAction];
	
	[self presentViewController:m_actionSheet animated:YES completion:^{
	
	}];*/
}

- (IBAction)addContact:(id)sender {
   
}


- (IBAction)accountType:(id)sender {

}

-(void)handlePresence:(const gloox::Presence& )presence{
   
 
   if(presence.from().bare()==m_data->getUserInfo().JID.bare() && presence.presence()==gloox::Presence::Available){
	  if(m_presence!=gloox::Presence::Available){
			m_xmppEngine->fetchVCard(m_xmppEngine->getMyJID().bareJID());
			[self scanContact];
	  }
	  m_presence=presence.presence();
   
	  
	 
	  
	 /* std::thread([self]{
		   m_xmppEngine->fetchVCard(std::get<0>(m_data->getUserInfo()));
			  
		 
		  for (auto chat : m_data->getAllUnsendChats()) {
			
			 AppData::MESSAGETYPE  type=std::get<3>(chat);
			 
			 NSString* txt=[NSString stringWithUTF8String:std::get<2>(chat).c_str()];;
			 std::string _to=std::get<1>(chat);;
			 std::string _id=std::get<0>(chat);
			 switch (type) {
				case AppData::MESSAGETYPE::TEXT:{
				   std::cout<<"mid mdisdiis "<<_id<<std::endl;
				   m_xmppEngine->sendMessage(XmppEgine::MESSAGETYPE::TEXT,txt.UTF8String,_id,_to,YES);
				   
				   break;
				}
				case AppData::MESSAGETYPE::WEB_LINK:{
				   m_xmppEngine->sendMessage(XmppEgine::MESSAGETYPE::WEB_LINK,txt.UTF8String,_id,_to,YES);
				   
				   break;
				}
				case AppData::MESSAGETYPE::DELETE: {
				  m_xmppEngine->sendMessage(XmppEgine::MESSAGETYPE::DELETE,txt.UTF8String,_id,_to,YES);
				   break;
				}
				case AppData::MESSAGETYPE::FILE_ASSET_ID:{
					std::cout<<4848484848484<<"\t"<<(int)type<<std::endl;
			       PHFetchResult *result=nil;
				   PHAsset *assett=nil;
				   PHImageManager *imageMgr=[PHImageManager defaultManager];
				   PHImageRequestOptions * imgRqst =[[PHImageRequestOptions alloc]init];
				   [imgRqst setSynchronous:YES];
				   
				   [imgRqst setResizeMode:PHImageRequestOptionsResizeModeExact];
				   __block NSString*  path =NSTemporaryDirectory();
				   __block NSData * data=nil;
				   
				   PHAssetMediaType fileType=PHAssetMediaTypeUnknown;
				   if([[txt pathExtension] isEqualToString:@"caf"]){
					  fileType=PHAssetMediaTypeAudio;
				   }else{
					  result=[PHAsset fetchAssetsWithLocalIdentifiers:@[txt] options:nil];
					  assett=[result firstObject];
					  imageMgr=[PHImageManager defaultManager];
					  fileType= [assett mediaType];
					  
				   }
				   switch(fileType){
					  case PHAssetMediaTypeUnknown: {
						 break;
					  }
					  case PHAssetMediaTypeImage:{
						 
						 __block PHImageRequestOptions *option=[[PHImageRequestOptions alloc] init];
						 [option setDeliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat];
						 [option setNetworkAccessAllowed:YES];
						 
						 [imageMgr requestImageDataForAsset:assett options:imgRqst resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
							data=[NSData dataWithData: imageData];
							NSString* ext=[NSString string];
							if([dataUTI pathExtension])
							   ext=[dataUTI pathExtension];
							path=[path stringByAppendingString:[[txt stringByAppendingString: @"."] stringByAppendingString:ext]];
							
						 }];
						 
						 
						 [data writeToFile:path atomically:YES];
						 
						 m_xmppEngine->m_fileTransferManager->sendFile(path.UTF8String,[assett localIdentifier].UTF8String, txt.UTF8String, [path pathExtension].UTF8String,_id,true);
						 
						 
						 break;
						 
					  }
					  case PHAssetMediaTypeVideo: {
						 __block PHVideoRequestOptions *option=[[PHVideoRequestOptions alloc] init];
						 [option setDeliveryMode:PHVideoRequestOptionsDeliveryModeHighQualityFormat];
						 [option setNetworkAccessAllowed:YES];
						 dispatch_semaphore_t sema=dispatch_semaphore_create(0);
						 [imageMgr requestAVAssetForVideo:assett options:option resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
							
							AVURLAsset *urlAsset=(AVURLAsset*)asset;
							path=[[urlAsset URL] path];
							dispatch_semaphore_signal(sema);
						 }];
						 dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
						 m_xmppEngine->m_fileTransferManager->sendFile(path.UTF8String,[assett localIdentifier].UTF8String, txt.UTF8String, [path pathExtension].UTF8String,_id,true);
						 break;
						 break;
					  }
					  case PHAssetMediaTypeAudio: {
						 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
						 NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
						 NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/records"];
						 dataPath=[dataPath stringByAppendingPathComponent:txt];
						
						   m_xmppEngine->m_fileTransferManager->sendFile(dataPath.UTF8String, [dataPath lastPathComponent].UTF8String, [dataPath lastPathComponent].UTF8String, [dataPath pathExtension].UTF8String,_id,true);
						 break;
					  }
					  default:
						 break;
				   }
				   
				   break;
				}
				case AppData::MESSAGETYPE::FILE_URL: {
				   
				   break;
				}
				case AppData::MESSAGETYPE::REPLY: {
				   
				   break;
				}

				   
			 }
		  }
	  }).detach();
	  */
	
   }
	  
	 
   if((m_xmppEngine->getToJID().bare() ==presence.from().bare()) ){
	  
	  
	  [m_chatDelegate handlePresence:presence.from() pres:presence.presence()];
   }
   self->m_data->setPresence(presence.from().bare(), presence.presence(),presence.status());
   
 
   
	
	   
	  //[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
   
	   /// [m_activityIndicator startAnimating];
   ///
  // std::thread t([self]{
   
	
	  
		 //std::this_thread::sleep_for (std::chrono::seconds(1));
   //});
  // t.detach();
   /*
	  
	   // [m_activityIndicator stopAnimating];
	  // [[UIApplication sharedApplication] endIgnoringInteractionEvents];
   
 
  */
}


   
   
   

   

-(void)setAccount{
   dispatch_async(dispatch_get_main_queue(), ^{
	  UIStoryboard * tmpStoryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
	  UIViewController* m_createAccountViewController=(UIViewController*) [tmpStoryBoard instantiateViewControllerWithIdentifier:@"CreateAccount"];
	  [m_createAccountViewController setModalPresentationStyle:UIModalPresentationFullScreen];
	  //[self.tabBarController setHidesBottomBarWhenPushed:YES];
	  //[self.navigationController setNavigationBarHidden:YES animated:YES];
	  [self presentViewController:m_createAccountViewController animated:YES completion:nil];
   });
   
   
}
-(NSString*)getInternationalNumber:(NSString*)number callingCode:(NSString *)code{
   if(![code length] ||! number.length)
	  return nil;
   NSString *tmpIntNum=[NSString stringWithString:code];
   NSString *realNumb=[[NSString alloc]init];
   for (int i=0;i<[number length];++i) {
	  if([number characterAtIndex:i]>=48 &&[number characterAtIndex:i]<=57){
		 realNumb=[realNumb stringByAppendingFormat:@"%c",[number characterAtIndex:i]];
	  }
   }
   NSString *tmp=[NSString stringWithString:realNumb];
 
   if([tmp length]>10){
	  return tmp;
   }
   tmpIntNum =[tmpIntNum stringByAppendingString:tmp];
   return tmpIntNum;
}

-(void)onDisconnect:(gloox::ConnectionError )e{

   if(m_xmppEngine->registrationMode)
		 return;
   if(e!=gloox::ConnectionError::ConnNoError){
	
	
		 if(self->m_xmppEngine){
			
			delete self->m_xmppEngine;
			self->m_xmppEngine=nullptr;
			self->m_appDelegate->m_xmppEngine=nil;
		
		 }
	  if(e==16 || m_data->getUserInfo().JID==gloox::JID()){
		 //self->m_data->dropUserData();
		 [self setAccount];
		 return;
	  }
	  
	  if(e!=17 && e!=16){
	  
		// dispatch_async (dispatch_get_main_queue(), ^{
				  
			self->m_presence=gloox::Presence::Unavailable;
			self->m_xmppEngine=new XmppEgine(self, self->m_data->getUserInfo().JID.bare() +"/iphone",self->
											 m_data->getUserInfo().JID.username(),self->m_server.UTF8String,false);
			self->m_xmppEngine->setDelegate(self);
			self->m_appDelegate->m_xmppEngine=(void*)self->m_xmppEngine;
		
		/// });
		 }
			   ///m_xmppEngine->disconnect();
		
	  
	  std::cout<<" connectinon err : "<<e<<std::endl;
   }
 
   
}
-(void)handleRegistrationResult:(const gloox::JID &)from registreationResult:(gloox::RegistrationResult)regResult{
   
}
-(void)newMessageTagView:(gloox::JID)jid parentView:(UIView*)pView{
   
   
   UITapGestureRecognizer *gest=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(whenNewMsgTagViewClick:)];
   UIView *tagView=[[UIView alloc]initWithFrame:CGRectMake(-10, -(self.view.bounds.size.height*.1), self.view.bounds.size.width*.6, self.view.bounds.size.height*.07)];
   [tagView setRestorationIdentifier:[NSString stringWithUTF8String: jid.bare().c_str()]];
   
   UILabel*name=[[UILabel alloc]init];
   UIImageView * image=[[UIImageView alloc]initWithFrame:CGRectMake(tagView.frame.size.width*.7, tagView.frame.size.height*.1, tagView.frame.size.width*.2, tagView.frame.size.height*.8)];
   [image setBackgroundColor:[UIColor  colorWithRed:1 green:.00f blue:.66 alpha:.5]];
   [name setTextColor:[UIColor  colorWithRed:1 green:.00f blue:.66 alpha:1]];
   AppData::PartnerInfoType part=m_data->isPartnerExisting(jid.bare());
   if(part.jid.size()){
	  [name setText:[NSString stringWithUTF8String:part.name.c_str()]];
	  if(part.photo.size()){
		 NSString *ph=[NSString stringWithUTF8String:part.photo.c_str()];
		 [image setImage:[ UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:ph options:0]]];
		
	  }
	  
   }else{
	  [name setText:[NSString stringWithUTF8String:jid.username().c_str()]];
	 
   }
    [image.layer setCornerRadius:20];
   [image.layer setMasksToBounds:YES];
   [name setFrame:CGRectMake(name.frame.origin.x+20, tagView.frame.size.height*.3, name.frame.size.width, name.frame.size.height)];
   [tagView setBackgroundColor:[UIColor whiteColor]];
   [tagView.layer setCornerRadius:10];
   [tagView addGestureRecognizer:gest];
   [name sizeToFit];
   
   
   
   [tagView addSubview:name];
   [tagView addSubview:image];
   [pView addSubview:tagView];
   [UIView animateWithDuration:1 animations:^{
	  [tagView setFrame:CGRectMake(-10, pView.bounds.size.height*.1, pView.bounds.size.width*.6, pView.bounds.size.height*.07)];
   }];
   char queueName[]="connectQueue";
   dispatch_queue_t t=dispatch_queue_create(queueName, NULL);
     dispatch_async(t, ^{
   [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
	  [UIView animateWithDuration:1 animations:^{
		  [tagView setFrame: CGRectMake(-tagView.frame.size.width, tagView.frame.origin.y, tagView.frame.size.width, tagView.frame.size.height)];
	  } completion:^(BOOL finished) {
		 
		
		 [tagView removeFromSuperview];
	  }];
  
   }];
    });
  
  
}

-(void)whenNewMsgTagViewClick:(UITapGestureRecognizer*)gester{
   [gester.view removeFromSuperview];
    gloox::JID tmpJid=gloox::JID([[gester view] restorationIdentifier].UTF8String);
    m_xmppEngine->setToJId(tmpJid);
    m_appDelegate->m_toJid=[NSString stringWithUTF8String:tmpJid.full().c_str()];
   for (int i=0;i<[m_rosterTableView numberOfRowsInSection:0]; ++i) {
	  NSIndexPath *tmpIndxPath=[NSIndexPath indexPathForRow:i inSection:0];
	  PartnerTableViewCell *cell=[m_rosterTableView cellForRowAtIndexPath:tmpIndxPath];
	  if(!cell)
		 break;
	  if(cell->m_jid==tmpJid.bare()){
		 [self tableView:m_rosterTableView didSelectRowAtIndexPath:tmpIndxPath];
		 break;
	  }
	  
   }
   
   
   
}

-(void)handleChatState:(const gloox::JID &)from state:(gloox::ChatStateType)state{
	std::cout<<"chatssssss sstaaateee from : "<<from.bare()<<" :\t"<<state<<std::endl;
   if(m_chatDelegate && (from.bare()== m_appDelegate->m_toJid.UTF8String)){
	  [m_chatDelegate handleChatState:from state:state];
	  
   }
}

-(void)handleMessage:(const gloox::Message&)msg session:(gloox::MessageSession*)session{
   
   try {
	  //if is incoming chatstate 
	  if(msg.id().empty()){
	    return;
	  }
	  
	  std::string msgID=msg.subject().substr(2,msg.subject().size()-1);
	 AppData::MESSAGETYPE chat_txt_type=(AppData::MESSAGETYPE)std::atoi(msg.subject().substr(0,1).c_str());

	  
	  NSString *_to=[NSString stringWithUTF8String:msg.to().bare() .c_str()];
	  NSString *_from=[NSString stringWithUTF8String:msg.from().bare().c_str()];
	  NSString *tmpMsg=[NSString stringWithUTF8String:msg.body().c_str()];
	  //gloox::Receipt *receipt=(gloox::Receipt*)msg.findExtension(gloox::ExtReceipt);
	  long prevNumOfPart=m_data->chatRoster().size();
	  switch (chat_txt_type) {
		 case AppData::MESSAGETYPE::TEXT:{
			
			[self storeMessage:[NSString stringWithUTF8String:msgID.c_str()]
								message:tmpMsg
							  toJIDBare:_to
							fromJIDBare:_from  textType:chat_txt_type];
			if(msg.from().bare()!=m_xmppEngine->getMyJID().bare() ){
			   m_xmppEngine->sendMessage(XmppEgine::MESSAGETYPE::RECEIPT,{}, msgID,msg.from().bare());
			   
			}else if(m_xmppEngine->clientIsconnected() && msg.from().bare()==m_xmppEngine->getMyJID().bare()){
			   m_data->setMsgStatus(msg.to().bare(), msgID, gloox::MessageEventOffline);

			}
			m_data->setPartnerChatPriority((msg.from().bare()==m_xmppEngine->getMyJID().bare()?msg.to().bare():msg.from().bare()));
			[self shuffleRow:msg.from().bare()==m_xmppEngine->getMyJID().bare()?msg.to().bare():msg.from().bare() preNumOfPart:prevNumOfPart];
			[self partnerNewMsgCount:msg.from()];
		 }break;
		 case AppData::MESSAGETYPE::FILE_URL:{
		
			if(msg.from().bare()!=m_xmppEngine->getMyJID().bare() ){
			   [self storeMessage:[NSString stringWithUTF8String:msgID.c_str()]
								   message:tmpMsg
								 toJIDBare:_to
							   fromJIDBare:_from  textType:chat_txt_type];
			   m_xmppEngine->sendMessage(XmppEgine::MESSAGETYPE::RECEIPT,{}, msgID,msg.from().bare());
			}else if(m_xmppEngine->clientIsconnected() && msg.from().bare()==m_xmppEngine->getMyJID().bare()){
			   m_data->setMsgStatus(msg.to().bare(), msgID, gloox::MessageEventOffline);
                    
			}
		
			m_data->setPartnerChatPriority((msg.from().bare()==m_xmppEngine->getMyJID().bare()?msg.to().bare():msg.from().bare())); 
			[self shuffleRow:msg.from().bare()==m_xmppEngine->getMyJID().bare()?msg.to().bare():msg.from().bare() preNumOfPart:prevNumOfPart];
			[self partnerNewMsgCount:msg.from()];
		 }break;
		 case AppData::MESSAGETYPE::FILE_ASSET_ID:{
			[self storeMessage:[NSString stringWithUTF8String:msgID.c_str()]
								message:tmpMsg
							  toJIDBare:_to
							fromJIDBare:_from  textType:chat_txt_type];
			m_data->setPartnerChatPriority((msg.from().bare()==m_xmppEngine->getMyJID().bare()?msg.to().bare():msg.from().bare()));
			[self shuffleRow:msg.from().bare()==m_xmppEngine->getMyJID().bare()?msg.to().bare():msg.from().bare() preNumOfPart:prevNumOfPart];
			[self partnerNewMsgCount:msg.from()];

		 }break;
		 case AppData::MESSAGETYPE::WEB_LINK:{
			[self storeMessage:[NSString stringWithUTF8String:msgID.c_str()]
								message:tmpMsg
							  toJIDBare:_to
							fromJIDBare:_from  textType:chat_txt_type];
			m_data->setPartnerChatPriority((msg.from().bare()==m_xmppEngine->getMyJID().bare()?msg.to().bare():msg.from().bare()));
			[self shuffleRow:msg.from().bare()==m_xmppEngine->getMyJID().bare()?msg.to().bare():msg.from().bare() preNumOfPart:prevNumOfPart];
		 
			[self partnerNewMsgCount:msg.from()];
		 }break;
		 case AppData::MESSAGETYPE::DELETE:{
			
			m_data->deleteMessage(msg.from().bare()==m_xmppEngine->getMyJID().bare()?msg.to().bare():msg.from().bare(), msg.body());
			
			[self partnerNewMsgCount:msg.from()];
		 }break;
		 case AppData::MESSAGETYPE::RECEIPT:{

			//set message with msgID delivered if not from you
			if(msg.from().bare()!=m_xmppEngine->getMyJID().bare()){
			   std::cout<<"your message :"<<msg.from().bare()<<"\t has be received your message :"<<msgID<<std::endl;
			   m_data->setMsgStatus(msg.from().bare(), msgID, gloox::MessageEventDelivered);
			}

		 }break;
		 default:
			break;
	  }
	  
	
	
	 

	  //when chat open between you and the current chat partner
	  if(m_appDelegate->m_toJid){

	      std::string toJID=gloox::JID(m_appDelegate->m_toJid.UTF8String).bare();
		 if((m_chatDelegate && msg.from().bare()==toJID) ||
			(m_chatDelegate && msg.to().bare()==toJID) ){
               
			
			   [ m_chatDelegate handleChatMessage:msg session:session];
			
		 }
		 //toggle sound,vibration and newMsgTagView

	  }
	  if(
		 chat_txt_type!=AppData::MESSAGETYPE::DELETE &&
		 chat_txt_type!=AppData::MESSAGETYPE::RECEIPT &&
		 msg.from().bare()!=m_xmppEngine->getMyJID().bare() &&
		 msg.from().bare()!=m_xmppEngine->getToJID().bare())

	  {

		   //if message is already in noti msg don't show tag

		 if([m_msgID4TagNotifRef count]){

			   for(int n=0;n<[m_msgID4TagNotifRef count];++n){
				  if(((NSString*)m_msgID4TagNotifRef[n]).UTF8String== msg.id()){
					 [m_msgID4TagNotifRef removeObject:m_msgID4TagNotifRef[n]];
				  }else{
					 AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
					 AudioServicesPlaySystemSound(1003);
				  }

			   }

			}else if (![m_msgID4TagNotifRef count] ){

			   //[self newMessageTagView:msg.from() parentView:self.view];
			   AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

			}

	 }
		 //if not connect set my msg sending event to cancel
		// if(!m_xmppEngine->clientIsconnected() && msg.to()!=std::get<0>(m_data->getUserInfo())){
		   // m_data->setMsgStatus(msg.to().bare(),msg.id(),gloox::MessageEventCancel);
		  //  [self handleMessageEvent:msg.from() state:gloox::MessageEventCancel _msgiID:[NSString stringWithUTF8String:msg.id().c_str()]];
	   //  }

   } catch (std::exception er) {
	  std::cout<<"error reading message receied err : "<<er.what()<<std::endl;
	  
   }
   
  
  

 

}

-(void)partnerNewMsgCount:(gloox::JID)jid{
   int rowSize=(int)m_data->chatRoster().size();
   for(int row=0;row<rowSize;row++){
	  PartnerTableViewCell *cell=[m_rosterTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
	   if(!cell)
		  continue;
	  if(gloox::JID(cell->m_jid).bare()==jid.bare()){
		 [m_rosterTableView beginUpdates];
		 int numUnread=m_data->getUnreadMsgCount(gloox::JID(cell->m_jid).bare());
		 std::cout<<" new message total : "<<numUnread<<std::endl;
		 [cell->m_msgeBadge setText: numUnread?[NSString stringWithFormat:@" %i ",numUnread]:@""];
		 
		 [m_rosterTableView endUpdates];
		 break;
	  }
   }
   
}

-(void)handleItemAdded:(const gloox::JID& )jid{
  
   //ADD TO PARTNERS IF  PARTNER NOT EXIST
   std::cout<<"handle item add:"<<jid.full()<<std::endl;
   AppData::AppData::PartnerInfoType  part=m_data->isPartnerExisting(jid.bare());

   if(part.jid.empty()){
	  part.jid=jid.bare();
	  part.name=jid.username();
	  part.photo=std::string();
	  part.chat_priority=std::string();;
	  part.inroster=true;
	  part.inContact=false;
	  part.registered=true;
	  m_data->addPartner(part);
	 
	  
   }else{
	  if(!part.inroster){
		 m_data->setPartnerInRoster(jid.bare(), true);
		
	  }
	  if(!part.registered){
		 //m_data->setPartnerRegistered(jid.bare(), true);
	  }
   }
  
//   if(m_xmppEngine && notInroster){
//
//	  [ m_rosterTableView beginUpdates];
//	  [ m_rosterTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self->m_data->chatRoster().size()-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//	    [m_rosterTableView endUpdates];
	  m_xmppEngine->fetchVCard(jid);
//
//
//       // std::cout<<"Addedss : "<<jid.full() <<"\troster : "<<self->m_data->roster().size()<<std::endl;
//
//   }
}
-(void)handleItemAlreadyExist:(const gloox::JID&)jid{
   std::cout<<"Already Exist : "<<jid.full()<<std::endl;
}

-(void)handleItemUnsubscribed:(const gloox::JID& )jid{
   std::cout<<"item unsubscribed  : "<<jid.full()<<std::endl;
}
-(void)handleItemRemoved:(const gloox::JID& )jid{
    std::cout<<"item removed  : "<<jid.full()<<std::endl;
}

-(void)handleRosterPresence:(const gloox::RosterItem&) item resource:(const std::string& )resource presence:( gloox::Presence::PresenceType) presence message:(const std::string&)msg{

   gloox::RosterItem *tempItem=new gloox::RosterItem(item);
    
    m_data->setPresence(tempItem->jidJID(), presence,msg);
   [self updateRosterData: tempItem];
   if(m_appDelegate->m_toJid){
	  if(m_chatDelegate && item.jidJID().bare()==gloox::JID(m_appDelegate->m_toJid.UTF8String).bare()){
		 [m_chatDelegate handleChatRosterPresence:item resource:resource presence:presence message:msg];
		 
	  }
	  
   }
	  
   
}
-(void)hanldeSelfPresence:(const gloox::RosterItem&) item resource:(const std::string& )resource presence:(const gloox::Presence::PresenceType) presence message:(const std::string&)msg{
   
   //[self setPresenceColor:m_selfPresence.image online:YES];
  
   if(  presence==gloox::Presence::Available){
	
	  
	  [UIView transitionWithView:m_presenceView.customView duration:2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		   std::cout<<"self presence "<<presence<<std::endl;
		 [self->m_presenceView setTitle:@"Online"];
		 
		
	  } completion:nil];
	  
   }else{
	  [UIView transitionWithView:m_presenceView.customView duration:2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		 [self->m_presenceView setTitle:@"Offline"];
		 
	  } completion:nil];
	  
   }
   
   
}
-(void)handleSubscriptionRequest:(const gloox::JID&)jid message:(const std::string&)msg{
   
   std::cout<<"subscription request : "<<jid.full()<<std::endl;
}
-(void)handleUnsubscriptionRequest:(const gloox::JID&)jid message:(const std::string&)msg{
   std::cout<<"Unsubscription request : "<<jid.full()<<std::endl;
}
-(void)handleNonrosterPresence:(const gloox::Presence&) presence{
   std::cout<<"Non Roster presence: "<<presence.presence()<<"  from JId :"<<presence.from().full()<<std::endl;
 
}
-(void)handleRosterError:( const  gloox::IQ& )iq{
   std::cout<<"Roster Error "<<iq.embeddedTag()->xmlns()<<std::endl;
}
/*
-(void)d{
   NSString *strUrl =[NSString stringWithFormat:@"%@/upload_file.php", [globalApp sharedUser].vg_dominio ];
   //strUrl = @"http://192.168.1.100/mismedicinas/upload_file.php";
   
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
   request.HTTPMethod = @"POST";
   request.timeoutInterval = 60;
   request.HTTPShouldHandleCookies = false;
   
   //[request setHTTPMethod:@"POST"];
   
   
   NSString *boundary = @"----------SwIfTeRhTtPrEqUeStBoUnDaRy";
   
   NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
   
   [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
   //[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
   
   
   
   NSMutableData *body = [NSMutableData data];
   NSMutableData *tempData = [NSMutableData data];
   
   [tempData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
   
   [tempData appendData:[@"Content-Disposition: form-data; name=\"userfile\"; filename=\"iphoneimage.xml\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
   
   [tempData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
   
   //[tempData appendData:[NSData dataWithData:imageData]];  ///IMAGEN
   [tempData appendData:[NSData dataWithData:cData]];
   
   [tempData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
   
   [body appendData: tempData];
   
   
   [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
   
   
   
   [request setValue: [NSString stringWithFormat:@"%d", body.length ] forHTTPHeaderField:@"Content-Length"];
   
   
   request.HTTPBody =body;
   
   
   
   
   
   NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
   
   NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
   
   NSLog(@"finalizacion %@", returnString);
}
 */
//swipe
/*
 - (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)){
 UISwipeActionsConfiguration *swipeConfig;
 NSLog(@"%@",[m_rosterTableView cellForRowAtIndexPath:indexPath].reuseIdentifier);
 if([[m_rosterTableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString: @"rosterCell"]){
 
	UIContextualAction *action=[UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal  title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
	[self->m_rosterTableView beginUpdates];


	[self->m_rosterTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationRight];
	[self->m_rosterTableView endUpdates];
	completionHandler(true);
	}];

	NSArray<UIContextualAction*> *actions=[[NSArray<UIContextualAction*> alloc]initWithObjects:action, nil];
    swipeConfig=[UISwipeActionsConfiguration configurationWithActions:actions];
	return swipeConfig;
 }else
   return swipeConfig;
 }*/


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   try {
	  
	  
	
		 // std::cout<<"clicked"<<std::endl;
		
		// if(m_xmppEngine->getRoster()->roster()->size()){
		//	m_xmppEngine->m_to= std::pair<const std::string,gloox::RosterItem*>();
		//	NSString *m_phoneJid=((PartnerTableViewCell*)[tableView cellForRowAtIndexPath:indexPath])->m_phoneNumber;
		//	gloox::Roster::iterator it=m_xmppEngine->getRoster()->roster()->find(std::string([m_phoneJid UTF8String])+"@"+m_xmppEngine->getServer());
			
		 
		 //}
	
		// UIColor *color=[UIColor colorWithRed:1 green:1 blue:1 alpha:.8];
		// NSString *name=[NSString string];
		 //NSDictionary *attr=@{NSStrokeColorAttributeName:color};
		 //NSMutableAttributedString * nameAttr=[[NSMutableAttributedString alloc]initWithString:name attributes:attr];
		 PartnerTableViewCell *tmpCell=(PartnerTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
	   
		 if(!tmpCell)
			return;
	     std::string noti_node =m_data->isPartnerExisting(tmpCell->m_jid).noti_pubsub_node;
		 if(noti_node.empty()){
			   m_xmppEngine->subscribToNodeItemNoti(gloox::JID(tmpCell->m_jid));
		
		 }
	  
		 gloox::JID tmpJid=gloox::JID();
		 tmpJid=gloox::JID(tmpCell->m_jid);
	      m_xmppEngine->setToJId(tmpJid);
		 [self viewPartnerChat:tmpJid userName:tmpCell->m_name.text];
		 tmpCell->m_msgeBadge.text=@"";
		 //m_xmppEngine->m_topImage=tmpCell->m_photos.image;
	
	
   } catch (std::exception errcpp) {
	  	std::cout<<"row selection err c++ :"<<errcpp.what()<<std::endl;
   }catch (NSException *errobjc){
	  NSLog(@"row selection err objc %@:",[errobjc description]);
   }
  
}


-(void)viewPartnerChat:(gloox::JID )jid userName:(NSString*)name{
 
   
   for(UIViewController *vc in [self childViewControllers]){
	  [vc removeFromParentViewController];
       
   }
   ChatNavViewController *nav=[[ChatNavViewController alloc]init];
   UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
   m_appDelegate->m_chatControllar=[[ChatCollectionViewController alloc]initWithCollectionViewLayout:layout];
   m_appDelegate->m_toJid=[NSString stringWithUTF8String: jid.full().c_str()];
   m_xmppEngine->setToJId(jid);

   
	 
     [nav setViewControllers:@[m_appDelegate->m_chatControllar]];
     [self presentViewController:nav animated:YES completion:^{}];
   
 


  

}
-(void)shuffleRow:(const gloox::JID )userJID preNumOfPart:(long )prevNum{
   long curNumbOfPart=m_data->chatRoster().size();
if(curNumbOfPart!=prevNum){
	 [ m_rosterTableView beginUpdates];
	 [ m_rosterTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
	 [m_rosterTableView endUpdates];
   [self displayChatIcon];
}else{
   for(int i=0;i<(int)curNumbOfPart;++i){
	  PartnerTableViewCell *cell1=[m_rosterTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
	  if(!cell1)
		 continue;
	  if(gloox::JID(cell1->m_jid).bare()==userJID.bare() && i!=0){
			[self->m_rosterTableView beginUpdates];
			[self->m_rosterTableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			[self->m_rosterTableView endUpdates];
	  }
   }
}
  

   
   std::cout<<"hey mr. shuffle size prev "<<prevNum<<"\t || cur "<<curNumbOfPart<<std::endl;

   
	  
}
//store msg
-(BOOL)storeMessage:(NSString*)_id  message:(NSString *)msg  toJIDBare:(NSString*) to fromJIDBare:(NSString*) from  textType:(AppData::MESSAGETYPE) txt_type {
   if(![msg length])
	  return false;
   std::string _from=!([from length])?m_data->getUserInfo().JID.bare():([from UTF8String]);
   auto tmp=m_data->insertNewMessage(_id.UTF8String,_from,[to UTF8String],[msg UTF8String],txt_type);
 
   if(!tmp.first)
     return false;
   else
	  return true;
   
   
   
   
   
   
   //add partner if not exist inRoster
   
   
 
   //store message in DB
   //NSLog(@"Message Store :  %@",m_appDelegate->m_messagesDB);
   
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the specified item to be editable.
  return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



//app delegate


- (void)applicationWillResignActive:(UIApplication*)application{
   
}
- (void)applicationDidEnterBackground:(UIApplication*)application{
    // dispatch_async(dispatch_get_main_queue(), ^{


  
   m_presence=gloox::Presence::Unavailable;
   if(m_chatShareDelegate)
	  [m_chatShareDelegate doneShare];
   
   if(self->m_xmppEngine){
		 m_xmppEngine->disconnect();
	  
   }
   NSLog(@"App is on background1");
	// });
}
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
 
  
   return true;
}
- (void)applicationDidBecomeActive:(UIApplication *)application{

   
   NSLog(@"App is is on active1");
 
  
  
   
 
}
- (void)applicationDidBecomeInActive:(UIApplication *)application{
 
  
}


- (void)applicationWillTerminate:(UIApplication *)application{
  
   if(m_chatShareDelegate){
	  [m_chatShareDelegate doneShare];
	 
   }
}
- (void)applicationWillEnterForeground:(UIApplication *)application{
   //dispatch_sync (dispatch_get_main_queue(), ^{
	  [self viewDidLoad];
	  //self->m_xmppEngine->connect();
	   [self getGroupMessage];
	
	  //if(self->m_appDelegate->m_chatControllar)
	//	 [self->m_appDelegate->m_chatControllar viewDidAppear:YES];
	 // if(self->m_appDelegate->m_contactViewController)
	///	 [((ContactViewController*)self->m_appDelegate->m_contactViewController) viewDidLoad];
   //});
}
-(void)applicationDeviceToken:(NSString*)token{
   
   
	  NSLog(@"device token :%@",token);
	  m_newDeviceToken=[NSString stringWithString:token];
    if(m_newDeviceToken.length)
	   m_data->setDeviceToken(m_newDeviceToken.UTF8String);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull void (^)(void))completionHandler{
   NSString* jidStr=[[[[[response  notification] request] content] userInfo] objectForKey:@"jid"];
   gloox::JID jid=gloox::JID(jidStr.UTF8String);
   if(m_data){
	  AppData::PartnerInfoType part=m_data->isPartnerExisting(jid.bare());
	  if(part.jid.size()){
	      [self viewPartnerChat:jid userName:[NSString stringWithUTF8String:part.name.c_str()]];
	  }
   }
   
}

-(void)handlePrivacyListNames:(const std::string&) active def: (const std::string &)def privacyList:( const gloox::StringList &)lists{
   std::cout<< "handlePrivacyListNames "<< active<<" "<<def<<std::endl;
   if(m_accountDelegate){
	  [m_accountDelegate handlePrivacyListNames:active def:def privacyList:lists];
   }
   
   
   for (std::string list : lists) {
	  NSLog(@"handlePrivacyListNames %s",list.c_str());
	  
	  
   }
   
  
}
-(void)handlePrivacyList: (const std::string &)name  privacyList:(const gloox::PrivacyListHandler::PrivacyList &)items{
   
   std::vector<gloox::PrivacyItem> list={};
   for (auto item : items) {
	  list.push_back(item);
	 
	  m_data->setBlockPartner(item.value(),item.action());
	  int index=0;
	  for(auto tmpPart:m_data->chatRoster()){
		 
		 if(tmpPart.jid==item.value()){
			PartnerTableViewCell *tmpCell=[m_rosterTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
			if(!tmpCell)
			   continue;
			if(!item.action()){
			   NSLog(@"handlePrivacyLis99ee9 %s\t%i",item.value().c_str(),item.action());
			   [self->m_rosterTableView beginUpdates];
			   NSMutableAttributedString *originalMutableAttributedString =[[NSMutableAttributedString alloc] initWithAttributedString:tmpCell->m_name.attributedText];
			   [originalMutableAttributedString removeAttribute:NSStrikethroughStyleAttributeName range:NSMakeRange(0, tmpCell->m_name.attributedText.length)];
			   tmpCell->m_name.attributedText=originalMutableAttributedString;
			   [self->m_rosterTableView endUpdates];
			}else{
			   
			   [self->m_rosterTableView beginUpdates];
			   NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithUTF8String:tmpPart.name.c_str()]];
			   [attributeString addAttribute:NSStrikethroughStyleAttributeName
									   value:@3
									   range:NSMakeRange(0, [attributeString length])];
			   [tmpCell->m_name setAttributedText:attributeString];
			   [self->m_rosterTableView endUpdates];
		 
			   
			}
		 }
		 
		 ++index;
	  }
   }
   if(m_accountDelegate){
	  [m_accountDelegate handlePrivacyList:name privacyList:list];
   }
   
}
-(void)handlePrivacyListChanged: (const std::string &)name{
   NSLog(@"handlePrivacyListChanged");
   if(m_accountDelegate){
	  [m_accountDelegate handlePrivacyListChanged:name];
   }
}
-(void)handlePrivacyListResult: (const std::string &)_id result:(gloox::PrivacyListResult) plResult{
   
   if(m_accountDelegate){
	  [m_accountDelegate handlePrivacyListResult:_id result:plResult];
   }
   NSLog(@"handlePrivacyListResult ");
}
-(NSString *)groupPath{
   NSString *appGroupDirectoryPath = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.guys"] path];
   NSString *dataPath = [appGroupDirectoryPath stringByAppendingPathComponent:@"ContactInfo"];
   return dataPath;
}

-(void)setAcountViewConDelegate:(id<AccountViewDelegate> )delegate{
   m_accountDelegate=delegate;
}

-(void)      handleSubscriptionResult:(const std::string &) _id serviceName:(const gloox::JID &)service nodeName:(const std::string &)node SID:(const std::string &)sid JID:(const gloox::JID&)  jid subscriptionType:(const gloox::PubSub::SubscriptionType) subType err:(const gloox::Error*) error{
   if(!error){
	  m_data->setPubSubNotification(m_xmppEngine->m_to.bare(), node);
   }else{
	  std::cout<<"error subscription not node : "<<node<<std::endl;
   }
}


@end
