# optical-quantal-analysis
Matlab functions to analyze iGluSnFR signals from single synapses

These matlab files were used to perform a quantal analyis on iGluSnFR data from Schaffer collateral boutons (Dürst et al., 2020).

_______________________
System requirements
_______________________

Personal computer (e.g. Intel Core i5-8500 CPU, 16 GB RAM)
Windows 10
Matlab R2017b

________________________
Installation guide
________________________

1) Download the .m files into a folder 
2) Include the folder in your matlab path

________________________
Demo
________________________

To load the provided demo data, type into the command line: BinoFit_LowHighCa(demodata, 1)

________________________
Instructions for use 
_________________________

BinoFit_LowHighCa(mydata, experiment) is designed to analyze data from boutons imaged under 2 conditions (high/low Ca2+).

mydata is a matlab array, organized in 4 colums per bouton: 
1) low Ca responses 2) no stim 3) high Ca responses 4) no stim

'responses' refer to the extracted peak of the iGluSnFR trace, 'no stim' is the amplitude of a fit to a section of the baseline fluorescence (before stimulation)

The 'experiment' variable allows loading data from individual boutons in large datasets containting datat from multiple boutons (in separate columns).
experiment=1 analyzes the first 4 columns (data from bouton #1)
experiment=2 analyzes column 5-8 (data from bouton #2), etc.



Created by Thomas Oertner, ZMNH Hamburg, Jan 2020
