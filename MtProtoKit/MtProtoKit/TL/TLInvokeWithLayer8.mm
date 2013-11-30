#import "TLInvokeWithLayer8.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInvokeWithLayer8

@synthesize query = _query;

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

@implementation TLInvokeWithLayer8$invokeWithLayer8 : TLInvokeWithLayer8


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe9abd9fd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2d9272ab;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInvokeWithLayer8$invokeWithLayer8 *object = [[TLInvokeWithLayer8$invokeWithLayer8 alloc] init];
    object.query = metaObject->getObject(0x5de9dcb1);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.query;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x5de9dcb1, value));
    }
}


@end

