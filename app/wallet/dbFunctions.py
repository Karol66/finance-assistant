import aiosqlite


class Database:
    async def ConnectDatabase(**kwargs):
        try:
            db = await aiosqlite.connect("./example.db")
            c = await db.cursor()
            await c.execute(
                "CREATE TABLE if not exists wallite (Bank TEXT, CardNumber TEXT, CVV TEXT)"
            )
            await db.commit()
            return db
        except:
            print("Error")

    async def InsertDatabase(db, values):
        c = await db.cursor()
        await c.execute(
            "INSERT INTO wallite (Bank, CardNumber, CVV) VALUES (?, ?, ?)",
            values,
        )
        await db.commit()

    async def ReadDatabase(db):
        c = await db.cursor()
        await c.execute("SELECT Bank, CardNumber, CVV FROM wallite")
        records = await c.fetchall()
        return records
