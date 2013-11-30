/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGTcpChannel.h"

@interface TGSimpleTcpChannel : NSObject <TGTcpChannel>

@property (nonatomic) int channelId;
@property (nonatomic) int channelToken;
@property (nonatomic, weak) id<TGTcpChannelListener> listener;
@property (nonatomic, strong) NSString *hostAddress;
@property (nonatomic) int hostPort;
@property (nonatomic) int timeout;

@end
