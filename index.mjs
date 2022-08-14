import { loadStdlib, ask } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib();

var isJohn = false;

const getBidders = async () => {
    const _isJohn = await ask.ask(
        `Are you John?`,
        ask.yesno
    );

    isJohn = _isJohn;
    return _isJohn ? 'John' : 'Jane';
}


const isJack = await ask.ask(
    `Are you Jack?`,
    ask.yesno
);
const who = isJack ? 'Jack' : await getBidders();

console.log(`Entering Auction as ${who}`);

let acc = null;
const createAcc = await ask.ask(
    `Would you like to create an account? (only possible on devnet)`,
    ask.yesno
);

if (createAcc) {
    acc = await stdlib.newTestAccount(stdlib.parseCurrency(1000));
} else {
    const secret = await ask.ask(
        `What is your account secret?`,
        (x => x)
    );
    acc = await stdlib.newAccountFromSecret(secret);
}

let ctc = null;
if (isJack) {
    ctc = acc.contract(backend);
    ctc.getInfo().then((info) => {
        console.log(`The contract is deployed as = ${JSON.stringify(info)}`);
    });
} else {
    const info = await ask.ask(
        `Please paste the contract information:`,
        JSON.parse
    );
    ctc = acc.contract(backend, info);
}

const fmt = (x) => stdlib.formatCurrency(x, 4);
const interact = {};

interact.informTimeout = () => {
    console.log(`There was a timeout.`);
    process.exit(1);
};

if (isJack) {
    const startAuction = await ask.ask(
        `Start Auction event`,
        ask.yesno
    );

    if (startAuction) {
        const bidPrice = await ask.ask(
            `How much is the opening bid for the product?`,
            stdlib.parseCurrency
        );
        interact.bidPrice = bidPrice;

        const minimumIncrement = await ask.ask(
            `Set minimum bid increment value`,
            stdlib.parseCurrency
        );
        interact.minimumIncrement = minimumIncrement;
        interact.deadline = { ETH: 100, ALGO: 100, CFX: 1000 }[stdlib.connector];
    }
} else {
    interact.enterAuction = async (bidPrice, minimumIncrement) => {
        const accepted = await ask.ask(
            `Do you want to enter auction? Starting price is ${fmt(bidPrice)} and minimum bid increment is ${fmt(minimumIncrement)}`,
            ask.yesno
        );
        if (!accepted) {
            process.exit(0);
        }
    };


    interact.placeBid = async(bidPrice, minimumIncrement) => {
        const bid = await ask.ask(
            `What bid do you want to place ? minimum increment is at ${fmt(minimumIncrement)}. Current price is at ${fmt(bidPrice)}`,
            stdlib.parseCurrency
        );
        while (bid - bidPrice < minimumIncrement) {
            console.log('Bid increment is lower than minimum increment, please bid again');
            bid = await ask.ask(
                `What bid do you want to place ? minimum increment is at ${fmt(minimumIncrement)}. Current price is at ${fmt(bidPrice)}`,
                stdlib.parseCurrency
            );
        }
        return bid;
    }
}


const OUTCOME = ['Product sold to John', 'Product sold to Jane'];
interact.seeOutcome = async (outcome) => {
  console.log(`The outcome is: ${OUTCOME[outcome]}`);
};

const part = isJack ? ctc.p.Jack : (isJohn ? ctc.p.John : ctc.p.Jane);
await part(interact);