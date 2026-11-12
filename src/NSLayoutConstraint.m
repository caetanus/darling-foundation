/*
 This file is part of Darling.

 Copyright (C) 2019 Lubos Dolezel

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

// OSXER APPKIT (layout): see Foundation/NSLayoutConstraint.h. Replaces a forwarding stub
// that swallowed every message.
#import <Foundation/NSLayoutConstraint.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>

@implementation NSLayoutConstraint
@synthesize firstItem = _firstItem, secondItem = _secondItem;
@synthesize firstAttribute = _firstAttribute, secondAttribute = _secondAttribute;
@synthesize relation = _relation, multiplier = _multiplier;
@synthesize identifier = _identifier;

// OSXER APPKIT (auto layout): changing a constraint schedules its view's layout pass.
- (CGFloat)constant { return _constant; }
- (void)setConstant:(CGFloat)constant
{
    _constant = constant;
    if ([_osxerOwner respondsToSelector:@selector(setNeedsLayout:)]) [_osxerOwner setNeedsLayout:YES];
}
- (NSLayoutPriority)priority { return _priority; }
- (void)setPriority:(NSLayoutPriority)priority
{
    _priority = priority;
    if ([_osxerOwner respondsToSelector:@selector(setNeedsLayout:)]) [_osxerOwner setNeedsLayout:YES];
}

- (id)init
{
    if ((self = [super init])) {
        _priority = NSLayoutPriorityRequired;
        _multiplier = 1;
    }
    return self;
}

- (void)dealloc
{
    [_identifier release];
    [super dealloc];
}

+ (instancetype)constraintWithItem:(id)first attribute:(NSLayoutAttribute)firstAttribute
    relatedBy:(NSLayoutRelation)relation toItem:(id)second attribute:(NSLayoutAttribute)secondAttribute
    multiplier:(CGFloat)multiplier constant:(CGFloat)constant
{
    if (!first || firstAttribute == NSLayoutAttributeNotAnAttribute ||
        (!second && (secondAttribute != NSLayoutAttributeNotAnAttribute ||
          (firstAttribute != NSLayoutAttributeWidth && firstAttribute != NSLayoutAttributeHeight))))
        [NSException raise:NSInvalidArgumentException format:@"Invalid constraint items or attributes"];
    NSLayoutConstraint *result = [[[self alloc] init] autorelease];
    result->_firstItem = first; result->_secondItem = second;
    result->_firstAttribute = firstAttribute; result->_secondAttribute = secondAttribute;
    result->_relation = relation; result->_multiplier = multiplier; result->_constant = constant;
    return result;
}

// Nibs archive constraints with these keys; items are views of the same nib (not retained,
// like the properties). Absent keys keep the defaults of -init.
- (id)initWithCoder:(NSCoder *)coder
{
    if (!(self = [self init])) return nil;
    if (![coder allowsKeyedCoding]) return self;
    _firstItem = [coder decodeObjectForKey:@"NSFirstItem"];
    _secondItem = [coder decodeObjectForKey:@"NSSecondItem"];
    _firstAttribute = [coder decodeIntegerForKey:@"NSFirstAttribute"];
    _secondAttribute = [coder decodeIntegerForKey:@"NSSecondAttribute"];
    _relation = [coder decodeIntegerForKey:@"NSRelation"];
    if ([coder containsValueForKey:@"NSMultiplier"]) _multiplier = [coder decodeDoubleForKey:@"NSMultiplier"];
    if ([coder containsValueForKey:@"NSConstant"]) _constant = [coder decodeDoubleForKey:@"NSConstant"];
    if ([coder containsValueForKey:@"NSPriority"]) _priority = [coder decodeIntegerForKey:@"NSPriority"];
    _identifier = [[coder decodeObjectForKey:@"NSLayoutIdentifier"] copy];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (![coder allowsKeyedCoding]) return;
    [coder encodeConditionalObject:_firstItem forKey:@"NSFirstItem"];
    [coder encodeConditionalObject:_secondItem forKey:@"NSSecondItem"];
    [coder encodeInteger:_firstAttribute forKey:@"NSFirstAttribute"];
    [coder encodeInteger:_secondAttribute forKey:@"NSSecondAttribute"];
    [coder encodeInteger:_relation forKey:@"NSRelation"];
    [coder encodeDouble:_multiplier forKey:@"NSMultiplier"];
    [coder encodeDouble:_constant forKey:@"NSConstant"];
    [coder encodeInteger:(NSInteger)_priority forKey:@"NSPriority"];
    if (_identifier) [coder encodeObject:_identifier forKey:@"NSLayoutIdentifier"];
}

- (id)_osxerOwner { return _osxerOwner; }
- (void)_osxerSetOwner:(id)view { _osxerOwner = view; }

@end
