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


@interface TLPhoneConnection : NSObject <TLObject>


@end

@interface TLPhoneConnection$phoneConnectionNotReady : TLPhoneConnection


@end

@interface TLPhoneConnection$phoneConnection : TLPhoneConnection

@property (nonatomic, retain) NSString *server;
@property (nonatomic) int32_t port;
@property (nonatomic) int64_t stream_id;

@end

