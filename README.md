# Decentralized Crop Insurance Protocol
A blockchain-based crop insurance system that enables automatic payouts based on weather data verification.

## 🎯 Features

- Transparent insurance pool management
- Automated claim processing
- Weather data integration
- Community-driven governance
- Direct farmer participation

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

## 💡 Usage

1. Join the pool with minimum contribution (1,000,000 microSTX)
2. Submit claims when weather events affect crops
3. Claims are verified using provided weather data
4. Approved claims receive automatic payouts

## 🔒 Security

- Minimum pool balance maintained
- Claim amount thresholds
- Owner-only claim processing
- Active member verification

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
