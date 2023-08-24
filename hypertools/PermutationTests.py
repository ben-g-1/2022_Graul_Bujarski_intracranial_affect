# data = {Dataframe} = row is indicative of a comparison between samples and column1 is subject column2 is electrode, column3 is electrode name,
# column4 is freq, column5 is sample1, and column6 is sample2

from netneurotools import stats as nnstats

def two_sample_permtest(data):
    stats_df = data.copy()
    stats_df['Test Statistic'] = 0
    stats_df['P Value'] = 0
    for i in range(len(data)):
        sample1 = data.iloc[i, 'Sample1']
        sample2 = data.iloc[i, 'Sample2']
        test_stat, pval = (nnstats.permtest_rel(sample1, sample2, n_perm=10000))
        print("Test-stat:", test_stat, "P-value:", pval)
        stats_df.loc[i, 'Test Statisic'] = test_stat
        stats_df.loc[i, 'P Value'] = test_stat
    stats_df.drop(stats_df.columns['Sample1'], axis=1, inplace=True)
    stats_df.drop(stats_df.columns['Sample2'], axis=1, inplace=True)
    csv_file = input("Name of two sample permutation test csv file")
    # Save the DataFrame to a CSV file
    stats_df.to_csv(csv_file, index=False)
    print(f"Permutation test data saved to {csv_file}")
