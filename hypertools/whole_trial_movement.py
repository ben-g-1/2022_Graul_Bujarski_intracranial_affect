# ----------------------------------------------------------------------
#                               libraries
# ----------------------------------------------------------------------
import numpy as np
import hypertools as hyp
from sklearn.decomposition import PCA
from matplotlib import pyplot as plt
import pandas as pd
import timecorr as tc
import seaborn as sns
import os
from scipy.stats import friedmanchisquare
from scikit_posthocs import posthoc_nemenyi_friedman
from mpl_toolkits import mplot3d
from mpl_toolkits.mplot3d import Axes3D

# Set path to location of the file
abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)

os.chdir(dname)

# Global variables
n_iter = 3
ndims = 3


subjects = ['sub01', 'sub02', 'sub03']
freq_time = ['alpha', 'beta', 'gamma']
channels = {'RTA1': 'Amygdala - Basal nucleus', 'LFC9': 'Superior Frontal Cortex'}

# ----------------------------------------------------------------------
#                               functions
# ----------------------------------------------------------------------
# Access CSV files from directory
def directory(data, sub, freq, chan):
    # Change directory to AveragePower folder
    os.chdir(data.format(sub, freq))
    cwd = os.getcwd()
    file_list = os.listdir(cwd)
    file_name = ""
    for i in file_list:
        if i == '{}_{}_{}_avgpow.csv'.format(sub, freq, chan):
            file_name = data.format(sub, freq) + i
    os.chdir(dname)
    print(file_name)
    return file_name

def dataload(datadir, index_label, transp=True):
    pd.set_option("display.max_column", None)
    data = np.loadtxt(datadir, delimiter=',')
    df = pd.DataFrame(data)
    # Arrange the 48 df index to trial numbers
    df.set_index(index_label, inplace=True)
    # Make time as rows and trials as columns
    if transp is True:
        df = df.T
    # Now the trial numbers should be the columns
    print("List of columns")
    print(df.columns)
    return df


def getclasslabels(trialinfo, class_labels_name):
    pd.set_option("display.max_column", None)
    # data = np.loadtxt(trialinfo, delimiter=',')
    data = pd.read_csv(trialinfo)
    # data.index = np.arange(1, len(data) + 1)
    class_labels = data.pop(class_labels_name)
    # pair_labels.index = np.arange(1, len(pair_labels ) + 1)
    print(class_labels)
    return class_labels

def phaseclass(phase_dict):
    # Phases of stimuli list setup:
    phase_labels = []
    for phase_num, phase_count in phase_dict.items():
        for p in range(phase_count):
            phase_labels.append(phase_num)
    print(phase_labels)
    return phase_labels

def group_tblock(df, num_blocks, idx_list):
    timeblocks = []
    for timeblock in range(1, num_blocks+1):
        timeblocks[timeblock] = df.iloc[idx_list[timeblock][0]:idx_list[timeblock][1], :]
        timeblocks[timeblock] = timeblocks[timeblock].reset_index()
        timeblocks[timeblock].drop(columns=['index'], inplace=True)

    return timeblocks

def hyper_analyze(*data, normalize='within', reduce='IncrementalPCA', ndims=3, align='hyper'):
    if len(data) == 1:
        # Row dimensions
        print(data.shape[0])
        # Column dimensions
        print(data.shape[1])
        # Visualizes raw data
        plt.title("Raw Data")
        sns.heatmap(data)
        png_file = input("Name of raw data png file")
        plt.savefig(png_file)
        plt.show()
        # Normalize data
        norm_data = hyp.analyze(data, normalize)
        # Visualize normalized data
        plt.title("Normalized Data")
        sns.heatmap(norm_data)
        png_file = input("Name of normalized data png file")
        plt.savefig(png_file)
        plt.show()
        # Normalized and reduced data
        norm_reduced_data = hyp.analyze(data, normalize, reduce, ndims)
        plt.title("Normalized and Reduced Data")
        sns.heatmap(norm_reduced_data)
        png_file = input("Name of normalized and reduced data png file")
        plt.savefig(png_file)
        plt.show()
    # If analyzing two dataframes
    if len(data) == 2:
        for x in data:
            # Row dimensions
            print(x.shape[0])
            # Column dimensions
            print(x.shape[1])

        for idx, x in enumerate(data):
            # Visualizes raw data
            plt.title("Raw Data")
            sns.heatmap(x)
            png_file = '/Users/evansalvarez/PycharmProjects/iEEG Data Analysis/sub01/raw{}.png'.format(str(idx+1))
            plt.savefig(png_file)
            plt.show()

        # Normalize data
        data_array = []
        for x in data:
            data_array.append(np.array(x))
        norm_data = hyp.analyze(data_array, normalize)
        # Visualize normalized data
        for idx, x in enumerate(norm_data):
            # Visualizes raw data
            plt.title("Normalized Data")
            sns.heatmap(x)
            png_file = input("Name of normalized data png file")
            plt.savefig(png_file)
            plt.show()

        # Normalized and reduced data
        norm_reduced_data = hyp.analyze(data_array, normalize, reduce, ndims)
        for idx, x in enumerate(norm_reduced_data):
            plt.title("Normalized and Reduced Data")
            sns.heatmap(x)
            png_file = input("Name of normalized and reduced data png file")
            plt.savefig(png_file)
            plt.show()
        # Visualize normalized reduced aligned data
        norm_red_algn_data = hyp.analyze(data_array, normalize, reduce, ndims, align)
        for idx, x in enumerate(norm_red_algn_data):
            plt.title("Normalized and Reduced and Aligned Data")
            sns.heatmap(x)
            png_file = input("Name of normalized, reduced, aligned data png file")
            plt.savefig(png_file)
            plt.show()

def pca_analyze(data, target, target_names, ndims=3, pca_columns=None, thres=0.95):
    if pca_columns is None:
        pca_columns = ['PC1', 'PC2', 'PC3']
    data['target'] = target
    data['target_names'] = data['target'].map(target_names)
    # Value Count number targets
    csv_file = input("Name of before-pca data csv file")
    # Save the DataFrame to a CSV file
    data.to_csv(csv_file, index=False)
    sns.countplot(x='target_names', data=data)
    plt.title("X targets value count")
    csv_file = input("Name of countplot csv file")
    plt.savefig(csv_file)
    plt.show()

    # Load features and targets separately
    X = data
    y = target
    feature_names = data.columns
    # Data preprocessing: data scaling
    x_scaled = StandardScaler().fit_transform(X)
    csv_file = input("Name of scaled features csv file")
    # Save the DataFrame to a CSV file
    x_scaled.to_csv(csv_file, index=False)
    # Dimension Reduction using PCA
    pca = PCA(n_components=ndims)
    pca_features = pca.fit_transform(x_scaled)
    print("Shaped before PCA:", x_scaled.shape)
    print("Shaped after PCA:", pca_features.shape)
    pca_df = pd.DataFrame(data=pca_features, columns=pca_columns)
    # Map targets to PCs
    pca_df['target'] = y
    pca_df['target_names'] = pca_df['target'].map(target_names)
    csv_file = input("Name of pca dataframe csv file")
    # Save the DataFrame to a CSV file
    pca_df.to_csv(csv_file, index=False)

    # Get explained variance & covariance matrix
    print("explained variance")
    pca_ev = pca.explained_variance_ratio_
    print(pca.explained_variance_ratio_)
    print("covariance")
    pca_cov = pca.get_covariance()
    print(pca.get_covariance())
    var_dict = {"Explained Variance": pca_ev,
            "Covariance Matrix": pca_cov}
    pca_var_df = pd.DataFrame(var_dict)
    csv_file = input("Name of pca variance dataframe csv file")
    # Save the DataFrame to a CSV file
    pca_var_df.to_csv(csv_file, index=False)

    # Plot the explained variance of each principal component
    sns.set()
    plt.bar(range(1, len(pca_ev)+1), pca_ev)
    plt.xlabel('Number of Principal Components')
    plt.ylabel('Explained Variance (eignenvalues)')
    plt.title('Feature Explained Variance')  # Data
    plt.xticks(np.arange(1, ndims+1))
    csv_file = input("Name of explained variance csv file")
    plt.savefig(csv_file)
    plt.show()

    # Plot the cumulative explained variance of each principal component passed a threshold
    fig, ax = plt.subplots()
    x_axis = np.arrange(1, ndims+1, step=1)
    y_axis = np.cumsum(pca_ev)
    plt.ylim(0.0, 1.1)
    plt.plot(x_axis, y_axis, marker='o', linestyle='--', color='b')
    plt.xlabel('Number of Principal Components')
    plt.ylabel('Cumulative Variance Percentage')
    plt.title('Number of Components Needed to Explain Variance')  # Data
    plt.xticks(np.arange(0, ndims+1, step=1))
    plt.axhline(y=thres, color='r', linestyle='-')
    plt.text(0.5, 0.85, '95% Cut-Off Threshold', color='red', fontsize=16)
    csv_file = input("Name of cumulative explained variance csv file")
    plt.savefig(csv_file)
    plt.show()

    # Principal components correlation coefficients
    loadings = pca.components_
    # Number of features before PCA
    n_features = pca.n_features_
    # PC names
    pc_list = [f'PC{i}' for i in list(range(1, n_features + 1))]
    # Match PC names to loadings
    pc_loadings = dict(zip(pc_list, loadings))
    # Matrix of corr coefs between feature names and PCs
    loadings_df = pd.DataFrame.from_dict(pc_loadings)
    loadings_df['feature_names'] = feature_names
    loadings_df = loadings_df.set_index('feature_names')
    # Show dataframe with the loadings (correlation coefficients)
    print(loadings_df)
    csv_file = input("Name of loadings dataframe csv file")
    # Save the DataFrame to a CSV file
    loadings_df.to_csv(csv_file, index=False)

    # 3D Visualizations
    if ndims == 3:
        # 3D Visualization of explained variance
        plt.style.use('default')
        # Prepare 3D graph
        fig = plt.figure()
        ax = plt.axes(projection='3d')
        # Plot Pca features of pca df
        pca1 = pca_df['PC1']
        pca2 = pca_df['PC2']
        pca3 = pca_df['PC3']
        # Plot 3d plot
        ax.scatter3D(pca1, pca2, pca3, c=pca3, cmap='viridis')
        plt.title('3D Scatter of Iris')
        # Plot pc1, pc2, pc3 labels
        ax.set_xlabel('PC1', rotation=150)
        ax.set_ylabel('PC2')
        ax.set_xlabel('PC3', rotation=60)
        csv_file = input("Name of 3d explained variance csv file")
        plt.savefig(csv_file)
        plt.show()

        # 3D Biplot
        # Create the scaled PCA dataframe
        pca_df_scaled = pca_df.copy()
        scaler_df = pca_df[['PC1', 'PC2', 'PC3']]
        scaler = 1 / (scaler_df.max() - scaler_df.min())
        for index in scaler.index:
            pca_df_scaled[index] *= scaler[index]
        # Initialize the 3D graph
        fig = plt.figure()
        ax = fig.add_subplot(111, projection='3d')
        # Define scaled features  as arrays
        pca1 = pca_df_scaled['PC1']
        pca2 = pca_df_scaled['PC2']
        pca3 = pca_df_scaled['PC3']
        # Plot 3d plot
        ax.scatter3D(pca1, pca2, pca3, c=pca3, cmap='Greens', alpha=0.5)
        # Define the pc1, pc2, pc3 variables
        loadings = pca.components_
        xpca1 = loadings[0]
        xpca2 = loadings[1]
        xpca3 = loadings[2]
        # Plot the loadings
        for i, varnames in enumerate(feature_names):
            ax.scatter(xpca1[i], xpca2[i], xpca3[i], s=200)
            ax.text(xpca1[i], xpca2[i], xpca3[i], varnames)
        # Plot the arrows
        x_arr = np.zeros(len(loadings[0]))
        y_arr = z_arr = x_arr
        ax.quiver(x_arr, y_arr, z_arr, xpca1, xpca2, xpca3)
        # Plot title the graph
        plt.title("3D Biplot of PCA")
        # Plot pc1, pc2, pc3 labels
        ax.set_xlabel('PC1', rotation=150)
        ax.set_ylabel('PC2')
        ax.set_xlabel('PC3', rotation=60)
        csv_file = input("Name of 3d biplot csv file")
        plt.savefig(csv_file)
        plt.show()



    # 2D Visualizations
    elif ndims == 2:
        # Plot 2D PCA Graph
        sns.set()
        sns.lmplot(x='PC1', y='PC2', data=pca_df, hue='target', fit_reg=False, legend=True)
        plt.title('2D PCA Graph')
        csv_file = input("Name of 2d pca graph csv file")
        plt.savefig(csv_file)
        plt.show()

        # Loading plots with scatter data
        # Define the pc1, pc2 variables
        loadings = pca.components_
        # Get the loadings of x and y axes
        pca1 = loadings[0]
        pca2 = loadings[1]
        # Plot the loadings on a scatterplot
        for i, varnames in enumerate(feature_names):
            plt.scatter(pca1[i], pca2[i], s=200)
            plt.arrow(
                0, 0,  # coordinates of arrow base
                pca1[i],  # length of the arrow along x
                pca2[i],  # length of the arrow along y
                color='r',
                head_width=0.01
            )
            plt.text(pca1[i], pca2[i], varnames)
        # Define the axes
        xticks = np.linspace(-0.8, 0.8, num=5)
        yticks = np.linspace(-0.8, 0.8, num=5)
        plt.xticks(xticks)
        plt.yticks(yticks)
        plt.xlabel('PC1')
        plt.ylabel('PC2')
        # Show plot
        plt.title('2D Loading plot with vectors')
        csv_file = input("Name of 2d loading plot csv file")
        plt.savefig(csv_file)
        plt.show()

        # 2D Biplot
        # Create the scaled PCA dataframe
        pca_df_scaled = pca_df.copy()
        scaler_df = pca_df[['PC1', 'PC2', 'PC3']]
        scaler = 1 / (scaler_df.max() - scaler_df.min())
        for index in scaler.index:
            pca_df_scaled[index] *= scaler[index]
        sns.set()
        sns.lmplot(
            x='PC1',
            y='PC2',
            data=pca_df_scaled,
            fit_reg=False,
        )

        for i, varnames in enumerate(feature_names):
            plt.scatter(pca1[i], pca2[i], s=200)
            plt.arrow(
                0, 0,  # coordinates of arrow base
                pca1[i],  # length of the arrow along x
                pca2[i],  # length of the arrow along y
                color='r',
                head_width=0.01
            )
            plt.text(pca1[i], pca2[i], varnames)

        xticks = np.linspace(-0.8, 0.8, num=5)
        yticks = np.linspace(-0.8, 0.8, num=5)
        plt.xticks(xticks)
        plt.yticks(yticks)
        plt.xlabel('PC1')
        plt.ylabel('PC2')
        plt.title('2D Biplot')
        csv_file = input("Name of 2d biplote csv file")
        plt.savefig(csv_file)
        plt.show()

def friedmantest(data, cond_names):
    stats_df = data.copy()
    stats_df['Test Statistic'] = 0
    stats_df['P Value'] = 0
    for i in range(len(data)):
        samples = data.iloc[i, 'Samples']
        test_stat, pval = friedmanchisquare(samples)
        print("Test-stat:", test_stat, "P-value:", pval)
        stats_df.loc[i, 'Test Statisic'] = test_stat
        stats_df.loc[i, 'P Value'] = pval
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

def hyperplot(*data, n_iter, ndims, labels, label_names, reduce='IncrementalPCA',
                                            align='hyper', internal_reduce='IncrementalPCA'):

    title = input("What is the title of hyper plot")
    png_file = input("What is name of hyper plot png file")
    mp4_file = input("What is name of hyper plot mp4 file")

    if len(data) == 1:
        if type(data) == list:
            alignedlist = []
            # Loop each dataframe in the dataframe list
            for x in data:
                # step 1: reduce dataset before aligning (runs much faster)
                reduced_data = hyp.reduce(x, reduce=internal_reduce, ndims=ndims)
                # step 2: smooth trajectories so they look prettier
                smoothed_data = tc.smooth(reduced_data, kernel_fun=tc.helpers.gaussian_weights,
                                          kernel_params={'var': 3})
                # step 3: align trajectories
                aligned_data = smoothed_data
                alignedlist.append(np.array(aligned_data))
            for i in range(n_iter):
                # aligned_data = hyp.align([np.array(aligned_data), np.array(aligned_data2)], align=align)
                hyperalignedlist = hyp.tools.align(alignedlist, align=align)

            hyp.plot(hyperalignedlist, reduce=reduce, legend=label_names, title=title,
                     save_path= png_file)

            hyp.plot(hyperalignedlist, reduce=reduce, legend=False, title=title, animate=True,
                     save_path= mp4_file)
        else:
            # step 1: reduce dataset before aligning (runs much faster)
            reduced_data1 = hyp.reduce(data, reduce=internal_reduce, ndims=ndims)

            # step 2: smooth trajectories so they look prettier
            smoothed_data1 = tc.smooth(reduced_data1, kernel_fun=tc.helpers.gaussian_weights, kernel_params={'var': 3})

            # step 3: align trajectories
            # aligned_data1 = smoothed_data1
            hyp.plot(smoothed_data1, group=labels, legend=label_names,
                     title=title, size=[10, 10],
                     save_path= png_file)
            # MP4
            hyp.plot(smoothed_data1, group=labels, legend=False,
                     title=title, animate=True,
                     save_path= mp4_file)

    if len(data) == 2:
        if type(data[0]) == list:
            alignedlist1 = []
            alignedlist2 = []
            # Loop each dataframe in the dataframe list
            for x in data[0]:
                # step 1: reduce dataset before aligning (runs much faster)
                reduced_data = hyp.reduce(x, reduce=internal_reduce, ndims=ndims)
                # step 2: smooth trajectories so they look prettier
                smoothed_data = tc.smooth(reduced_data, kernel_fun=tc.helpers.gaussian_weights,
                                          kernel_params={'var': 3})
                # step 3: align trajectories
                aligned_data = smoothed_data
                alignedlist1.append(np.array(aligned_data))
            for x in data[1]:
                # step 1: reduce dataset before aligning (runs much faster)
                reduced_data = hyp.reduce(x, reduce=internal_reduce, ndims=ndims)
                # step 2: smooth trajectories so they look prettier
                smoothed_data = tc.smooth(reduced_data, kernel_fun=tc.helpers.gaussian_weights,
                                          kernel_params={'var': 3})
                # step 3: align trajectories
                aligned_data = smoothed_data
                alignedlist2.append(np.array(aligned_data))

            for i in range(n_iter):
                # aligned_data = hyp.align([np.array(aligned_data), np.array(aligned_data2)], align=align)
                hyperalignedlist = hyp.tools.align([np.array(alignedlist1), np.array(alignedlist2)], align=align)

            hyp.plot(hyperalignedlist, reduce=reduce, legend=label_names, title=title,
                     save_path=png_file)

            hyp.plot(hyperalignedlist, reduce=reduce, legend=False, title=title, animate=True,
                     save_path=mp4_file)
        else:
            # step 1: reduce dataset before aligning (runs much faster)
            reduced_data1 = hyp.reduce(data[0], reduce=internal_reduce, ndims=ndims)
            reduced_data2 = hyp.reduce(data[1], reduce=internal_reduce, ndims=ndims)
            # step 2: smooth trajectories so they look prettier
            smoothed_data1 = tc.smooth(reduced_data1, kernel_fun=tc.helpers.gaussian_weights, kernel_params={'var': 3})
            smoothed_data2 = tc.smooth(reduced_data2, kernel_fun=tc.helpers.gaussian_weights, kernel_params={'var': 3})
            # step 3: align trajectories
            aligned_data1 = smoothed_data1
            aligned_data2 = smoothed_data2
            for i in range(n_iter):
                alignedlist = hyp.tools.align([np.array(aligned_data1), np.array(aligned_data2)], align=align)
            # PNG:
            hyp.plot(alignedlist, reduce=reduce, legend=label_names,
                     title=title, size=[10, 10],
                     save_path= png_file)
            # MP4
            hyp.plot(alignedlist, reduce=reduce, legend=False,
                     title=title, animate=True,
                     save_path = mp4_file)

# ----------------------------------------------------------------------
#                               main code
# ----------------------------------------------------------------------
def main():
    # iEEG data directory
    data = "/Users/evansalvarez/PycharmProjects/iEEG Data Analysis/{}/Analysis/{}/Data/"
    # Collect all class labels from subject number trial info csv
    task_info = '/Users/evansalvarez/PycharmProjects/iEEG Data Analysis/sub01/broadband_trialinfo.csv'
    # Trial numbers
    trial_labels = getclasslabels(task_info, 'trial')

    # Stimuli label phase labels
    # Stimuli phase setup
    phase_dict = {
        1: 101,
        2: 100,
        3: 100,
        4: 100
    }
    phase_labels = phaseclass(phase_dict)
    mapping_dict = {1: '0-999ms', 2: '1000-1999ms', 3: '2000-2999ms', 4: '3000-3999ms'}
    mapped_list = [mapping_dict[value] for value in phase_labels]
    phase_names = list(set([mapped_list]))

    columns = ["Subject ID", "Electrode", "Electrode Name", "Frequency", "Samples"]
    stats_df = pd.DataFrame(columns=columns)

    for sub in subjects:
        for freq in freq_time:
            for chan, chan_name in channels.items():
                print('check: current subject number and electrode channel')
                print(sub, freq, chan)
                datadir = directory(data, sub, freq, chan)
                dataframe = dataload(datadir, trial_labels)
                print('check: current loaded dataframe')
                print(dataframe.shape)
                hyper_analyze(dataframe)
                # Hyerplot phases trial movement
                hyperplot(dataframe, n_iter, ndims, phase_labels, phase_names)
                pca_analyze(dataframe, phase_labels, mapping_dict)
                dataframe_timeblocks = group_tblock(dataframe, 4, [[0, 100], [101, 201], [201, 301], [301, 401]])
                # Append new stats dataframe row
                data = [sub, chan, chan_name, freq, dataframe_timeblocks]
                stats_df = stats_df.append(pd.Series(data), ignore_index=True)

    friedmantest(stats_df, phase_names)

if __name__ == "__main__":
    main()
