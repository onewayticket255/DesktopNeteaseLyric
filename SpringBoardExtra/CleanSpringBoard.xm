@interface SBIconListPageControl:UIView
@end

@interface MTLumaDodgePillView:UIView
@end

@interface CSTeachableMomentsContainerView:UIView
@end

@interface NCNotificationListSectionRevealHintView:UIView
@end

%group CleanSpringBoard

    //iPhoneX home indicator
	%hook MTLumaDodgePillView
	-(void)layoutSubviews
	{
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
	-(void)layoutSubviews{
		%orig;
		[self removeFromSuperview];
	}

	%end

    //swipe up tip && ControlCenterGrabber
	%hook CSTeachableMomentsContainerView
	-(void)layoutSubviews{
		%orig;
		[self removeFromSuperview];
	}
	%end

    //No Old Notifications in LC
	%hook NCNotificationListSectionRevealHintView
	-(void)layoutSubviews{
		%orig;
		[self removeFromSuperview];
	}
	%end




%end

%ctor{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/mlyx.neteaselyricsetting.plist"];
	bool isCleanSpringBoardEnabled=[settings objectForKey:@"isCleanSpringBoardEnabled"] ? [[settings objectForKey:@"isCleanSpringBoardEnabled"] boolValue] : 1;
    if(isCleanSpringBoardEnabled){
		%init(CleanSpringBoard);
	}
}