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

    const client = new Client({
        host: process.env.DB_HOST,
        database: process.env.DB_NAME,
        user: process.env.DB_USERNAME,
        password: process.env.DB_PASSWORD,
        port: 5432,
        ssl: ssl,
    });
    console.log("client test:");
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

        // Insert some prime numbers
        const primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29];
        for (let prime of primes) {
            const insertQuery = 'INSERT INTO checkt_numbers (number, is_prime) VALUES ($1, $2) ON CONFLICT (number) DO NOTHING;';
            await client.query(insertQuery, [prime, true]);
        }

        // Retrieve all entries
        const selectQuery = 'SELECT * FROM checkt_numbers;';
        const res = await client.query(selectQuery);
        
        await client.end();

        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Table created and data inserted successfully',
                data: res.rows,
            }),
        };
    } catch (error) {
        console.error('Error:', JSON.stringify(error, null, 2), error.stack);
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Failed to create table or insert data',
            }),
        };
    } finally {
        if (client) {
            await client.end();
        }
    }
};
