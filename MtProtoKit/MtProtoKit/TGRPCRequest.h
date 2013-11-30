/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TGTcpWorker.h"

#include <set>
#import "tl/TLMetaScheme.h"

#import "TLSerializationContext.h"

@interface TGRPCRequest : NSObject
{
    std::set<int64_t> _respondsToMessageIds;
}

@property (nonatomic) int testCount;
@property (nonatomic) int transportChannelToken;

@property (nonatomic, strong) TGTcpWorker *worker;

@property (nonatomic) int requestClass;

@property (nonatomic, strong) TLMetaRpc *rawRequest;
@property (nonatomic, strong) id<TLObject> rpcRequest;
@property (nonatomic) int32_t serializedLength;

@property (nonatomic, strong) TLSerializationContext *serializationContext;

@property (nonatomic, copy) void (^completionBlock)(id<TLObject> response, int64_t responseTime, TLError *error);
@property (nonatomic, copy) void (^progressBlock)(int length, float progress);
@property (nonatomic, copy) void (^quickAckBlock)();
@property (nonatomic) bool requiresCompletion;

@property (nonatomic) int token;
@property (nonatomic) bool cancelled;

@property (nonatomic) int64_t runningSessionId;
@property (nonatomic) int runningDatacenterId;
@property (nonatomic) int64_t runningMessageId;
@property (nonatomic) int32_t runningMessageSeqNo;

@property (nonatomic) NSTimeInterval runningStartTime;
@property (nonatomic) NSTimeInterval runningMinStartTime;

@property (nonatomic) int serverFailureCount;
@property (nonatomic) bool confirmed;

@property (nonatomic, strong) id<TGTransport> transport;

- (void)addRespondMessageId:(int64_t)messageId;
- (bool)respondsToMessageId:(int64_t)messageId;

@end
