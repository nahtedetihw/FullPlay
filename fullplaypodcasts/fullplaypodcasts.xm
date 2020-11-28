#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <Cephei/HBPreferences.h>

HBPreferences *preferences;
BOOL enablePodcasts;
BOOL enableControlsVibrationPodcasts;
BOOL removeGrabberPodcasts;

@interface UIView (FindUIViewController)
- (UIViewController *) firstAvailableViewController;
- (id) traverseResponderChainForViewController;
@end

@implementation UIView (FindUIViewController)
- (UIViewController *) firstAvailableViewController {
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[self traverseResponderChainForViewController];
}

- (id) traverseResponderChainForViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForViewController];
    } else {
        return nil;
    }
}
@end

@interface MusicNowPlayingControlsViewController : UIViewController
@property (nonatomic, strong) UIButton *dismissButton;
@end

%group FullPlayPodcasts

%hook UIViewController // hook the base class
- (void)setModalPresentationStyle:(UIModalPresentationStyle)arg1 {
    // point the base class to the swift class (Music. for iOS 12 and MusicApplication. for iOS 13)
    if ([NSStringFromClass([((UIViewController *)self) class])isEqualToString:@"NowPlayingUI.NowPlayingViewController"]) {
    
        // set the Modal View Controller to Full Screen
        arg1 = UIModalPresentationOverFullScreen;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:tapGesture];
    }
    %orig;
}

// dismiss our view controller inside the swipe gesture method
%new
-(void)handleTapGesture:(id)sender {
    if ([NSStringFromClass([((UIViewController *)self) class])isEqualToString:@"NowPlayingUI.NowPlayingViewController"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
%end

// Remove now player grabber iOS 13
%hook MusicNowPlayingControlsViewController
- (void)viewDidLayoutSubviews {
    %orig;
    if (removeGrabberPodcasts) {
        UIView *chevron = MSHookIvar<UIView *>(self, "chevronView");
        chevron.hidden = YES;
    }
}
%end

// add custom vibrations to the Music Controls
%hook UIButton
-(BOOL)beginTrackingWithTouch:(id)arg1 withEvent:(id)arg2 {
    if ([NSStringFromClass([((UIButton *)self) class])isEqualToString:@"NowPlayingUI.NowPlayingTransportButton"]) {
        if (arg1 && enableControlsVibrationPodcasts) {
        AudioServicesPlaySystemSound(1519);
        return %orig;
        }
        return %orig;
    }
    return %orig;
}
%end
%end

%ctor {

    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.nahtedetihw.fullplayprefs"];
    [preferences registerBool:&enablePodcasts default:NO forKey:@"enablePodcasts"];
    [preferences registerBool:&enableControlsVibrationPodcasts default:NO forKey:@"enableControlsVibrationPodcasts"];
    [preferences registerBool:&removeGrabberPodcasts default:NO forKey:@"removeGrabberPodcasts"];

    if (enablePodcasts) {
        %init(FullPlayPodcasts);
        return;
    }
    return;
}
