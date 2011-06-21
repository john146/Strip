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

- (BOOL)first: (NSString *)firstValue matches: (NSString *)secondValue firstRange: (NSRange)range1 secondRange: (NSRange)range2 {
    BOOL retVal = NO;
    if (1 == [firstValue length]) {
        if (NSOrderedSame == [secondValue compare: firstValue options: NSLiteralSearch range: range1]) {
            if (NSOrderedSame == [secondValue compare: @"0" options: NSLiteralSearch range: range2]) {
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

- (BOOL) firstZone: (NSString *)firstZone matches: (NSString *)secondZone {
    NSRange range1, range2;
    range1.location = 0;
    range1.length = 1;
    range2.location = 1;
    range2.length = 1;
    return [self first: firstZone matches: secondZone firstRange: range1 secondRange: range2];
}

- (BOOL)firstNotZone: (NSString *)firstValue matches: (NSString *)secondValue {
    NSRange range1, range2;
    range1.location = 0;
    range1.length = 1;
    range2.location = 1;
    range2.length = 1;
    return [self first: firstValue matches: secondValue firstRange: range2 secondRange: range1];
}

- (BOOL)match: (NSArray *)components {
    if (2 > [components count]) {
        return NO;
    }
    
    NSString *firstComponent = (NSString *)[components objectAtIndex: 0]; // Meijer ILC
    NSString *secondComponent = (NSString *)[components objectAtIndex: 1]; // PI ILC
    NSArray *firstValues = [firstComponent componentsSeparatedByString: @"-"];
    NSArray *secondValues = [secondComponent componentsSeparatedByString: @"-"];
    return (![self firstZone: [firstValues objectAtIndex: 0] matches: [secondValues objectAtIndex: 0]] ||
         ![self firstNotZone: [firstValues objectAtIndex: 1] matches: [secondValues objectAtIndex: 1]] ||
            ![self firstNotZone: [firstValues objectAtIndex: 2] matches: [secondValues objectAtIndex: 2]]); 
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

@end
