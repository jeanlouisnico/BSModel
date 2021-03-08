# BSModel
Building Stock Model

![Tux, the Linux mascot](/BSModel/fig/icon_small.jpg)

This repository collects all the files that allows you to model building stock model projection based on the 

`` >> BSModel.mlapp ``

## Inputs ##

In order to run the building stock model, one should build first the starting matrix to input into the model the building stock matrix should be composed of 7 columns withthe following specs:

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


## Outputs ##

The BSModel outputs 6 main variables that can be used in the heat load model.

"**SIM\_vol**" (37x22x100)

Definition: Contains annual information on the volume of building stock, duplicated 100 times for sensitivity analysis of the simulation (randomness of the sample of building stock variation).
    
1. Column 1 is the year
1. Column 2 is the annual volume of the building stock
1. Column 3 is the annual volume of RB
1. Columns 4-6 are the annual volume of detached, row and apartment buildings
1. Column 7 is the annual volume of NRB
1. Column 8 is the annual volume of renovated RB
1. Columns 9-11 are the annual volume of renovated detached, row and apartment buildings
1. Column 12 is the annual volume of renovated NRB
1. Column 13 is the annual volume of demolished RB
1. Columns 14-16 are the annual volume of demolished detached, row and apartment buildings
1. Column 17 is the annual volume of demolished NRB
1. Column 18 is the annual volume of new RB
1. Columns 19-21 are the annual volume of new detached, row and apartment buildings
1. Column 22 is the annual volume of new NRB  

"**SIM\_rates**" (38x6x100)

Defintion: Contains annual and mean renovation, demolition and new building rates for RB and NRB

1. Columns 1-3 contain renovation, demolition and new building rates for RB
1. Columns 4-6 contain renovation, demolition and new building rates for NRB

"**SIM\_NRBs**" (37x5x100)

Defintion: Contains annual information on the number of NRB and the number of demolished, renovated and new NRB

1. First column is the year
1. Second column is the number of NRB at the start of the year
1. Columns 3-5 are the annual number of renovated, demolished and new NRB

"**SIM\_RBs**" (37x17x100)

Defintion: Contains annual information on the number of RB and the number of demolished, renovated and new RB

1. First column is the year
1. Second column is the number of RB at the start of the year
1. Columns 3-5 are the number of detached, row and apartment buildings at the start of the year
1. Columns 6-8 are the annual number of renovated, demolished and new RB
1. Columns 9-11 are the annual number of renovated, demolished and new detached houses
1. Columns 12-14 are the annual number of renovated, demolished and new row houses
1. Columns 15-17 are the annual number of renovated, demolished and new apartment buildings

## Reference ##

Dataset are available from 