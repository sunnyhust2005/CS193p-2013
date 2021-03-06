//
//  CardGameViewController.h
//  Matchismo
//
//  Created by 孙 昱 on 13-9-8.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"
#import "CardMatchingGame.h"

@interface CardGameViewController : UIViewController

// all of the following methods must be overriden by concrete subclasses

- (Deck *)createDeck;

- (void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card;

@property (weak, nonatomic) IBOutlet UICollectionView *cardCollectionView;
@property (strong, nonatomic) CardMatchingGame *game;

@property (readonly, nonatomic) NSUInteger startingCardCount;
@property (readonly, nonatomic) NSUInteger numberOfCardsToMatch;

@property (readonly, nonatomic) NSUInteger matchBonus;
@property (readonly, nonatomic) NSUInteger mismatchPenalty;
@property (readonly, nonatomic) NSUInteger flipCost;

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (readonly, nonatomic) BOOL shouldRemoveUnplayableCards;

@end
