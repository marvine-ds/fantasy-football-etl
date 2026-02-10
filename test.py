import mysql.connector
from config import DB_CONFIG

conn = mysql.connector.connect(**DB_CONFIG)
cursor = conn.cursor()

# Check which database we are connected to
cursor.execute("SELECT DATABASE()")
print("DB:", cursor.fetchone())

# List tables visible to this connection
cursor.execute("SHOW TABLES")
print("Tables:", cursor.fetchall())

cursor.close()
conn.close()
