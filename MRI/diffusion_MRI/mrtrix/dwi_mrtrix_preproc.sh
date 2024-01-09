# run dwifslpreproc
cd $DATA_DIR/*${sub}*/dwi/mrtrix
# dwifslpreproc 006_den.mif 006_den_preproc.mif -nocleanup -pe_dir AP -rpe_pair -se_epi b0_pair.mif -eddy_options " --slm=linear --data_is_shelled"
dwifslpreproc dwi_den.mif dwi_den_preproc.mif -nocleanup -pe_dir AP -rpe_pair -se_epi b0_pair.mif -eddy_options " --slm=linear --data_is_shelled"

# subjects=(001 002 003 004 005 006 007 008 009 010 011 013 014 015 016 017 018 019 020 022 023 024 025 026 027 028 029 030 031 032 033 034 035 036 037 038 039 040 041 042 043 044 045 046 047 048 049 050 051 052 053 054 055 056 057 058 059 060 061 062 063 064 065 066 068 069 070 071)
# subjects=(005)
# # Loop through each subject
# for subject in "${subjects[@]}"; do
#     (
#         cd /vols/Data/als/Alicia/mrtrix
#         echo $subject
#         cd $subject
#         # Preprocessing
#         dwifslpreproc $subject\_den.mif $subject\_den_preproc.mif -nocleanup -pe_dir AP -rpe_pair -se_epi b0_pair.mif -eddy_options " --slm=linear --data_is_shelled"
#         # mrview $subject\_den_preproc.mif -overlay.load $subject\.mif
#         # Bias correction and brain masking
#         dwibiascorrect ants $subject\_den_preproc.mif $subject\_den_preproc_unbiased.mif -bias bias.mif
#         dwi2mask $subject\_den_preproc_unbiased.mif mask.mif
#     ) 
# done