@interface SBIconListPageControl:UIView
@end

%group CleanSpringBoard
	%hook SBDockView
	- (void)setBackgroundAlpha:(double)arg1{
		%orig(0);
	}
	%end

	%hook SBIconListPageControl
	-(void)layoutSubviews{
		%orig;
		self.hidden=1;
		self.userInteractionEnabled=0;
	}

	%end

	%hook SBHomeGrabberView
    - (void)setHidden:(BOOL)arg1 forReason:(id)arg2 withAnimationSettings:(id)arg3 {
        %orig(YES, arg2, arg3);
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