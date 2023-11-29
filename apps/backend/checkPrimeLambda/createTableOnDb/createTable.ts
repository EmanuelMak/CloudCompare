import { Client } from 'pg';

export const handler = async (): Promise<{ statusCode: number, body: string }> => {
  const client = new Client({
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    port: parseInt(process.env.DB_PORT || '5432'),
  });

  try {
    await client.connect();

    const createTableQuery = `
      CREATE TABLE IF NOT EXISTS checkt_numbers (
        number BIGINT PRIMARY KEY,
        is_prime BOOLEAN NOT NULL
      );
    `;

    await client.query(createTableQuery);
    await client.end();

    return {
      statusCode: 200,
      body: 'Table created successfully',
    };
  } catch (error) {
    console.error('Error creating table:', error);
    return {
      statusCode: 500,
      body: 'Failed to create table',
    };
  }
};
