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

@class TLPeer;

@interface TLDialog : NSObject <TLObject>

@property (nonatomic, retain) TLPeer *peer;
@property (nonatomic) int32_t top_message;
@property (nonatomic) int32_t unread_count;

@end

@interface TLDialog$dialog : TLDialog


@end

