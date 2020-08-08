#include <Preferences/PSSpecifier.h>
#include <Preferences/PSTableCell.h>
#include <Preferences/PSViewController.h>
#include <Preferences/PSListController.h>

@interface PSSpecifier (PreferenceLoader)
- (void)setupIconImageWithBundle:(NSBundle *)bundle;
- (void)pl_setupIcon;
@end

@interface PSUIPrefsListController : PSListController
- (void)lazyLoadBundle:(PSSpecifier *)sender;
@end

@interface UIImage (PreferenceLoader)
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

%hook PSUIPrefsListController

- (NSArray *)specifiers {
	if (MSHookIvar<id>(self, "_specifiers") != nil) return %orig;
	NSMutableArray *specs = [NSMutableArray new];
	NSString *dir = @"/Library/PreferenceLoader/Preferences";
	for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil]) {
		NSDictionary *entry;
		NSString *path = [dir stringByAppendingPathComponent:file];

		if (![file.pathExtension isEqualToString:@"plist"]) continue;

		entry = [NSDictionary dictionaryWithContentsOfFile:path][@"entry"];

		if (!entry) continue;     

		PSSpecifier *specifier = [%c(PSSpecifier) new];

		for (NSString *key in entry.allKeys) [specifier setProperty:entry[key] forKey:key];
		 
		specifier.name = entry[@"label"];
		specifier.cellType = [PSTableCell cellTypeFromString:entry[@"cell"]];
			
		NSString *bundlePath = [NSString stringWithFormat:@"/Library/PreferenceBundles/%@.bundle", entry[@"bundle"]];
		[specifier setProperty:bundlePath forKey:@"lazy-bundle"];
		specifier.controllerLoadAction = @selector(lazyLoadBundle:);
		
		specifier.target = self;

		MSHookIvar<SEL>(specifier, "getter") = @selector(readPreferenceValue:);
		MSHookIvar<SEL>(specifier, "setter") = @selector(setPreferenceValue: specifier:);
		[specifier pl_setupIcon];
		[specs addObject:specifier];
	}

	if (specs.count == 0) return %orig;
    //sort
	[specs sortUsingComparator:^NSComparisonResult(PSSpecifier *a, PSSpecifier *b) {
		return [a.name localizedCaseInsensitiveCompare:b.name];
	}];
    
	//Group
	[specs insertObject:[%c(PSSpecifier) emptyGroupSpecifier] atIndex:0];
	NSMutableArray *mutableSpecifiers = [%orig mutableCopy];
	
	//index0-1 给Apple
	NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2,[specs count])];
	[mutableSpecifiers insertObjects:specs atIndexes:indexes];
	
	MSHookIvar<NSArray *>(self, "_specifiers") = [mutableSpecifiers copy];
	return MSHookIvar<NSArray *>(self, "_specifiers");
}
%end

%hook PSSpecifier
%new
- (void)pl_setupIcon {
  if (NSBundle *bundle = [NSBundle bundleWithPath:[self propertyForKey:@"lazy-bundle"]]) [self setupIconImageWithBundle:bundle];
  UIImage *icon = [self propertyForKey:@"iconImage"] ? : [UIImage imageWithContentsOfFile:@"/Library/PreferenceLoader/Default.png"];
  //无论什么size的icon保持一致的mask
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(29, 29), NO, [UIScreen mainScreen].scale);
  CGRect iconRect = CGRectMake(0, 0, 29, 29);
  NSBundle *mobileIconsBundle = [NSBundle bundleWithIdentifier:@"com.apple.mobileicons.framework"];
  UIImage *mask = [UIImage imageNamed:@"TableIconMask" inBundle:mobileIconsBundle];
  if (mask) CGContextClipToMask(UIGraphicsGetCurrentContext(), iconRect, mask.CGImage);
  [icon drawInRect:iconRect];
  icon = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  [self setProperty:icon forKey:@"iconImage"];
}

%end

%ctor {
  dlopen("/usr/lib/libprefs.dylib", RTLD_LAZY);
}