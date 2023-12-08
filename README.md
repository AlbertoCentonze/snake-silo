# Snake Silo
![DALL·E 2023-12-08 17 28 30 - A charming scene filled with numerous silos, all artistically crafted from yarn and cloth  These silos are whimsically overflowing with an abundance o](https://github.com/AlbertoCentonze/snake-silo/assets/11707683/b387e4d7-c4b7-4dc8-b174-441ff6933ba0)

## For the Curve team
Hello Curve team 👋🏻, I feel like my CV was a bit weak on the vyper side, and since I know how much you love this language, I have decided to start a vyper project to show you how motivated I am to be part of the team.

If you want to go straight to the technical part and see what I've done, skip this section. I'm just going to do some autobiographical shilling here.
Here's a couple of points that I feel like I'm not able to transmit through my CV:
- Curve is one of the first protocols I aped in, my very first time was on [the geist pool on Fantom](https://ftmscan.com/tx/0xee0a9731c8b56ce76b4bd7baa9182cf1396d609b96719d24d6c9032daea29dbd) (questionable choice with the benefit of hindsight).
- I've explained at least 10 times how the veTokenomics works at EPFL, spending countless hours introducing beginners to the fascinating world of locks and convex-like layers, leaving the audience speechless every time.
- My obsession with bribes (voting incentives, not real bribes I promise) led me to work for [Paladin](https://paladin.vote/), whose main product is a voting incentives marketplace. During this time, I learned to interact with gauges, curve pools and many other ecosystems (Uniswap, Balancer, etc).
- I've built a [protocol](https://github.com/PaladinFinance/Warlord) on top of Convex and Aura that acts as an index that dumps all the bribes in ETH. The way the index keeps rebalancing itself is very interesting and I had a discussion with Micheal when we met in person during a conference he gave at the Starling Hotel for C4DT.
<p align="center">
<img src="https://github.com/AlbertoCentonze/snake-silo/assets/11707683/78f4131d-c35a-48ae-8bb7-c0bed6ea1632" width="300" height="280">
</p>

I aim to contribute daily to this repository to give you a better idea of my motivation and capabilities. I'd be happy to take on new challenges if you have something to propose in the meantime (just drop me a message on Telegram: [@alberto_centonze](https://t.me/alberto_centonze)).

## Why this project
Discussing with a friend we realized that shorting LPs kind of resembles constructing a long straddle position, but where can we do this? The only lending market able to onboard such exotic collaterals is Silo, and since I'm not expecting to launch a protocol any time soon I took the opportunity to practice vyper by constructing a minimal version of Silo where I can simulate these kinds of positions, hoping that one day someone will build it for real.

The goal of this project is to create a very minimal version of Silo able to onboard curve LPs as collateral and create a simple frontend to do that in a simple and accessible way. I know this is already possible on Silo but I feel like this could be a great educational resource for people that want to learn more about blockchain development, especially on the application layer.

## What has been done so far?
For now, I have stripped down and implemented the basic functionalities you would expect from a lending market (deposit, withdraw, borrow, repay). Here's what's next:
- [x] Lending market basic implementation.
- [ ] Initial testing to make sure that I can move forward to the simulation of short positions on LPs.
- [ ] Function that batches all the necessary calls to open the short in one transaction.
- [ ] Use a front-end procedural generator like scaffold-eth/blacksmith-eth to generate a minimal front-end.
- [ ] Implement liquidations with mock oracles.
- [ ] Implement interest rates and protocol fees.
- [ ] Fully test the codebase with proper fuzzing and invariant testing.
- [ ] Make an actual simple front-end.

## Given unlimited resources, I would: 
- Try to adapt the previous work done by Certora on Silo to formally verify this codebase.
- Turn this into a complete porting of the Silo finance implementation.
- Compare the gas efficiency of the two projects once equivalence is reached.
- Differential testing with the solidity implementation.


## About the original Silo implementation
Even tho I cannot guarantee my comments to be 100% accurate, comments of the form `# SILO: description of the change` try to mention explicitly when sections of the code were changed from the original codebase. This might be useful to understand how/why I changed certain things and if someone ever decides to audit this codebase (for educational purposes), it can help to reference Silo audits.

## Acknowledgements
A special thank goes to [Silo Finance](https://www.silo.finance/) for creating such a cool protocol, that pursues the ideals of immutability and decentralisation that make DeFi great. Their code and documentation were very well written and easy to navigate.
