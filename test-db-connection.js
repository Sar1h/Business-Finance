require('dotenv').config({ path: '.env.local' });

const mysql = require('mysql2/promise');

async function testConnection() {
  try {
    // Create a connection pool
    const pool = mysql.createPool({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      port: process.env.DB_PORT || 3306,
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0
    });

    // Test the connection
    console.log('Attempting to connect to the database...');
    const [rows] = await pool.execute('SELECT 1');
    console.log('Database connection successful!');
    
    // Test a simple query
    const [testQuery] = await pool.execute('SELECT COUNT(*) as count FROM transactions');
    console.log('Number of transactions:', testQuery[0].count);
    
    // Close the connection pool
    await pool.end();
    console.log('Connection pool closed.');
  } catch (error) {
    console.error('Database connection error:', error);
  }
}

testConnection(); 