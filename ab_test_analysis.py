import pandas as pd
from statsmodels.stats.proportion import proportions_ztest

df = pd.read_csv(r'C:\Users\Aryan\Downloads\AB testing\cookie_cats.csv')

print(df.dtypes)
print(df.head())

g = df.groupby('version')['retention_7'].agg(['sum', 'count'])
print("\n=== GROUP SUMMARY ===")
print(g)

gate30_converted = int(g.loc['gate_30', 'sum'])
gate30_total = int(g.loc['gate_30', 'count'])
gate40_converted = int(g.loc['gate_40', 'sum'])
gate40_total = int(g.loc['gate_40', 'count'])

rate_30 = gate30_converted / gate30_total
rate_40 = gate40_converted / gate40_total

print("\n=== RETENTION RATES ===")
print(f"gate_30 Day 7 retention: {rate_30:.2%}")
print(f"gate_40 Day 7 retention: {rate_40:.2%}")
print(f"Absolute difference: {(rate_30 - rate_40)*100:.2f} percentage points")
print(f"Relative lift (gate_30 over gate_40): {(rate_30/rate_40 - 1):.1%}")

stat, p = proportions_ztest(
    [gate30_converted, gate40_converted],
    [gate30_total, gate40_total]
)

print("\n=== STATISTICAL TEST ===")
print(f"Z-statistic: {stat:.4f}")
print(f"P-value: {p:.4f}")
print(f"Significant at p<0.05: {p < 0.05}")

if p < 0.05:
    print("\nCONCLUSION: Statistically significant.")
    print("gate_30 performs better — recommend keeping gate at level 30.")
else:
    print("\nCONCLUSION: NOT statistically significant.")


# Export for Power BI
df['retention_1'] = df['retention_1'].astype(int)
df['retention_7'] = df['retention_7'].astype(int)

# Add cohort column
df['cohort'] = pd.cut(df['sum_gamerounds'], 
                       bins=[-1, 0, 10, 40, float('inf')], 
                       labels=['0_never_played', '1_early_dropoff', '2_mid_player', '3_engaged'])

df.to_csv(r'C:\Users\Aryan\Downloads\AB testing\powerbi_data.csv', index=False)
print("Exported powerbi_data.csv successfully")