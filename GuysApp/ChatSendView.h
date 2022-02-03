//
//  ChatSendView.h
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/23/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatCollectionViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface ChatSendView : UIView{
    UITextView *m_textVW;
    UIButton *m_sendBTN;
    UIButton *m_hideKeyBTN;
    UIButton *m_photoBTN;
    UIButton *m_micBTN;
    UIView* m_parentView;
    CGRect m_parentViewFullRect;
    ChatNavViewController* m_controller;
}
-(instancetype)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
