#import "TGSecurity.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#include <openssl/bn.h>
#include <openssl/rsa.h>
#include <openssl/evp.h>
#include <openssl/bn.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/sha.h>
#include <openssl/evp.h>
#include <openssl/aes.h>

static void initializeOpenSSL()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        OpenSSL_add_all_algorithms();
        ERR_load_crypto_strings();
    });
}

static int64_t getPrimeFactor(int64_t n)
{
    if (n < 0)
        n = -n;
    
    if (n < 2)
        return n;
    
    if (n % 2 == 0)
        return 2;

    for (int div = 3; n >= div * div; div += 2)
    {
        if (n % div == 0)
            return div;
    }
    
    return n;
}

TGFactorizedValue getFactorizedValue1(int64_t value)
{
    TGFactorizedValue result = {0, 0};
    
    int64_t factor = getPrimeFactor(value);
    result.p = factor;

    if (factor != value)
    {
        result.q = (value / factor);
    }
    
    return result;
}

static inline uint64_t mygcd(uint64_t a, uint64_t b)
{
    while (a != 0 && b != 0)
    {
        while ((b & 1) == 0)
        {
            b >>= 1;
        }
        while ((a & 1) == 0)
        {
            a >>= 1;
        }
        if (a > b)
        {
            a -= b;
        } else
        {
            b -= a;
        }
    }
    return b == 0 ? a : b;
}

TGFactorizedValue getFactorizedValue(uint64_t what)
{
    int it = 0;
    uint64_t g = 0;
    for (int i = 0; i < 3 || it < 1000; i++)
    {
        int q = ((lrand48() & 15) + 17) % what;
        uint64_t x = (int64_t)lrand48 () % (what - 1) + 1, y = x;
        int lim = 1 << (i + 18);
        int j;
        for (j = 1; j < lim; j++)
        {
            ++it;
            unsigned long long a = x, b = x, c = q;
            while (b)
            {
                if (b & 1)
                {
                    c += a;
                    if (c >= what)
                    {
                        c -= what;
                    }
                }
                a += a;
                if (a >= what)
                {
                    a -= what;
                }
                b >>= 1;
            }
            x = c;
            unsigned long long z = x < y ? what + x - y : x - y;
            g = mygcd(z, what);
            if (g != 1)
            {
                break;
            }
            if (!(j & (j - 1)))
            {
                y = x;
            }
        }
        
        if (g > 1 && g < what)
            break;
    }
    
    if (g > 1 && g < what)
    {
        TGLog(@"Factorization for %lld took %d iterations", what, it);
        
        uint64_t p1 = g;
        uint64_t p2 = what / g;
        if (p1 > p2)
        {
            uint64_t tmp = p1;
            p1 = p2;
            p2 = tmp;
        }
        
        TGFactorizedValue result;
        result.p = p1;
        result.q = p2;
        
        return result;
    }
    else
    {
        TGLog(@"**** Factorization failed for %lld", what);
        TGFactorizedValue result;
        result.p = 0;
        result.q = 0;
        return result;
    }
}

NSData *computeSHA1(NSData *data)
{
    uint8_t digest[20];
    SHA1(data.bytes, data.length, digest);
    
    NSData *result = [[NSData alloc] initWithBytes:digest length:20];
    return result;
}

NSData *computeSHA1ForSubdata(NSData *data, int offset, int length)
{
    uint8_t digest[20];
    SHA1(data.bytes + offset, length, digest);
    
    NSData *result = [[NSData alloc] initWithBytes:digest length:20];
    return result;
}

int64_t getPublicKeyFingerprint(NSString *publicKey)
{
    BIO *keyBio = BIO_new(BIO_s_mem());
    const char *keyData = [publicKey UTF8String];
    BIO_write(keyBio, keyData, publicKey.length);
    RSA *rsaKey = PEM_read_bio_RSAPublicKey(keyBio, NULL, NULL, NULL);
    BIO_free(keyBio);
    
    RSA_free(rsaKey);
    return 0;
}

NSData *encryptWithRSA(NSString *publicKey, NSData *data)
{
    BIO *keyBio = BIO_new(BIO_s_mem());
    const char *keyData = [publicKey UTF8String];
    BIO_write(keyBio, keyData, publicKey.length);
    RSA *rsaKey = PEM_read_bio_RSAPublicKey(keyBio, NULL, NULL, NULL);
    BIO_free(keyBio);
    
    BN_CTX *ctx = BN_CTX_new();
    BIGNUM *a = BN_bin2bn(data.bytes, data.length, NULL);
    BIGNUM *r = BN_new();
    
    BN_mod_exp(r, a, rsaKey->e, rsaKey->n, ctx);
    
    unsigned char *res = malloc(BN_num_bytes(r));
    int resLen = BN_bn2bin(r, res);
    
    BN_CTX_free(ctx);
    BN_free(a);
    BN_free(r);
    
    RSA_free(rsaKey);
    
    NSData *result = [[NSData alloc] initWithBytesNoCopy:res length:resLen freeWhenDone:true];
    
    return result;
}

NSData *encryptWithAES(NSData *data, NSData *key, NSData *iv, bool encrypt)
{
    if (key == nil || iv == nil)
    {
        TGLog(@"***** encryptWithAES: empty key or iv");
        return nil;
    }
    AES_KEY aesKey;
    if (encrypt)
        AES_set_encrypt_key(key.bytes, 256, &aesKey);
    else
        AES_set_decrypt_key(key.bytes, 256, &aesKey);
    unsigned char aesIv[AES_BLOCK_SIZE * 2];
    memcpy(aesIv, iv.bytes, iv.length);
    
    uint8_t *resultBytes = malloc(data.length);
    AES_ige_encrypt(data.bytes, resultBytes, data.length, &aesKey, aesIv, encrypt ? AES_ENCRYPT : AES_DECRYPT);
    
    NSData *result = [[NSData alloc] initWithBytesNoCopy:resultBytes length:data.length freeWhenDone:true];
    
    return result;
}

void encryptWithAESInplace(NSMutableData *data, NSData *key, NSData *iv, bool encrypt)
{
    AES_KEY aesKey;
    if (encrypt)
        AES_set_encrypt_key(key.bytes, 256, &aesKey);
    else
        AES_set_decrypt_key(key.bytes, 256, &aesKey);
    unsigned char aesIv[AES_BLOCK_SIZE * 2];
    memcpy(aesIv, iv.bytes, iv.length);
    
    AES_ige_encrypt(data.bytes, (void *)data.bytes, data.length, &aesKey, aesIv, encrypt ? AES_ENCRYPT : AES_DECRYPT);
}

void encryptWithAESInplaceAndModifyIv(NSMutableData *data, NSData *key, NSMutableData *iv, bool encrypt)
{
    AES_KEY aesKey;
    if (encrypt)
        AES_set_encrypt_key(key.bytes, 256, &aesKey);
    else
        AES_set_decrypt_key(key.bytes, 256, &aesKey);
    
    AES_ige_encrypt(data.bytes, (void *)data.bytes, data.length, &aesKey, iv.mutableBytes, encrypt ? AES_ENCRYPT : AES_DECRYPT);
}

NSData *computeExp(NSData *base, NSData *exp, NSData *modulus)
{
    BN_CTX *ctx = BN_CTX_new();
    BIGNUM *bnBase = BN_bin2bn(base.bytes, base.length, NULL);
    BIGNUM *bnExp = BN_bin2bn(exp.bytes, exp.length, NULL);
    BIGNUM *bnModulus = BN_bin2bn(modulus.bytes, modulus.length, NULL);
    
    BIGNUM *bnRes = BN_new();
    
    BN_mod_exp(bnRes, bnBase, bnExp, bnModulus, ctx);
    
    unsigned char *res = malloc(BN_num_bytes(bnRes));
    int resLen = BN_bn2bin(bnRes, res);
    
    BN_CTX_free(ctx);
    BN_free(bnBase);
    BN_free(bnExp);
    BN_free(bnModulus);
    BN_free(bnRes);
    
    NSData *result = [[NSData alloc] initWithBytes:res length:resLen];
    free(res);
    
    return result;
}
