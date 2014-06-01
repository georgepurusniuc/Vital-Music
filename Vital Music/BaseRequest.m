//  Created by Silviu Pop on 3/12/13.
//  Copyright (c) 2013 Whatevra. All rights reserved.
//

#import "BaseRequest.h"

@implementation BaseRequest

- (id)init {
    self = [super init];
    if (self != nil) {
        self.showsProgressIndicator = YES;
        self.hasCustomDisplayErrorMessage = NO;
    }
    return self;
}

+ (instancetype)request {
    return [self new];
}

- (NSString *)serverBase {
    return SERVER_BASE_URL;
}

- (NSString *)requestURL {
    return @"";
}

- (NSDictionary *)params {
    return @{};
}

- (RequestMethod)requestMethod {
    return kRequestMethodGET;
}

// Required For Autocomplete

- (void)setSuccess:(RequestSuccessBlock)success {
    _success = success;
}

- (void)setError:(RequestErrorBlock)error {
    _error = error;
}

- (void)setExceptionBlock:(RequestExceptionBlock)exceptionBlock {
    _exceptionBlock = exceptionBlock;
}

- (void)handleException:(NSException *)exception {
    if (self.exceptionBlock) {
        self.exceptionBlock(self,exception);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(request:didThrowException:)]) {
        [self.delegate request:self didThrowException:exception];
    }
}

- (void)handleException:(NSException *)exception forRequest:(id)request andResponse:(id)response {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success Exception."
                                                    message:[NSString stringWithFormat:@"Success exception \n, %@ \nResponse: \n%@", exception.description, response]
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    [self handleException:exception];
}

- (void)handleException:(NSException *)exception forRequest:(id)request andError:(id)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Exception."
                                                    message:[NSString stringWithFormat:@"Success exception \n, %@ \nError: \n%@", exception.description, error]
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    [self handleException:exception];
}

- (id)successData:(id)data {
    return data;
}

- (void)sendRequest:(id)failureBlock successBlock:(id)successBlock path:(NSString *)path {
    switch ([self requestMethod]) {
        case kRequestMethodGET:
            [self.httpClient getPath:path
                          parameters:[self params]
                             success:successBlock
                             failure:failureBlock];
            break;
        case kRequestMethodPOST:
            [self.httpClient postPath:path
                           parameters:[self params]
                              success:successBlock
                              failure:failureBlock];
            break;
        case kRequestMethodPUT:
            [self.httpClient putPath:path
                          parameters:[self params]
                             success:successBlock
                             failure:failureBlock];
            break;
        case kRequestMethodDELETE:
            [self.httpClient deletePath:path
                             parameters:[self params]
                                success:successBlock
                                failure:failureBlock];
            break;
    }
}

- (BOOL)shouldReturnFromNetworkError:(NSError *)error {
    if (error.code == -1009) {
        [UIAlertView showMessage:@"Please check your internet connection." withTitle:@"Network Failure"];
        return YES;
    }
    return NO;
}

- (void)handleError:(NSError *)error {
    if (error.code == -1011) {
        id messageData = [error.userInfo objectForKey:@"NSLocalizedRecoverySuggestion"];
        NSArray *messages = [NSJSONSerialization JSONObjectWithData:[messageData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        
        if (messages.count > 0) {
            if ([messages[0] isKindOfClass:[NSString class]]) {
                [UIAlertView showErrorWithMessage:messages[0]];
                return;
            }
            
            NSString *message = [messages reduceWithBlock:^id(id accumulator, id element) {
                if (element[@"message"]) {
                    return [accumulator stringByAppendingString:[NSString stringWithFormat:@"%@\n",element[@"message"]]];
                } else {
                    return [accumulator stringByAppendingString:[NSString stringWithFormat:@"%@\n",element]];
                }
            } andBase:@""];
            
            [UIAlertView showErrorWithMessage:message];
        } else {
            [UIAlertView showErrorWithMessage:error.description];
        }
    } else {
        [UIAlertView showErrorWithMessage:error.description];
    }
}

- (NSString *)pathWithMemoryParameterforPath:(NSString *)path {
    if ([path containsString:@"?"]) {
        return [path stringByAppendingString:[NSString stringWithFormat:@"&memory=%@", [UIApplication usedMemory]]];
    } else {
        return [path stringByAppendingString:[NSString stringWithFormat:@"?memory=%@", [UIApplication usedMemory]]];
    }
}

- (void)runRequest {
    self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[self serverBase]]];

//    if (ACCEPT_HEADER == 0) {
//        [self.httpClient setDefaultHeader:@"Accept" value:@"application/api.v0"];
//    } else if (ACCEPT_HEADER == 1) {
//        [self.httpClient setDefaultHeader:@"Accept" value:@"application/api.v1"];
//    }
    
    NSString *path = [[self serverBase] stringByAppendingString:[self requestURL]];
    path = [self pathWithMemoryParameterforPath:path];

    UIView *window = [[[UIApplication sharedApplication] delegate] window];
    
    if (self.showsProgressIndicator) {
        [MBProgressHUD showHUDAddedTo:window animated:YES];
    }
    
    __weak BaseRequest *_self = self;
    
    id successBlock = ^(AFHTTPRequestOperation *request, id response){
        @try {

            if (_self.showsProgressIndicator) {
                [MBProgressHUD hideHUDForView:window animated:YES];
            }
            
            id data = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
//            id data = [response JSONValue];
            if (_self.success) {
                _self.success(_self, [_self successData:data]);
            }
            if (_self.delegate && [_self.delegate respondsToSelector:@selector(request:didFinishWithResponse:)]) {
                [_self.delegate request:_self didFinishWithResponse:[_self successData:data]];
            }
        }
        @catch (NSException *exception) {
//            PO(exception)
            [self handleException:exception forRequest:request andResponse:response];
        }
    };
    
    id failureBlock = ^(AFHTTPRequestOperation *request, NSError *error) {
        @try {
            if (_self.showsProgressIndicator) {
                [MBProgressHUD hideHUDForView:window animated:YES];
            }
            
            
            if ([_self shouldReturnFromNetworkError:error]) {
                return;
            }
            
            if (_self.error) {
                _self.error(_self, error);
                if (_self.hasCustomDisplayErrorMessage == NO) {
                    [_self handleError:error];
                }
            } else {
                [_self handleError:error];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
            [self handleException:exception forRequest:request andError:error];
        }
        
    };

    [self sendRequest:failureBlock successBlock:successBlock path:path];
    
}

@end
