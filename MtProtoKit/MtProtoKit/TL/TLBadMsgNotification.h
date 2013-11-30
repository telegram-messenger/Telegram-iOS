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


@interface TLBadMsgNotification : NSObject <TLObject>

@property (nonatomic) int64_t bad_msg_id;
@property (nonatomic) int32_t bad_msg_seqno;
@property (nonatomic) int32_t error_code;

@end

@interface TLBadMsgNotification$bad_msg_notification : TLBadMsgNotification


@end

@interface TLBadMsgNotification$bad_server_salt : TLBadMsgNotification

@property (nonatomic) int64_t n_new_server_salt;

@end

