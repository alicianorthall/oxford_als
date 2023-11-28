## Script name: rest_fmri_4_fslnets
# Script purpose: This script performs inter-network connectivity analyses using FSLNets in an FSL python environment.
# Written by Alicia Northall (Nov2023)

## Section 1: Run FSLNets.
    # see script rest_fmri_3_pre_fslnets to prepare data and environment
    matplotlib # configure matplotlib for plotting
    from fsl import nets # import the fslnets package
    # nets.__path__ # check which fslnets is being used
    # PYTHONPATH=/vols/Data/als/Alicia/data/fslnets fslipython # import the updated fslnets package (installed locally) - Chet

## Section 1A: Load networks.
    # Estimate networks. Set TR (here 0.74
    # gunzip *stage1*.gz # for some reason, all of my dual regression outputs were automatically zipped and cannot be accessed by fslnets
    ts = nets.load('groupICA20.dr', 0.74, varnorm=0, thumbnaildir='groupICA20.sum'); 

## Section 1B: Clean networks (optional).
    nets.plot_spectra(ts); # QC: insepct temporal spectra of the RSNs
    # # identify noise components based on visual inspection - create a list of good components starting from 0 (goodnodes)
    # goodnodes = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
    # nets.clean(ts, goodnodes, True) # clean components

## Section 1C: Calculate single-subject netmats
    Fnetmats = nets.netmats(ts, 'corr', True) # calculate full correlation netmats
    Pnetmats = nets.netmats(ts, 'ridgep', True, 0.1) # calculate partial correlation netmats

## Section 1D: Calculate group-averaged netmats
    # This calculates both the simple average of netmats across all subjects (Mnet) and the results of a simple one-group t-test (against zero) across subjects as Z values (Znet)
    Znet_F, Mnet_F = nets.groupmean(ts, Fnetmats, False) # calculate full correlation netmat
    Znet_P, Mnet_P = nets.groupmean(ts, Pnetmats, True, 'Partial correlation') # calculate partial correlation netmat, show plot with title
    # see FSLNets practical instructions for plot info

    # Group average network hierarchy
    # this considers how nodes cluster together to form larger RSNs. For this, we run a clustering method that groups nodes together based on their covariance structure.
    nets.plot_hierarchy(ts, Znet_F, Znet_P, 'Full correlations', 'Partial correlations') # display network hierarchy grid plot
    nets.web(ts, (Znet_F, Znet_P), ('Full correlation', 'Partial correlation')) # display network hierarchy plot as dendogram 
    # see FSLNets practical instructions for plot info

## Section 1E: Cross-subject comparison
    # This compares each edge in the netmat between groups (patients and controls)
    # Use design file from dual regression
    p_corr,p_uncorr = nets.glm(ts, Fnetmats, 'design.mat', 'design.con');
    p_corr,p_uncorr = nets.glm(ts, Pnetmats, 'design.mat', 'design.con');
    # see FSLNets practical instructions for plot info
    nets.boxplots(ts, Pnetmats, Znet_P, p_corr[0], groups=(6, 6)) 
    # this shows which nodes and edges were linked to the strongest differences between the groups.

## Section 2: Mutlivariate cross-subject analysis
    nets.classify(Pnetmats, (32,22))
    # see FSLNets practical instructions for plot info

exit # to exit the python environment

## End of script