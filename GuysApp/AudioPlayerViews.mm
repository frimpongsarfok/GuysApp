//
//  SMSViewController.m
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/14/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "AudioPlayerViews.h"

@interface AudioPlayerViews ()

@end

@implementation AudioPlayerViews
-(instancetype)initWithFrame:(CGRect)frame filePath:(NSString*)path{
   self=[super initWithFrame:frame];
   [self setBackgroundColor:[UIColor darkGrayColor]];
     NSError *err;
    m_player=[[AVAudioPlayer alloc]initWithData:[NSData dataWithContentsOfFile:path] error:&err];
   
    if(err){
        NSLog(@"Fail to load Audio file%@",err);
        
        m_player=nil;
        
    }else{
         [m_player setDelegate:self];
         [m_player prepareToPlay];
        
    }

   
    
    m_play=[UIButton buttonWithType:UIButtonTypeCustom];
    [m_play setFrame:CGRectMake(0, 0, 150, 130)];
    [m_play  setTintColor:[UIColor whiteColor]];
    [m_play setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
    m_stop=[UIButton buttonWithType:UIButtonTypeCustom];
    [m_stop setFrame:CGRectMake(0,0, 150, 130)];
    [m_stop setImage:[UIImage systemImageNamed:@"stop.fill"] forState:UIControlStateNormal];
    [m_stop  setTintColor:[UIColor whiteColor]];
    
    m_sliderView=[[UISlider alloc]initWithFrame:CGRectMake(self.frame.size.width*.05, self.frame.size.height*.2, self.frame.size.width*.9, 70)];
    [m_sliderView setBackgroundColor:[UIColor lightGrayColor]];
    [m_sliderView.layer setCornerRadius:15];
    [m_sliderView.layer setMasksToBounds:YES];
    [m_sliderView setMaximumValue:m_player.duration];
    [m_sliderView  addTarget:self action:@selector(updatePlayer:) forControlEvents:UIControlEventValueChanged];
    
    
    [m_play addTarget:self action:@selector(playNpause) forControlEvents:UIControlEventTouchUpInside];
    [m_stop  addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
   

    
    [self addSubview:m_play];
    [self addSubview:m_stop];
    [self addSubview:m_sliderView];
    [m_play setTranslatesAutoresizingMaskIntoConstraints:NO];
       //[[m_play.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:70] setActive:YES];
     [[m_play.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-50] setActive:YES];
     [[m_play.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:40] setActive:YES];
    
     [m_stop setTranslatesAutoresizingMaskIntoConstraints:NO];
     [[m_stop.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-50] setActive:YES];
    // [[m_stop.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-70] setActive:YES];
     [[m_stop.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-40] setActive:YES];
    
    [m_sliderView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[m_sliderView.topAnchor constraintEqualToAnchor:self.topAnchor constant:30] setActive:YES];
    [[m_sliderView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20] setActive:YES];
    [[m_sliderView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20] setActive:YES];
     
  
    m_playing=NO;
    return self;
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
    }else{
         [m_play setImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateNormal];
         [m_player play];
         m_playing=YES;
        
       // m_timer=[NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateSlider:) userInfo:nil repeats:YES];
       // dispatch_queue_t t=dispatch_queue_create("cellPlayer", NULL);
       // dispatch_async(t, ^{
            self->m_timer=[NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(updateSlider:) userInfo:nil repeats:YES];
        //});
        
        
        
    }

}
-(void)stop{
    if(!m_player)
        return;
    
    [m_player stop];
    m_playing=NO;
    [m_player setCurrentTime:0];
    [m_play setImage:[UIImage systemImageNamed:@"play"] forState:UIControlStateNormal];
    if(m_timer)
       [m_timer invalidate];
    [m_sliderView setValue:0.0];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if(!m_player)
        return;
    m_playing=NO;
    [m_play setImage:[UIImage systemImageNamed:@"play"] forState:UIControlStateNormal];
    [m_timer invalidate];
    [m_sliderView setValue:0.0];
}

@end
