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

@class TLupdates_Difference;

@interface TLRPCupdates_getDifference : TLMetaRpc

@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t qts;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCupdates_getDifference$updates_getDifference : TLRPCupdates_getDifference


@end

