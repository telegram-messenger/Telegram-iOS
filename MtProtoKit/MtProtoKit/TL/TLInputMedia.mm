#import "TLInputMedia.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputFile.h"
#import "TLInputPhoto.h"
#import "TLInputGeoPoint.h"
#import "TLInputVideo.h"

@implementation TLInputMedia


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

@implementation TLInputMedia$inputMediaEmpty : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9664f57f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb1217c38;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputMedia$inputMediaEmpty *object = [[TLInputMedia$inputMediaEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputMedia$inputMediaUploadedPhoto : TLInputMedia

@synthesize file = _file;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2dc53a7d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7527a4be;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaUploadedPhoto *object = [[TLInputMedia$inputMediaUploadedPhoto alloc] init];
    object.file = metaObject->getObject(0x3187ec9);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.file;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x3187ec9, value));
    }
}


@end

@implementation TLInputMedia$inputMediaPhoto : TLInputMedia

@synthesize n_id = _n_id;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8f2ab2ec;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x813364f2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaPhoto *object = [[TLInputMedia$inputMediaPhoto alloc] init];
    object.n_id = metaObject->getObject(0x7a5601fb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7a5601fb, value));
    }
}


@end

@implementation TLInputMedia$inputMediaGeoPoint : TLInputMedia

@synthesize geo_point = _geo_point;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf9c44144;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x222d34ba;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaGeoPoint *object = [[TLInputMedia$inputMediaGeoPoint alloc] init];
    object.geo_point = metaObject->getObject(0xa4670371);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.geo_point;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xa4670371, value));
    }
}


@end

@implementation TLInputMedia$inputMediaContact : TLInputMedia

@synthesize phone_number = _phone_number;
@synthesize first_name = _first_name;
@synthesize last_name = _last_name;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa6e45987;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcfb05079;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaContact *object = [[TLInputMedia$inputMediaContact alloc] init];
    object.phone_number = metaObject->getString(0xaecb6c79);
    object.first_name = metaObject->getString(0xa604f05d);
    object.last_name = metaObject->getString(0x10662e0e);
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
}


@end

@implementation TLInputMedia$inputMediaUploadedVideo : TLInputMedia

@synthesize file = _file;
@synthesize duration = _duration;
@synthesize w = _w;
@synthesize h = _h;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4847d92a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x73df18bb;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaUploadedVideo *object = [[TLInputMedia$inputMediaUploadedVideo alloc] init];
    object.file = metaObject->getObject(0x3187ec9);
    object.duration = metaObject->getInt32(0xac00f752);
    object.w = metaObject->getInt32(0x98407fc3);
    object.h = metaObject->getInt32(0x27243f49);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.file;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x3187ec9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.duration;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xac00f752, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.w;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x98407fc3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.h;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x27243f49, value));
    }
}


@end

@implementation TLInputMedia$inputMediaUploadedThumbVideo : TLInputMedia

@synthesize file = _file;
@synthesize thumb = _thumb;
@synthesize duration = _duration;
@synthesize w = _w;
@synthesize h = _h;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe628a145;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xacaa44e6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaUploadedThumbVideo *object = [[TLInputMedia$inputMediaUploadedThumbVideo alloc] init];
    object.file = metaObject->getObject(0x3187ec9);
    object.thumb = metaObject->getObject(0x712c4d9);
    object.duration = metaObject->getInt32(0xac00f752);
    object.w = metaObject->getInt32(0x98407fc3);
    object.h = metaObject->getInt32(0x27243f49);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.file;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x3187ec9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.thumb;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x712c4d9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.duration;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xac00f752, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.w;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x98407fc3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.h;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x27243f49, value));
    }
}


@end

@implementation TLInputMedia$inputMediaVideo : TLInputMedia

@synthesize n_id = _n_id;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7f023ae6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb54dc1e3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaVideo *object = [[TLInputMedia$inputMediaVideo alloc] init];
    object.n_id = metaObject->getObject(0x7a5601fb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7a5601fb, value));
    }
}


@end

