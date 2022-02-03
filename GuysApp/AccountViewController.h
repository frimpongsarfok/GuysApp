//
//  AccountViewController.h
//  GuysApp
//
//  Created by SARFO KANTANKA FRIMPONG on 7/22/18.
//  Copyright © 2018 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "XmppProtocol.h"
#import "XmppEngine.h"
#import "ReadData.h"

enum SIDES{SIDE_1,SIDE_2,SIDE_3,SIDE_4};
@interface AccountViewController : UIViewController<UIGestureRecognizerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    UITapGestureRecognizer *m_usrDPGesture;
    UIActivityIndicatorView* m_indicator;
    BOOL m_fromCamera;
    bool  m_deleteAccountVerified;
    AppDelegate * m_appDelegate;
    XmppEgine *m_xmppEngine;
    AppData * m_data;
}
@property (weak, nonatomic) IBOutlet UITextField *m_lname;
@property (weak, nonatomic) IBOutlet UITextField *m_fname;
@property (weak, nonatomic) IBOutlet UIImageView *m_usrDP;
@property (weak, nonatomic) IBOutlet UIButton *m_accountBtn;
@property (weak, nonatomic) IBOutlet UIButton *m_privacyBtn;
@property (weak, nonatomic) IBOutlet UIButton *m_deleteAcount;
@property (weak, nonatomic) IBOutlet UITextField *m_emailAdress;
@property (weak, nonatomic) IBOutlet UITextField *m_phoneNum;
@property (weak, nonatomic) IBOutlet UITextField *m_fullname;

@property (weak, nonatomic) IBOutlet UISwitch *m_notificationSwitch;
-(void)textChanged:(UITextField *)textField;

@end
