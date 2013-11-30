#import "TLP_Q_inner_data.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLP_Q_inner_data

@synthesize pq = _pq;
@synthesize p = _p;
@synthesize q = _q;
@synthesize nonce = _nonce;
@synthesize server_nonce = _server_nonce;
@synthesize n_new_nonce = _n_new_nonce;

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

@implementation TLP_Q_inner_data$p_q_inner_data : TLP_Q_inner_data


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x83c95aec;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf92ddfed;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLP_Q_inner_data$p_q_inner_data *object = [[TLP_Q_inner_data$p_q_inner_data alloc] init];
    object.pq = metaObject->getBytes(0x77e01332);
    object.p = metaObject->getBytes(0xb91d8925);
    object.q = metaObject->getBytes(0xcd45cb1c);
    object.nonce = metaObject->getBytes(0x48cbe731);
    object.server_nonce = metaObject->getBytes(0xe1dc3f2c);
    object.n_new_nonce = metaObject->getBytes(0xa65868aa);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.pq;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x77e01332, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.p;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xb91d8925, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.q;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xcd45cb1c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.nonce;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x48cbe731, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.server_nonce;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xe1dc3f2c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.n_new_nonce;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xa65868aa, value));
    }
}


@end

