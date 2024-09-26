import requests
import pyodbc
import pandas as pd

# API configuration
api_key = 'XEDYETTNBTRDXTTG'
symbol = 'MSFT'
url = f'https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol={symbol}&apikey={api_key}'

# Fetch data from API
response = requests.get(url)
data = response.json()

# Extract relevant data
time_series = data['Time Series (Daily)']
df = pd.DataFrame.from_dict(time_series, orient='index')
df.reset_index(inplace=True)
df.columns = ['date', 'open', 'high', 'low', 'close', 'volume']

# Connect to SQL Server using Windows Authentication
conn = pyodbc.connect('DRIVER={SQL Server};SERVER=SHIVANI;DATABASE=ALPHA_VANTAGE_DATA;Trusted_Connection=yes')
cursor = conn.cursor()

# Check if table exists and create if not
cursor.execute('''
IF OBJECT_ID('StockData', 'U') IS NULL
BEGIN
    CREATE TABLE StockData (
        date DATE PRIMARY KEY,
        [open] FLOAT,
        high FLOAT,
        low FLOAT,
        [close] FLOAT,
        volume INT
    )
END
''')

# Insert data into table
for index, row in df.iterrows():
    cursor.execute('''
    INSERT INTO StockData (date, [open], high, low, [close], volume)
    VALUES (?, ?, ?, ?, ?, ?)
    ''', row['date'], row['open'], row['high'], row['low'], row['close'], row['volume'])

conn.commit()
cursor.close()
conn.close()