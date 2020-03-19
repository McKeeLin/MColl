//
//  NSArray+Ex.h
//  MColl
//
//  Created by McKee on 2018/3/12.
//  Copyright © 2018年 mckeelin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Ex)

- (id)objectAtIndexEx:(NSInteger)index;

@end


@interface NSMutableArray (Ex)

- (void)exInserObject:(id)object atIndex:(NSInteger)i;

- (void)exAddObject:(id)anObject;



@end
