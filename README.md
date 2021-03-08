# BSModel
Building Stock Model

![Tux, the Linux mascot](/BSModel/fig/icon_small.jpg)

This repository collects all the files that allows you to model building stock model projection based on the 

`` >> BSModel.mlapp ``

In order to run the building stock mode, one should build first the starting matrix to input into the model the building stock matric should be composed of 7 columns withthe following specs:

1. Column 1: contains ID number for the building from 1 to xxxx (number of buildings) initially.
2. Column 2: contains building group number for the building:
	-  1 = detached house
	-  2 = row house
	-  3 = apartment building
	-  4 = non-residential building
3. Third column contains number for contruction decade (original data) or year for the building:
	- 0  = unknown
	- 1  = before 1949
	- 2  = 1950-1959
	- 3  = 1960-1969
	- 4  = 1970-1979
	- 5  = 1980-1989
	- 6  = 1990-1999
	- 7  = 2000-2009
	- 8-43  = 2014-2049
4. Column 4: contains the volume (m3) of the building
5. Column 5: contains the characteristic heat demand (kWh/m3) of the building.
6. Column 6: contains the grace period (years) for renovation and demolition. If zero building can be renovated or demolished.
7. Column 7: contains energy efficiency coefficient. Initially 1.