import csv
import random

# Function to generate fractally distributed stock symbols
def gen(frac, N):
    p = list(range(1, N + 1))
    random.shuffle(p)
    outvec = p.copy()
    while len(p) > 1:
        p = p[:int(frac * len(p))]
        outvec = p + outvec  # Prepend the reduced list to outvec
    random.shuffle(outvec)
    return outvec

# Function to create trades based on fractal distribution
def generate_trades(symbols, num_trades):
    trade_data = []
    last_price = {symbol: random.randint(50, 500) for symbol in symbols}  # Initial prices

    for time in range(1, num_trades + 1):
        stock_symbol = random.choice(symbols)
        quantity = random.randint(100, 10000)
        # Ensure price is within 50-500 and changes by at least 1, but no more than 5
        price_change = random.randint(-5, 5)
        new_price = max(50, min(500, last_price[stock_symbol] + price_change))
        
        trade_data.append([stock_symbol, time, quantity, new_price])
        last_price[stock_symbol] = new_price

    return trade_data

# Parameters
N = 70000        # Number of unique stock symbols
frac = 0.3       # Fractal distribution fraction
num_trades = 10_000_000  # Total number of trades

# Generate fractal distribution of stock symbols
symbols = gen(frac, N)

# Generate trade data
trade_data = generate_trades(symbols, num_trades)

# Write trade data to CSV
with open('trades.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(['stocksymbol', 'time', 'quantity', 'price'])  # Write headers
    writer.writerows(trade_data)

print("CSV generation complete: 'trades.csv'")

