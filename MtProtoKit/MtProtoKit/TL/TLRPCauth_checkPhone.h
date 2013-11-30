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

@class TLauth_CheckedPhone;

@interface TLRPCauth_checkPhone : TLMetaRpc

@property (nonatomic, retain) NSString *phone_number;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCauth_checkPhone$auth_checkPhone : TLRPCauth_checkPhone


@end

