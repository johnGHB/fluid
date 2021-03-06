//
//  PKSlashStarState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/TDSlashStarState.h>
#import <ParseKit/TDSlashState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKTypes.h>

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
@end

@implementation TDSlashStarState

- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);
    
    BOOL reportTokens = t.slashState.reportsCommentTokens;
    if (reportTokens) {
        [self resetWithReader:r];
        [self append:'/'];
    }
    
    NSInteger c = cin;
    while (-1 != c) {
        if (reportTokens) {
            [self append:c];
        }
        c = [r read];
        
        if ('*' == c) {
            NSInteger peek = [r read];
            if ('/' == peek) {
                if (reportTokens) {
                    [self append:c];
                    [self append:peek];
                }
                c = [r read];
                break;
            } else if ('*' == peek) {
                [r unread];
            } else {
                if (reportTokens) {
                    [self append:c];
                }
                c = peek;
            }
        }
    }

    if (-1 != c) {
        [r unread];
    }
    
    if (reportTokens) {
        return [PKToken tokenWithTokenType:PKTokenTypeComment stringValue:[self bufferedString] floatValue:0.0];
    } else {
        return [t nextToken];
    }
}

@end
