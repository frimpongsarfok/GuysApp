//
//  Demo.h
//  Guys!
//
//  Created by SARFO KANTANKA FRIMPONG on 7/21/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Demo : UIView{
    UIImageView*  m_imageView;
    UIButton*  m_skip;
    UIButton*  m_next;
    
}
-(instancetype)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
