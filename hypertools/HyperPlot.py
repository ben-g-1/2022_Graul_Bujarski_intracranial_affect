# Notes:
#   1. Maybe not need the internal reduce
#   2. How to set csv-file and hyperplot title
#   3. How keep sub, freq, chan, and chankey info

# *data {Dataframes} one or two dataframes of before reduced data
#  n_iter {Int} number of iterations for alignment step
# ndims {Int} number of dimensions to redudce data to
# labels {Series, List} the group of labels to for the group parameter
# label_names {List} the list of labels names to for the legend parameter
#   (list(set(labels))) and map numbers to label names

# reduce {String} dimension reduction method during plot step
# internal reduce {String} dimension reduction method before alignment
# Other supported reduction models include: PCA, IncrementalPCA, SparsePCA, MiniBatchSparsePCA, KernelPCA, FastICA,
# FactorAnalysis, TruncatedSVD, DictionaryLearning, MiniBatchDictionaryLearning, TSNE, Isomap, SpectralEmbedding, LocallyLinearEmbedding, MDS, UMA

# align {String} alignment emthod
# If str, either 'hyper' or 'SRM'.  If 'hyper', alignment algorithm will be
#         hyperalignment. If 'SRM', alignment algorithm will be shared response
#         model.

import timecorr as tc
import hypertools as hyp
import numpy as np

def hyperplot(*data, n_iter, ndims, labels, label_names, reduce='IncrementalPCA',
                                            align='hyper', internal_reduce='IncrementalPCA'):

    title = input("What is the title of hyper plot")
    png_file = input("What is name of hyper plot csv file")

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
                     save_path= png_file)
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
                     save_path= png_file)

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
                     save_path=png_file)
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
                     save_path = png_file)
