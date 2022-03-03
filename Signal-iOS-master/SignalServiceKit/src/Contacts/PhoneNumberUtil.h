//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import <libPhoneNumber_iOS/NBPhoneNumberUtil.h>

NS_ASSUME_NONNULL_BEGIN

@class PhoneNumberUtilWrapper;

@interface PhoneNumberUtil : NSObject

// This property should only be accessed by Swift.
@property (nonatomic, readonly) PhoneNumberUtilWrapper *phoneNumberUtilWrapper;

+ (BOOL)name:(NSString *)nameString matchesQuery:(NSString *)queryString;

+ (nullable NSString *)countryNameFromCountryCode:(NSString *)countryCode;
+ (NSArray<NSString *> *)countryCodesForSearchTerm:(nullable NSString *)searchTerm;

// Returns the most likely country code for a calling code based on population.
- (NSString *)probableCountryCodeForCallingCode:(NSString *)callingCode;

+ (NSUInteger)translateCursorPosition:(NSUInteger)offset
                                 from:(NSString *)source
                                   to:(NSString *)target
                    stickingRightward:(bool)preferHigh;

+ (nullable NBPhoneNumber *)getExampleNumberForType:(NSString *)regionCode
                                               type:(NBEPhoneNumberType)type
                                  nbPhoneNumberUtil:(NBPhoneNumberUtil *)nbPhoneNumberUtil;

@end

NS_ASSUME_NONNULL_END
