#import "TLMessageMedia.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLPhoto.h"
#import "TLVideo.h"
#import "TLGeoPoint.h"

@implementation TLMessageMedia


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

@implementation TLMessageMedia$messageMediaEmpty : TLMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3ded6320;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfb752ca9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessageMedia$messageMediaEmpty *object = [[TLMessageMedia$messageMediaEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessageMedia$messageMediaPhoto : TLMessageMedia

@synthesize photo = _photo;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc8c45a2a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x77fb40e5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageMedia$messageMediaPhoto *object = [[TLMessageMedia$messageMediaPhoto alloc] init];
    object.photo = metaObject->getObject(0xe6c52372);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.photo;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xe6c52372, value));
    }
}


@end

@implementation TLMessageMedia$messageMediaVideo : TLMessageMedia

@synthesize video = _video;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa2d24290;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x508c8007;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageMedia$messageMediaVideo *object = [[TLMessageMedia$messageMediaVideo alloc] init];
    object.video = metaObject->getObject(0x2182fe3c);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.video;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x2182fe3c, value));
    }
}


@end

@implementation TLMessageMedia$messageMediaGeo : TLMessageMedia

@synthesize geo = _geo;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x56e0d474;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7f81253;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageMedia$messageMediaGeo *object = [[TLMessageMedia$messageMediaGeo alloc] init];
    object.geo = metaObject->getObject(0x3c803e05);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.geo;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x3c803e05, value));
    }
}


@end

@implementation TLMessageMedia$messageMediaContact : TLMessageMedia

@synthesize phone_number = _phone_number;
@synthesize first_name = _first_name;
@synthesize last_name = _last_name;
@synthesize user_id = _user_id;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5e7d2f39;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbe4c9bee;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageMedia$messageMediaContact *object = [[TLMessageMedia$messageMediaContact alloc] init];
    object.phone_number = metaObject->getString(0xaecb6c79);
    object.first_name = metaObject->getString(0xa604f05d);
    object.last_name = metaObject->getString(0x10662e0e);
    object.user_id = metaObject->getInt32(0xafdf4073);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_number;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xaecb6c79, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.first_name;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xa604f05d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.last_name;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x10662e0e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xafdf4073, value));
    }
}


@end

@implementation TLMessageMedia$messageMediaUnsupported : TLMessageMedia

@synthesize bytes = _bytes;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x29632a36;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8bdaec28;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageMedia$messageMediaUnsupported *object = [[TLMessageMedia$messageMediaUnsupported alloc] init];
    object.bytes = metaObject->getBytes(0xec5ef20a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.bytes;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xec5ef20a, value));
    }
}


@end

