# Snake Silo
![DALL·E 2023-12-08 17 28 30 - A charming scene filled with numerous silos, all artistically crafted from yarn and cloth  These silos are whimsically overflowing with an abundance o](https://github.com/AlbertoCentonze/snake-silo/assets/11707683/b387e4d7-c4b7-4dc8-b174-441ff6933ba0)

## Why this project
Discussing with a friend we realized that shorting LPs kind of resembles constructing a long straddle position, but where can we do this? The only lending market able to onboard such exotic collaterals is Silo, and since I'm not expecting to launch a protocol any time soon I took the opportunity to practice vyper by constructing a minimal version of Silo where I can simulate these kinds of positions, hoping that one day someone will build it for real.

The goal of this project is to create a very minimal version of Silo able to onboard curve LPs as collateral and create a simple frontend to do that in a simple and accessible way. I know this is already possible on Silo but I feel like this could be a great educational resource for people that want to learn more about blockchain development, especially on the application layer.

## What has been done so far?
For now, I have stripped down and implemented the basic functionalities you would expect from a lending market (deposit, withdraw, borrow, repay). Here's what's next:
- [x] Lending market basic implementation.
- [x] Setup vyper compilation for foundry
- [x] Initial testing to make sure that I can move forward.
- [ ] Port the router to be able to batch multiple interactions with the market at once.
- [ ] Functions that batches all the necessary calls to open the short in one transaction.
- [ ] Onboard Curve LPs.
- [ ] Use a procedural generator like scaffold-eth/blacksmith-eth to generate a minimal front-end.
- [ ] Do some maths to compute the payout of such a position and visualize it.
- [ ] Implement liquidations with mock oracles.
- [ ] Implement interest rates and protocol fees.
- [ ] Fully test the codebase with proper fuzzing and invariant testing.

## Given unlimited resources, I would: 
- Turn this into a complete porting of the Silo finance implementation.
- Try to adapt the previous work done by Certora on Silo to verify this codebase formally.
- Compare the gas efficiency of the two projects once equivalence is reached.
- Differential testing with the solidity implementation.

## A couple of ideas around an LP-centric money market
- Collateral-only deposits (those that are not lent out) could stake the collateral in Curve gauges to farm liquidity incentives. This could be used to offer lower interest rates or automatically pay back the loan.
- Afaik Curve doesn't have a protocol offering leverage on their LPs (like Impermax for UniV2-like protocols), this is indeed a possibility that could be offered by customizing this implementation,
- As mentioned above enabling LPs to be shorted could turn impermanent loss into impermanent gains, allowing people to bet on high-volatility market movements.


## Differences from the original Silo implementation
### Style Conventions
All function signatures are changed from `camelCase` to `snake_case`. Please be careful since this will change the signature of the functions.

### Explicit changes
Even though I cannot guarantee to be 100% accurate, I try to follow these conventions for comments:
- Comments of the form `# SILO: description of the change` mention explicitly when sections of the code were changed from the original codebase. This might be useful to understand how/why I changed certain things and if someone ever decides to audit this codebase (for educational purposes), it can help to reference Silo audits.
- Comments of the form `# VYPER: description of the change` mention when a necessary change had to be made to make the code more idiomatic for Vyper. These kinds of choices can sometimes be opinionated and change the way the codebase behaves.

### Functions visibility
Given that vyper 0.3.10 only supports two types of visibility `internal` or `external` I'll try to respect the following conventions when converting visibility from solidity to vyper:
- For **external methods**, no particular change will be required since `@external` does the same thing.
- For **public methods**, I will create both an `@internal` function containing the implementation (prefixed by `_` and an `@external` one with just the name of the function. The external function will have a comment justifying the change: `# VYPER: Exposing internal function to obtain the equivalent of a public solidity method
- For both **internal and private methods** I will be using `@internal` since vyper doesn't use inheritance.

## Security Considerations
Regardless of how much time I will spend on this project, this codebase should be used only for educational purposes and it is not production-ready. Using snippets of this project to develop production applications is at your own risk and I decline any responsibility in case of loss of funds. 

## Acknowledgements
- A special thank goes to [Silo Finance](https://www.silo.finance/) for creating such a cool protocol, that pursues the ideals of immutability and decentralisation that make DeFi great. Their code and documentation were very well written and easy to navigate.
- The amazing [Snekmate](https://github.com/pcaversaccio/snekmate) by [pcaversaccio](https://github.com/pcaversaccio) was used as the base implementation for `ShareCollateralToken` and `ShareDebtToken`.
- The vyper and titanoboa team for their support during the development of the project.
