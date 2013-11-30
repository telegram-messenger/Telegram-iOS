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

@class TLSet_client_DH_params_answer;

@interface TLRPCset_client_DH_params : TLMetaRpc

@property (nonatomic, retain) NSData *nonce;
@property (nonatomic, retain) NSData *server_nonce;
@property (nonatomic, retain) NSData *encrypted_data;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCset_client_DH_params$set_client_DH_params : TLRPCset_client_DH_params


@end

