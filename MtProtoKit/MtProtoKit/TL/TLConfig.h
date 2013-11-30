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


@interface TLConfig : NSObject <TLObject>

@property (nonatomic) int32_t date;
@property (nonatomic) bool test_mode;
@property (nonatomic) int32_t this_dc;
@property (nonatomic, retain) NSArray *dc_options;
@property (nonatomic) int32_t chat_size_max;

@end

@interface TLConfig$config : TLConfig


@end

