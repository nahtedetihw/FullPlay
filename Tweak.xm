#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <Cephei/HBPreferences.h>

HBPreferences *preferences;
BOOL enable;
double offsetValue;
BOOL enableControlsVibration;

%group FullPlay

%hook UIViewController // hook the base class
- (void)setModalPresentationStyle:(UIModalPresentationStyle)arg1 {
    // point the base class to the swift class (Music. for iOS 12 and MusicApplication. for iOS 13)
    if ([NSStringFromClass([((UIViewController *)self) class])isEqualToString:@"MusicApplication.NowPlayingViewController"] || [NSStringFromClass([((UIViewController *)self) class])isEqualToString:@"Music.NowPlayingViewController"]) {
    
        // set the Modal View Controller to Full Screen
        arg1 = UIModalPresentationOverFullScreen;

        // Add our custom swipe gesture since Full Screen Modal Presentation Style removes the swipe to dismiss
        UISwipeGestureRecognizer *gestureRecognizerDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandlerDown:)];
        [gestureRecognizerDown setDirection:(UISwipeGestureRecognizerDirectionDown)];
        [self.view addGestureRecognizer:gestureRecognizerDown];
        
    }
    
    %orig;
}

// dismiss our view controller inside the swipe gesture method
%new
-(void)swipeHandlerDown:(id)sender {
    if ([NSStringFromClass([((UIViewController *)self) class])isEqualToString:@"MusicApplication.NowPlayingViewController"] || [NSStringFromClass([((UIViewController *)self) class])isEqualToString:@"Music.NowPlayingViewController"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

%end

// add custom vibrations to the Music Controls
%hook UIButton
-(BOOL)beginTrackingWithTouch:(id)arg1 withEvent:(id)arg2 {
    if ([NSStringFromClass([((UIButton *)self) class])isEqualToString:@"Music.NowPlayingTransportButton"] || [NSStringFromClass([((UIButton *)self) class])isEqualToString:@"MusicApplication.NowPlayingTransportButton"]) {
        if (arg1 && enableControlsVibration) {
        AudioServicesPlaySystemSound(1519);
        return %orig;
        }
        return %orig;
    }
    return %orig;
}
%end

// remove the autoresizing mask
%hook UIView
- (void)willMoveToWindow:(id)arg1 {
    if ([NSStringFromClass([((UIView *)self) class])isEqualToString:@"MusicApplication.NowPlayingContentView"] || [NSStringFromClass([((UIView *)self) class])isEqualToString:@"Music.NowPlayingContentView"]) {
        %orig;
        self.autoresizingMask = nil;
    }
    %orig;
}

// add a custom value to the y offset to that users can conform it to their specific devices
- (void)setFrame:(CGRect)arg1 {
    if ([NSStringFromClass([((UIView *)self) class])isEqualToString:@"MusicApplication.NowPlayingContentView"] || [NSStringFromClass([((UIView *)self) class])isEqualToString:@"Music.NowPlayingContentView"]) {
        %orig;
        if (self.frame.size.width>100) {
        arg1 = CGRectMake(self.frame.origin.x, self.frame.origin.y+offsetValue, self.frame.size.width, self.frame.size.height);
        }
        %orig;
    }
    %orig;
}

%end
%end

%ctor {

    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.nahtedetihw.fullplayprefs"];
    [preferences registerBool:&enable default:YES forKey:@"enable"];
    [preferences registerDouble:&offsetValue default:44 forKey:@"offsetValue"];
    [preferences registerBool:&enableControlsVibration default:YES forKey:@"enableControlsVibration"];

    if (enable) {
        %init(FullPlay);
        return;
    }
    return;
}
