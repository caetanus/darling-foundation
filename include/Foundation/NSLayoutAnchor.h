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

#import <Foundation/NSObject.h>
#import <Foundation/NSLayoutConstraint.h>

// OSXER APPKIT (anchors): immutable constraint factories, without a layout solver.
@interface NSLayoutAnchor<AnchorType> : NSObject <NSCopying, NSCoding> {
    id _osxerAnchorItem; // zeroing weak storage managed with objc_storeWeak
    NSLayoutAttribute _osxerAnchorAttribute;
}
@property(readonly, weak) id item;
@property(readonly, copy) NSString *name;
- (NSLayoutConstraint *)constraintEqualToAnchor:(NSLayoutAnchor<AnchorType> *)anchor;
- (NSLayoutConstraint *)constraintEqualToAnchor:(NSLayoutAnchor<AnchorType> *)anchor constant:(CGFloat)constant;
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(NSLayoutAnchor<AnchorType> *)anchor;
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(NSLayoutAnchor<AnchorType> *)anchor constant:(CGFloat)constant;
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(NSLayoutAnchor<AnchorType> *)anchor;
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(NSLayoutAnchor<AnchorType> *)anchor constant:(CGFloat)constant;
@end

@class NSLayoutXAxisAnchor, NSLayoutYAxisAnchor, NSLayoutDimension;
@interface NSLayoutXAxisAnchor : NSLayoutAnchor<NSLayoutXAxisAnchor *>
@end
@interface NSLayoutYAxisAnchor : NSLayoutAnchor<NSLayoutYAxisAnchor *>
@end
@interface NSLayoutDimension : NSLayoutAnchor<NSLayoutDimension *>
- (NSLayoutConstraint *)constraintEqualToConstant:(CGFloat)constant;
- (NSLayoutConstraint *)constraintLessThanOrEqualToConstant:(CGFloat)constant;
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToConstant:(CGFloat)constant;
- (NSLayoutConstraint *)constraintEqualToAnchor:(NSLayoutDimension *)anchor multiplier:(CGFloat)multiplier;
- (NSLayoutConstraint *)constraintEqualToAnchor:(NSLayoutDimension *)anchor multiplier:(CGFloat)multiplier constant:(CGFloat)constant;
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(NSLayoutDimension *)anchor multiplier:(CGFloat)multiplier;
- (NSLayoutConstraint *)constraintLessThanOrEqualToAnchor:(NSLayoutDimension *)anchor multiplier:(CGFloat)multiplier constant:(CGFloat)constant;
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(NSLayoutDimension *)anchor multiplier:(CGFloat)multiplier;
- (NSLayoutConstraint *)constraintGreaterThanOrEqualToAnchor:(NSLayoutDimension *)anchor multiplier:(CGFloat)multiplier constant:(CGFloat)constant;
@end
