//
//  Utils.h
//  Dashboard test
//
//  Created by Silviu Pop on 6/20/12.
//  Copyright (c) 2012 Whatevra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>

#define NSStringWithFormat(fmt,...) [NSString stringWithFormat:fmt,##__VA_ARGS__]

@interface UIApplication(helpers)
+ (NSString *)usedMemory;
+ (void)displayMemoryUsage;
@end

@interface NSString(helpers)

- (NSString *)stringByRemovingSuffix:(NSString *)suffix;
+ (NSString *)random;
- (NSString *)simpleHash;
- (BOOL)containsString:(NSString *)substring;
- (BOOL)containsStringCaseInsensitive:(NSString *)substring;
- (BOOL)booleanValue;


@end

typedef void(^voidLambda)(id element);
typedef void(^voidIndexedLambda)(id element, int index);

typedef id(^simpleLambda)(id element);
typedef id(^simpleIndexedLambda)(id element, int index);
typedef id(^doubleLambda)(id accumulator, id element);
typedef id(^zipLambda)(id firstElement, id secondElement);
typedef int(^boolLambda)(id element);

@interface NSArray(lambda)


- (NSMutableArray *)mapArrayUsingBlock:(simpleLambda)lamdba;
- (NSMutableArray *)mapArrayUsingBlockWithIndex:(simpleIndexedLambda)lamdba;
- (void)each:(voidLambda)lambda;
- (void)eachWithIndex:(voidIndexedLambda)lambda;

- (NSMutableArray *)mapArrayUsingSelector:(SEL)selector;
- (NSMutableArray *)filterArrayUsingBlock:(boolLambda)lambda;
- (id)reduceWithBlock:(doubleLambda)lambda andBase:(id)base;
- (id)reduceWithBlock:(doubleLambda)lambda;
- (id)map:(simpleLambda)lambda reduce:(doubleLambda)reduceLambda withBase:(id)base;
- (id)map:(simpleLambda)lambda reduce:(doubleLambda)reduceLambda;
- (id)first;
- (id)pluck:(NSString *)string;
- (id)zip:(NSArray *)otherArray andLambda:(zipLambda)zipLambda;

+ (NSArray *)arrayFromPlistNamed:(NSString *)name;

@end

@interface NSData(DataUtils)

- (NSString *)stringInBase64FromData;

@end

@interface NSString(StringUtils)

- (NSString *)stringInBase64FromString;
+ (NSString *)stringWithStrings:(NSString *)firstArg, ...;
- (NSString *)stringWithStrings:(NSString *)firstArg, ...;
- (NSString *)mimeType;

@end

@interface NSDictionary(DictionaryUtils)

+ (NSDictionary *)dictionaryFromPlistNamed:(NSString *)name;
- (NSArray *)values;
- (NSArray *)keys;

@end

float lerp(float x1,float x2,float t);
float clamp(float x,float min,float max);

@interface UIColor(ColorUtils)
+ (UIColor *)colorWithRed:(int)red green:(int)green blue:(int)blue;
+ (UIColor *)colorWithHex:(unsigned int)hexColor;

@end

@interface UIButton(Helpers)
- (void)setImageNamed:(NSString *)imageName;
- (void)setTitle:(NSString *)title;
@end

@interface UIAlertView(AlertViewUtils)
+ (void)showErrorWithMessage:(NSString *)message;
+ (void)showSuccessWithMessage:(NSString *)message;
+ (void)showMessage:(NSString *)message withTitle:(NSString *)title;
@end

@interface UINib(UNibUtils)
+ (UIView *)instantiateNibNamed:(NSString *)nibName;
@end

