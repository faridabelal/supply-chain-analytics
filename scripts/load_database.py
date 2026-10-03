import pandas as pd
import sqlite3

DATA_PATH = "data/processed/supply_chain_cleaned.csv"
DATABASE_PATH = "data/processed/supply_chain.db"

df = pd.read_csv(DATA_PATH)

conn = sqlite3.connect(DATABASE_PATH)

df.to_sql(
    "supply_chain",
    conn,
    if_exists="replace",
    index=False
)

conn.close()

print("Database created successfully.")
print(f"Rows loaded: {len(df):,}")