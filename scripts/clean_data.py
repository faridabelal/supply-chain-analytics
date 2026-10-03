from pathlib import Path
import pandas as pd

# File paths
RAW_PATH = Path("data/raw/supply_chain_dataset1.csv")
OUTPUT_PATH = Path("data/processed/supply_chain_cleaned.csv")


def clean_data(df):
    """Clean the raw supply chain dataset and create analysis-ready features."""

    df = df.copy()

    # Convert date column
    df["Date"] = pd.to_datetime(df["Date"])

    # Remove duplicate records
    df = df.drop_duplicates()

    # Inventory risk indicator
    df["Below_Reorder_Point"] = (
        df["Inventory_Level"] <= df["Reorder_Point"]
    )

    # Financial metrics
    df["Revenue"] = df["Units_Sold"] * df["Unit_Price"]
    df["Cost_of_Goods_Sold"] = df["Units_Sold"] * df["Unit_Cost"]
    df["Gross_Profit"] = df["Revenue"] - df["Cost_of_Goods_Sold"]

    # Forecast accuracy
    df["Forecast_Error"] = (
        df["Units_Sold"] - df["Demand_Forecast"]
    )
    df["Absolute_Forecast_Error"] = df["Forecast_Error"].abs()

    # Reporting period
    df["Month"] = df["Date"].dt.to_period("M").astype(str)

    return df


def main():
    # Load raw data
    df = pd.read_csv(RAW_PATH)

    print(f"Raw rows: {len(df):,}")

    # Transform data
    df = clean_data(df)

    # Save analysis-ready dataset
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUTPUT_PATH, index=False)

    print(f"Cleaned rows: {len(df):,}")
    print(f"Cleaned dataset saved to: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()