Decentralized Crop Insurance Protocol
A blockchain-based crop insurance system that enables automatic payouts based on weather data verification.

## 🎯 Features

- Transparent insurance pool management
- Automated claim processing
- Weather data integration
- Community-driven governance
- Direct farmer participation
- Decentralized threshold adjustments via proposals and voting

## 🔧 Smart Contract Functions

### Farmer Operations
- `join-pool`: Join the insurance pool with minimum contribution
- `contribute`: Add more funds to the insurance pool
- `submit-claim`: Submit an insurance claim with weather data
- `withdraw`: Withdraw contributions from the pool

### Administrative Functions
- `process-claim`: Process and approve/reject claims
- `get-pool-status`: View current pool statistics
- `get-farmer-info`: Get information about a specific farmer
- `get-claim-info`: View details of a specific claim

### Governance Functions
- `propose-threshold-change`: Propose a new auto-approval threshold
- `vote-on-proposal`: Vote for or against a proposal
- `execute-proposal`: Execute a proposal if voting period ended and majority approved
- `get-proposal-info`: View details of a specific proposal

## 💡 Usage

1. Join the pool with minimum contribution (1,000,000 microSTX)
2. Submit claims when weather events affect crops
3. Claims are verified using provided weather data
4. Approved claims receive automatic payouts
5. Participate in governance by proposing and voting on auto-approval threshold changes

## 🗳️ Governance

Farmers can now actively shape the protocol's auto-approval threshold through a decentralized voting system. This empowers the community to adapt claim processing rules based on real-world conditions and collective wisdom.

### Governance Workflow
1. Active farmers propose new threshold values
2. Community votes on proposals within a 100-block voting period
3. Proposals with majority approval automatically update the threshold
4. Transparent proposal tracking ensures accountability

## � Security

- Minimum pool balance maintained
- Claim amount thresholds
- Owner-only claim processing
- Active member verification
- Voter eligibility restricted to active farmers

## 🚀 Getting Started

```bash
clarinet contract call join-pool location="FARM-001"
```

```bash
clarinet contract call contribute amount=u1000000
```

```bash
clarinet contract call submit-claim amount=u500000 weather-data="DROUGHT-20230815"
```
```

## 🌱 Referral Incentive System

Farmers can now refer new members to the insurance pool and earn bonuses upon successful referrals. This feature encourages organic network growth and increases community participation.

### Referral Workflow
1. Existing farmers provide their address as referrer when new farmers join
2. New farmers join the pool with minimum contribution
3. Referrers receive a bonus (50,000 microSTX) added to their contribution if pool balance allows
4. Referral relationships are tracked transparently on-chain

### Updated Functions
- `join-pool`: Now accepts an optional referrer parameter for bonus eligibility

### Example Usage
```bash
clarinet contract call join-pool location="FARM-002" referrer=ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
```
