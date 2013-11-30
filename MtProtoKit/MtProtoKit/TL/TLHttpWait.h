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


@interface TLHttpWait : NSObject <TLObject>

@property (nonatomic) int32_t max_delay;
@property (nonatomic) int32_t wait_after;
@property (nonatomic) int32_t max_wait;

@end

@interface TLHttpWait$http_wait : TLHttpWait


@end

