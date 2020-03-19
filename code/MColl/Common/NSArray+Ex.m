//
//  NSArray+Ex.m
//  MColl
//
//  Created by McKee on 2018/3/12.
//  Copyright © 2018年 mckeelin. All rights reserved.
//

#import "NSArray+Ex.h"

@implementation NSArray (Ex)

- (id)objectAtIndexEx:(NSInteger)index
{
    NSInteger count = self.count;
    if( count == 0 ) return nil;
    if( index < 0 || index >= count ) return nil;
    return [self objectAtIndex:index];
}


@end



@implementation NSMutableArray (Ex)

- (void)exInserObject:(id)object atIndex:(NSInteger)i
{
    if( !object )
    {
        return;
    }
    
    if( i < 0 || i > self.count )
    {
        return;
    }
    
    [self insertObject:object atIndex:i];
}

- (void)exAddObject:(id)anObject
{
    if( !anObject )
    {
        return;
    }
    [self addObject:anObject];
}

@end
