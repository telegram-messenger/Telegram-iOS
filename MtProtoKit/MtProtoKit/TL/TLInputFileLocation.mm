#import "TLInputFileLocation.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInputFileLocation


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

@implementation TLInputFileLocation$inputFileLocation : TLInputFileLocation

@synthesize volume_id = _volume_id;
@synthesize local_id = _local_id;
@synthesize secret = _secret;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x14637196;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcab26024;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputFileLocation$inputFileLocation *object = [[TLInputFileLocation$inputFileLocation alloc] init];
    object.volume_id = metaObject->getInt64(0xdfa67416);
    object.local_id = metaObject->getInt32(0x1a9ce92a);
    object.secret = metaObject->getInt64(0x6706b4b7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.volume_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xdfa67416, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.local_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x1a9ce92a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.secret;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x6706b4b7, value));
    }
}


@end

@implementation TLInputFileLocation$inputVideoFileLocation : TLInputFileLocation

@synthesize n_id = _n_id;
@synthesize access_hash = _access_hash;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3d0364ec;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa76549d4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputFileLocation$inputVideoFileLocation *object = [[TLInputFileLocation$inputVideoFileLocation alloc] init];
    object.n_id = metaObject->getInt64(0x7a5601fb);
    object.access_hash = metaObject->getInt64(0x8f305224);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.access_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x8f305224, value));
    }
}


@end

@implementation TLInputFileLocation$inputEncryptedFileLocation : TLInputFileLocation

@synthesize n_id = _n_id;
@synthesize access_hash = _access_hash;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf5235d55;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xeabc984c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputFileLocation$inputEncryptedFileLocation *object = [[TLInputFileLocation$inputEncryptedFileLocation alloc] init];
    object.n_id = metaObject->getInt64(0x7a5601fb);
    object.access_hash = metaObject->getInt64(0x8f305224);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.access_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x8f305224, value));
    }
}


@end

