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


@interface TLauth_SentCode : NSObject <TLObject>

@property (nonatomic) bool phone_registered;

@end

@interface TLauth_SentCode$auth_sentCodePreview : TLauth_SentCode

@property (nonatomic, retain) NSString *phone_code_hash;
@property (nonatomic, retain) NSString *phone_code_test;

@end

@interface TLauth_SentCode$auth_sentPassPhrase : TLauth_SentCode


@end

@interface TLauth_SentCode$auth_sentCode : TLauth_SentCode

@property (nonatomic, retain) NSString *phone_code_hash;

@end

