#import "TLDecryptedMessageAction.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLDecryptedMessageAction

@synthesize ttl_seconds = _ttl_seconds;

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

@implementation TLDecryptedMessageAction$decryptedMessageActionSetMessageTTL : TLDecryptedMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa1733aec;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa6a09e05;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDecryptedMessageAction$decryptedMessageActionSetMessageTTL *object = [[TLDecryptedMessageAction$decryptedMessageActionSetMessageTTL alloc] init];
    object.ttl_seconds = metaObject->getInt32(0x401ae035);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.ttl_seconds;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x401ae035, value));
    }
}


@end

