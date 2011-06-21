//
//  Strip.h
//  Strip
//
//  Created by John Ahrens on 6/20/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Strip : NSObject {
    NSString *oldFile;
    NSString *newFile;
}

@property (nonatomic, retain)NSString *oldFile;
@property (nonatomic, retain)NSString *newFile;

-(id)initWithFile: (NSString *)fileName;
-(BOOL)stripFile;

@end
