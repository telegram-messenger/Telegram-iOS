/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#ifndef __TG_SECURITY_H_
#define __TG_SECURITY_H_

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
    uint64_t p, q;
} TGFactorizedValue;

TGFactorizedValue getFactorizedValue(uint64_t value);

NSData *computeSHA1(NSData *data);
NSData *computeSHA1ForSubdata(NSData *data, int offset, int length);
int64_t getPublicKeyFingerprint(NSString *publicKey);
NSData *encryptWithRSA(NSString *publicKey, NSData *data);
NSData *encryptWithAES(NSData *data, NSData *key, NSData *iv, bool encrypt);
void encryptWithAESInplace(NSMutableData *data, NSData *key, NSData *iv, bool encrypt);
void encryptWithAESInplaceAndModifyIv(NSMutableData *data, NSData *key, NSMutableData *iv, bool encrypt);
NSData *computeExp(NSData *base, NSData *exp, NSData *modulus);

#ifdef __cplusplus
}
#endif

#endif