#import "TLauth_SentCode.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLauth_SentCode

@synthesize phone_registered = _phone_registered;

- (int32_t)TLconstructorSignature
{
    TGLog(@"constructorSignature is not implemented for base type");
    return 0;
}

- (int32_t)TLconstructorName
{
    TGLog(@"constructorName is not implemented for base type");
    return 0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLauth_SentCode$auth_sentCodePreview : TLauth_SentCode

@synthesize phone_code_hash = _phone_code_hash;
@synthesize phone_code_test = _phone_code_test;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3cf5727a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe3ffd86f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLauth_SentCode$auth_sentCodePreview *object = [[TLauth_SentCode$auth_sentCodePreview alloc] init];
    object.phone_registered = metaObject->getBool(0xd2179e1d);
    object.phone_code_hash = metaObject->getString(0xd4dfef1b);
    object.phone_code_test = metaObject->getString(0x9a6ac976);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.phone_registered;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xd2179e1d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_code_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xd4dfef1b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_code_test;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x9a6ac976, value));
    }
}


@end

@implementation TLauth_SentCode$auth_sentPassPhrase : TLauth_SentCode


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1a1e1fae;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x91c3e08;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLauth_SentCode$auth_sentPassPhrase *object = [[TLauth_SentCode$auth_sentPassPhrase alloc] init];
    object.phone_registered = metaObject->getBool(0xd2179e1d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.phone_registered;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xd2179e1d, value));
    }
}


@end

@implementation TLauth_SentCode$auth_sentCode : TLauth_SentCode

@synthesize phone_code_hash = _phone_code_hash;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2215bcbd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xca956015;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLauth_SentCode$auth_sentCode *object = [[TLauth_SentCode$auth_sentCode alloc] init];
    object.phone_registered = metaObject->getBool(0xd2179e1d);
    object.phone_code_hash = metaObject->getString(0xd4dfef1b);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.phone_registered;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xd2179e1d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_code_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xd4dfef1b, value));
    }
}


@end

