# data = {Dataframe} dataframe or dataframes being analyzed
# normalize = {String}
# reduce = {String}
# ndims {Int} = number of pc components
# align = {String}
import seaborn as sns
import matplotlib.pyplot as plt
import hypertools as hyp
import numpy as np


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
