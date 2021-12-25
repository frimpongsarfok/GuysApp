//
//  MainCameraViewController.h
//  Guys!
//
//  Created by SARFO KANTANKA FRIMPONG on 12/9/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface MainCameraViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
    UIView* m_previewImageView;
    UIImagePickerController *m_imageViewController;
    
    AVCaptureSession*m_session;
    AVCaptureVideoPreviewLayer* m_captureVideoPreviewLayer;
    
    AVCaptureDevice *m_device;
    AVCaptureInput*m_input;
    
    UITapGestureRecognizer* m_tapGesture;
    
}
@property(nonatomic,retain)AVCapturePhotoOutput* m_stillImageOutput;
@property (weak, nonatomic) IBOutlet UIButton *m_captureBtn;
@property (weak, nonatomic) IBOutlet UIButton *m_exit;

@end

NS_ASSUME_NONNULL_END
