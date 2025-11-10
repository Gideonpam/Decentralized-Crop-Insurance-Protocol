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

## 🔄 Emergency Pool Pause Mechanism

Introducing a critical safety feature that allows the contract owner to temporarily halt all pool operations during emergencies, ensuring protocol stability and protecting participants from potential risks.

### Emergency Pause Workflow
1. Contract owner can activate emergency pause when critical issues are detected
2. All contribution, claim submission, and withdrawal functions are suspended
3. Pool status remains readable for transparency
4. Owner can resume operations once issues are resolved
5. Pause state is tracked on-chain for auditability

### New Functions
- `pause-pool`: Emergency pause activation (owner only)
- `resume-pool`: Resume normal operations (owner only)
- `is-pool-paused`: Check current pause status

### Example Usage
```bash
clarinet contract call pause-pool
```

```bash
clarinet contract call resume-pool
```

## 📊 Farmer Performance Analytics Dashboard

Empowering farmers with comprehensive performance insights through an advanced analytics system that tracks contribution patterns, claim histories, and risk profiles to optimize insurance strategies and decision-making.

### Analytics Dashboard Workflow
1. Farmers can access detailed performance metrics anytime
2. System calculates contribution efficiency and claim success rates
3. Risk scoring helps farmers understand their insurance positioning
4. Historical data enables better planning for future crop seasons
5. Analytics drive personalized premium adjustments and recommendations

### New Functions
- `get-farmer-analytics`: Retrieve comprehensive farmer performance data
- `get-contribution-history`: View contribution patterns over time
- `get-claim-success-rate`: Calculate claim approval percentages
- `get-risk-profile`: Assess farmer's risk positioning in the pool

### Example Usage
```bash
clarinet contract call get-farmer-analytics farmer=ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
```

```bash
clarinet contract call get-claim-success-rate farmer=ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
## ⚖️ Decentralized Claim Dispute Resolution System

Empowering farmers with a transparent, community-driven mechanism to challenge rejected claims, ensuring fairness and accountability in the insurance process through democratic voting.

### Dispute Resolution Workflow
1. Farmers can dispute rejected claims within the protocol
2. Community members vote on dispute validity during a 100-block voting period
3. Disputes with majority approval result in claim reversal and payout
4. Transparent voting records maintain system integrity

### New Functions
- `dispute-claim`: Initiate a dispute for a rejected claim
- `vote-on-dispute`: Cast votes on active disputes
- `resolve-dispute`: Execute dispute outcome after voting period
- `get-dispute-info`: Access dispute details and voting status

### Example Usage
```bash
clarinet contract call dispute-claim claim-id=u1
```

```bash
clarinet contract call vote-on-dispute dispute-id=u1 vote=true
```

```bash
clarinet contract call resolve-dispute dispute-id=u1
```
```
