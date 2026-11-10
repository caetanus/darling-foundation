#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>

enum {
    NSWindowsNTOperatingSystem = 1,
    NSWindows95OperatingSystem,
    NSSolarisOperatingSystem,
    NSHPUXOperatingSystem,
    NSMACHOperatingSystem,
    NSSunOSOperatingSystem,
    NSOSF1OperatingSystem,
    NSAndroidOperatingSystem,
};

typedef struct
{
	NSInteger majorVersion;
	NSInteger minorVersion;
	NSInteger patchVersion;
}
NSOperatingSystemVersion;

typedef NS_ENUM(NSInteger, NSProcessInfoThermalState) {
    NSProcessInfoThermalStateNominal = 0,
    NSProcessInfoThermalStateFair = 1,
    NSProcessInfoThermalStateSerious = 2,
    NSProcessInfoThermalStateCritical = 3,
};

// OSXER APPKIT (activity tokens): the power-policy bits are retained but no
// host power assertion service is connected yet.
typedef NS_OPTIONS(uint64_t, NSActivityOptions) {
    NSActivityIdleDisplaySleepDisabled = 1ULL << 40,
    NSActivityIdleSystemSleepDisabled = 1ULL << 20,
    NSActivitySuddenTerminationDisabled = 1ULL << 14,
    NSActivityAutomaticTerminationDisabled = 1ULL << 15,
    NSActivityUserInitiated = 0x00FFFFFFULL | NSActivityIdleSystemSleepDisabled,
    NSActivityUserInitiatedAllowingIdleSystemSleep = NSActivityUserInitiated & ~NSActivityIdleSystemSleepDisabled,
    NSActivityBackground = 0x000000FFULL,
    NSActivityLatencyCritical = 0xFF00000000ULL
};
@class NSArray, NSString, NSDictionary;

@interface NSProcessInfo : NSObject
{
    NSDictionary *environment; // not used it seems
    NSArray *arguments; // is really mutable
    NSString *hostName; // singly created
    NSString *name; // singly created, but replaceable
    NSInteger automaticTerminationOptOutCounter;
}

+ (NSProcessInfo *)processInfo;

- (NSDictionary *)environment;
- (NSArray *)arguments;
- (NSString *)hostName;
- (NSString *)processName;
- (int)processIdentifier;
- (void)setProcessName:(NSString *)newName;
- (NSString *)globallyUniqueString;
- (NSUInteger)operatingSystem;
- (NSString *)operatingSystemName;
- (NSString *)operatingSystemVersionString;
- (NSUInteger)processorCount;
- (NSUInteger)activeProcessorCount;
- (unsigned long long)physicalMemory;
- (NSTimeInterval)systemUptime;
- (NSOperatingSystemVersion)operatingSystemVersion;
- (BOOL)isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion)version;
@property (readonly) NSProcessInfoThermalState thermalState;

// OSXER APPKIT (activity tokens)
- (id<NSObject>)beginActivityWithOptions:(NSActivityOptions)options reason:(NSString *)reason;
- (void)endActivity:(id<NSObject>)activity;
- (void)performActivityWithOptions:(NSActivityOptions)options reason:(NSString *)reason usingBlock:(void (^)(void))block;
// OSXER APPKIT (public compatibility)
- (void)disableAutomaticTermination:(NSString *)reason;
- (void)enableAutomaticTermination:(NSString *)reason;
- (void)disableSuddenTermination;
- (void)enableSuddenTermination;
@end

@interface NSProcessInfo (NSProcessInfoPlatform)
-(BOOL)isMacCatalystApp;
-(BOOL)isiOSAppOnMac;
@property(readonly, getter=isMacCatalystApp) BOOL macCatalystApp;
@property(readonly, getter=isiOSAppOnMac) BOOL iOSAppOnMac;
@end

#ifdef DARLING
FOUNDATION_EXPORT void __NSInitializeProcess(int argc,const char *argv[]);
#endif

FOUNDATION_EXPORT NSString *const NSProcessInfoThermalStateDidChangeNotification;

// OSXER APPS (power notification)
FOUNDATION_EXPORT NSString *const NSProcessInfoPowerStateDidChangeNotification;
