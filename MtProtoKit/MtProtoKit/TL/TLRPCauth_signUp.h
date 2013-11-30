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

@class TLauth_Authorization;

@interface TLRPCauth_signUp : TLMetaRpc

@property (nonatomic, retain) NSString *phone_number;
@property (nonatomic, retain) NSString *phone_code_hash;
@property (nonatomic, retain) NSString *phone_code;
@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCauth_signUp$auth_signUp : TLRPCauth_signUp


@end

