/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TGTransport.h"
#import "TGTcpTransport.h"

@class TGTcpWorker;

@protocol TGTcpWorkerHandler <TGTransportHandler>

@required

- (void)workerFailed:(TGTcpWorker *)worker;
- (void)freeWorkerTimedOut:(TGTcpWorker *)worker;

@end

@interface TGTcpWorker : NSObject

@property (nonatomic, weak) id<TGTcpWorkerHandler> workerHandler;
@property (nonatomic, strong) TGTcpTransport *transport;

@property (nonatomic, readonly) int requestClasses;
@property (nonatomic, strong) TGDatacenterContext *datacenter;

@property (nonatomic) bool isBusy;
@property (nonatomic) NSMutableSet *currentRequestTokens;
@property (nonatomic) bool mergingEnabled;

- (id)initWithRequestClasses:(int)requestClasses datacenter:(TGDatacenterContext *)datacenter;

- (void)sendData:(NSData *)data;
- (void)setIsBusy:(bool)isBusy;

- (void)addRequestToken:(int)token;
- (void)removeRequestToken:(int)token;

- (void)prepareForRemoval;

@end
