#!/bin/bash

#SBATCH --time=01:30:00  #walltime
#SBATCH --ntasks=1  # number of processor cores (i.e. tasks)
#SBATCH --nodes=1  # number of nodes
#SBATCH --mem-per-cpu=4gb # memory per CPU core
#SBATCH -J "preprocessing"  # job name

### Set up BIDS parent dirs
BIDS_dir=~/Dani/processed
for i in derivatives sourcedata stimuli rawdata; do
	if [ ! -d ${BIDS_dir}/$i ]; then
		mkdir -p ${BIDS_dir}/$i
	fi
done

cd ~/
### Do dcm2niix

for i in `cat ~/Dani/subj2.txt`; do

# set reference pathways

dicom_dir=Dani/SampleData/${i}/t1* \
work_dir=Dani/processed/SampleData/${i} \
anat_dir=${work_dir}/anat \


# make output directory
	if [ ! -d ${anat_dir} ]; then
		mkdir -p $anat_dir
	fi 

# check for nii.gz file

	if [ ! -f ${anatDir}/t1.nii.gz ]; then

		dcm2niix
		~/research_bin/dcm2niix/build/bin/dcm2niix \
		-b y \
		-ba y \
		-z y \
		-o ${anat_dir} \
		-f t1 \
		-x y \
		~/${dicom_dir}/
	fi

#done

### N4 Bias Field Correction
	if [ ! -f ${anatDir}/n4.nii.gz ]; then
		~/research_bin/antsbin/bin/N4BiasFieldCorrection \
		-v \
		-d 3 \
		-i ${anat_dir}/t1.nii.gz \
		-o ${anat_dir}/n4.nii.gz \
		-s 4 \
		-b [200] \
		-c [50x50x50x50,0.000001] 
	fi

#done

##Resample
~/research_bin/c3d/bin/c3d \
${anat_dir}/n4.nii.gz \
-resample-mm 1x1x1mm \
-o ${anat_dir}/resampled.nii.gz  

done
