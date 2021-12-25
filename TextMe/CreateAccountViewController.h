//
//  CreateAccountViewController.h
//  Guys!
//
//  Created by SARFO KANTANKA FRIMPONG on 7/20/18.
//  Copyright © 2018 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "XmppProtocol.h"
#import "ReadData.h"
@interface CreateAccountViewController :UIViewController<XmppProtocol,UIPickerViewDelegate,UIPickerViewDataSource>{

    NSMutableString* gmail;
    NSMutableString* password;
    AppDelegate *m_delegate;
    XmppEgine *m_xmppEngine;
    AppData * m_data;
    AppDelegate *m_appDelegate;
}

- (IBAction)createAccount:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *m_phoneNumber;
@property (weak, nonatomic) IBOutlet UIPickerView *cntryCodePicker;
@property (weak, nonatomic) IBOutlet UILabel *m_callingCode;

@property (weak, nonatomic) IBOutlet UIButton *m_log;
@property (weak, nonatomic) IBOutlet UIButton *m_delete_account;

@end
