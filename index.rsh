'reach 0.1';

const Bidder = {
    enterAuction: Fun([UInt, UInt], Null),
    placeBid: Fun([UInt, UInt], UInt),
    seeOutcome: Fun([UInt], Null),
    informTimeout: Fun([], Null),
};

const Auctioneer = {
    bidPrice: UInt,
    minimumIncrement: UInt,
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

    const informTimeout = () => {
        each([Jack, John, Jane], () => {
            interact.informTimeout();
        });
    };

    Jack.only(() => {
        const bidPrice = declassify(interact.bidPrice);
        const minimumIncrement = declassify(interact.minimumIncrement);
    });

    Jack.publish(bidPrice, minimumIncrement);
    commit();


    each([John, Jane], () => {
        interact.enterAuction(bidPrice, minimumIncrement);
    });

    John.only(() => {
        const bidJohn = declassify(interact.placeBid(bidPrice, minimumIncrement));
    });

    Jane.only(() => {
        const bidJane = declassify(interact.placeBid(bidPrice, minimumIncrement));
    });

    Jack.only(() => {

    });



    each([Jack, John, Jane], () => {
        // interact.seeOutcome(0);
    });
});