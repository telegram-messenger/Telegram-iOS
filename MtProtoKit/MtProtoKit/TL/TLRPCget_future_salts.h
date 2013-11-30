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

@class TLFutureSalts;

@interface TLRPCget_future_salts : TLMetaRpc

@property (nonatomic) int32_t num;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCget_future_salts$get_future_salts : TLRPCget_future_salts


@end

