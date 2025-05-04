require('dotenv').config({ path: '.env.local' });
const { query } = require('./lib/db');

async function testConnections() {
  console.log('Testing database connections...\n');

  // Test direct database connection
  try {
    console.log('1. Testing direct database connection...');
    const result = await query('SELECT 1 as test');
    console.log('✅ Direct database connection successful!\n');
  } catch (error) {
    console.error('❌ Direct database connection failed:', error, '\n');
  }

  // Test database queries
  try {
    console.log('2. Testing database queries...');
    const transactions = await query('SELECT COUNT(*) as count FROM transactions');
    console.log(`✅ Database queries working! Found ${transactions[0].count} transactions.\n`);
  } catch (error) {
    console.error('❌ Database query failed:', error, '\n');
  }

  // Test customer table
  try {
    console.log('3. Testing customers table...');
    const customers = await query('SELECT COUNT(*) as count FROM customers');
    console.log(`✅ Customers table accessible! Found ${customers[0].count} customers.\n`);
  } catch (error) {
    console.error('❌ Customers table query failed:', error, '\n');
  }

  // Test sales stages
  try {
    console.log('4. Testing sales stages...');
    const stages = await query('SELECT COUNT(*) as count FROM sales_stages');
    console.log(`✅ Sales stages table accessible! Found ${stages[0].count} stages.\n`);
  } catch (error) {
    console.error('❌ Sales stages query failed:', error, '\n');
  }

  process.exit(0);
}

testConnections(); 