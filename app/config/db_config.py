import aiomysql
import asyncio

# Konfiguracja połączenia do bazy danych MySQL
DATABASE_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'root',
    'db': 'finance-assistant'
}

async def create_pool():
    return await aiomysql.create_pool(
        host=DATABASE_CONFIG['host'],
        port=DATABASE_CONFIG['port'],
        user=DATABASE_CONFIG['user'],
        password=DATABASE_CONFIG['password'],
        db=DATABASE_CONFIG['db'],
        autocommit=True
    )

async def create_user_table(pool):
    async with pool.acquire() as conn:
        async with conn.cursor() as cur:
            await cur.execute('''
                CREATE TABLE IF NOT EXISTS users (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    email VARCHAR(100) NOT NULL UNIQUE,
                    password VARCHAR(100) NOT NULL
                )
            ''')
