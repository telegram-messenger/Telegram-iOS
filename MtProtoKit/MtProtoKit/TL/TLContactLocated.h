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

@class TLGeoPoint;

@interface TLContactLocated : NSObject <TLObject>

@property (nonatomic) int32_t date;
@property (nonatomic) int32_t distance;

@end

@interface TLContactLocated$contactLocated : TLContactLocated

@property (nonatomic) int32_t user_id;
@property (nonatomic, retain) TLGeoPoint *location;

@end

@interface TLContactLocated$contactLocatedPreview : TLContactLocated

@property (nonatomic, retain) NSString *hash;
@property (nonatomic) bool hidden;

@end

