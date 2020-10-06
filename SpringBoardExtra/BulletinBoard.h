extern dispatch_queue_t __BBServerQueue;

@interface BBServer : NSObject
- (void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2;
@end

@interface BBAction : NSObject
+ (id)actionWithLaunchBundleID:(id)arg1 callblock:(id)arg2;
@end

@interface BBBulletin : NSObject
@property (nonatomic,copy) NSString *header;  
@property(copy, nonatomic) NSString *title;
@property(copy, nonatomic) NSString *message;
@property(copy, nonatomic) NSString *section;
@property(copy, nonatomic) NSString *sectionID;
@property(copy, nonatomic) NSString *bulletinID; 
@property(retain, nonatomic) NSString *recordID;
@property(copy, nonatomic) NSString *publisherBulletinID;
@property(retain, nonatomic) NSDate *date;
@property(assign, nonatomic) BOOL turnsOnDisplay;
@property(copy, nonatomic) id defaultAction;
@end

@interface BBSectionIcon : NSObject
-(void)addVariant:(id)variant;
@end

@interface BBSectionIconVariant: NSObject
+ (id)variantWithFormat:(long long)arg1 imageName:(id)arg2 inBundle:(id)arg3;
@end