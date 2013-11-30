/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TLObject.h"

#import "TGDatacenterContext.h"

@protocol TGTransport;

@protocol TGTransportHandler <NSObject>

@required

- (void)transport:(id<TGTransport>)transport receivedData:(NSData *)data;
- (int64_t)transport:(id<TGTransport>)transport needsToDecodeMessageIdFromPartialData:(NSData *)data;
- (void)transport:(id<TGTransport>)transport updatedRequestProgress:(int64_t)requestMessageId length:(int)length progress:(float)progress;
- (void)transportHasConnectedChannels:(id<TGTransport>)transport;
- (void)transportHasDisconnectedAllChannels:(id<TGTransport>)transport;
- (void)transportReceivedQuickAck:(int)quickAckId;

@end

@protocol TGTransport <NSObject>

@required

@property (nonatomic) int transportRequestClass;

@property (nonatomic, weak) id<TGTransportHandler> transportHandler;

- (void)setDatacenter:(TGDatacenterContext *)datacenter;
- (TGDatacenterContext *)datacenter;

- (void)sendData:(NSData *)data reportAck:(bool)reportAck startResponseTimeout:(bool)startResponseTimeout;

- (void)setTransportTimeout:(NSTimeInterval)timeout;
- (void)suspendTransport;
- (void)resumeTransport;
- (void)forceTransportReconnection;
- (int)connectedChannelToken;

- (void)sendPingData:(NSData *)pingData;

@end
