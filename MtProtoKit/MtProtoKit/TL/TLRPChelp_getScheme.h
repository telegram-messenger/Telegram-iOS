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

@class TLScheme;

@interface TLRPChelp_getScheme : TLMetaRpc

@property (nonatomic) int32_t version;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPChelp_getScheme$help_getScheme : TLRPChelp_getScheme


@end

