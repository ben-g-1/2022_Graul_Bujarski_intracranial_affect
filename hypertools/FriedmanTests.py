# data = {Dataframe} = row is indicative of a comparison between samples and column1 is subject column2 is electrode, column3 is electrode name,
# column4 is freq, column5 or "Samples" is samples or observations to compare
# cond_names = [List] = a list of list of condition names that corresponds to the samples of each row in data
    # ex: [[sample1a, sample2a, sample3a], [sample1b, sample2b, sample3b]]


from scipy.stats import friedmanchisquare
from scikit_posthocs import posthoc_nemenyi_friedman

def friedmantest(data, cond_names):
    stats_df = data.copy()
    stats_df['Test Statistic'] = 0
    stats_df['P Value'] = 0
    for i in range(len(data)):
        samples = data.iloc[i, 'Samples']
        test_stat, pval = friedmanchisquare(samples)
        print("Test-stat:", test_stat, "P-value:", pval)
        stats_df.loc[i, 'Test Statisic'] = test_stat
        stats_df.loc[i, 'P Value'] = test_stat
        if pval <= 0.05:
            pos_pval = posthoc_nemenyi_friedman(samples)
            for j, new_name in enumerate(cond_names[i]):
                pos_pval.columns.values[j] = new_name
            csv_file = input("Name of post hoc test csv file")
            # Save the DataFrame to a CSV file
            pos_pval.to_csv(csv_file, index=False)
    stats_df.drop(stats_df.columns['Sample'], axis=1, inplace=True)
    csv_file = input("Name of friedman test csv file")
    # Save the DataFrame to a CSV file
    stats_df.to_csv(csv_file, index=False)
    print(f"Permutation test data saved to {csv_file}")
