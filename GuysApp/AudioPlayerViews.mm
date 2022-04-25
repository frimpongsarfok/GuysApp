//
//  SMSViewController.m
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/14/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "AudioPlayerViews.h"
#import <iostream>

@interface AudioPlayerViews ()

@end

@implementation AudioPlayerViews
-(instancetype)init{
   self=[super init];
    [self.layer setCornerRadius:10];
    [self.layer setMasksToBounds:YES];
     
    m_play=[UIButton buttonWithType:UIButtonTypeCustom];
    [m_play setFrame:CGRectMake(5, 15, 30, 30)];
    [m_play  setTintColor:[UIColor whiteColor]];
    [m_play setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];

    m_sliderView=[[UISlider alloc]initWithFrame:CGRectMake(40, 15, 200, 30)];
    
    [m_sliderView setBackgroundColor:[UIColor whiteColor]];
    [m_sliderView.layer setCornerRadius:15];
    [m_sliderView.layer setMasksToBounds:YES];
    [m_sliderView setNeedsLayout];
    [m_sliderView  addTarget:self action:@selector(updatePlayer:) forControlEvents:UIControlEventValueChanged];
     //[m_sliderView setSelected:YES];
    
    
    [m_play addTarget:self action:@selector(playNpause) forControlEvents:UIControlEventTouchUpInside];
    
    m_audoSession= [AVAudioSession sharedInstance];
   [m_audoSession setCategory:AVAudioSessionCategoryMultiRoute withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
     [self addSubview:m_play];
   
    [self addSubview:m_sliderView];

    m_playing=NO;
    return self;
}
-(void)setfilePath:(NSString*)path{
    NSError *err;
    m_player=[[AVAudioPlayer alloc]initWithData:[NSData dataWithContentsOfFile:path] error:&err];
    if(err){
        NSLog(@"Fail to load Audio file%@",err);
        
        m_player=nil;
        
    }else{
         [m_player setDelegate:self];
         [m_player prepareToPlay];
        [m_sliderView setMaximumValue:m_player.duration];
        
        
    }
   
}
-(void)updatePlayer:(UISlider*)slider{
    if(!m_player)
        return;
    [m_player setCurrentTime:slider.value];
   

}
-(void)updateSlider:(NSTimer*)time{
    if(!m_player)
        return;
    [m_sliderView setValue:m_player.currentTime];
   
}
-(void)playNpause{
     if(!m_player)
         return;
    
    if(m_playing){
        [m_player pause];
        m_playing=NO;
         [m_play setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
         [m_timer invalidate];
        [m_audoSession setActive:NO error: nil];
    }else{
         [m_play setImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateNormal];
         [m_player play];
         m_playing=YES;
        
        [m_audoSession setActive:YES error: nil];
            self->m_timer=[NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(updateSlider:) userInfo:nil repeats:YES];
     
        
        
        
    }

}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if(!m_player)
        return;
    m_playing=NO;
    [m_play setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
    [m_timer invalidate];
    [m_sliderView setValue:0.0];
    [m_audoSession setActive:NO error: nil];
}

@end
