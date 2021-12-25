//
//  SendSMS.h
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/14/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface AudioRecord : NSObject{
    
    NSMutableDictionary* recordSetting;
   
    AVAudioRecorder *recorder;
    AVAudioSession *audioSession;
    id<AVAudioRecorderDelegate> m_delegate;
   
@public
   BOOL m_cancel;
    NSString* recorderFilePath;
}
-(instancetype)initWithDelegate:(id<AVAudioRecorderDelegate>) delegate;
- (void) startRecording;
- (NSString*) stopRecording;
-(BOOL)cancel;
@end

NS_ASSUME_NONNULL_END
