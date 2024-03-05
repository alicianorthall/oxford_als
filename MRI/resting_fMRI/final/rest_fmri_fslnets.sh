## Script name: rest_fmri_fslnets
# Script purpose: This script performs inter-network connectivity analyses using FSLNets in an FSL python environment.
# NOTE: THIS CODE MUST BE MANUALLY ENTERED INTO THE TERMINAL!!!

# Written by Alicia Northall, University of Oxford, 11.2023

## Set up environment
./rest_fmri_prep_fslnets.sh # prepare files and start python environment
matplotlib # configure matplotlib for plotting
from fsl import nets # import the fslnets package

## Debugging notes
# nets.__path__ # check which fslnets is being used
# PYTHONPATH=/vols/Data/als/users/alicia/data/fslnets fslipython # import the updated fslnets package (installed locally)

## Estimate networks
# ls -1 *dr_stage1_* >> nets_input_files.txt
# ts = nets.load(nets_input_files.txt, 0.74, varnorm=0, thumbnaildir='groupICA20.sum'); # set study-specific TR
# gunzip *stage1*.gz # for some reason, all of my dual regression output were automatically zipped and cannot be accessed by fslnets
ts = nets.load('groupICA20.dr', 0.74, varnorm=0, thumbnaildir='groupICA20.sum'); 
ts = nets.load('groupICA30.dr', 0.74, varnorm=0, thumbnaildir='groupICA30.sum'); 

## Clean components
nets.plot_spectra(ts); # QC: insepct temporal spectra of the RSNs
# goodnodes = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14] # edit list of good components
# nets.clean(ts, goodnodes, True) # clean components

## Calculate netmats
# Single-subject netmats
Fnetmats = nets.netmats(ts, 'corr', True) # calculate full correlation netmats
Pnetmats = nets.netmats(ts, 'ridgep', True, 0.1) # calculate partial correlation netmats

# Group-averaged netmat
# This calculates both the simple average of netmats across all subjects (Mnet) and the results of a simple one-group t-test (against zero) across subjects as Z values (Znet)
Znet_F, Mnet_F = nets.groupmean(ts, Fnetmats, False) # calculate full correlation netmat
Znet_P, Mnet_P = nets.groupmean(ts, Pnetmats, True, 'Partial correlation') # calculate partial correlation netmat, show plot with title
# Plot info: left show results from group t-test, right shows a consistency plot showing how similar the results from each subject are to the group (i.e., more diagonal = more consistent across subjects)

## Network hierarchy
# This considers how nodes cluster together to form larger RSNs. For this, we run a clustering method that groups nodes together based on their covariance structure
nets.plot_hierarchy(ts, Znet_F, Znet_P, 'Full correlations', 'Partial correlations') # display network hierarchy grid plot
# Plot info: note that this is not a statistical test and is just for visualisation. Also note that the full corrrelation drives the clustering and the partial correlation is just shown for comparsion
nets.web(ts, (Znet_F, Znet_P), ('Full correlation', 'Partial correlation')) # display network hierarchy plot as dendogram 
# Plot info: This page displays the same clustered node hierarchy arranged in a circle, with the top of the hierarchy (the root) in the centre, and the nodes (the leaves) around the perimeter
# Note that you can click on a node to highlight the connectivity from that node to its most strongly connected neighbours

## Cross-subject comparison
# This compares each edge in the netmat between groups (patients and controls), using the design files created for dual regression
p_corr,p_uncorr = nets.glm(ts, Fnetmats, 'design.mat', 'design.con');
p_corr,p_uncorr = nets.glm(ts, Pnetmats, 'design.mat', 'design.con');
# Plot info: this results in a matrix of p-values, where the upper triangle shows only the significant group differences while the lower triangle shows all group comparisons (with correction for mutliple comparisons)

## Dispalying significant group differences
# This shows which nodes and edges were linked to the strongest differences between the groups.
nets.boxplots(ts, Pnetmats, Znet_P, p_corr[0], groups=(6, 6)) 
# Plot info: Each pair of thumbnails corresponds to one position in the NxN network matrix and the node numbers are listed in the text captions
# The coloured bar joining each pair of nodes tells you what the overall group-average connection strength is: thicker means a stronger connection; red means it's positive, and blue means that the connection is "negative" (meaning that the two nodes tend to anti-correlate on average)
# The "P value" numbers tell you the 1-p-values - so the higher these are, the more significantly different this edge strength is between the two groups. Anything less than 0.95 is not significant, after correcting for multiple comparisons
# The plots on the right show how the partial correlation differs between the patients and the controls for each of the edges with the strongest group difference
# The plots summarise the distributions of the correlation values (connection strengths) in the two groups - Group 1 being healthy controls in this data, and Group 2 being patients - for each node-pair

## Mutlivariate cross-subject analysis
nets.classify(Pnetmats, (32,27))
# This considers the whole netmat, rather than each netmat edge in isolation (as above). 
# For example, we can attempt to classify subjects into patients or controls using machine learning methods, such as support vector machines (SVM) or linear discriminant analysis (LDA)
# Such methods look at the overall pattern of values in the netmat, and try to learn how the overall pattern changes between the two groups
# The following command feeds the regularised partial correlation netmats from both groups into LDA
# It uses a method known as leave-one-out cross-validation to train and test a classifier, and reports in what percentage of tests it was successful at discriminating between patients and controls:

# Alternative approach
# You can use any other classifier available in scikit-learn by passing a third argument to nets.classify. For example, to use a random forest classifier:
from sklearn.ensemble import RandomForestClassifier
nets.classify(Pnetmats, (32, 27), RandomForestClassifier())
# Note: One "downside" of such multivariate testing is that you can no longer make strong statistical claims about individual edges in the network - the whole pattern of edges has been used, so we don't know which individual edges are significantly different in the two groups

exit # exit the python environment