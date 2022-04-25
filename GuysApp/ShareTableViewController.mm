//
//  ShareTableViewController.m
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/5/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "ShareTableViewController.h"


@implementation ShareTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(!self)
        return self;
    self->m_background=[[UILabel alloc] init];
    self->m_name=[[UILabel alloc]init];
    self->m_number=[[UILabel alloc]init];
    //self->m_invite=[[UILabel alloc]init];
    
  
    self->m_background.translatesAutoresizingMaskIntoConstraints=NO;
    [self setUserInteractionEnabled:YES];
    [self addSubview:m_background];
    [m_background addSubview:m_name];
    [m_background addSubview:m_number];
    //[m_background addSubview:m_invite];
    
    
    
    
    
    
    self->m_name.translatesAutoresizingMaskIntoConstraints=NO;
    self->m_number.translatesAutoresizingMaskIntoConstraints=NO;
    
    //self->m_invite.translatesAutoresizingMaskIntoConstraints=NO;
    // self->m_invite.layer.cornerRadius=5;
    // [self->m_invite.layer setMasksToBounds:YES];
    //self->m_invite.numberOfLines=0;
    // [self->m_invite setTextAlignment:NSTextAlignmentLeft];
    
    
    [[m_background.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10] setActive:YES];
    [[m_background.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10] setActive:YES];
    [[m_background.topAnchor constraintEqualToAnchor:self.topAnchor constant:10] setActive:YES];
    [[m_background.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10] setActive:YES];
    
    [[self->m_name.widthAnchor constraintEqualToAnchor:m_background.widthAnchor] setActive:YES];
    [[self->m_name.topAnchor constraintEqualToAnchor:m_background.topAnchor constant:5] setActive:YES];
    [[self->m_name.bottomAnchor constraintEqualToAnchor:m_background.bottomAnchor constant:-30] setActive:YES];
    
    [[self->m_number.widthAnchor constraintEqualToAnchor:m_background.widthAnchor] setActive:YES];
    
    [[self->m_number.bottomAnchor constraintEqualToAnchor:m_background.bottomAnchor constant:-10] setActive:YES];
    [[m_number.leadingAnchor constraintEqualToAnchor:m_background.leadingAnchor constant:10] setActive:YES];
    
    
   // [[self->m_invite.bottomAnchor constraintEqualToAnchor:self->m_background.bottomAnchor constant:-10] setActive:YES];
    //[[self->m_invite.trailingAnchor constraintEqualToAnchor:self->m_background.trailingAnchor constant:-20] setActive:YES];
    
    [self->m_background setBackgroundColor:[UIColor blackColor]];
    
    [m_name setTextColor:[UIColor whiteColor]];
    [m_number setTextColor:[UIColor whiteColor]];

    [m_name   setFont:[UIFont fontWithName:@"GillSans-Semibold" size:20]];

    [m_number   setFont:[UIFont fontWithName:@"GillSans-Semibold" size:17]];
    [m_name setTextAlignment:NSTextAlignmentCenter];
    [self setBackgroundColor:[UIColor clearColor]];
   
    
    
    
    
    //[[self->m_number.bottomAnchor constraintEqualToAnchor:self->m_name.bottomAnchor constant:-20] setActive:YES];
    //self labe
    
    m_background.layer.cornerRadius=15;
    m_background.layer.masksToBounds=YES;
    return self;
}

@end

@interface ShareTableViewController ()

@end

@implementation ShareTableViewController
-(instancetype)initWithDataArray:(NSArray*)data{
    self=[super init];
    if(data)
     m_shareData=[[NSArray alloc]initWithArray:data];
    [self.view setBackgroundColor:[UIColor  blackColor]];
   
    //[[[[self.navigationController navigationBar] topItem] titleView] setTintColor:[UIColor blackColor] ];
    [self.tableView setAllowsSelection:YES];
   
    [self.tableView setAllowsMultipleSelection:YES];
    [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];

    UIBarButtonItem* itemRight=[[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:@selector(shareData)];
    [itemRight setBackgroundImage:[UIImage systemImageNamed:@"arrowshape.turn.up.forward"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [itemRight setBackgroundImage:[UIImage systemImageNamed:@"arrowshape.turn.up.forward.fill"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [itemRight setTintColor:[UIColor whiteColor]];
      
    [self.navigationItem setRightBarButtonItem:itemRight];
    
    
    //[m_bar setItems:@[barItem ]];
    //[self.view addSubview:m_bar];
    

    return self;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];

    m_activityIndicator=[[UIActivityIndicatorView alloc]init];
    [m_activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleLarge];
    m_activityIndicatorParentView=[[UIView alloc]initWithFrame:self.tableView.bounds];
    [m_activityIndicatorParentView  addSubview:m_activityIndicator];
    [m_activityIndicatorParentView setBackgroundColor:[UIColor  colorWithRed:1 green:.00f blue:.66 alpha:.4]];
    [self.view addSubview:m_activityIndicatorParentView];
    [self.view bringSubviewToFront:m_activityIndicatorParentView];
    [m_activityIndicatorParentView setHidden:YES];
    m_appDelegate =(AppDelegate*)[[UIApplication sharedApplication]delegate];
    ((ViewController*)m_appDelegate->m_viewControllar)->m_chatShareDelegate=self;
    m_data=(AppData*)m_appDelegate->m_data;
    m_xmppEngine=(XmppEgine*)m_appDelegate->m_xmppEngine;
     m_appDelegate->shareToArray =[NSMutableArray  array];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[ShareTableViewCell class] forCellReuseIdentifier:@"shareCellIdentifier"];
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return m_data->registered().size();
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shareCellIdentifier" forIndexPath:indexPath];
    AppData::PartnerInfoType part=m_data->registered()[indexPath.row];
    std::string contactNumber=gloox::JID(part.jid).username();
    std::string contactName=part.name;
    NSString *number=[NSString stringWithUTF8String:contactNumber.c_str()];
    NSString *name=[NSString stringWithUTF8String:contactName.c_str()];
    cell->jid=part.jid;
    
    //set name and number as in contact
    [cell->m_name setText: name];
    [cell->m_number setText: number];
    
 
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    ShareTableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
  
    if(gloox::JID(cell->jid).bare()==m_xmppEngine->getToJID().bare()){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        [m_appDelegate->shareToArray  addObject:@[[NSNumber numberWithInteger: indexPath.row],[NSString stringWithUTF8String: cell->jid.c_str()]]];
        
        
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    /// ShareTableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    NSArray *m;
    for (NSArray* dA in m_appDelegate->shareToArray) {
        if(dA[0]==[NSNumber numberWithInteger:indexPath.row]){
            m=dA;
            break;
        }
        
    }
    [m_appDelegate->shareToArray removeObject:m];
}

-(void)shareData{
    
    if(!m_shareData)
        return;
    
    [m_activityIndicatorParentView setHidden:NO];
    [m_activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[m_activityIndicator.centerXAnchor constraintEqualToAnchor:m_activityIndicatorParentView.centerXAnchor constant:0] setActive:YES];
    [[m_activityIndicator.centerYAnchor constraintEqualToAnchor:m_activityIndicatorParentView.centerYAnchor constant:0]setActive:YES];;
    [m_activityIndicator startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    AppData::MESSAGETYPE msgType=(AppData::MESSAGETYPE)[m_shareData[1] intValue];
    NSString*txt=[[m_shareData[2] pathComponents] firstObject];
  
   
        switch (msgType) {
            case AppData::MESSAGETYPE::FILE_ASSET_ID:{
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
                       
                        self->m_xmppEngine->m_fileTransferManager->sendFile(path.UTF8String,[assett localIdentifier].UTF8String, txt.UTF8String, [path pathExtension].UTF8String);
                       
                        
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
                        m_xmppEngine->m_fileTransferManager->sendFile(path.UTF8String,[assett localIdentifier].UTF8String, txt.UTF8String, [path pathExtension].UTF8String);
                        break;
                        break;
                    }
                    case PHAssetMediaTypeAudio: {
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
                        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/records"];
                        dataPath=[dataPath stringByAppendingPathComponent:txt];
                        
                         self->m_xmppEngine->m_fileTransferManager->sendFile(dataPath.UTF8String,txt.UTF8String, txt.UTF8String, [dataPath pathExtension].UTF8String);
                        break;
                    }
                        
                        
                    default:
                        break;
                }
               
            }
                break;
            case AppData::MESSAGETYPE::FILE_URL:{
                
            }
                break;
            case AppData::MESSAGETYPE::TEXT:{
                for(NSArray* partJID in m_appDelegate->shareToArray){
                   m_xmppEngine->sendMessage(XmppEgine::MESSAGETYPE::TEXT, txt.UTF8String,"",((NSString*) partJID[1]).UTF8String);
                }
                [m_appDelegate->shareToArray removeAllObjects];
                [self doneShare];
            }
            break;
                
            default:
                break;
        }
    
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

-(void)setPartnerSharingDataJID:(gloox::JID)jid{
   
}

-(void)doneShare{
    [m_activityIndicator stopAnimating];
    [m_activityIndicatorParentView removeFromSuperview];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [self.navigationController popViewControllerAnimated:YES];
    ((ViewController*)m_appDelegate->m_viewControllar)->m_chatShareDelegate=nil;
}
@end
