//
//  CreateAccountViewController.m
//  GuysApp
//
//  Created by SARFO KANTANKA FRIMPONG on 7/20/18.
//  Copyright © 2018 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "CreateAccountViewController.h"
#import <Foundation/Foundation.h>


@interface CreateAccountViewController (){
int result;
}
@end

@implementation CreateAccountViewController{

    NSMutableArray *m_countryCode;
    std::string m_number;
    std::string m_currentCallingCode;
    
}
@synthesize m_phoneNumber;
@synthesize m_callingCode;
@synthesize cntryCodePicker;
@synthesize m_delete_account;
@synthesize m_log;
- (void)viewDidLoad {
    [super viewDidLoad];
    m_phoneNumber.layer.cornerRadius=20;
    m_phoneNumber.layer.masksToBounds=YES;
    [m_phoneNumber setAttributedPlaceholder:[[NSAttributedString alloc]initWithString:@" >>> enter your phone number <<<" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}]];
    m_callingCode.layer.cornerRadius=20;
    m_callingCode.layer.masksToBounds=YES;
    [cntryCodePicker selectRow:0 inComponent:0 animated:YES];
    cntryCodePicker.layer.cornerRadius=20;
    cntryCodePicker.layer.masksToBounds=YES;

    m_delete_account.layer.cornerRadius=20;
    m_delete_account.layer.masksToBounds=YES;
    m_log.layer.cornerRadius=20;
    m_log.layer.masksToBounds=YES;
    
    //get coundry code
    
    m_countryCode=[[NSMutableArray alloc]init];
    m_countryCode=[self countryCodes];
   
   
   NSDictionary *tmpDic=(NSDictionary*)m_countryCode[0];
   [m_callingCode setText:[tmpDic objectForKey:@"code"]];
    
    result=-1;
    m_delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    m_xmppEngine=nullptr;//(XmppEgine*)m_delegate->m_xmppEngine;
    m_data=nullptr;//(AppData*)m_delegate->m_data;
    [self->cntryCodePicker setDataSource:self];
    [self->cntryCodePicker setDelegate:self];
    //if(std::get<0>(m_data->getUserInfo()).size()){
    //    NSString *num=[NSString stringWithUTF8String:gloox::JID(std::get<0>(m_data->getUserInfo())).username().c_str()];
    //    NSString *code= [@"+" stringByAppendingString:[NSString stringWithUTF8String:std::get<1>(m_data->getUserInfo()).c_str()]];
    //    num=[num substringFromIndex:code.length-1];
       // [m_log setHidden:YES];
   //     [m_phoneNumber setText:num];
    //    [m_callingCode setText:code];
      //  [cntryCodePicker setHidden:YES];
   // }else{
      //  [m_delete_account setHidden:YES];
   // }
    

   
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSDictionary *tmpDic=(NSDictionary*)m_countryCode[row];
    [m_callingCode setText:[tmpDic objectForKey:@"code"]];
   
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [m_countryCode count];
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}
-(NSAttributedString*)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary *tmpDic=(NSDictionary*)m_countryCode[row];
    NSAttributedString *attrString=[[NSAttributedString alloc] initWithString: [tmpDic objectForKey:@"name"]attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return attrString;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if([m_phoneNumber isFirstResponder])
        [m_phoneNumber resignFirstResponder];
   
}




/*

-(void)viewDidAppear:(BOOL)animated{
   // if(m_delegate->m_xmppEngine)
}
-(void)viewDidDisappear:(BOOL)animated{
  
}*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)closeViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createAccount:(id)sender {
    if([m_phoneNumber isFirstResponder])
      [ m_phoneNumber resignFirstResponder];
    std::string tmpNumber=std::string();
    for (int idx=0;idx<m_phoneNumber.text.length;idx++) {
        if([m_phoneNumber.text characterAtIndex:idx]>=48 &&[m_phoneNumber.text characterAtIndex:idx]<=57){
            tmpNumber+=[m_phoneNumber.text characterAtIndex:idx];
        }

    }
    NSString * tmpNumberStr=[NSString stringWithUTF8String:tmpNumber.c_str()];
   if ([tmpNumberStr length]<9 ){
    
        UIAlertController *cont=[UIAlertController alertControllerWithTitle:@"GuysApp" message:@"Number is incorrect" preferredStyle:UIAlertControllerStyleAlert];

        [cont addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDestructive handler:nil]];
        [self presentViewController:cont animated:YES completion:nil];
        return;
    }else if([tmpNumberStr length]>10){
        UIAlertController *cont=[UIAlertController alertControllerWithTitle:@"GuysApp" message:@"Number is incorrect,Enter number without extension" preferredStyle:UIAlertControllerStyleAlert];

        [cont addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDestructive handler:nil]];
        [self presentViewController:cont animated:YES completion:nil];
        return;
    }else{
      
         m_phoneNumber.text=tmpNumberStr;
    }
    
   
    //if(![self validateEmail])
      //  return;
 try {
 /*

     NSString *code=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSinceReferenceDate ]* 1000 ];
      code=[code substringFromIndex:[code length]-6 ];
     NSString *number=[[self->m_callingCode.text stringByAppendingString:self->m_phoneNumber.text] stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString * urlStr=[[[@"https://platform.clickatell.com/messages/http/send?apiKey=_Mp9M3CCQJ6Kwpah42Mrzw==&to=" stringByAppendingString:number] stringByAppendingString: @"&content=Tex3tMe+Code+:"]  stringByAppendingString:code];
     NSURL *url=[NSURL URLWithString:urlStr];
 
     NSURLSessionTask *codeTast=[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
         NSError *err=nil;
         NSDictionary *json=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
         NSLog(@"%@",[[json objectForKey:@"messages"][0] objectForKey:@"accepted"]);
         
         //when fail to send code
         if(! [[[json objectForKey:@"messages"][0] objectForKey:@"accepted"] boolValue]){
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertController *cont=[UIAlertController alertControllerWithTitle:@"GuysApp" message:[@"Incorrect Number : " stringByAppendingString:number] preferredStyle:UIAlertControllerStyleAlert];
                 [cont addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDestructive handler:nil]];
                 [self presentViewController:cont animated:YES completion:NULL];
             });

             return;
          
        }else{
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertController *cont=[UIAlertController alertControllerWithTitle:@"GuysApp" message:@"Code is sent to your number" preferredStyle:UIAlertControllerStyleAlert];
                 [cont addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                     textField.placeholder=@"Enter Code here";
                 }];
                 [cont addAction:[UIAlertAction actionWithTitle:@"Verify" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                     UITextField *tf=cont.textFields[0];
                     if(![tf.text isEqualToString:code] ){
                         [tf setText:@""];
                         tf.placeholder=@"Enter Code here";
                         [self presentViewController:cont animated:YES completion:nil];
                         return;
                 }
*/
     
     
                     if(self->m_xmppEngine){
                        
                         delete m_xmppEngine;
                         m_xmppEngine=nullptr;
                        
                      }
     
                     if(m_delegate){
                         m_delegate->m_xmppEngine=nullptr;
                   
                      }
     
                    self->m_xmppEngine=new XmppEgine(self,"www.guysapp.net");
                    self->m_data=new AppData();
                    m_delegate->m_xmppEngine=self->m_xmppEngine;
                    self->m_currentCallingCode=std::string([self->m_callingCode.text substringFromIndex:1].UTF8String);
                    self->m_number=std::string(m_phoneNumber.text.UTF8String);
                    NSLog(@"Creating Account %s",m_number.c_str());
     
     
     

   /*
                 }]];
                 [cont addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                     
                     
                 }]];
                 [self presentViewController:cont animated:YES completion:nil];
                
             });
            
            
         }
        
         
         
    }];
    [codeTast resume];
*/
    } catch (std::exception ex) {
        //std::cout<<ex.what()<<std::endl;
    }catch(NSException *objex){
        NSLog(@"Create Account Exep :%@",[objex description]);
    }
     
    
}


-(void)handleAlreadyRegistered:(const gloox::JID &)from{
    NSLog(@"Account Already Exist");

}
-(void)handleOOB:(const gloox::JID &)from OOB:(const gloox::OOB &)oob{
    
}
-(void)handleRegistrationResult:(const gloox::JID &)from registreationResult:(gloox::RegistrationResult)regResult{
    try {
    


        //std::cout<<"result : "<<regResult<<std::endl;
        if(regResult==0 || regResult==2){
            
                if(self->m_data){
                   // std::string token=std::get<3>(self->m_data->getUserInfo());
                    
                    self->m_data->dropUserData();
                    self->m_data->setAccount(std::string(self->m_currentCallingCode)+std::string(self->m_number+"@www.guysapp.net"),"","", std::string(self->m_currentCallingCode),"","");
                    
                    m_xmppEngine->disconnect();
                 /* REGISTER NEW DEVICE TOKEN
                    NSString * oldToken=[NSString stringWithUTF8String:std::get<3>(self->m_data->getUserInfo()).c_str()];
                    if(![oldToken length] && std::get<0>(self->m_data->getUserInfo()).size()){
                      [self registerDevice:self->m_delegate->m_deviceToken subscriber:[NSString stringWithUTF8String:std::get<0>(self->m_data->getUserInfo()).c_str()]];
                        if([self->m_delegate->m_deviceToken length])
                            self->m_data->setDeviceToken(std::string(self->m_delegate->m_deviceToken.UTF8String));
                }else if(![oldToken isEqualToString:self->m_delegate->m_deviceToken]){
                  
                        //REMOVE OLD DEVICE TOKEN
                       // [self unregisterDevice:oldToken subscriber:[NSString stringWithUTF8String:std::get<0>(self->m_data->getUserInfo()).c_str()]];
                    
                    if(self->m_delegate->m_deviceToken){
                        [self registerDevice:self->m_delegate->m_deviceToken subscriber:[NSString stringWithUTF8String:std::get<0>(self->m_data->getUserInfo()).c_str()]];
                        self->m_data->setDeviceToken(self->m_delegate->m_deviceToken.UTF8String);
                    }
                    //}
                  */
                }
             //dispatch_async(dispatch_get_main_queue(), ^{
               
               // UIStoryboard * tmpStoryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                //UIViewController* viewController=(UIViewController*) [tmpStoryBoard instantiateViewControllerWithIdentifier:@"ViewController"];
                
                //[self.navigationController setNavigationBarHidden:NO animated:YES];
                //[self.tabBarController setHidesBottomBarWhenPushed:NO];
                //[self.navigationController pushViewController:viewController animated:YES];
        
            [self removeFromParentViewController];
           
            //});
            
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *cont=[UIAlertController alertControllerWithTitle:@"Registration" message:@"Error occured try again!!!" preferredStyle:UIAlertControllerStyleAlert];
                
                [cont addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [cont dismissViewControllerAnimated:YES completion:nil];
                }]];
                [self presentViewController:cont animated:YES completion:nil];
                
            });
            
        }

        
    } catch (std::exception excpp) {
        //std::cout<<"registration result err: "<<excpp.what()<<std::endl;
    }
    catch(NSException *exobjc){
        NSLog(@"%@",[exobjc description]);
    }

}

-(void)handleDataForm:(const gloox::JID &)from dataForm:(const gloox::DataForm &)form{
    //std::cout<<"registration datafields received"<<std::endl;
}

-(void)handleRegistrationFields:(const gloox::JID &)jid Fields:(int)fields Instruction:(std::string)instruction{
     //std::cout<<"registration fields received"<<std::endl;
   
    m_xmppEngine->registerAccount(m_currentCallingCode+m_number,m_currentCallingCode+m_number);
}


-(void)connected{
    
    if(m_xmppEngine){
        //std::cout<<"connect : "<<std::endl;
      if(self->m_xmppEngine->registrationMode)
             m_xmppEngine->fetchFields();
    }
}

   
-(void)handleLog:(NSString *)message{
    //std::cout<<[message UTF8String]<<std::endl;
}

-(NSMutableArray*)countryCodes{
   
                     // Country code
   // NSLog(@"%@",[@"~/CountryCode.js" stringByExpandingTildeInPath]);
    NSData *fileData=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CountryCode" ofType:@"js"]];
    if(fileData)
        return [[NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingMutableContainers error:nil] objectForKey:@"countries"];
    else
        return nil;
   
    
}
-(void)onDisconnect:(gloox::ConnectionError)e{
      
        [self->m_delegate->m_viewControllar viewDidLoad];
       
        [self  dismissViewControllerAnimated:YES completion:^{
      
        }];
   
 
}

@end
