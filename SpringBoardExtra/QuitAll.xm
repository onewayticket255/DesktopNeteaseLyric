@interface SBDisplayItem: NSObject
@property (nonatomic,copy,readonly) NSString * bundleIdentifier;              
@end

@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;                                                                                   
@end

@interface SBMediaController : NSObject
@property (nonatomic, weak,readonly) SBApplication * nowPlayingApplication;
+(id)sharedInstance;
@end


@interface SBMainSwitcherViewController: UIViewController
+ (id)sharedInstance;
-(id)recentAppLayouts;
-(void)_deleteAppLayout:(id)arg1 forReason:(long long)arg2;
@end

@interface SBAppLayout:NSObject
@property (nonatomic,copy) NSDictionary * rolesToLayoutItemsMap;                                       
@end

@interface SBSwitcherAppSuggestionContentView: UIView
@end

bool isQuitAllInitialized =0;


%group QuitAll
	%hook SBSwitcherAppSuggestionContentView
	-(void)layoutSubviews{
		%orig;

		if(!isQuitAllInitialized){
			UIButton *blueview = [UIButton buttonWithType:UIButtonTypeCustom];
			blueview.layer.cornerRadius = 12;
			[blueview addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
			[blueview setTitle:@"Kill" forState:0];
			[blueview setTitleColor:[UIColor whiteColor] forState:0];

			blueview.backgroundColor=[[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.233];
			blueview.translatesAutoresizingMaskIntoConstraints = 0;
			[self addSubview:blueview];

			//height
			NSLayoutConstraint *blueHC= [NSLayoutConstraint constraintWithItem:blueview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];  
			[blueview addConstraint:blueHC];
			
			
			//width
			NSLayoutConstraint *blueWC= [NSLayoutConstraint constraintWithItem:blueview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50];  
			[blueview addConstraint:blueWC];
			
			
			//right
			NSLayoutConstraint *blueRC= [NSLayoutConstraint constraintWithItem:blueview attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:blueview.superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10];   
			[blueview.superview addConstraint:blueRC];

			//top 
			NSLayoutConstraint *blueTC= [NSLayoutConstraint constraintWithItem:blueview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:blueview.superview  attribute:NSLayoutAttributeTop multiplier:1.0 constant:20];  
			[blueview.superview addConstraint:blueTC];

			isQuitAllInitialized=1;
		}

	}


	%new
	-(void) buttonClicked:(UIButton*)sender {

		//remove the apps
		SBMainSwitcherViewController *mainSwitcher = [%c(SBMainSwitcherViewController) sharedInstance];
		NSArray *items = mainSwitcher.recentAppLayouts;
			
			
		for(SBAppLayout *item in items) {
			SBDisplayItem *itemz = [item.rolesToLayoutItemsMap objectForKey:@1];
			NSString *bundleID = itemz.bundleIdentifier;
			NSString *nowPlayingID = [[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier];
			if(![bundleID isEqualToString: nowPlayingID]){
				[mainSwitcher _deleteAppLayout:item forReason: 1];
			}				
		}

	}
	%end
%end


%ctor{
 	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/mlyx.neteaselyricsetting.plist"];
	bool isQuitAllEnabled=[settings objectForKey:@"isQuitAllEnabled"] ? [[settings objectForKey:@"isQuitAllEnabled"] boolValue] : 1;
    if(isQuitAllEnabled){
		%init(QuitAll);
	}
}