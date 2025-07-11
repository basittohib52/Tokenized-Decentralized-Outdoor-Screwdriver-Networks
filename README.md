# Tokenized Decentralized Outdoor Screwdriver Networks

A blockchain-based system for managing community screwdriver resources through smart contracts on the Stacks blockchain.

## Overview

This system consists of five interconnected smart contracts that manage different aspects of a decentralized screwdriver sharing network:

1. **Tip Condition Contract** - Monitors screwdriver wear and replacement requirements
2. **Size Availability Contract** - Manages screwdriver inventory for different screw types
3. **Sharing Coordination Contract** - Organizes screwdriver lending for community projects
4. **Storage Management Contract** - Handles proper screwdriver organization and protection
5. **Usage Instruction Contract** - Provides screw installation techniques and best practices

## Features

### Tip Condition Management
- Track wear levels of individual screwdrivers
- Set replacement thresholds
- Monitor usage history
- Alert system for maintenance needs

### Size Availability Tracking
- Inventory management for different screwdriver sizes
- Phillips, flathead, Torx, and hex driver support
- Real-time availability status
- Reservation system for high-demand tools

### Sharing Coordination
- Community project coordination
- Lending request system
- User reputation tracking
- Fair distribution algorithms

### Storage Management
- Location tracking for screwdrivers
- Environmental condition monitoring
- Security and access control
- Maintenance scheduling

### Usage Instructions
- Best practice guidelines
- Technique documentation
- Safety protocols
- Community knowledge sharing

## Smart Contract Architecture

Each contract is designed to be independent while working together to create a comprehensive tool management ecosystem. The contracts use native Clarity features without cross-contract calls or traits for maximum simplicity and security.

## Getting Started

### Prerequisites
- Stacks blockchain node
- Clarity CLI tools
- Node.js for testing

### Installation

1. Clone the repository
2. Install dependencies: \`npm install\`
3. Run tests: \`npm test\`
4. Deploy contracts to Stacks testnet

### Testing

The project uses Vitest for testing smart contract functionality:

\`\`\`bash
npm test
\`\`\`

## Contract Deployment

Deploy each contract individually to the Stacks blockchain:

1. tip-condition.clar
2. size-availability.clar
3. sharing-coordination.clar
4. storage-management.clar
5. usage-instruction.clar

## Usage Examples

### Registering a Screwdriver
\`\`\`clarity
(contract-call? .tip-condition register-screwdriver u1 "Phillips #2" u100)
\`\`\`

### Checking Availability
\`\`\`clarity
(contract-call? .size-availability check-availability "Phillips" u2)
\`\`\`

### Requesting to Borrow
\`\`\`clarity
(contract-call? .sharing-coordination request-borrow u1 u7)
\`\`\`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Community

Join our community discussions and contribute to the decentralized tool sharing revolution!
\`\`\`

Now let's create the PR details file:
