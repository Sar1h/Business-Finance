import { Suspense } from "react"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Table, TableBody, TableCaption, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Progress } from "@/components/progress"
import ClientRevenueChart from "@/components/client-revenue-chart"
import CustomerSegmentsChart from "@/components/customer-segments-chart"
import SalesFunnelChart from "@/components/sales-funnel-chart"
import CashflowTimelineChart from "@/components/cashflow-timeline-chart"
import KpiRadialCharts from "@/components/kpi-radial-charts"
import { getFinancialSummary } from "@/lib/db"
import type { FinancialSummary } from "@/lib/types"

export default async function Home() {
  const financialSummary = await getFinancialSummary() as FinancialSummary;
  
  const formatCurrency = (amount: number) => {
    return "₹" + amount.toLocaleString('en-IN', { maximumFractionDigits: 0 });
  };

  const getChangeColor = (change: number) => {
    return change >= 0 ? "text-green-500 dark:text-green-400" : "text-red-500 dark:text-red-400";
  };

  const formatChange = (change: number) => {
    const prefix = change >= 0 ? "↑" : "↓";
    return `${prefix} ${Math.abs(change).toFixed(1)}%`;
  };

  return (
    <div className="flex min-h-screen flex-col">
      <header className="sticky top-0 z-10 flex h-16 items-center gap-4 border-b bg-background px-4 md:px-6">
        <div className="flex items-center gap-2">
          <h1 className="text-lg font-semibold text-orange-500">Bufi</h1>
          <Badge variant="outline" className="text-xs">
            BETA
          </Badge>
        </div>
        <nav className="ml-auto flex gap-4">
          <Button variant="ghost" size="sm" className="text-orange-700 hover:text-orange-900 hover:bg-orange-50">
            Dashboard
          </Button>
          <Button variant="ghost" size="sm" className="hover:text-orange-700 hover:bg-orange-50">
            Insights
          </Button>
          <Button variant="ghost" size="sm" className="hover:text-orange-700 hover:bg-orange-50">
            Settings
          </Button>
        </nav>
        <Button size="icon" variant="ghost" className="text-orange-600 hover:text-orange-700 hover:bg-orange-50">
          <UserIcon className="h-5 w-5" />
          <span className="sr-only">User menu</span>
        </Button>
      </header>
      <main className="flex-1 p-4 md:p-6">
        <div className="mb-6 flex flex-col items-center justify-between gap-4 md:flex-row">
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Financial Dashboard</h1>
            <p className="text-muted-foreground">Comprehensive overview of your business finances</p>
          </div>
          <div className="flex gap-2">
            <Button variant="outline" size="sm" className="border-orange-200 hover:bg-orange-50">
              <DownloadIcon className="mr-2 h-4 w-4" />
              Export
            </Button>
            <Button size="sm" className="bg-orange-500 hover:bg-orange-600">
              <RefreshIcon className="mr-2 h-4 w-4" />
              Refresh Data
            </Button>
          </div>
        </div>
        
        <div className="grid gap-4 md:grid-cols-2 md:gap-6 lg:grid-cols-4">
          <Card className="border-orange-100">
            <CardHeader className="pb-2">
              <CardDescription>Monthly Revenue</CardDescription>
              <CardTitle className="text-4xl">{formatCurrency(financialSummary.monthlyRevenue)}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-xs text-muted-foreground">
                <span className={getChangeColor(financialSummary.revenueChange)}>
                  {formatChange(financialSummary.revenueChange)}
                </span> from last month
              </div>
            </CardContent>
          </Card>
          <Card className="border-orange-100">
            <CardHeader className="pb-2">
              <CardDescription>Monthly Expenses</CardDescription>
              <CardTitle className="text-4xl">{formatCurrency(financialSummary.monthlyExpenses)}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-xs text-muted-foreground">
                <span className={getChangeColor(-financialSummary.expensesChange)}>
                  {formatChange(financialSummary.expensesChange)}
                </span> from last month
              </div>
            </CardContent>
          </Card>
          <Card className="border-orange-100">
            <CardHeader className="pb-2">
              <CardDescription>Net Profit</CardDescription>
              <CardTitle className="text-4xl">{formatCurrency(financialSummary.netProfit)}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-xs text-muted-foreground">
                <span className={getChangeColor(financialSummary.netProfitChange)}>
                  {formatChange(financialSummary.netProfitChange)}
                </span> from last month
              </div>
            </CardContent>
          </Card>
          <Card className="border-orange-100">
            <CardHeader className="pb-2">
              <CardDescription>Cash Balance</CardDescription>
              <CardTitle className="text-4xl">{formatCurrency(financialSummary.cashBalance)}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-xs text-muted-foreground">
                <span className={getChangeColor(financialSummary.netProfitChange)}>
                  {formatChange(financialSummary.netProfitChange)}
                </span> from last month
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="grid gap-4 mt-6 md:gap-6">
          <Card className="border-orange-100 overflow-hidden">
            <CardHeader className="flex flex-row items-center space-y-0 pb-2 bg-gradient-to-r from-orange-50 to-white">
              <div className="grid gap-0.5">
                <CardTitle>Key Performance Indicators</CardTitle>
                <CardDescription>Real-time business metrics</CardDescription>
              </div>
            </CardHeader>
            <CardContent className="pt-6">
              <Suspense fallback={<div className="h-[180px] w-full flex items-center justify-center">Loading KPIs...</div>}>
                <KpiRadialCharts />
              </Suspense>
            </CardContent>
          </Card>
        </div>

        <div className="grid gap-4 mt-6 md:grid-cols-2 md:gap-6">
          <Card className="border-orange-100">
            <CardHeader className="flex flex-row items-center space-y-0 pb-2 bg-gradient-to-r from-orange-50 to-white">
              <div className="grid gap-0.5">
                <CardTitle>Revenue & Expenses</CardTitle>
                <CardDescription>Monthly overview for the last 6 months</CardDescription>
              </div>
              <div className="ml-auto flex items-center gap-2">
                <Badge variant="secondary" className="rounded-sm bg-orange-100 text-orange-700 hover:bg-orange-200">
                  Revenue
                </Badge>
                <Badge variant="outline" className="rounded-sm border-orange-200 text-orange-600 hover:bg-orange-50">
                  Expenses
                </Badge>
              </div>
            </CardHeader>
            <CardContent>
              <div className="h-[350px] w-full">
                <Suspense fallback={<div className="h-full w-full flex items-center justify-center">Loading chart...</div>}>
                  <ClientRevenueChart />
                </Suspense>
              </div>
            </CardContent>
          </Card>
          
          <Card className="border-orange-100">
            <CardHeader className="flex flex-row items-center space-y-0 pb-2 bg-gradient-to-r from-orange-50 to-white">
              <div className="grid gap-0.5">
                <CardTitle>Customer Segments</CardTitle>
                <CardDescription>Distribution by business size</CardDescription>
              </div>
            </CardHeader>
            <CardContent>
              <div className="h-[350px] w-full">
                <Suspense fallback={<div className="h-full w-full flex items-center justify-center">Loading chart...</div>}>
                  <CustomerSegmentsChart />
                </Suspense>
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="grid gap-4 mt-6 md:grid-cols-2 md:gap-6">
          <Card className="border-orange-100">
            <CardHeader className="flex flex-row items-center space-y-0 pb-2 bg-gradient-to-r from-orange-50 to-white">
              <div className="grid gap-0.5">
                <CardTitle>Sales Funnel</CardTitle>
                <CardDescription>Customer journey conversion rates</CardDescription>
              </div>
            </CardHeader>
            <CardContent>
              <div className="h-[350px] w-full">
                <Suspense fallback={<div className="h-full w-full flex items-center justify-center">Loading chart...</div>}>
                  <SalesFunnelChart />
                </Suspense>
              </div>
            </CardContent>
          </Card>
          
          <Card className="border-orange-100">
            <CardHeader className="flex flex-row items-center space-y-0 pb-2 bg-gradient-to-r from-orange-50 to-white">
              <div className="grid gap-0.5">
                <CardTitle>Cash Flow Timeline</CardTitle>
                <CardDescription>Annual cash flow projection</CardDescription>
              </div>
            </CardHeader>
            <CardContent>
              <div className="h-[350px] w-full">
                <Suspense fallback={<div className="h-full w-full flex items-center justify-center">Loading chart...</div>}>
                  <CashflowTimelineChart />
                </Suspense>
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="grid gap-4 mt-6 md:gap-6">
          <Card className="border-orange-100">
            <CardHeader className="flex flex-row items-center space-y-0 pb-2 bg-gradient-to-r from-orange-50 to-white">
              <div className="grid gap-0.5">
                <CardTitle>Financial Health</CardTitle>
                <CardDescription>Key financial metrics and indicators</CardDescription>
              </div>
            </CardHeader>
            <CardContent>
              <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                <div className="grid gap-1">
                  <div className="flex items-center justify-between text-sm">
                    <div>Profit Margin</div>
                    <div className="font-medium">43.5%</div>
                  </div>
                  <Progress value={43.5} className="bg-orange-100" indicatorClassName="bg-orange-500" />
                </div>
                <div className="grid gap-1">
                  <div className="flex items-center justify-between text-sm">
                    <div>Current Ratio</div>
                    <div className="font-medium">2.8</div>
                  </div>
                  <Progress value={70} className="bg-orange-100" indicatorClassName="bg-orange-500" />
                </div>
                <div className="grid gap-1">
                  <div className="flex items-center justify-between text-sm">
                    <div>Debt-to-Equity</div>
                    <div className="font-medium">0.4</div>
                  </div>
                  <Progress value={40} className="bg-orange-100" indicatorClassName="bg-orange-500" />
                </div>
                <div className="grid gap-1">
                  <div className="flex items-center justify-between text-sm">
                    <div>Cash Conversion Cycle</div>
                    <div className="font-medium">28 days</div>
                  </div>
                  <Progress value={65} className="bg-orange-100" indicatorClassName="bg-orange-500" />
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="grid gap-4 mt-6 md:gap-6">
          <Card className="border-orange-100">
            <CardHeader className="flex flex-row items-center space-y-0 pb-2 bg-gradient-to-r from-orange-50 to-white">
              <div className="grid gap-0.5">
                <CardTitle>Recent Transactions</CardTitle>
                <CardDescription>Latest financial activities</CardDescription>
              </div>
              <div className="ml-auto flex items-center gap-2">
                <Input placeholder="Search transactions..." className="h-8 w-[150px] sm:w-[200px] border-orange-200 focus-visible:ring-orange-500" />
                <Button size="sm" className="bg-orange-500 hover:bg-orange-600">Export</Button>
              </div>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow className="hover:bg-orange-50">
                    <TableHead>Description</TableHead>
                    <TableHead>Category</TableHead>
                    <TableHead>Date</TableHead>
                    <TableHead className="text-right">Amount</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  <TableRow className="hover:bg-orange-50">
                    <TableCell>Client Payment - ABC Corp</TableCell>
                    <TableCell>
                      <Badge variant="outline" className="border-green-200 bg-green-50 text-green-700">Income</Badge>
                    </TableCell>
                    <TableCell>Apr 05, 2023</TableCell>
                    <TableCell className="text-right font-medium text-green-600">₹5,400.00</TableCell>
                  </TableRow>
                  <TableRow className="hover:bg-orange-50">
                    <TableCell>Software Subscription</TableCell>
                    <TableCell>
                      <Badge variant="outline" className="border-red-200 bg-red-50 text-red-700">Expense</Badge>
                    </TableCell>
                    <TableCell>Apr 03, 2023</TableCell>
                    <TableCell className="text-right font-medium text-red-600">-₹89.00</TableCell>
                  </TableRow>
                  <TableRow className="hover:bg-orange-50">
                    <TableCell>Client Payment - XYZ Ltd</TableCell>
                    <TableCell>
                      <Badge variant="outline" className="border-green-200 bg-green-50 text-green-700">Income</Badge>
                    </TableCell>
                    <TableCell>Apr 01, 2023</TableCell>
                    <TableCell className="text-right font-medium text-green-600">₹3,200.00</TableCell>
                  </TableRow>
                  <TableRow className="hover:bg-orange-50">
                    <TableCell>Office Rent</TableCell>
                    <TableCell>
                      <Badge variant="outline" className="border-red-200 bg-red-50 text-red-700">Expense</Badge>
                    </TableCell>
                    <TableCell>Apr 01, 2023</TableCell>
                    <TableCell className="text-right font-medium text-red-600">-₹1,500.00</TableCell>
                  </TableRow>
                  <TableRow className="hover:bg-orange-50">
                    <TableCell>Contractor Payment</TableCell>
                    <TableCell>
                      <Badge variant="outline" className="border-red-200 bg-red-50 text-red-700">Expense</Badge>
                    </TableCell>
                    <TableCell>Mar 28, 2023</TableCell>
                    <TableCell className="text-right font-medium text-red-600">-₹2,400.00</TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </CardContent>
            <CardFooter className="bg-gradient-to-r from-white to-orange-50">
              <div className="flex w-full items-center justify-between">
                <div className="text-xs text-muted-foreground">Showing 5 of 24 transactions</div>
                <div className="flex items-center gap-2">
                  <Button size="sm" variant="outline" disabled className="border-orange-200 hover:bg-orange-50">
                    Previous
                  </Button>
                  <Button size="sm" variant="outline" className="border-orange-200 hover:bg-orange-50 hover:text-orange-700">
                    Next
                  </Button>
                </div>
              </div>
            </CardFooter>
          </Card>
        </div>
      </main>
      <footer className="border-t border-orange-100 py-4 px-6 text-center text-sm text-muted-foreground">
        <p>© 2023 Bufi Financial Intelligence. All rights reserved.</p>
      </footer>
    </div>
  )
}

function UserIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2" />
      <circle cx="12" cy="7" r="4" />
    </svg>
  )
}

function DownloadIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
      <polyline points="7 10 12 15 17 10" />
      <line x1="12" x2="12" y1="15" y2="3" />
    </svg>
  )
}

function RefreshIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8" />
      <path d="M21 3v5h-5" />
      <path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16" />
      <path d="M3 21v-5h5" />
    </svg>
  )
} 