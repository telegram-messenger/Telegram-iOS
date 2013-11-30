/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TGTcpChannel.h"

@interface TGGCDTcpChannel : NSObject <TGTcpChannel>

@property (nonatomic) int channelId;
@property (nonatomic) int channelToken;

@property (nonatomic, strong) NSString *hostAddress;
@property (nonatomic) int hostPort;

@property (nonatomic, weak) id<TGTcpChannelListener> listener;

@end
