'reach 0.1';

const Bidder = {
    placeBid: Fun([UInt], Null),
    seeOutcome: Fun([UInt], Null),
};

const Auctioneer = {
    openBidding: Fun([UInt], Null),
    setMinimumIncrement: Fun([UInt], Null),
    lowerStartingPrice: Fun([UInt], Null),
    seeOutcome: Fun([UInt], Null),
};

export const main = Reach.App(() => {
    const Jack = Participant('Jack', {
        ...Auctioneer,
    });
    const John = Participant('John', {
        ...Bidder,
    });
    const Jane = Participant('Jane', {
        ...Bidder,
    });
    const James = Participant('James', {
        ...Bidder,
    });
    const Amy = Participant('Amy', {
        ...Bidder,
    });
});