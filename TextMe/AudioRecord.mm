//
//  SendSMS.m
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/14/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "AudioRecord.h"

@implementation AudioRecord
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

-(instancetype)initWithDelegate:(id<AVAudioRecorderDelegate>) delegate{
     self=[super init];
    m_delegate=delegate;
    m_cancel=NO;
    return self;
}
- (void) startRecording{
    

    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/records"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
     [recordSetting setValue:[NSNumber numberWithInt: 320000] forKey:AVEncoderBitRateKey];
    //[recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
   // [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
   // [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    
    
    // Create a new dated file
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    recorderFilePath = [NSString stringWithFormat:@"%@/%@.caf", dataPath, caldate] ;
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    err = nil;
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!recorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
 
       
       
        return;
    }
    
    //prepare to record
    [recorder setDelegate:m_delegate];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.isInputAvailable;
    if (! audioHWAvailable) {
        NSLog(@"Warning: Audio input hardware not available");
  
       
        return;
    }
    
    // start recording
    [recorder record];
    
}

- (NSString*) stopRecording{
    m_cancel=NO;
    [recorder stop];
    [audioSession setCategory:AVAudioSessionCategoryMultiRoute error:nil];
    [audioSession setActive:YES error: nil];
    return recorderFilePath;

    
}

-(BOOL)cancel{
    m_cancel=YES;
    [recorder stop];
   return [recorder deleteRecording];
    
}
@end
