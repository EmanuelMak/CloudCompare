import os
import psycopg2

def lambda_handler(event, context):
    db_host = os.environ['DB_HOST']
    db_user = os.environ['DB_USERNAME']
    db_pass = os.environ['DB_PASSWORD']
    db_name = os.environ['DB_NAME']

    conn = psycopg2.connect(
        dbname=db_name, user=db_user, password=db_pass, host=db_host
    )

    with conn.cursor() as cursor:
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS checkt_numbers (
                number BIGINT PRIMARY KEY,
                is_prime BOOLEAN NOT NULL
            );
        """)
        conn.commit()

    return {
        'statusCode': 200,
        'body': 'Table created successfully'
    }