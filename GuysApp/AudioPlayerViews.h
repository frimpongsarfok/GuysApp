//
//  SMSViewController.h
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/14/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface AudioPlayerViews : UIView<AVAudioPlayerDelegate>{
    AVAudioPlayer* m_player;
    UIButton *m_play;
  
   // UIButton *m_pause;
    UISlider *m_sliderView;
    NSTimer *m_timer;

    AVAudioSession* m_audoSession;
  
    
@public
      BOOL m_playing;
   
}


-(void)playNpause;

//-(void)pause;
-(void)setfilePath:(NSString*)path;
@end

NS_ASSUME_NONNULL_END
