#import <UIKit/UIKit.h>
@interface SBIconListPageControl:UIView
@end

@interface MTLumaDodgePillView:UIView
@end

@interface CSTeachableMomentsContainerView:UIView
@end

@interface NCNotificationListSectionRevealHintView:UIView
@end



//iPhoneX home indicator
%hook MTLumaDodgePillView
-(void)didMoveToWindow{
	%orig;
	[self removeFromSuperview];
}
%end

//Dock 透明
%hook SBDockView
- (void)setBackgroundAlpha:(double)arg1{
	%orig(0);
}
%end

//homescreen翻页点
%hook SBIconListPageControl
-(void)didMoveToWindow{
	%orig;
	[self removeFromSuperview];
}

%end

//swipe up tip && ControlCenterGrabber
%hook CSTeachableMomentsContainerView
-(void)didMoveToWindow{
	%orig;
	[self removeFromSuperview];
}
%end

//No Old Notifications in LC
%hook NCNotificationListSectionRevealHintView
-(void)didMoveToWindow{
	%orig;
	[self removeFromSuperview];
}
%end

%ctor{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/mlyx.neteaselyricsetting.plist"];
	bool isCleanSpringBoardEnabled=[settings objectForKey:@"isCleanSpringBoardEnabled"] ? [[settings objectForKey:@"isCleanSpringBoardEnabled"] boolValue] : 1;
    if(isCleanSpringBoardEnabled){
		%init;
	}
}