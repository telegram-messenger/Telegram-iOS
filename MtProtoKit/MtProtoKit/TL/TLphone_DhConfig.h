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


@interface TLphone_DhConfig : NSObject <TLObject>

@property (nonatomic) int32_t g;
@property (nonatomic, retain) NSString *p;
@property (nonatomic) int32_t ring_timeout;
@property (nonatomic) int32_t expires;

@end

@interface TLphone_DhConfig$phone_dhConfig : TLphone_DhConfig


@end

