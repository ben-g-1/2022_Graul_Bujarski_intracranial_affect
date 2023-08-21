# data {Dataframe} = dataframe that contains number of samples (rows) and feature or predictor variables (columns)
    # ex: timeblock, type of freq, ERP
# target {Dataframe, Series, List} = group of predicted variables
    # e.g: timeblock, type of freq, valence rating
# target_names {Dictionary} = maps the target name with target value
# ndims {Int} = number of pc components
# thres {Int} Threshold of  explained variance to determine number of principal components

import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
import seaborn as sns
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits import mplot3d
from mpl_toolkits.mplot3d import Axes3D

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
