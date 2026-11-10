// OSXER APPS (background activity): dispatch timer fallback. No thermal/power
// policy is available; shouldDefer only reflects invalidation. Completions gate
// subsequent executions, including retries requested with ResultDeferred.
#import <Foundation/NSBackgroundActivityScheduler.h>
#import <Foundation/NSString.h>
#import <Foundation/NSAutoreleasePool.h>
#include <darling/osxer-apps.h>
#include <math.h>
#include <stdint.h>

@implementation NSBackgroundActivityScheduler
- (instancetype)initWithIdentifier:(NSString *)identifier {
    if ((self = [super init])) {
        _identifier = [identifier copy];
        _qualityOfService = NSQualityOfServiceBackground;
    }
    return self;
}
- (NSString *)identifier { return _identifier; }
- (NSQualityOfService)qualityOfService { @synchronized(self) { return _qualityOfService; } }
- (void)setQualityOfService:(NSQualityOfService)value { @synchronized(self) { _qualityOfService = value; } }
- (BOOL)repeats { @synchronized(self) { return _repeats; } }
- (void)setRepeats:(BOOL)value { @synchronized(self) { _repeats = value; } }
- (NSTimeInterval)interval { @synchronized(self) { return _interval; } }
- (void)setInterval:(NSTimeInterval)value { @synchronized(self) { _interval = isfinite(value) && value > 0 ? value : 0; } }
- (NSTimeInterval)tolerance { @synchronized(self) { return _toleranceSet ? _tolerance : _interval / 2; } }
- (void)setTolerance:(NSTimeInterval)value { @synchronized(self) { _tolerance = isfinite(value) && value > 0 ? value : 0; _toleranceSet = YES; } }
- (BOOL)shouldDefer { @synchronized(self) { return _invalidated; } }
- (void)_cancelTimer {
    if (_timer) {
        dispatch_source_cancel(_timer);
        dispatch_release(_timer);
        _timer = NULL;
    }
}
- (void)_armTimer {
    NSUInteger generation = _generation;
    long priority = DISPATCH_QUEUE_PRIORITY_BACKGROUND;
    if (_qualityOfService == NSQualityOfServiceUserInteractive || _qualityOfService == NSQualityOfServiceUserInitiated)
        priority = DISPATCH_QUEUE_PRIORITY_HIGH;
    else if (_qualityOfService == NSQualityOfServiceDefault) priority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
    else if (_qualityOfService == NSQualityOfServiceUtility) priority = DISPATCH_QUEUE_PRIORITY_LOW;
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(priority, 0));
    if (!_timer) return;
    // Bound conversion and prevent a repeating/deferred zero-interval busy loop.
    int64_t delay = (int64_t)(fmin(fmax(_interval, 0.001), (double)(INT64_MAX / NSEC_PER_SEC)) * NSEC_PER_SEC);
    uint64_t leeway = (uint64_t)(fmin([self tolerance], (double)(INT64_MAX / NSEC_PER_SEC)) * NSEC_PER_SEC);
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, delay), DISPATCH_TIME_FOREVER, leeway);
    dispatch_source_set_event_handler(_timer, ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        void (^work)(NSBackgroundActivityCompletionHandler) = nil;
        @synchronized(self) {
            if (!_invalidated && generation == _generation) {
                [self _cancelTimer];
                work = [_activity copy];
            }
        }
        if (work) {
            __block BOOL completed = NO;
            work(^(NSBackgroundActivityResult result) {
                @synchronized(self) {
                    if (completed || _invalidated || generation != _generation) return;
                    completed = YES;
                    if (_repeats || result == NSBackgroundActivityResultDeferred) [self _armTimer];
                    else { [_activity release]; _activity = nil; }
                }
            });
            [work release];
        }
        [pool drain];
    });
    dispatch_resume(_timer);
}
- (void)scheduleWithBlock:(void (^)(NSBackgroundActivityCompletionHandler))block {
    OSXER_APPS_STUB("timer fallback; energy/thermal arbitration unavailable");
    @synchronized(self) {
        [self _cancelTimer];
        ++_generation;
        [_activity release];
        _activity = [block copy];
        _invalidated = NO;
        if (_activity) [self _armTimer];
    }
}
- (void)invalidate {
    @synchronized(self) {
        _invalidated = YES;
        ++_generation;
        [self _cancelTimer];
        [_activity release];
        _activity = nil;
    }
}
- (void)dealloc {
    [self invalidate];
    [_identifier release];
    [super dealloc];
}
@end
