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


@interface TLmessages_AffectedHistory : NSObject <TLObject>

@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t seq;
@property (nonatomic) int32_t offset;

@end

@interface TLmessages_AffectedHistory$messages_affectedHistory : TLmessages_AffectedHistory


@end

