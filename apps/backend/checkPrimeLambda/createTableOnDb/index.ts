import { Context, APIGatewayProxyResult, APIGatewayEvent } from 'aws-lambda';
import { Client } from 'pg';
import { readFileSync } from 'fs';

export const handler = async (event: APIGatewayEvent, context: Context): Promise<APIGatewayProxyResult> => {
    console.log(`Event: ${JSON.stringify(event, null, 2)}`);
    console.log(`Context: ${JSON.stringify(context, null, 2)}`);
    console.log(`DB Host: ${process.env.DB_HOST}`);
    console.log(`DB Name: ${process.env.DB_NAME}`);
    console.log(`DB User: ${process.env.DB_USERNAME}`);
    const pathToCert = './rds-combined-ca-bundle.pem';
    const ssl = {
      rejectUnauthorized: false, // Set to true for production
      ca: readFileSync(pathToCert).toString(),
    };
      console.log(`PostgreSQL Client Configuration:`, {
        host: process.env.DB_HOST,
        database: process.env.DB_NAME,
        user: process.env.DB_USERNAME,
        port: 5432,
      });
      console.log('Client created:');
      console.log(client);
    
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
          body: JSON.stringify({
            message: 'Table created successfully',
        }),
        };
      } catch (error) {
        console.error('Error creating table:', JSON.stringify(error, null, 2), error.stack);
        return {
          statusCode: 500,
          body: JSON.stringify({
            message: 'Failed to create table',
        }),
        };
      } finally {
        await client.end();
      }
};