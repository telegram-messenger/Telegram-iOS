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


@interface TLRPCcontest_saveDeveloperInfo : TLMetaRpc

@property (nonatomic) int32_t vk_id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *phone_number;
@property (nonatomic) int32_t age;
@property (nonatomic, retain) NSString *city;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCcontest_saveDeveloperInfo$contest_saveDeveloperInfo : TLRPCcontest_saveDeveloperInfo


@end

