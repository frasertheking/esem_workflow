# Earth System Model Emulation Workflow
## CNN and GP Regression Methods

This repository links multiple other Earth System Model (ESM) emulation libraries and scripts in both Python and R. Here, we provide an example script which covers data preprocessing, running the models and examining outputs. The primary emulators linked to in this work are: 

- Duncan Watson-Parris' ESEM (https://github.com/duncanwp/ESEm; https://gmd.copernicus.org/articles/14/7659/2021/gmd-14-7659-2021.html)
- Christopher G. Fletcher's Gaussian Process emulator (https://acp.copernicus.org/articles/18/17529/2018/)

## Overview

This workflow is broken into two primary component examples: i) CNN emulation with ESEM; and ii) GP Emulation in R. The main.py runscript couples both of these processes together by preprocessing example CESM output and feeding data into the model. 

While this workflow is set up for a specific exampl at f19 resolution with pre-industrial cam/clm and prescribed ice/ocn inputs to CESM, the CNN and GP are model agnostic and can work with other ESMs.

Example data is currently hosted on the University of Waterloo's Manabe server. For access to this data, please reach out to Chris Fletcher (chris.fletcher@uwaterloo.ca). It is recommended to just run an ESM on your own however to generate your own test output if you do not have access.

## Installation

After cloning this repo on Manabe, run the following commands to set up the Python environment:

```sh
conda env create -f esem_workflow.yml
conda activate esem_workflow
```

You can then run the test example using:

```sh
Python main.py
```

Which should load the example f19 data, perform the preprocessing and generate output using the ESEM CNN based on the provided 100 perturbed parameter runs.

## GP Regression Setup

The GP code is written in R and you'll need to install the following libraries in R Studio for the code to run:

- DiceKriging
- RNetCDF
- fields
- randtoolbox
- sensitivity

It is important to note that you must run the above main.py script first to generate the required inputs to the GP model. After installing these packages you can run the example in RStudio for the common.R script (or using the command line).

Outputs are saved from both scripts in the output or images folder, depending on what is being generated.
