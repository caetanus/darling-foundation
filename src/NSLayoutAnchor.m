/*
 This file is part of Darling.

 Copyright (C) 2025 Darling Developers

 Darling is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Darling is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Darling.  If not, see <http://www.gnu.org/licenses/>.
*/

// OSXER APPKIT (anchors): Foundation owns the constraint model; AppKit owns layout.
#import <Foundation/NSLayoutAnchor.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import <math.h>
#import <objc/runtime.h>

@implementation NSLayoutAnchor
- (id)_osxerInitWithItem:(id)item attribute:(NSLayoutAttribute)attribute {
    if ((self = [super init])) { objc_storeWeak(&_osxerAnchorItem, item); _osxerAnchorAttribute = attribute; }
    return self;
}
- (id)item { return objc_loadWeak(&_osxerAnchorItem); }
- (void)dealloc { objc_storeWeak(&_osxerAnchorItem, nil); [super dealloc]; }
- (NSString *)name {
    return [NSString stringWithFormat:@"%@:attribute=%ld", [[self item] class], (long)_osxerAnchorAttribute];
}
- (id)copyWithZone:(NSZone *)zone { return [self retain]; }
- (id)initWithCoder:(NSCoder *)coder {
    return [self _osxerInitWithItem:[coder decodeObjectForKey:@"OSXERAnchorItem"]
                       attribute:[coder decodeIntegerForKey:@"OSXERAnchorAttribute"]];
}
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeConditionalObject:[self item] forKey:@"OSXERAnchorItem"];
    [coder encodeInteger:_osxerAnchorAttribute forKey:@"OSXERAnchorAttribute"];
}
- (NSLayoutConstraint *)_osxerConstraint:(NSLayoutAnchor *)other relation:(NSLayoutRelation)relation
                            multiplier:(CGFloat)multiplier constant:(CGFloat)constant {
    BOOL dimension = [self isKindOfClass:[NSLayoutDimension class]];
    Class family = dimension ? [NSLayoutDimension class] :
        ([self isKindOfClass:[NSLayoutXAxisAnchor class]] ? [NSLayoutXAxisAnchor class] : [NSLayoutYAxisAnchor class]);
    if (other && ![other isKindOfClass:[NSLayoutAnchor class]])
        [NSException raise:NSInvalidArgumentException format:@"Expected a layout anchor"];
    id firstItem = [self item], secondItem = [other item];
    if (!firstItem || !isfinite(multiplier) || !isfinite(constant) ||
        (other && (![other isKindOfClass:family] || !secondItem)) || (!other && !dimension))
        [NSException raise:NSInvalidArgumentException format:@"Incompatible layout anchors"];
    if (other && family == [NSLayoutXAxisAnchor class]) {
        BOOL directional = _osxerAnchorAttribute == NSLayoutAttributeLeading || _osxerAnchorAttribute == NSLayoutAttributeTrailing;
        BOOL absolute = _osxerAnchorAttribute == NSLayoutAttributeLeft || _osxerAnchorAttribute == NSLayoutAttributeRight;
        BOOL otherDirectional = other->_osxerAnchorAttribute == NSLayoutAttributeLeading || other->_osxerAnchorAttribute == NSLayoutAttributeTrailing;
        BOOL otherAbsolute = other->_osxerAnchorAttribute == NSLayoutAttributeLeft || other->_osxerAnchorAttribute == NSLayoutAttributeRight;
        if ((directional && otherAbsolute) || (absolute && otherDirectional))
            [NSException raise:NSInvalidArgumentException format:@"Cannot mix directional and absolute anchors"];
    }
    return [NSLayoutConstraint constraintWithItem:firstItem attribute:_osxerAnchorAttribute
        relatedBy:relation toItem:secondItem
        attribute:other ? other->_osxerAnchorAttribute : NSLayoutAttributeNotAnAttribute
        multiplier:multiplier constant:constant];
}
- (NSLayoutConstraint *)constraintEqualToAnchor:(NSLayoutAnchor *)anchor {
    return [self constraintEqualToAnchor:anchor constant:0];
}
- (NSLayoutConstraint *)constraintEqualToAnchor:(NSLayoutAnchor *)anchor constant:(CGFloat)constant {
    if (!anchor) [NSException raise:NSInvalidArgumentException format:@"Missing layout anchor"];
    return [self _osxerConstraint:anchor relation:NSLayoutRelationEqual multiplier:1 constant:constant];
}
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(NSLayoutAnchor *)anchor {
    return [self constraintLessThanOrEqualToAnchor:anchor constant:0];
}
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(NSLayoutAnchor *)anchor constant:(CGFloat)constant {
    if (!anchor) [NSException raise:NSInvalidArgumentException format:@"Missing layout anchor"];
    return [self _osxerConstraint:anchor relation:NSLayoutRelationLessThanOrEqual multiplier:1 constant:constant];
}
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(NSLayoutAnchor *)anchor {
    return [self constraintGreaterThanOrEqualToAnchor:anchor constant:0];
}
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(NSLayoutAnchor *)anchor constant:(CGFloat)constant {
    if (!anchor) [NSException raise:NSInvalidArgumentException format:@"Missing layout anchor"];
    return [self _osxerConstraint:anchor relation:NSLayoutRelationGreaterThanOrEqual multiplier:1 constant:constant];
}
@end
@implementation NSLayoutXAxisAnchor
@end
@implementation NSLayoutYAxisAnchor
@end
@implementation NSLayoutDimension
- (NSLayoutConstraint *)constraintEqualToConstant:(CGFloat)constant {
    return [self _osxerConstraint:nil relation:NSLayoutRelationEqual multiplier:1 constant:constant];
}
- (NSLayoutConstraint *)constraintEqualToAnchor:(NSLayoutDimension *)anchor multiplier:(CGFloat)multiplier {
    return [self constraintEqualToAnchor:anchor multiplier:multiplier constant:0];
}
- (NSLayoutConstraint *)constraintEqualToAnchor:(NSLayoutDimension *)anchor multiplier:(CGFloat)multiplier constant:(CGFloat)constant {
    if (!anchor) [NSException raise:NSInvalidArgumentException format:@"Missing dimension anchor"];
    return [self _osxerConstraint:anchor relation:NSLayoutRelationEqual multiplier:multiplier constant:constant];
}
- (NSLayoutConstraint *)constraintLessThanOrEqualToConstant:(CGFloat)constant {
    return [self _osxerConstraint:nil relation:NSLayoutRelationLessThanOrEqual multiplier:1 constant:constant];
}
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(NSLayoutDimension *)anchor multiplier:(CGFloat)multiplier {
    return [self constraintLessThanOrEqualToAnchor:anchor multiplier:multiplier constant:0];
}
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(NSLayoutDimension *)anchor multiplier:(CGFloat)multiplier constant:(CGFloat)constant {
    if (!anchor) [NSException raise:NSInvalidArgumentException format:@"Missing dimension anchor"];
    return [self _osxerConstraint:anchor relation:NSLayoutRelationLessThanOrEqual multiplier:multiplier constant:constant];
}
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToConstant:(CGFloat)constant {
    return [self _osxerConstraint:nil relation:NSLayoutRelationGreaterThanOrEqual multiplier:1 constant:constant];
}
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(NSLayoutDimension *)anchor multiplier:(CGFloat)multiplier {
    return [self constraintGreaterThanOrEqualToAnchor:anchor multiplier:multiplier constant:0];
}
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(NSLayoutDimension *)anchor multiplier:(CGFloat)multiplier constant:(CGFloat)constant {
    if (!anchor) [NSException raise:NSInvalidArgumentException format:@"Missing dimension anchor"];
    return [self _osxerConstraint:anchor relation:NSLayoutRelationGreaterThanOrEqual multiplier:multiplier constant:constant];
}
@end
