# Bufi - Financial Dashboard

![Bufi Dashboard](https://i.imgur.com/placeholder-image.png)

A comprehensive financial intelligence platform designed for Small and Medium Businesses to monitor, analyze, and optimize their financial health in real-time.

## 🚀 Features

- **Interactive Data Visualizations**: Multiple chart types to visualize key business metrics
- **Financial KPIs**: Real-time tracking of revenue, expenses, profit margins, and more
- **Customer Segmentation**: Breakdown of customer distribution by business size
- **Sales Funnel Analysis**: Track conversion rates throughout the sales pipeline
- **Cash Flow Management**: Monitor cash inflows and outflows over time
- **Financial Health Metrics**: Visual indicators of key financial ratios
- **Transaction Tracking**: Recent transaction history with filtering capabilities
- **Responsive Design**: Fully responsive layout that works on all device sizes
- **Light/Dark Mode**: Themeable UI with light and dark mode support

## 🛠️ Tech Stack

- **Frontend Framework**: [Next.js 14](https://nextjs.org/)
- **UI Components**: [shadcn/ui](https://ui.shadcn.com/)
- **Styling**: [Tailwind CSS](https://tailwindcss.com/)
- **Charts**: [ApexCharts](https://apexcharts.com/)
- **TypeScript**: Type-safe code
- **React 18**: Latest React features with Server Components
- **State Management**: React's built-in state management with Context API

## 🚦 Getting Started

### Prerequisites

- Node.js 18.x or later
- npm or yarn

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/bufi-dashboard.git
   cd bufi-dashboard
   ```

2. Install dependencies:
   ```bash
   npm install
   # or
   yarn install
   ```

3. Run the development server:
   ```bash
   npm run dev
   # or
   yarn dev
   ```

4. Open [http://localhost:3000](http://localhost:3000) in your browser to see the application.

## 📊 Dashboard Components

The dashboard is composed of several key visualizations:

1. **KPI Cards**: Overview of monthly revenue, expenses, net profit, and cash balance
2. **Key Performance Indicators**: Radial gauges showing sales targets, customer retention, profit margin, and ROI
3. **Revenue & Expenses Chart**: Bar chart comparing revenue and expenses over 6 months
4. **Customer Segments Chart**: Donut chart showing distribution of customers by business size
5. **Sales Funnel Chart**: Horizontal bar chart tracking lead conversion through the sales pipeline
6. **Cash Flow Timeline Chart**: Area chart showing cash inflows and outflows throughout the year
7. **Financial Health Metrics**: Progress bars visualizing key financial ratios
8. **Recent Transactions Table**: Tabular data of recent financial activities

## 🧩 Project Structure

```
bufi-dashboard/
├── app/                    # Next.js app directory
│   ├── globals.css         # Global styles
│   ├── layout.tsx          # Root layout
│   └── page.tsx            # Main dashboard page
├── components/             # React components
│   ├── ui/                 # shadcn UI components
│   ├── client-revenue-chart.tsx
│   ├── customer-segments-chart.tsx
│   ├── sales-funnel-chart.tsx
│   ├── cashflow-timeline-chart.tsx
│   ├── kpi-radial-charts.tsx
│   ├── progress.tsx
│   └── theme-provider.tsx
├── lib/                    # Utility functions
│   └── utils.ts
├── public/                 # Static assets
├── styles/                 # Additional styles
├── next.config.js          # Next.js configuration
├── package.json            # Dependencies
├── postcss.config.js       # PostCSS configuration
├── tailwind.config.js      # Tailwind CSS configuration
└── tsconfig.json           # TypeScript configuration
```

## 📝 Database Schema

The dashboard is designed to work with a financial database with the following core entities:

- **Transactions**: Financial transactions with amount, date, type, etc.
- **Customers**: Business clients with size, industry, status, etc.
- **Accounts**: Financial accounts with balances and types
- **Categories**: Transaction categorization system
- **Products**: Goods and services sold
- **Sales**: Sales records with dates, amounts, and status
- **Financial Metrics**: Pre-calculated business indicators
- **Cash Flow**: Aggregated cash movement records
- **Sales Funnel**: Sales pipeline tracking by stage

## 🔐 Environment Variables

Create a `.env.local` file in the root directory with the following variables:

```
NEXT_PUBLIC_API_URL=your_api_url
```

## 🌐 Deployment

This application can be deployed to Vercel with a single click:

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fyourusername%2Fbufi-dashboard)

## 🧪 Testing

```bash
# Run unit tests
npm run test

# Run end-to-end tests
npm run test:e2e
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📧 Contact

For any inquiries, please reach out to:

- Email: contact@bufi-finance.com
- Website: [https://bufi-finance.com](https://bufi-finance.com)

---

Built with ❤️ by the Bufi Team 

## Database Setup

### Prerequisites

- MySQL Server 5.7+ or MySQL 8.0+
- Node.js 14.0+
- npm or yarn

### Installation Steps

1. **Create MySQL Database**

   ```sql
   CREATE DATABASE bufi_finance;
   USE bufi_finance;
   ```

2. **Run Schema Script**

   Save the database schema to a file (e.g., `schema.sql`) and run:

   ```bash
   mysql -u your_username -p bufi_finance < database/schema.sql
   ```

   Or you can copy and paste the contents of `database/schema.sql` into your MySQL client.

3. **Seed Sample Data (Optional)**

   ```bash
   mysql -u your_username -p bufi_finance < database/seed_data.sql
   ```

4. **Configure Environment Variables**

   Create a `.env.local` file in the project root with:

   ```
   DB_HOST=localhost
   DB_USER=your_mysql_username
   DB_PASSWORD=your_mysql_password
   DB_NAME=bufi_finance
   DB_PORT=3306

   NEXT_PUBLIC_API_URL=http://localhost:3000/api
   NODE_ENV=development
   ```

## Database Schema

The database includes the following tables:

- **users**: Application users with authentication information
- **customer_segments**: Categories of customers
- **customers**: Customer information and metadata
- **revenue_categories**: Types of revenue sources
- **expense_categories**: Types of expenses
- **transactions**: All financial transactions (both revenue and expenses)
- **sales_stages**: Stages in the sales pipeline
- **sales_funnel_entries**: Customer journey through the sales pipeline
- **cashflow_projections**: Future cash flow forecasts
- **kpi_metrics**: Key performance indicators and targets

## API Routes

The application provides the following API endpoints:

- **GET /api/dashboard**: Get all dashboard data in a single request
- **GET /api/transactions**: Get transactions with optional filtering
- **POST /api/transactions**: Create a new transaction
- **PATCH /api/transactions/:id**: Update an existing transaction
- **DELETE /api/transactions/:id**: Delete a transaction

## Development

1. **Install Dependencies**

   ```bash
   npm install
   # or
   yarn install
   ```

2. **Run Development Server**

   ```bash
   npm run dev
   # or
   yarn dev
   ```

3. **Open Application**

   Navigate to [http://localhost:3000](http://localhost:3000) in your browser.

## Useful MySQL Queries

The `database/queries.sql` file contains a collection of useful queries for:

- Dashboard overview metrics
- Revenue and expense analysis
- Customer segment analysis
- Sales funnel metrics
- Cash flow projections
- KPI performance tracking
- Transaction reporting

## Production Deployment

For production deployment:

1. **Setup a Production MySQL Database**

   Configure your production database and update environment variables accordingly.

2. **Build the Application**

   ```bash
   npm run build
   # or
   yarn build
   ```

3. **Start the Production Server**

   ```bash
   npm start
   # or
   yarn start
   ```

## MySQL Database Management

- **Backup Database**

  ```bash
  mysqldump -u username -p bufi_finance > bufi_finance_backup.sql
  ```

- **Restore Database**

  ```bash
  mysql -u username -p bufi_finance < bufi_finance_backup.sql
  ```

- **Running Direct Queries**

  You can use the MySQL command line client or a GUI tool like MySQL Workbench:

  ```bash
  mysql -u username -p bufi_finance
  ```

## License

This project is licensed under the MIT License. 