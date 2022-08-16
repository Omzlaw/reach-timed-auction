'reach 0.1';

const [isOutcome, JANE_WINS, STILL_BIDDING, JOHN_WINS] = makeEnum(3);

const winner = (bidJane, bidJohn) => {
    if (bidJohn > bidJane) {
        return JOHN_WINS;
    }
    else if (bidJane > bidJohn) {
        return JANE_WINS;
    } else {
        return STILL_BIDDING;
    }
}

const Bidder = {
    enterAuction: Fun([UInt, UInt, UInt], Null),
    placeBid: Fun([UInt, UInt], UInt),
    seeOutcome: Fun([UInt], Null),
    informTimeout: Fun([], Null),
};

const Auctioneer = {
    setOpeningBidPrice: Fun([], UInt),
    minimumIncrement: UInt,
    seeOutcome: Fun([UInt], Null),
    informTimeout: Fun([], Null),
};

export const main = Reach.App(() => {
    const Jack = Participant('Jack', {
        ...Auctioneer,
        deadline: UInt,
        auctionTime: UInt,
        entryPrice: UInt,
        bidPrice: UInt
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
        const openingBid = declassify(interact.setOpeningBidPrice());
        const minimumIncrement = declassify(interact.minimumIncrement);
        const entryPrice = declassify(interact.entryPrice);
        const deadline = declassify(interact.deadline);
        const auctionTime = declassify(interact.auctionTime);
    });

    Jack.publish(openingBid, minimumIncrement, entryPrice, deadline, auctionTime);
    commit();


    each([John, Jane], () => {
        interact.enterAuction(openingBid, minimumIncrement, entryPrice);
    });

    John.pay(entryPrice)
        .timeout(relativeTime(deadline), () => closeTo(Jack, informTimeout));
    commit();

    Jane.pay(entryPrice)
        .timeout(relativeTime(deadline), () => closeTo(Jack, informTimeout));

    var outcome = STILL_BIDDING;
    invariant(balance() == 2 * entryPrice && isOutcome(outcome));
    while (outcome == STILL_BIDDING) {
        commit();

        John.only(() => {
            const bidJohn = declassify(interact.placeBid(23, minimumIncrement));
        });

        John.publish(bidJohn)
            .timeout(absoluteTime(auctionTime), () => {
                Jack.publish();
            });
        commit();

        Jane.only(() => {
            const bidJane = declassify(interact.placeBid(23, minimumIncrement));
        });

        Jane.publish(bidJane)
            .timeout(absoluteTime(auctionTime), () => {
                Jack.publish();
                
            });
        commit();
        
        Jack.publish();

        // Publish current bid price with Jack

        outcome = winner(bidJane, bidJohn);
        continue;
    }



    assert(outcome == JANE_WINS || outcome == JOHN_WINS);
    commit();

    each([Jack, John, Jane], () => {
        interact.seeOutcome(outcome);
    });
});