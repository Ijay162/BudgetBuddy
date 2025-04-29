# Budget Buddy

A blockchain-based personal finance management system that helps users create budgets, track expenses, and monitor income on the blockchain.

## Overview

Budget Buddy is a smart contract solution designed to empower users with better financial management through decentralized budgeting tools. The platform enables setting budget limits, recording expenses across various categories, tracking income from different sources, and monitoring financial progress through transparent blockchain records.

## Features

- **Budget Management**: Create and modify personal budget limits
- **Expense Tracking**: Log expenses with detailed categorization
- **Income Monitoring**: Record income from multiple sources
- **Financial Overview**: Track remaining balance and cumulative income
- **Category Organization**: Predefined expense types and income sources
- **Budget Reset**: Option to reset financial data when needed

## Core Functions

### Public Functions
- `set-budget`: Establish or update a budget limit
- `record-expense`: Log a new expense with category
- `record-income`: Document incoming funds with source
- `reset-budget-profile`: Reset all financial data

### Read-Only Functions
- `get-remaining-balance`: Check current available funds
- `get-cumulative-income`: View total recorded income
- `get-expense`: Retrieve details of a specific expense
- `get-income-entry`: Access information about a specific income entry
- `get-valid-expense-types`: List all valid expense categories
- `get-valid-income-sources`: List all valid income sources

## Categories

### Expense Types
- basics
- housing
- transport
- utilities
- health
- leisure
- misc

### Income Sources
- salary
- business
- investment
- freelance
- misc

## Getting Started

1. Deploy the contract to your blockchain
2. Set your initial budget limit
3. Begin recording expenses and income
4. Monitor your financial status through the read-only functions

## Security

All financial data is securely stored on the blockchain, providing an immutable record of transactions and ensuring transparency in personal financial management.