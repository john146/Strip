//
//  Strip.m
//  Strip
//
//  Created by John Ahrens on 6/20/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import "Strip.h"


@implementation Strip

@synthesize oldFile;
@synthesize newFile;

- (id)initWithFile:(NSString *)fileName {
    if ((self = [super init])) {
        oldFile = fileName;
        NSString *fileName = [oldFile lastPathComponent];
        NSString *path = [oldFile stringByDeletingLastPathComponent];
        NSString *newFileName = [NSString stringWithFormat: @"revised_%@", fileName];
        newFile = [path stringByAppendingPathComponent: newFileName];
    }
    
    return self;
}

- (BOOL)first: (NSString *)firstValue matches: (NSString *)secondValue {
    BOOL retVal = NO;
    if (1 == [firstValue length]) {
        NSRange range, range1;
        range.location = 0;
        range.length = 1;
        range1.location = 1;
        range1.length = 1;
        if (NSOrderedSame == [secondValue compare: firstValue options: NSLiteralSearch range: range]) {
            if (NSOrderedSame == [secondValue compare: @"0" options: NSLiteralSearch range: range1]) {
                retVal = YES;
            }
        } 
    } else if (NSOrderedSame == [firstValue compare: secondValue options: NSLiteralSearch]) {
        retVal = YES;
    } else {
        NSLog(@"%@ not equal to %@", firstValue, secondValue);
    }
    
    return retVal;
}

- (BOOL)match: (NSArray *)components {
    if (2 > [components count]) {
        return NO;
    }
    
    NSString *firstComponent = (NSString *)[components objectAtIndex: 0]; // Meijer ILC
    NSString *secondComponent = (NSString *)[components objectAtIndex: 1]; // PI ILC
    NSArray *firstValues = [firstComponent componentsSeparatedByString: @"-"];
    NSArray *secondValues = [secondComponent componentsSeparatedByString: @"-"];
    return ([self first: [firstValues objectAtIndex: 0] matches: [secondValues objectAtIndex: 0]] &&
         [self first: [firstValues objectAtIndex: 1] matches: [secondValues objectAtIndex: 1]] &&
            [self first: [firstValues objectAtIndex: 2] matches: [secondValues objectAtIndex: 2]]); 
}

- (BOOL)stripFile {
    NSError *error = [[[NSError alloc] init] autorelease];
    NSString *file = [NSString stringWithContentsOfFile: oldFile encoding: NSUTF8StringEncoding error: &error];
    if (!file) {
        NSLog(@"Could not read %@. %@", oldFile, [error localizedDescription]);
        return NO;
    }
    
    NSArray *lines = [file componentsSeparatedByString:@"\n"];
    NSMutableString *output = [[[NSMutableString alloc] init] autorelease];
    NSRange range;
    range.location = 0;
    range.length = 6;
    for (id value in lines) {
        if (NSOrderedSame == [(NSString *)value compare:@"meijer" options: NSLiteralSearch range: range]) {
            [output appendString: [NSString stringWithFormat: @"%@\n", value]];
        } else {
            NSArray *components = [(NSString *)value componentsSeparatedByString: @","];
            if ([self match: components]) {
                [output appendString: [NSString stringWithFormat: @"%@\n", value]];
            }
        }
    }
    
    if (![output writeToFile: newFile atomically: NO encoding: NSUTF8StringEncoding error: &error]) {
        NSLog(@"Error writing file. %@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

- (void)dealloc {
    [oldFile release];
    [newFile release];
    
    [super dealloc];
}

@end
