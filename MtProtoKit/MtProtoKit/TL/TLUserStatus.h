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


@interface TLUserStatus : NSObject <TLObject>


@end

@interface TLUserStatus$userStatusEmpty : TLUserStatus


@end

@interface TLUserStatus$userStatusOnline : TLUserStatus

@property (nonatomic) int32_t expires;

@end

@interface TLUserStatus$userStatusOffline : TLUserStatus

@property (nonatomic) int32_t was_online;

@end

