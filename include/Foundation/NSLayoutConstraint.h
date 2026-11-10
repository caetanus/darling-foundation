// OSXER APPKIT (layout): the NSLayoutConstraint model. The class lives in Foundation because
// binaries built with recent SDKs bind _OBJC_CLASS_$_NSLayoutConstraint from Foundation;
// AppKit re-exports Foundation, so binds from AppKit (older SDKs) find the same class.
// Activation needs NSView and is an AppKit category (AppKit/NSLayoutConstraint.h).
// No layout solver is installed: constraints are stored, frames are left alone.
#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>

@class NSArray, NSString;

typedef float NSLayoutPriority;
typedef NS_ENUM(NSInteger, NSLayoutConstraintOrientation) {
    NSLayoutConstraintOrientationHorizontal = 0,
    NSLayoutConstraintOrientationVertical = 1,
};
typedef NS_ENUM(NSInteger, NSLayoutRelation) {
    NSLayoutRelationLessThanOrEqual = -1, NSLayoutRelationEqual = 0,
    NSLayoutRelationGreaterThanOrEqual = 1
};
typedef NS_ENUM(NSInteger, NSLayoutAttribute) {
    NSLayoutAttributeNotAnAttribute = 0, NSLayoutAttributeLeft = 1,
    NSLayoutAttributeRight, NSLayoutAttributeTop, NSLayoutAttributeBottom,
    NSLayoutAttributeLeading, NSLayoutAttributeTrailing, NSLayoutAttributeWidth,
    NSLayoutAttributeHeight, NSLayoutAttributeCenterX, NSLayoutAttributeCenterY,
    NSLayoutAttributeLastBaseline, NSLayoutAttributeBaseline = NSLayoutAttributeLastBaseline,
    NSLayoutAttributeFirstBaseline = 12
};
enum { NSLayoutPriorityRequired = 1000, NSLayoutPriorityDefaultHigh = 750,
       NSLayoutPriorityDefaultLow = 250, NSLayoutPriorityFittingSizeCompression = 50 };

@interface NSLayoutConstraint : NSObject <NSCoding> {
    id _firstItem, _secondItem;
    NSLayoutAttribute _firstAttribute, _secondAttribute;
    NSLayoutRelation _relation;
    CGFloat _multiplier, _constant;
    NSLayoutPriority _priority;
    NSString *_identifier;
    id _osxerOwner; // the view the constraint is installed on (AppKit), not retained
}
@property(readonly, assign) id firstItem;
@property(readonly, assign) id secondItem;
@property(readonly) NSLayoutAttribute firstAttribute;
@property(readonly) NSLayoutAttribute secondAttribute;
@property(readonly) NSLayoutRelation relation;
@property(readonly) CGFloat multiplier;
@property CGFloat constant;
@property NSLayoutPriority priority;
@property(copy) NSString *identifier;
+ (instancetype)constraintWithItem:(id)first attribute:(NSLayoutAttribute)firstAttribute
    relatedBy:(NSLayoutRelation)relation toItem:(id)second attribute:(NSLayoutAttribute)secondAttribute
    multiplier:(CGFloat)multiplier constant:(CGFloat)constant;
@end

@interface NSLayoutConstraint (OSXEROwner)
- (id)_osxerOwner;
- (void)_osxerSetOwner:(id)view;
@end
