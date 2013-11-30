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


@interface TLRpcDropAnswer : NSObject <TLObject>


@end

@interface TLRpcDropAnswer$rpc_answer_unknown : TLRpcDropAnswer


@end

@interface TLRpcDropAnswer$rpc_answer_dropped_running : TLRpcDropAnswer


@end

@interface TLRpcDropAnswer$rpc_answer_dropped : TLRpcDropAnswer

@property (nonatomic) int64_t msg_id;
@property (nonatomic) int32_t seq_no;
@property (nonatomic) int32_t bytes;

@end

