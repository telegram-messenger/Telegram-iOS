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

@class TLInputPhoneCall;
@class TLPhoneConnection;

@interface TLRPCphone_confirmCall : TLMetaRpc

@property (nonatomic, retain) TLInputPhoneCall *n_id;
@property (nonatomic, retain) NSData *a_or_b;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphone_confirmCall$phone_confirmCall : TLRPCphone_confirmCall


@end

