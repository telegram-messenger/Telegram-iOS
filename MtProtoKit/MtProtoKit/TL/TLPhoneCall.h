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


@interface TLPhoneCall : NSObject <TLObject>

@property (nonatomic) int64_t n_id;

@end

@interface TLPhoneCall$phoneCallEmpty : TLPhoneCall


@end

@interface TLPhoneCall$phoneCall : TLPhoneCall

@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t user_id;
@property (nonatomic) int32_t callee_id;

@end

