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

@class TLRpcDropAnswer;

@interface TLRPCrpc_drop_answer : TLMetaRpc

@property (nonatomic) int64_t req_msg_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCrpc_drop_answer$rpc_drop_answer : TLRPCrpc_drop_answer


@end

