/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputPhotoCrop : NSObject <TLObject>


@end

@interface TLInputPhotoCrop$inputPhotoCropAuto : TLInputPhotoCrop


@end

@interface TLInputPhotoCrop$inputPhotoCrop : TLInputPhotoCrop

@property (nonatomic) double crop_left;
@property (nonatomic) double crop_top;
@property (nonatomic) double crop_width;

@end

