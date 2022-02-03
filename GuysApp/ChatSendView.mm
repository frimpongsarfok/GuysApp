//
//  ChatSendView.m
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/23/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "ChatSendView.h"

@implementation ChatSendView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame{
 //   m_controller=controllerView;
    
    self=[super initWithFrame:CGRectMake(0, 0, m_controller.view.frame.size.width, 80)];
    //[self setTranslatesAutoresizingMaskIntoConstraints:NO];
    //[self.bottomAnchor constraintEqualToAnchor:m_controller.view.bottomAnchor constant:80];
    //[self addSubview:m_sendBTN];
    //[self addSubview:m_textVW];
    
    //[self setFrame: CGRectMake(0, m_parentViewFullRect.size.height-80, m_parentViewFullRect.size.width, 80)];


    [self setBackgroundColor:[UIColor redColor]];
    
    return self;
    
}

@end
