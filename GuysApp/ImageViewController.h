//
//  ImageViewController.h
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/3/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface ImageViewController : UIViewController{
    UIImageView *m_blureImageView;
    UIImageView *m_imageView;
    UIVisualEffectView *m_blur;
    UIButton *m_closeBtn;
    UIBarButtonItem *m_shareBarItem;
    NSArray *m_data;
    NSString* m_to;
    AppDelegate *m_appDelegate;
}


-(void)setImage:(UIImage*)image data:(NSArray*) data;
-(void)setToJID:(NSString*)jid;
@end

NS_ASSUME_NONNULL_END
