//
//  ToesViewController.m
//  Toes
//
//  Created by Hans Sjunnesson on 9/13/13.
//  Copyright (c) 2013 Hans Sjunnesson. All rights reserved.
//

#import "ToesViewController.h"
@import JavaScriptCore;


@interface MarkCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *markLabel;

@end

@implementation MarkCell

@end


@interface InfoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *resetGameButton;

@end

@implementation InfoCell

@end




@interface ToesViewController ()

@property (strong) JSContext *context;


#pragma mark - JS references

@property (strong) JSValue *currentBoardFunction;
@property (strong) JSValue *legalPlaceFunction;
@property (strong) JSValue *moveFunction;
@property (strong) JSValue *nextTurnFunction;
@property (strong) JSValue *markToStringFunction;
@property (strong) JSValue *markAtIndexFunction;
@property (strong) JSValue *winnerFunction;
@property (strong) JSValue *drawFunction;
@property (strong) JSValue *resetGameFunction;

@end

@implementation ToesViewController

- (void)awakeFromNib {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"toes" ofType:@"js"];
    if (filePath) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSString *source = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (source) {
            self.context = [[JSContext alloc] init];
            [self.context evaluateScript:source];
            
            JSValue *game = self.context[@"toes"][@"game"];
            JSValue *board = self.context[@"toes"][@"board"];
            
            self.currentBoardFunction = game[@"current_board"];
            self.legalPlaceFunction = board[@"legal_place_QMARK_"];
            self.moveFunction = game[@"move_BANG_"];
            self.nextTurnFunction = board[@"next_turn"];
            self.markToStringFunction = board[@"mark_to_string"];
            self.markAtIndexFunction = board[@"mark_at_index"];
            self.winnerFunction = board[@"winner"];
            self.drawFunction = board[@"draw_QMARK_"];
            self.resetGameFunction = game[@"new_game_BANG_"];
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - Game accessors

- (JSValue *)currentBoard {
    return [self.currentBoardFunction callWithArguments:nil];
}

- (NSString *)markForIndexPath:(NSIndexPath *)indexPath {
    JSValue *mark = [self.markAtIndexFunction callWithArguments:@[self.currentBoard, @(indexPath.item)]];
    return [[self.markToStringFunction callWithArguments:@[mark]] toString];
}


#pragma mark - Collection View Data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item <= 8) {
        MarkCell *cell = (MarkCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Mark" forIndexPath:indexPath];
        
        NSString *mark = [self markForIndexPath:indexPath];
        cell.markLabel.text = mark;
        
        return cell;
    } else {
        InfoCell *cell = (InfoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Info" forIndexPath:indexPath];
        
        NSString *infoString = nil;
        BOOL enableNewGameButton = NO;
        
        JSValue *draw = [self.drawFunction callWithArguments:@[self.currentBoard]];
        JSValue *winner = [self.winnerFunction callWithArguments:@[self.currentBoard]];
        
        if ([draw toBool]) {
            infoString = @"It's a draw!";
            enableNewGameButton = YES;
        } else if ([winner toBool]) {
            NSString *mark = [[self.markToStringFunction callWithArguments:@[winner]] toString];
            infoString = [NSString stringWithFormat:@"%@ is the winner!", mark];
            enableNewGameButton = YES;
        } else {
            JSValue *nextTurn = [self.nextTurnFunction callWithArguments:@[self.currentBoard]];
            NSString *mark = [[self.markToStringFunction callWithArguments:@[nextTurn]] toString];
            infoString = [NSString stringWithFormat:@"%@'s turn to play", mark];
        }
        
        cell.infoLabel.text = infoString;
        cell.resetGameButton.hidden = !enableNewGameButton;
        cell.resetGameButton.tintColor = [UIColor greenColor];
        
        return cell;
    }
}


#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.moveFunction callWithArguments:@[@(indexPath.item)]];
    
    [collectionView reloadItemsAtIndexPaths:@[indexPath, [NSIndexPath indexPathForItem:9 inSection:0]]];
}


#pragma mark - Flow Layout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item <= 8) {
        return CGSizeMake(90, 90);
    } else {
        return CGSizeMake(300, 80);
    }
}


#pragma mark - Actions

- (IBAction)newGameAction:(id)sender {
    [self.resetGameFunction callWithArguments:nil];
    [self.collectionView reloadData];
}

@end
