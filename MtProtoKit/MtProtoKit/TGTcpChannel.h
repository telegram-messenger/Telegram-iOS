/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    
int TGGenerateChannelToken();
    
#ifdef __cplusplus
}
#endif

@protocol TGTcpChannel;

@protocol TGTcpChannelListener <NSObject>

- (void)dataReceivedFromChannel:(NSData *)data;
- (int64_t)decodeMessageIdFromPartialData:(NSData *)data;
- (void)requestProgressUpdated:(int64_t)requestMessageId length:(int)length progress:(float)progress;
- (void)quiackAckReceived:(int)quickAck;

- (void)channelClosed:(id<TGTcpChannel>)channel;
- (void)channelConnected:(id<TGTcpChannel>)channel;
- (void)channelDisconnected:(id<TGTcpChannel>)channel;

@end

@protocol TGTcpChannel <NSObject>

- (void)setChannelId:(int)channelId;
- (int)channelId;

- (int)channelToken;

- (void)setListener:(id<TGTcpChannelListener>)listener;
- (void)setHostAddress:(NSString *)hostAddress;
- (void)setHostPort:(int)hostPort;
- (void)setTimeout:(int)timeout;

- (void)connect;
- (void)clearFailCountAndConnect;
- (void)disconnect;
- (bool)isConnected;

- (void)sendData:(NSData *)data reportAck:(bool)reportAck startResponseTimeout:(bool)startResponseTimeout;

@end
