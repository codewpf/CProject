/*
     File: CredentialsManager.m
 Abstract: Manages the list of trusted anchor certificates.
  Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "CredentialsManager.h"

@import Security;

@interface CredentialsManager ()

@property (atomic, strong, readonly ) NSMutableArray *   mutableTrustedAnchors;

@end

@implementation CredentialsManager

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        self->_mutableTrustedAnchors = [[NSMutableArray alloc] init];
        assert(self->_mutableTrustedAnchors != nil);
        [self initCer];
    }
    return self;
}

- (NSArray *)trustedAnchors
{
    NSArray *   result;

    @synchronized (self) {
        result = [self->_mutableTrustedAnchors copy];
        assert(result != nil);
    }
    return result;
}

- (void)initCer
{
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"key" ofType:@"der"];
    NSData *data =  [NSData dataWithContentsOfFile:path];
    BOOL result = [self parseAndInstallCertificateData:data error:&error];
}

- (BOOL)parseAndInstallCertificateData:(NSData *)data error:(__autoreleasing NSError **)errorPtr
{
    NSError *           error;
    SecCertificateRef   anchor;
    
    assert(data != nil);
    // errorPtr may be NULL
    assert([NSThread isMainThread]);
    
    // Try to create a certificate from the data we downloaded.  If that
    // succeeds, tell our delegate.
    
    error = nil;
    anchor = SecCertificateCreateWithData(NULL, (__bridge CFDataRef) data);
    if (error == nil) {
        [self addTrustedAnchor:anchor];
        
    }
    
    // Clean up.
    
    if (anchor != NULL) {
        CFRelease(anchor);
    }
    if ( (error != nil) && (errorPtr != NULL) ) {
        *errorPtr = error;
    }
    
    return (error == nil);
}


- (void)addTrustedAnchor:(SecCertificateRef)newAnchor
{
    BOOL        found;
    
    assert(newAnchor != NULL);
    
    @synchronized (self) {
        
        // Check to see if the certificate is already in the mutableTrustedAnchors 
        // array.  Somewhere along the line SecCertificate refs started supporting 
        // CFEqual, so we can use -indexOfObject:, which is nice.
        
        found = [self->_mutableTrustedAnchors indexOfObject:(__bridge id) newAnchor] != NSNotFound;
        
        // If the new anchor isn't already in the array, add it.
        
        if ( ! found ) {
            NSIndexSet *    indexSet;
            
            indexSet = [NSIndexSet indexSetWithIndex:[self->_mutableTrustedAnchors count]];
            assert(indexSet != nil);
            
            [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:@"trustedAnchors"];
            [self->_mutableTrustedAnchors addObject:(__bridge id)newAnchor];
            [self  didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:@"trustedAnchors"];
        }
    }
}

@end
