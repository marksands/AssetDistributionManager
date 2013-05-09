//
//  ADMUntar.m
//  ADMContentLoader
//
//  Created by Mark Sands on 4/28/13.
//  Copyright (c) 2013 Mark Sands. All rights reserved.
//

#import "ADMUntar.h"

#define kTarBlockSize 512
#define kTarTypePosition 156
#define kTarNamePosition 0
#define kTarNameSize 100
#define kTarSizePosition 124
#define kTarSizeSize 12
#define kTarMaxBlockLoadInMemory 100

@interface NSFileManager (Untar)
- (BOOL)createFilesAndDirectoriesAtPath:(NSString *)path withTarObject:(id)object size:(unsigned long long)size error:(NSError * __autoreleasing *)error;
+ (char)typeForObject:(id)object atOffset:(unsigned long long)offset;
+ (NSString*)nameForObject:(id)object atOffset:(unsigned long long)offset;
+ (unsigned long long)sizeForObject:(id)object atOffset:(unsigned long long)offset;
- (void)writeFileDataForObject:(id)object atLocation:(unsigned long long)location withLength:(unsigned long long)length atPath:(NSString*)path;
+ (NSData*)dataForObject:(id)object inRange:(NSRange)range orLocation:(unsigned long long)location andLength:(unsigned long long)length;
@end

@implementation ADMUntar

+ (BOOL)untarFileAtPath:(NSString *)path error:(NSError * __autoreleasing *)error
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    BOOL success = NO;
    
    if ([fm fileExistsAtPath:path]) {
        NSString *parentPath = [path stringByDeletingLastPathComponent];
        
        NSDictionary *attributes = [fm attributesOfItemAtPath:path error:nil];
        unsigned long long size = [[attributes objectForKey:NSFileSize] longLongValue];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
        
        success = [[NSFileManager defaultManager] createFilesAndDirectoriesAtPath:parentPath
                                                                    withTarObject:fileHandle
                                                                             size:size
                                                                            error:error];
        [fileHandle closeFile];
    }

    if (!success && error) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:path
                                                             forKey:NSFilePathErrorKey];
        *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoSuchFileError userInfo:userInfo];
    }
    
    return success;
}

@end

@implementation NSFileManager (Untar)

- (BOOL)createFilesAndDirectoriesAtPath:(NSString *)path withTarObject:(id)object size:(unsigned long long)size error:(NSError * __autoreleasing *)error
{
    [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]; //Create path on filesystem
    
    unsigned long long location = 0; // Position in the file
    
    while (location<size) {
        unsigned long long blockCount = 1; // 1 block for the header
        @autoreleasepool {
            
            switch ([[self class] typeForObject:object atOffset:location]) {
                case '0': // It's a File
                {
                    NSString* name = [[self class] nameForObject:object atOffset:location];

                    NSString *filePath = [path stringByAppendingPathComponent:name]; // Create a full path from the name
                    
                    unsigned long long size = [[self class] sizeForObject:object atOffset:location];
                    
                    if (size == 0){
                        [@"" writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:error];
                        break;
                    }
                    
                    // size/kTarBlockSize rounded up
                    blockCount += (size-1)/kTarBlockSize+1;
                    
                    [self writeFileDataForObject:object atLocation:(location+kTarBlockSize) withLength:size atPath:filePath];
                    break;
                }
                case '5': // It's a directory
                {
                    NSString* name = [[self class] nameForObject:object atOffset:location];
                    NSString *directoryPath = [path stringByAppendingPathComponent:name]; // Create a full path from the name
                    [self createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil]; //Write the directory on filesystem
                    break;
                }
                case '\0': // It's a null block
                {
                    break;
                }
                case '1':
                case '2':
                case '3':
                case '4':
                case '6':
                case '7':
                case 'x':
                case 'g': // It's not a file neither a directory
                {
                    unsigned long long size = [[self class] sizeForObject:object atOffset:location];
                    blockCount += ceil(size/kTarBlockSize);
                    break;
                }
                default: // It's not a tar type
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Invalid block type found"
                                                                         forKey:NSLocalizedDescriptionKey];
                    if (error)
                        *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:userInfo];
                
                    return NO;
                }
            }
            
            location += blockCount * kTarBlockSize;
        }
    }
    return YES;
}

+ (char)typeForObject:(id)object atOffset:(unsigned long long)offset
{
    char type;
    memcpy(&type, [self dataForObject:object
                              inRange:NSMakeRange(offset+kTarTypePosition, 1)
                           orLocation:offset+kTarTypePosition
                            andLength:1].bytes, 1);
    return type;
}

+ (NSString *)nameForObject:(id)object atOffset:(unsigned long long)offset
{
    char nameBytes[kTarNameSize + 1];
    memset(&nameBytes, '\0', kTarNameSize + 1);
    memcpy(&nameBytes, [self dataForObject:object
                                   inRange:NSMakeRange(offset+kTarNamePosition, kTarNameSize)
                                orLocation:offset+kTarNamePosition
                                 andLength:kTarNameSize].bytes, kTarNameSize);
    return [NSString stringWithCString:nameBytes encoding:NSASCIIStringEncoding];
}

+ (unsigned long long)sizeForObject:(id)object atOffset:(unsigned long long)offset
{
    char sizeBytes[kTarSizeSize + 1];
    memset(&sizeBytes, '\0', kTarSizeSize + 1);
    memcpy(&sizeBytes, [self dataForObject:object
                                   inRange:NSMakeRange(offset+kTarSizePosition, kTarSizeSize)
                                orLocation:offset+kTarSizePosition
                                 andLength:kTarSizeSize].bytes, kTarSizeSize);
    
    return strtoull(sizeBytes, NULL, 8);
}

- (void)writeFileDataForObject:(id)object atLocation:(unsigned long long)location withLength:(unsigned long long)length atPath:(NSString*)path
{
    if ([object isKindOfClass:[NSData class]]) {
        [self createFileAtPath:path contents:[object subdataWithRange:NSMakeRange(location, length)] attributes:nil]; //Write the file on filesystem
    }
    else if ([object isKindOfClass:[NSFileHandle class]]) {
        if ([[NSData data] writeToFile:path atomically:NO]) {
            
            NSFileHandle *destinationFile = [NSFileHandle fileHandleForWritingAtPath:path];
            [object seekToFileOffset:location];
            
            unsigned long long maxSize = kTarMaxBlockLoadInMemory*kTarBlockSize;
            
            while(length > maxSize) {
                @autoreleasepool {
                    [destinationFile writeData:[object readDataOfLength:maxSize]];
                    location += maxSize;
                    length -= maxSize;
                }
            }
            [destinationFile writeData:[object readDataOfLength:length]];
            [destinationFile closeFile];
        }
    }
}

+ (NSData *)dataForObject:(id)object inRange:(NSRange)range orLocation:(unsigned long long)location andLength:(unsigned long long)length
{
    if ([object isKindOfClass:[NSData class]]) {
        return [object subdataWithRange:range];
    }
    else if ([object isKindOfClass:[NSFileHandle class]]) {
        [object seekToFileOffset:location];
        return [object readDataOfLength:length];
    }
    
    return nil;
}

@end
