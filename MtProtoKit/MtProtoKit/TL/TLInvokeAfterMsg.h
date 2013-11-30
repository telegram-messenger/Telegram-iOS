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


@interface TLInvokeAfterMsg : NSObject <TLObject>

@property (nonatomic) int64_t msg_id;
@property (nonatomic) id<NSObject> query;

@end

@interface TLInvokeAfterMsg$invokeAfterMsg : TLInvokeAfterMsg


@end

