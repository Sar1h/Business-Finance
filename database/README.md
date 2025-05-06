# Business Finance Database Schema Documentation

This document provides a comprehensive overview of the database schema used in the Business Finance application, explaining the purpose and relationships of all tables, views, and triggers.

## Quick Reference

| Table | Primary Purpose | Relationships |
|-------|----------------|---------------|
| `categories` | Transaction classification | 1:N with transactions |
| `customers` | Client information | 1:N with transactions, N:1 with segments |
| `customer_segments` | Business segment grouping | 1:N with customers |
| `transactions` | Financial activity records | N:1 with customers, categories |
| `users` | System access | 1:N with various tables |
| `cashflow` | Financial projections | Derived from transactions |
| `inventory` | Product stock tracking | Referenced by transactions |
| `sales_pipeline` | Opportunity tracking | N:1 with customers |
| `tax_calendar` | Tax obligation tracking | Derived from transactions |
| `financial_insights` | AI recommendations | Related to transactions |

## Tables

### Core Tables

#### `categories`
- **Purpose**: Stores categorization information for both revenue and expense transactions
- **Key Fields**: 
  - `category_name`: Name of the category
  - `type`: Either 'revenue' or 'expense'
  - `is_recurring`: Indicates if this category typically involves recurring transactions
  - `is_fixed`: Indicates if this is considered fixed income/expense
  - `is_tax_deductible`: For expense categories, indicates if they're tax deductible
- **Primary Key**: `id` (Surrogate key)
- **Candidate Keys**: `category_name` + `type` (Natural key)
- **Indexes**: `id` (PK index), `category_name` (Unique)
- **Relationships**: Parent in 1:N with `transactions` (via `category_id` FK)

#### `customers`
- **Purpose**: Stores information about business customers/clients
- **Key Fields**:
  - `name`: Name of the customer/business
  - `business_size`: Size classification (Small, Medium, Large, Enterprise)
  - `segment_id`: Reference to customer segment
  - `lifetime_value`: Accumulated value of all transactions with this customer
  - `risk_score`: Assessment of customer risk (lower is better)
  - `payment_reliability`: Score indicating payment reliability (higher is better)
- **Primary Key**: `id` (Surrogate key)
- **Candidate Keys**: `email`/`phone` combination (Natural key)
- **Foreign Keys**: `segment_id` references `customer_segments.id`
- **Indexes**: `segment_id` (for joins), `business_size` (for filtering)
- **Relationships**:
  - Parent in 1:N with `transactions` (via `customer_id` FK)
  - Child in N:1 with `customer_segments` (via `segment_id` FK)

#### `customer_segments`
- **Purpose**: Groups customers into business segments for analysis
- **Key Fields**:
  - `segment_name`: Name of the segment (e.g., Enterprise, SMB)
  - `profitability_score`: Score indicating profitability of this segment
  - `growth_potential`: Assessment of growth potential (Low, Medium, High)
- **Primary Key**: `id` (Surrogate key)
- **Candidate Keys**: `segment_name` (Natural key, unique)
- **Indexes**: `segment_name` (Unique)
- **Relationships**: Parent in 1:N with `customers` (via `segment_id` FK)

#### `transactions`
- **Purpose**: Core table that stores all financial transactions (both revenue and expense)
- **Key Fields**:
  - `transaction_date`: When the transaction occurred
  - `amount`: Monetary value of the transaction
  - `type`: Whether 'revenue' or 'expense'
  - `category_id`: Category classification
  - `customer_id`: Associated customer (may be NULL for expenses)
  - `recurring`: Whether this is a recurring transaction
  - `recurring_frequency`: For recurring transactions, how often they recur
  - `tax_relevant`: Whether this transaction is relevant for tax calculations
- **Primary Key**: `id` (Surrogate key)
- **Foreign Keys**:
  - `category_id` references `categories.id`
  - `customer_id` references `customers.id`
- **Indexes**:
  - `transaction_date` (for time-based queries)
  - `type` (for filtering)
  - Composite: `customer_id` + `transaction_date` (for customer-specific time analysis)
- **Relationships**:
  - Child in N:1 with `customers` (via `customer_id` FK)
  - Child in N:1 with `categories` (via `category_id` FK)

#### `users`
- **Purpose**: Stores user accounts for system access
- **Key Fields**:
  - `username`: User's login name
  - `password`: Hashed password
  - `role`: User role (admin, user, financial_advisor, investor)
- **Primary Key**: `id` (Surrogate key)
- **Candidate Keys**: `username` (Natural key, unique)
- **Indexes**: `username` (Unique)

### Financial Planning & Analysis Tables

#### `cashflow`
- **Purpose**: Stores cash flow projections and actuals for financial planning
- **Key Fields**:
  - `period_date`: Date for the cashflow period
  - `projected_inflow`: Expected incoming cash
  - `projected_outflow`: Expected outgoing cash
  - `actual_inflow`: Actual incoming cash (once realized)
  - `actual_outflow`: Actual outgoing cash (once realized)
- **Primary Key**: `id` (Surrogate key)
- **Candidate Keys**: `period_date` (Natural key, unique)
- **Indexes**: `period_date` (Unique)

#### `inventory`
- **Purpose**: Tracks inventory items for businesses that sell products
- **Key Fields**:
  - `item_name`: Name of the inventory item
  - `cost_price`: Price paid to acquire the item
  - `selling_price`: Price at which item is sold
  - `current_stock`: Current quantity in stock
  - `reorder_level`: Threshold for when to reorder
- **Primary Key**: `id` (Surrogate key)
- **Candidate Keys**: `item_name` + `supplier` (Natural key)
- **Indexes**: Composite `item_name` + `supplier` (Unique)

#### `sales_pipeline`
- **Purpose**: Tracks sales opportunities through different stages
- **Key Fields**:
  - `customer_id`: Associated customer
  - `stage_name`: Current stage in the sales process
  - `stage_order`: Numerical order of stages
  - `entry_date`: When opportunity entered this stage
  - `exit_date`: When opportunity left this stage (NULL if current)
  - `value`: Potential value of the opportunity
  - `confidence_score`: Likelihood of closing (percentage)
- **Primary Key**: `id` (Surrogate key)
- **Foreign Keys**: `customer_id` references `customers.id`
- **Indexes**: `customer_id` + `stage_name` (for filtering pipeline by customer and stage)

#### `tax_calendar`
- **Purpose**: Tracks tax obligations and due dates
- **Key Fields**:
  - `tax_type`: Type of tax (Income Tax, VAT/Sales Tax, etc.)
  - `due_date`: When the tax payment is due
  - `amount_due`: Amount to be paid
  - `is_paid`: Whether this obligation has been paid
  - `period_start`/`period_end`: The period this tax covers
- **Primary Key**: `id` (Surrogate key)
- **Candidate Keys**: `tax_type` + `period_start` + `period_end` (Natural key)
- **Indexes**: Composite index on tax period fields

#### `financial_insights`
- **Purpose**: Stores AI-generated financial insights and recommendations
- **Key Fields**:
  - `insight_type`: Type of insight (opportunity, risk, trend, recommendation)
  - `category`: Business area the insight relates to
  - `title`: Brief summary of the insight
  - `description`: Detailed explanation
  - `impact_level`: Importance level (low, medium, high)
  - `is_implemented`: Whether action has been taken on this insight
- **Primary Key**: `id` (Surrogate key)
- **Indexes**: `insight_date` (for chronological listing), `impact_level` (for prioritization)

## Database Key Concepts Explained

### Key Types Used in This Schema

#### Super Keys
- **Definition**: Any set of attributes that uniquely identifies a record
- **Examples in Schema**:
  1. In `customers`: {id}, {id, name}, {id, email, phone}, {email, phone} - all are super keys
  2. In `transactions`: {id}, {id, transaction_date, amount} - all are super keys
  3. In `categories`: {id}, {id, category_name, type}, {category_name, type} - all are super keys

#### Candidate Keys
- **Definition**: Minimal super keys (cannot remove any attribute while maintaining uniqueness)
- **Examples in Schema**:
  1. In `customers`: {id} and {email, phone} are candidate keys
  2. In `transactions`: {id} is the only candidate key
  3. In `categories`: {id} and {category_name, type} are candidate keys

#### Primary Keys
- **Definition**: The chosen candidate key for main record identification
- **Implementation**: All tables use surrogate integer `id` as primary key
- **Rationale**: Integer keys provide better indexing performance and join efficiency

#### Foreign Keys
- **Definition**: Attributes referencing primary keys in other tables
- **Key Examples**:
  1. `customers.segment_id` → `customer_segments.id`
  2. `transactions.customer_id` → `customers.id`
  3. `transactions.category_id` → `categories.id`
  4. `sales_pipeline.customer_id` → `customers.id`

#### Alternative Keys
- **Definition**: Candidate keys not chosen as primary key
- **Examples in Schema**:
  1. `categories`: {category_name, type} is an alternative key (enforced via unique constraint)
  2. `customers`: {email, phone} is an alternative key (enforced via unique constraint)

## Entity-Relationship Model

### Star Schema Design for Financial Analysis

The database uses a specialized form of star schema centered around the `transactions` table:

```
                     ┌─────────────────┐
                     │ customer_segments│
                     └────────┬────────┘
                              │
                              │ segment_id (FK)
                              ▼
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│  categories  │◄──────┤ transactions ├──────►│  customers  │
└─────────────┘ cat_id │             │ cust_id└─────────────┘
                (FK)   └──────┬──────┘  (FK)         ▲
                              │                       │
                              │                       │
                              ▼                       │
                     ┌─────────────────┐             │
                     │    cashflow     │             │
                     └─────────────────┘             │
                                                     │
                                                     │
                                              ┌──────┴──────┐
                                              │sales_pipeline│
                                              └─────────────┘
```

### Relationship Details

1. **Customer Segments to Customers (1:N)**
   - One segment can contain multiple customers
   - Each customer belongs to exactly one segment
   - Foreign Key: `customers.segment_id` references `customer_segments.id`
   - Deletion Rule: SET NULL (if segment deleted, customers remain but lose segment association)

2. **Customers to Transactions (1:N)**
   - One customer can have multiple transactions
   - Each transaction belongs to at most one customer (NULL for general expenses)
   - Foreign Key: `transactions.customer_id` references `customers.id`
   - Deletion Rule: SET NULL (if customer deleted, transactions remain but lose customer association)

3. **Categories to Transactions (1:N)**
   - One category can be used for multiple transactions
   - Each transaction must belong to exactly one category
   - Foreign Key: `transactions.category_id` references `categories.id`
   - Deletion Rule: RESTRICT (cannot delete categories used by transactions)

4. **Customers to Sales Pipeline (1:N)**
   - One customer can have multiple sales opportunities
   - Each pipeline entry belongs to exactly one customer
   - Foreign Key: `sales_pipeline.customer_id` references `customers.id`
   - Deletion Rule: CASCADE (if customer deleted, their pipeline entries are removed)

5. **Transactions to Derived Data (1:N)**
   - Not explicit foreign keys, but logical derivation
   - Transactions drive cashflow, tax calendar, and insight generation
   - Implemented through triggers that monitor transaction creation

## Views

### `vw_monthly_financials`
- **Purpose**: Provides monthly summary of financial performance
- **Key Information**: Revenue, expenses, profit, profit margin, customer count, recurring revenue
- **Used For**: Month-to-month financial analysis and reporting
- **Based on**: Transactions table with monthly grouping

### `vw_cashflow_analysis`
- **Purpose**: Analyzes cash flow performance against projections
- **Key Information**: Projected vs. actual inflows and outflows, status comparison
- **Used For**: Cash flow monitoring and variance analysis
- **Based on**: Cashflow table with comparative calculations

### `vw_revenue_analysis`
- **Purpose**: Detailed breakdown of revenue sources and patterns
- **Key Information**: Revenue sources, growth rates, customer distribution
- **Used For**: Revenue stream analysis and forecasting
- **Based on**: Transactions and customers tables

## Triggers

### `update_customer_lifetime_value`
- **Purpose**: Automatically updates a customer's lifetime value when new transactions are added
- **Fires On**: After INSERT on `transactions` table
- **Action**: Adds transaction amount to customer's lifetime value if it's a revenue transaction
- **Dependencies**: Requires customer_id to be set on revenue transactions

### `generate_cashflow_projections`
- **Purpose**: Creates cashflow projections for recurring transactions
- **Fires On**: After INSERT on `transactions` table
- **Action**: When a recurring transaction is added, creates projected cashflow entries for future periods
- **Dependencies**: Checks recurring_frequency to determine projection pattern

### `detect_expense_anomalies`
- **Purpose**: Identifies unusual expense patterns and creates insights
- **Fires On**: After INSERT on `transactions` table for expense type
- **Action**: Compares expense to historical averages and generates insights for significant deviations
- **Dependencies**: Requires sufficient historical data for meaningful comparison

### `update_tax_obligations`
- **Purpose**: Tracks tax-relevant transactions and updates tax calendar
- **Fires On**: After INSERT on `transactions` table with tax_relevant=TRUE
- **Action**: Creates or updates tax obligation records based on the transaction date and type
- **Dependencies**: Requires tax_relevant flag to be properly set

### `update_inventory_on_sale`
- **Purpose**: Updates inventory levels based on sales transactions
- **Fires On**: After INSERT on `transactions` table for inventory purchases
- **Action**: Increases inventory quantities and updates last restock date
- **Dependencies**: Requires properly formatted transaction descriptions

## Data Integrity Enforcement

### Referential Integrity
- FK constraints prevent orphaned records
- CASCADE options on customer deletions to clean up related data
- RESTRICT on category deletion to prevent data loss

### Domain Constraints
- ENUMs for type fields (revenue/expense, business size)
- CHECK constraints on numeric fields (scores, amounts)
- DEFAULT values for standard configurations

### Procedural Integrity
- Triggers maintain derived values automatically
- Before-insert validations in trigger logic
- Transaction management for multi-table updates

## Database Design Principles

1. **Unified Transaction Model**: Both revenue and expenses use the same transaction table with a type field
2. **Temporal Tracking**: Most financial data includes date fields to enable time-based analysis
3. **Business Intelligence**: Views and triggers automate calculations and insights
4. **Financial Planning**: Forward-looking projections complement historical tracking

## How This Schema Supports Business Reporting

1. **Customer Analysis**: Dimensional model connecting customers → segments → transactions
2. **Financial Reporting**: Temporal organization with extensive date indexing
3. **Cash Flow Management**: Projection vs. actual tracking with automation
4. **Pipeline Analytics**: Stage-based sales tracking with conversion metrics
5. **Inventory Control**: Stock-level monitoring with financial integration 