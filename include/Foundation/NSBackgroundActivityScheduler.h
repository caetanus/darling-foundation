// OSXER APPS (background activity): timer-backed fallback, without power arbitration.
#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>
#import <dispatch/dispatch.h>

typedef NS_ENUM(NSInteger, NSBackgroundActivityResult) {
    NSBackgroundActivityResultFinished = 1,
    NSBackgroundActivityResultDeferred = 2
};
typedef void (^NSBackgroundActivityCompletionHandler)(NSBackgroundActivityResult result);

@interface NSBackgroundActivityScheduler : NSObject {
    NSString *_identifier;
    NSQualityOfService _qualityOfService;
    NSTimeInterval _interval, _tolerance;
    BOOL _repeats, _invalidated, _toleranceSet;
    NSUInteger _generation;
    dispatch_source_t _timer;
    void (^_activity)(NSBackgroundActivityCompletionHandler);
}
- (instancetype)initWithIdentifier:(NSString *)identifier;
@property(readonly, copy) NSString *identifier;
@property NSQualityOfService qualityOfService;
@property BOOL repeats;
@property NSTimeInterval interval;
@property NSTimeInterval tolerance;
@property(readonly) BOOL shouldDefer;
- (void)scheduleWithBlock:(void (^)(NSBackgroundActivityCompletionHandler completion))block;
- (void)invalidate;
@end
