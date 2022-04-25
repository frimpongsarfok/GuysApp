//
//  ContactViewController.m
//  GuysApp
//
//  Created by SARFO KANTANKA FRIMPONG on 12/19/21.
//  Copyright © 2021 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "ContactViewController.h"


@implementation ContactTableViewCell



-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

   self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
   if(!self)
      return self;
    self->m_background=[[UILabel alloc] init];
    self->m_name=[[UILabel alloc]init];
    self->m_number=[[UILabel alloc]init];
   

   
     self->m_background.translatesAutoresizingMaskIntoConstraints=NO;
   
    [self addSubview:m_background];
   [m_background addSubview:m_name];
   [m_background addSubview:m_number];
   
   
   self->m_name.translatesAutoresizingMaskIntoConstraints=NO;
    self->m_number.translatesAutoresizingMaskIntoConstraints=NO;
   
   
  
    //self->m_invite.numberOfLines=0;
   // [self->m_invite setTextAlignment:NSTextAlignmentLeft];
  
   
   [[m_background.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10] setActive:YES];
   [[m_background.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10] setActive:YES];
  [[m_background.topAnchor constraintEqualToAnchor:self.topAnchor constant:10] setActive:YES];
   [[m_background.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10] setActive:YES];
   
   [[self->m_name.widthAnchor constraintEqualToAnchor:m_background.widthAnchor] setActive:YES];
   [[self->m_name.topAnchor constraintEqualToAnchor:m_background.topAnchor constant:5] setActive:YES];
   [[self->m_name.bottomAnchor constraintEqualToAnchor:m_background.bottomAnchor constant:-30] setActive:YES];
   //[[self->m_name.leadingAnchor constraintEqualToAnchor:self->m_background.leadingAnchor constant:self.frame.size.width-50] setActive:YES];
   
   [[self->m_number.widthAnchor constraintEqualToAnchor:m_background.widthAnchor] setActive:YES];

   [[self->m_number.bottomAnchor constraintEqualToAnchor:m_background.bottomAnchor constant:-10] setActive:YES];
   [[m_number.leadingAnchor constraintEqualToAnchor:m_background.leadingAnchor constant:10] setActive:YES];
   
 

   [m_name setTextColor:[UIColor whiteColor]];
   [m_number setTextColor:[UIColor whiteColor]];
  
   [m_number setTextColor:[UIColor lightGrayColor]];
   [m_name   setFont:[UIFont systemFontOfSize:20 weight:UIFontWeightHeavy]];
   
   [m_number   setFont:[UIFont fontWithName:@"GillSans-Semibold" size:17]];
   [m_name setTextAlignment:NSTextAlignmentCenter];
   [self setSelectionStyle:UITableViewCellSelectionStyleNone];
   [self setBackgroundColor:[UIColor clearColor]];
   


   m_name.layer.cornerRadius=23;
   m_name.layer.masksToBounds=YES;
   return self;
}

@end
@interface ContactViewController ()

@end

@implementation ContactViewController
@synthesize m_emailTableView;
@synthesize m_searchContact;
@synthesize  m_mainView;



- (void)viewDidLoad {
    [super viewDidLoad];
    [m_searchContact setDelegate:self];
    m_appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    m_data = (AppData*)m_appDelegate->m_data;
    m_xmppEngine=(XmppEgine*)m_appDelegate->m_xmppEngine;
    m_appDelegate->m_contactViewController=self;
    m_currentRequestedVCardJID={};
    m_activityIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    [m_activityIndicator setHidesWhenStopped: YES];
    m_activityIndicator.center=self.view.center;
    [self.view addSubview:m_activityIndicator];
    [self.view bringSubviewToFront:m_activityIndicator];

    
    
    
    [m_emailTableView setDelegate:self];
    [m_emailTableView setDataSource:self];
    m_emailTableView.separatorColor=[UIColor whiteColor];
 
    [m_emailTableView setAllowsMultipleSelection:NO];
    [m_emailTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [m_emailTableView setRowHeight:100];
    [m_emailTableView registerClass:[ContactTableViewCell self] forCellReuseIdentifier:@"ContactList"];
    
    m_mainView.layer.shadowOffset  = CGSizeZero;
    m_mainView.layer.shadowOpacity = 1.f;
    m_mainView.layer.shadowRadius=5;
    m_mainView.layer.cornerRadius=10;
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    m_currentRequestedVCardJID={};
    
   
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    m_currentRequestedVCardJID={};
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [m_searchContact resignFirstResponder];
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
   
 
   if([searchText length]){
    
      m_searching=true;
    
   }else{
      m_searching=false;
      [m_searchContact resignFirstResponder];
   }
   [m_emailTableView reloadData];
   
    
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        
          return m_data->contact(m_searchContact.text.UTF8String).size();
 
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
         ContactTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ContactList" forIndexPath:indexPath];
         std::string contactNumber=gloox::JID(m_data->contact(m_searchContact.text.UTF8String)[indexPath.row].jid).username();
         std::string contactName=m_data->contact(m_searchContact.text.UTF8String)[indexPath.row].name;
         NSString *number=[NSString stringWithUTF8String:contactNumber.c_str()];
         NSString *name=[NSString stringWithUTF8String:contactName.c_str()];
         cell->jid=m_data->contact(m_searchContact.text.UTF8String)[indexPath.row].jid;
         //set name and number as in contact
         [cell->m_name setText: name];
         [cell->m_number setText: number];
      return cell;
      
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   try {
      
         if([m_searchContact isFirstResponder])
            [m_searchContact resignFirstResponder];
         ContactTableViewCell *cell=(ContactTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
          NSString *name=cell->m_name.text;
       auto tmpPartner=m_data->isPartnerExisting(cell->jid);
         if(tmpPartner.registered){
             std::string noti_node =tmpPartner.noti_pubsub_node;
             if(noti_node.empty()){
                   m_xmppEngine->subscribToNodeItemNoti(gloox::JID(cell->jid));
             }
            [self viewPartnerChat:cell->jid userName:name];
             
         }else {
             if(m_xmppEngine &&m_xmppEngine->clientIsconnected()){
                 [m_activityIndicator startAnimating];
                 m_currentRequestedVCardJID={name.UTF8String,gloox::JID(cell->jid)};
                 m_xmppEngine->fetchVCard(cell->jid);
             }
            

         }
        
      
  
   }catch (NSException *errobjc){
      NSLog(@"row selection err objc %@:",[errobjc description]);
   }
  
}
-(void)viewPartnerChat:(gloox::JID )jid userName:(NSString*)name{
   UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
   
   ChatCollectionViewController *chatCon=[[ChatCollectionViewController alloc]initWithCollectionViewLayout:layout];
   m_appDelegate->m_toJid=[NSString stringWithUTF8String: jid.full().c_str()];
   m_xmppEngine->setToJId(jid);
  
      for (UIViewController *vc in [m_appDelegate->m_chatControllar.navigationController childViewControllers]) {
         [vc dismissViewControllerAnimated:YES completion:nil];
      }
      //[m_appDelegate->m_chatControllar.navigationController pushViewController:chatCon animated:YES];

      ChatNavViewController *nav=[[ChatNavViewController alloc]init];
      [nav setViewControllers:@[chatCon]];
      [self presentViewController:nav animated:YES completion:^{}];
   
 


  

}

-(void)handleVCard:(const gloox::JID) jid fetchResult:(gloox::VCard*) vcard{
        [m_activityIndicator stopAnimating];
        std::cout<<"contact list vcard search :"<<jid.bare()<<std::endl;
        
        if(vcard->jabberid().empty()){
        UIAlertController *unkownPartnerAler=[UIAlertController alertControllerWithTitle:@"Invite" message:@"This Partner is not using GuysApp..." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sendMsg=[UIAlertAction actionWithTitle:@"Send Invite" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {


              if(![MFMessageComposeViewController canSendText]) {
                 return;
              }

              NSArray *recipents = @[[NSString stringWithUTF8String:jid.username().c_str()]];
             NSString *message = [NSString stringWithFormat:@"Im using very excisting messaging app called 'GuysApp' available at apple app store, download now and let chat"];
              MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
              messageController.messageComposeDelegate = self;
              [messageController setRecipients:recipents];
              [messageController setBody:message];

              // Present message view controller on screen
              [self presentViewController:messageController animated:YES completion:nil];

        }];
        UIAlertAction *close=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
        [unkownPartnerAler addAction:sendMsg];
        [unkownPartnerAler addAction:close];
        [self presentViewController:unkownPartnerAler animated:YES completion:nil];

    }else{
        m_data->setPartnerRegistered(jid.bare(), YES);
        [self viewPartnerChat:jid userName:[NSString stringWithUTF8String:std::get<0>(m_currentRequestedVCardJID).c_str()]];
    }
    
  
}

@end

