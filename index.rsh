'reach 0.1';

const Bidder = {
    enterAuction: Fun([UInt, UInt], Null),
    placeBid: Fun([UInt], UInt),
    seeOutcome: Fun([UInt], Null),
    informTimeout: Fun([], Null),
};

const Auctioneer = {
    openingBid: UInt,
    minimumIncrement: UInt,
    lowerStartingPrice: Fun([UInt], Null),
    seeOutcome: Fun([UInt], Null),
    informTimeout: Fun([], Null),
};

export const main = Reach.App(() => {
    const Jack = Participant('Jack', {
        ...Auctioneer,
        deadline: UInt,
    });
    const John = Participant('John', {
        ...Bidder,
    });
    const Jane = Participant('Jane', {
        ...Bidder,
    });

    init();

    Jack.only(() => {
        const openingBid = declassify(interact.openingBid);
        const minimumIncrement = declassify(interact.minimumIncrement);
    });

    Jack.publish(openingBid, minimumIncrement);
    commit();



    each([Jack, John, Jane], () => {
        // interact.seeOutcome();
    });
});