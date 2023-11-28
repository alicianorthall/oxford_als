## Script name: rest_fmri_preprocess
# Script purpose: This script performs the preprocessing steps (e.g., subject and group level cleaning) on resting-state fMRI data.
# Written by Alicia Northall (Oct2023)

## Section 1: Prepare data.
cd /vols/Data/als/Alicia/data
for dir in */; do
    (
        # Prepare resting state images
        cd /vols/Data/als/Alicia/data
        echo $dir
        cd $dir 
        cd fmap
        mv images_05_MB8_FMRI_fov210_2.4mm_resting.nii rest_functional.nii # rename resting 4D (multi-band) image
        mv images_04_MB8_FMRI_fov210_2.4mm_resting.nii rest_reference.nii # rename resting 3D (single-band) image
        # Prepare structural image
        cd /vols/Data/als/Alicia/data
        echo $dir
        cd $dir 
        cd anat
        mv images_02_t1_mpr_ax_1mm_iso_withNose_32ch_v2.nii structural.nii # rename structural image
        bet structural.nii structural_brain.nii -m -f 0.2 # brain extract structural image
        # Prepare field map image
        cd /vols/Data/als/Alicia/data
        cd $dir 
        cd fmap
        mv images_06_fieldmap_210FoV_2.4mm_e1.nii mag.nii # rename magnitude imae
        mv images_07_fieldmap_210FoV_2.4mm_e2_ph.nii phase.nii # rename phase image
        bet mag.nii mag_brain.nii -m -f 0.2 # brain extract magnitude image
        fsl_prepare_fieldmap SIEMENS phase.nii mag_brain.nii fmap_rads 2.46 # create field map
    )
done 

## Section 2: Single-subject ICA.
# note that this is done manually using the Melodic GUI - MANUAL (follow instructions):
    # Navigate to subject directory and load GUI by typing Melodic. 
    # Data tab: load 4D file (rest_functional.nii) 
    # Pre-stats tab: select B0 warping, load field map (fmap.nii.gz), load brain-extracted magnitude image (mag_brain.nii.gz), set effective echo spacing (0.64 ms) and EPI TE (39 ms)
    # Pre-stats tab: select alternative reference image, load the high-contrast 3D reference image (rest_reference.nii)
    # Registration tab: select main structural image, load the brain-extracted structural image (structural_brain.nii.gz)

## Section 3: Train and apply FIX to clean the single-subject data - MANUAL (follow instructions here)
    # Section 3A: Manual classify ICA components 
    # Use the fsleyes Melodic GUI to classify components for 20 subjects (10 PAT, 10 CON).
    fsleyes --scene melodic -ad filtered_func_data.ica & # open fsleyes in melodic mode, manually label components (signal or unclassified noise) and save as labels.txt

    # Section 3B: Train FIX on the study-specific manually classified data.
    cd /vols/Data/als/Alicia/data
    for dir in */; do
        (
        echo $dir
        cd $dir
        cd rest.ica/filtered_func_data.ica
        tail -n 1 labels.txt > /vols/Data/als/Alicia/data/$dir/rest.ica/hand_labels_noise.txt # create list of noise components from the labels text file
        )
    done 

    # If you want to clean a single dataset after manual classification - edit noise components list
    # fsl_regfilt -i filtered_func_data.nii.gz -d filtered_func_data.ica/melodic_mix -o filtered_func_data_clean.nii.gz -f "1, 2, 3, 4, 5, 9, 11, 12, 13, 14, 17, 18, 23, 24, 26, 27, 28, 31, 32, 34, 37, 38, 39, 40, 42, 43, 46, 47, 48, 49, 51, 53, 54, 56, 57, 58, 59, 61, 62, 63, 65, 66, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89"

    # Example training code for context: /usr/local/fix/fix -t <Training> [-l]  <Melodic1.ica> <Melodic2.ica> ...
    /home/fs0/steve/NETWORKS/fix/fix -t ALS_HC_3T_106 -l /vols/Data/als/Alicia/data/001/rest.ica /vols/Data/als/Alicia/data/002/rest.ica /vols/Data/als/Alicia/data/003/rest.ica /vols/Data/als/Alicia/data/004/rest.ica /vols/Data/als/Alicia/data/005/rest.ica /vols/Data/als/Alicia/data/008/rest.ica /vols/Data/als/Alicia/data/011/rest.ica /vols/Data/als/Alicia/data/016/rest.ica /vols/Data/als/Alicia/data/018/rest.ica /vols/Data/als/Alicia/data/019/rest.ica /vols/Data/als/Alicia/data/006/rest.ica /home/fs0/hpc655/scratch/W3T_2022_106/009/rest.ica /vols/Data/als/Alicia/data/010/rest.ica /vols/Data/als/Alicia/data/020/rest.ica /vols/Data/als/Alicia/data/022/rest.ica /vols/Data/als/Alicia/data/025/rest.ica /vols/Data/als/Alicia/data/028/rest.ica /vols/Data/als/Alicia/data/032/rest.ica /vols/Data/als/Alicia/data/034/rest.ica /vols/Data/als/Alicia/data/036/rest.ica
    # note that you must use the full paths to the melodic dirs

    # Section 3C: Quality check of trained FIX compared to manual classifications in two new datasets (1 PAT, 1 CON)
    # Manual classification of new subject
    fsleyes --scene melodic -ad /vols/Data/als/Alicia/data/037/rest.ica/filtered_func_data.ica & # open fsleyes in melodic mode, manually label components and save as labels.txt
    # Run trained FIX (combined stages)
    fsl_sub /home/fs0/steve/NETWORKS/fix/fix /vols/Data/als/Alicia/data/037/rest.ica /vols/Data/als/Alicia/data/ALS_HC_3T_106.RData 20 -m  # FULL SCRIPT: to identify, classify and clean
    # Run trained FIX (separate stages, if combined does not work)
    # fsl_sub /home/fs0/steve/NETWORKS/fix/fix -f rest.ica # SUB-SCRIPT: this step identifies the components
    # fsl_sub /home/fs0/steve/NETWORKS/fix/fix -c /vols/Data/als/Alicia/data/037/rest.ica /vols/Data/als/Alicia/data/ALS_HC_3T_106.RData 20 # SUB-SCRIPT: this step classifies components
    # fsl_sub /home/fs0/steve/NETWORKS/fix/fix -a /vols/Data/als/Alicia/data/037/rest.ica/fix4melview_ALS_HC_3T_106_thr20.txt -m # SUB-SCRIPT: this step cleans the data

    # Section 3D: Run trained-FIX.
    # run FIX using the study-specific training dataset - run on all subjects (including those you did manual classification on)
    cd /vols/Data/als/Alicia/data
    for dir in */; do
        (
            cd /vols/Data/als/Alicia/data
            echo $dir
            cd $dir 
            fsl_sub /home/fs0/steve/NETWORKS/fix/fix /vols/Data/als/Alicia/data/$dir/rest.ica /home/fs0/hpc655/scratch/ALS_HC_3T_106.RData 20 -m  # run FIX (batch on fsl_sub)
        )
    done 

## Section 4: Registration to standard space.
    # note that all data must be in the same space before running the group ICA
    cd /vols/Data/als/Alicia/data
    for dir in */; do
        (
        cd /vols/Data/als/Alicia/data/$dir 
        echo $dir
        flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -in anat/structural_brain.nii.gz -omat rest.ica/reg/my_affine_transf.mat # estimate linear transform (structural to standard)
        fnirt --in=anat/structural_brain.nii.gz --aff=rest.ica/reg/my_affine_transf.mat --cout=rest.ica/reg/my_nonlinear_transf --config=T1_2_MNI152_2mm # estimate non-linear transform (structural to standard)
        fsl_sub applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=rest.ica/filtered_func_data_clean.nii.gz --warp=rest.ica/reg/my_nonlinear_transf --premat=rest.ica/reg/example_func2highres.mat --out=rest.ica/filtered_func_data_clean_standard.nii.gz
        # use applywarp to apply both transforms in one step from function to standard space (use fsl_sub to batch this)
        )
    done

## Section 5: Group ICA.
    cd /vols/Data/als/Alicia/data
    ls -1 */*rest.ica/filtered_func_data_clean_standard.nii.gz >> input_files.txt # get txt list of cleaned data for all subjects
    melodic -i input_files.txt -o groupICA20 --tr=0.72 --nobet -a concat -m $FSLDIR/data/standard/MNI152_T1_2mm_brain_mask.nii.gz --report --Oall -d 20
    # note that you need to investigate different component thresholds (here -d 20 means that the data are decomposed into 20 components) - if you change this then reaname the output folder (-o)
    # note that you need to set the tr for the study

## Section 6: Clean group ICA data.
    # note that you need to inspect the group melodic components (here for thr = 20) and identify the noise components
    cd /vols/Data/als/Alicia/data/groupICA20
    # fsleyes -std groupICA20/melodic_IC -un -cm -red-yellow -nc blue-lightblue -dr 4 15 # view group melodic components - identify noise components and list below
    fslsplit melodic_IC.nii.gz # split 4D image into 3D volumes
    mkdir noise_group_IC_components # create dir for noise components
    mv vol0011.nii.gz vol0013.nii.gz vol0015.nii.gz vol0016.nii.gz vol0017.nii.gz noise_group_IC_components/ # move noise components to respective directory - edit this list accordingly
    mkdir signal_group_IC_components # create dir for signal components
    mv vol* signal_group_IC_components/ # move signal components to respective directory (to reduce clutter)
    fslmerge -t melodic_IC_clean.nii.gz signal_group_IC_components/vol* # merge signal components to create cleaned group melodic 4D image