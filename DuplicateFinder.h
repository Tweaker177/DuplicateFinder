#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Duplicate : NSObject
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) unsigned long long memoryUsage;
@property (nonatomic, assign) BOOL isSafeToDelete;
@end


@interface DuplicateFinder : NSObject
- (void)findDuplicatesWithOutputFile:(NSString *)outputFilePath;
//-(Duplicate *)duplicate;
//-(NSArray *)duplicates;
-(BOOL)isSafeToDeleteFilePath:(NSString*)filePath;
@end


@implementation Duplicate : NSObject

@end