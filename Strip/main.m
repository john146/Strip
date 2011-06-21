//
//  main.m
//  Strip
//
//  Created by John Ahrens on 6/20/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Strip.h"

void usage() {
    NSLog(@"Usage Strip <directory>");
    NSLog(@"\t<directory> is the directory where the csv files are stored");
}

BOOL getFiles(NSString *directory) {
    NSFileManager *manager = [[[NSFileManager alloc] init] autorelease];
    NSError *error = [[[NSError alloc] init] autorelease];
    NSArray *contents = [manager contentsOfDirectoryAtPath: directory error: &error];
    for (id value in contents) {
        NSLog(@"File name: %@", value);
        if (NSOrderedSame == [[value pathExtension] compare:@"csv" options: NSLiteralSearch]) {
            Strip *stripper = [[[Strip alloc] initWithFile: [NSString stringWithFormat: @"%@/%@", directory, value]] autorelease];
            if (![stripper stripFile]) {
                return NO;
            }
        }
    }
    
    return YES;
}

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if (2 != argc) {
        usage();
        exit(1);
    }

    int retVal = 0;
    if (!getFiles([NSString stringWithUTF8String: argv[1]])) {
        retVal = 1;
    }
                   
    [pool drain];
    return retVal;
}

