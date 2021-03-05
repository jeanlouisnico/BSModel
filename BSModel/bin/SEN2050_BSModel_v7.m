function [BS_matrix_new,BS_matrix_new30,RBs,NRBs,rates,vol]=SEN2050_BSModel_v7(BS_matrix,PARAMETER_matrix,population,areaP,RENO_matrix)
tic
%% INFO ON INPUT FILES
%_BS_matrix_% (3880x58)
    %BS_matrix contains data for all 3880 buildings included in the original
    %data.
    %First colu mn contains ID number for the building from 1 to 3880 initially.
    %Second column contains building group number for the building:
    %1 = detached house
    %2 = row house
    %3 = apartment building
    %4 = non-residential building
    %Third column contains number for contruction decade (original data) or year for the building:
    %0  = unknown
    %1  = before 1949
    %2  = 1950-1959
    %3  = 1960-1969
    %4  = 1970-1979
    %5  = 1980-1989
    %6  = 1990-1999
    %7  = 2000-2009
    %8-43  = 2014-2049 (15-16:30) 13:30:14:30 (30min 
    %Fourth column contains the volume (m3) of the building
    %Fifth column contains the characteristic heat demand (kWh/m3) of the
    %building.
    %Sixth column contains the grace period (years) for renovation and demolition. If zero building
    %can be renovated or demolished.
    %Seventh column contains energy efficiency coefficient. Initially 1.
    %Columns 8-58 contain information for the heat demand model.
%_PARAMETER_matrix_% (18x1)
    %PARAMETER_matrix contains variables affecting the renovation, demolition
    %and construction of buildings
    %PARAMETER_matrix(1)    = number of years calculated
    %PARAMETER_matrix(2)    = 1 if renovation is enabled, 0 if renovation is not
    %                         enabled
    %PARAMETER_matrix(3)    = mean value of normal distribution for modelling RB
    %                         renovation (years)
    %PARAMETER_matrix(4)    = annual renovation rate for NRB (%)
    %PARAMETER_matrix(5)    = grace period for renovation and demolition (years)
    %PARAMETER_matrix(6)    = energy efficiency improvement after renovation (%)
    %PARAMETER_matrix(7-9)  = parameters of the Weibull distribution for modelling RB demolition
    %PARAMETER_matrix(10)   = annual demolition rate for NRB (%)
    %PARAMETER_matrix(11)   = parameter for correlation between RB volume
    %                         and floor area
    %PARAMETER_matrix(12-14)= share of the volume of detached, row and apartment buildings among new RB (%)
    %PARAMETER_matrix(15)   = allowed error for calculation of the volume of new buildings (%)
    %PARAMETER_matrix(16)   = energy efficiency improvement for new
    %                         buildings built before 2020
    %PARAMETER_matrix(17)   = energy efficiency improvement for new
    %                         buildings built after 2020
    %PARAMETER_matrix(18)   = annual volume of new NRB compared with new RB (%)
%_population_% (37x1)
    %Annual population from 2013 to 2049 (length is PARAMETER_matrix(1)+1)
%_areaP_% (37x1)
    %Annual floor are per person from 2013 to 2049 (length is PARAMETER_matrix(1)+1)
%_RENO_matrix_% (5x1)
    %RENO_matrix contains information on the evolution of renovastion rate
    %Rates for 2030 and 2050 are defined
    %RENO_matrix(1)     = 1 if renovation rate changes, 0 if not
    %RENO_matrix(2)     = renovation rate for 2030
    %RENO_matrix(3)     = renovation rate for 2049
    if RENO_matrix(1)==1
        RENO_NRB=fit([1;17;36],[PARAMETER_matrix(4);RENO_matrix(2);RENO_matrix(3)],'linearinterp');
    end
%_outtemp20(30/50)_% (25x744)
    %Outdoor temperatures for 2030 and 2050
    %Rows 1:2       Cold2010_ECEM_RCP(45/85)
    %Rows 3:5       Cold2010_Paituli_RCP(26/45/85)
    %Rows 6:7       TMY_ECEM_RCP(45/85)
    %Rows 8:10      TMY_Paituli_RCP(26/45/85)
    %Rows 11:12     TMY2004_2018_ECEM_RCP(45/85)
    %Rows 13:15     TMY2004_2018_Paituli_RCP(26/45/85)
    %Rows 16:17     TRY2012_ECEM_RCP(45/85)
    %Rows 18:20     TRY2012_Paituli_RCP(26/45/85)
    %Rows 21:22     Warm2008_ECEM_RCP(45/85)
    %Rows 23:25     Warm2008_Paituli_RCP(26/45/85)
%_time20(30/50)_% (2x744)
    %Row 1      Hour of the day (0:23)
    %Row 2      Binary value for weekend/holiday (=1) or weekday (=0)
%% INFO ON OUTPUT FILES
%_BS_matrix_new_% (7000x58)
    %Contains same information as BS_matrix but for 2050, some buildings have been
    %demolished or renovated and new buildings have been added.
    %BS_matrix_new has always 7000 rows to allow multiple simulation runs' output be saved in same file. Number of actual buildings can vary.
%_BS_matrix_new30_% (7000x58)
    %Contains same information as BS_matrix but for 2030, some buildings have been
    %demolished or renovated and new buildings have been added.
    %BS_matrix_new30 has always 7000 rows to allow multiple simulation runs' output be saved in same file. Number of actual buildings can vary.
%_RBs_% (37x17)
    %Contains annual information on the number of RB and the
    %number of demolished, renovated and new RB
    %First column is the year
    %Second column is the number of RB at the start of the year
    %Columns 3-5 are the number of detached, row and apartment buildings at
    %the start of the year
    %Columns 6-8 are the annual number of renovated, demolished and new RB
    %Columns 9-11 are the annual number of renovated, demolished and new
    %detached houses
    %Columns 12-14 are the annual number of renovated, demolished and new
    %row houses
    %Columns 15-17 are the annual number of renovated, demolished and new
    %apartment buildings
%_NRBs_% (37x5)
    %Contains annual information on the number of NRB and the
    %number of demolished, renovated and new NRB
    %First column is the year
    %Second column is the number of NRB at the start of the year
    %Columns 3-5 are the annual number of renovated, demolished and new NRB
%_rates_% (38x6)
    %Contains annual and mean renovation, demolition and new building rates for RB
    %and NRB
    %Columns 1-3 contain renovation, demolition and new building rates for RB
    %Columns 4-6 contain renovation, demolition and new building rates for NRB
%_vol_% (37x22)
    %Contains annual information on the volume of building stock
    %Column 1 is the year
    %Column 2 is the annual volume of the building stock
    %Column 3 is the annual volume of RB
    %Columns 4-6 are the annual volume of detached, row and apartment
    %buildings
    %Column 7 is the annual volume of NRB
    %Column 8 is the annual volume of renovated RB
    %Columns 9-11 are the annual volume of renovated detached, row and
    %apartment buildings
    %Column 12 is the annual volume of renovated NRB
    %Column 13 is the annual volume of demolished RB
    %Columns 14-16 are the annual volume of demolished detached, row and
    %apartment buildings
    %Column 17 is the annual volume of demolished NRB
    %Column 18 is the annual volume of new RB
    %Columns 19-21 are the annual volume of new detached, row and apartment
    %buildings
    %Column 22 is the annual volume of new NRB  
%% INITIALIZING MATRICES AND OTHER STUFF
%set original BS_matrix as new for simulation:
BS_matrix_new=BS_matrix;
%initialize matrix for number of renovated RBs by age and building group:
BS_ren_RB=zeros(PARAMETER_matrix(1),6+PARAMETER_matrix(1),3);
%initialize matrix for number of demolished RBs by age and building group:
BS_dem_RB=zeros(PARAMETER_matrix(1),6+PARAMETER_matrix(1),3);
%initialize matrix for number of new RBs in a building group:
BS_new_RB=zeros(PARAMETER_matrix(1),3);
%initialize matrix for total number of renovated, demolished and new RBs:
RBs=zeros(PARAMETER_matrix(1)+1,17);
%first column contains year, first year to be calculated is set:
RBs(1,1)=2014;
%columns 2-5 contains total number of RBs at the start of a year:
RBs(1,2)=sum(BS_matrix_new(:,2)==1 | BS_matrix_new(:,2)==2 | BS_matrix_new(:,2)==3);
RBs(1,3)=sum(BS_matrix_new(:,2)==1);
RBs(1,4)=sum(BS_matrix_new(:,2)==2);
RBs(1,5)=sum(BS_matrix_new(:,2)==3);
% initialize matrix for total number of renovated, demolished and new NRBs:
NRBs=zeros(PARAMETER_matrix(1)+1,5);
%first column contains year, first year to be calculated is set:
NRBs(1,1)=2014;
%second column contains total number of RBs at the start of a year:
NRBs(1,2)=sum(BS_matrix_new(:,2)==4);
%set options for intlinprog used for new building calculation:
lin_options=optimoptions(@intlinprog,'Disp','off','MaxTime',10,'RootLPAlgorithm','primal-simplex');
%Calculating the demolition rate for RBs utilizing Weibull distribution:
demrate=zeros(1,300);
demrate(1,1:PARAMETER_matrix(9)-1)=1;
for i=PARAMETER_matrix(9):300
    demrate(i)=exp(-((i-PARAMETER_matrix(9))/PARAMETER_matrix(7))^PARAMETER_matrix(8));
end
%if renovation is enabled, calculating the renovation rate utilizing Normal distribution:
% if PARAMETER_matrix(2)==1
%     renrate=zeros(1,200);
%     renrate2=zeros(1,200); %from 2030 onwards
%     for i=1:ceil(200/PARAMETER_matrix(3))
%         for j=1:200
%             renrate(j)=renrate(j)+pdf(makedist('Normal','mu',i*PARAMETER_matrix(3),'sigma',PARAMETER_matrix(3)/4),j)*demrate(j+PARAMETER_matrix(3));
%             renrate2(j)=renrate2(j)+pdf(makedist('Normal','mu',i*(PARAMETER_matrix(3)-15),'sigma',(PARAMETER_matrix(3)-15)/4),j)*demrate(j+(PARAMETER_matrix(3)-15));
%         end
%     end
% end
%Calculating the original RB stock age groups assuming that
%buildings have already been demolished based on Weibull distribution
%initialize matrix for calculated "original" RB stock by age and building group:
BS_orig_RB=zeros(3,max(BS_matrix(:,3)));
for i=1:3 %building group
    for j=1:max(BS_matrix(:,3)) %age group
        if j==1
            BS_orig_RB(i,j)=round(sum(BS_matrix(:,2)==i & BS_matrix(:,3)==j)/mean(demrate(64:113)));
        else
            BS_orig_RB(i,j)=round(sum(BS_matrix(:,2)==i & BS_matrix(:,3)==j)/mean(demrate((7-j)*10+4:(8-j)*10+3)));
        end
    end
end
%initialize matrix for the volume of new RBs (columns 1:3) and the real
%added volume of new RBs (columns 4:6)
vol_new_RB=zeros(PARAMETER_matrix(1),6);
%initialize matrices for floor area and volume
areaN=zeros(PARAMETER_matrix(1)+1,1);
volN=zeros(PARAMETER_matrix(1)+1,1);
%floor area for year 0
areaN(1)=population(1)*areaP(1);
%volume for year 0
volN(1)=PARAMETER_matrix(11)*areaN(1);
%initializing matrix for the volume of new NRBs (first column) and real
%added volume of new NRBs (second column)
vol_new_NRB=zeros(PARAMETER_matrix(1),2);
%average characteristic heat demand of NRBs for new building calculation
temp_chdNRB=mean(BS_matrix(BS_matrix(:,2)==4,5));
%intializing matrix for renovation, demolition and new building rate
rates=zeros(PARAMETER_matrix(1)+2,6);
%initializing matrix for volume
vol=zeros(PARAMETER_matrix(1)+1,22);
%1. column contains year
vol(1,1)=2014;
%2. column contains total volume of all buildings
vol(1,2)=sum(BS_matrix(:,4));
%3. column contains total volume of RB
vol(1,3)=sum(BS_matrix(BS_matrix(:,2)==1 | BS_matrix(:,2)==2 | BS_matrix(:,2)==3,4));
%4. column contains total volume of detached houses
vol(1,4)=sum(BS_matrix(BS_matrix(:,2)==1,4));
%5. column contains total volume of row houses
vol(1,5)=sum(BS_matrix(BS_matrix(:,2)==2,4));
%6. column contains total volume of apartment buildings
vol(1,6)=sum(BS_matrix(BS_matrix(:,2)==3,4));
%7. column contains total volume of NRB
vol(1,7)=sum(BS_matrix(BS_matrix(:,2)==4,4));

p=1; %variable for updating ID number for new buildings
X=0;
%% SIMULATION OF BUILDING STOCK EVOLUTION
%calculating the annual evolution of building stock:
for Y=1:PARAMETER_matrix(1)
    %checking if renovation is enabled:
    if PARAMETER_matrix(2)==1
        renrate=zeros(1,200);
%         if mod(Y,2)==0
%             if X==0
%                 X=2;
%             else
%                 X=X+2;
%             end
%         end
        if Y>1
            if RENO_NRB(Y)>temp_rateRB(Y-1)
                %X=X+1;
                X=X+(RENO_NRB(Y)/temp_rateRB(Y-1))^3;
            elseif RENO_NRB(Y)<temp_rateRB(Y-1)
                %X=X-1;
                X=X-(temp_rateRB(Y-1)/RENO_NRB(Y))^3;
            end
        end
        for i=1:ceil(200/(PARAMETER_matrix(3)-X))
            for j=1:200
                renrate(j)=renrate(j)+pdf(makedist('Normal','mu',i*(PARAMETER_matrix(3)-X),'sigma',(PARAMETER_matrix(3)-X)/4),j)*demrate(j+ceil(PARAMETER_matrix(3)-X));
            end
        end
        
        %%%%%-- R E N O V A T I O N --%%%%%
        %Already renovated buildings have grace period decreased by one year:
        BS_matrix_new(BS_matrix_new(:,6)>0,6)=BS_matrix_new(BS_matrix_new(:,6)>0,6)-1;
        %%%- RBs -%%%
        %Calculating the number of renovated RBs in each age and building group
        %Selecting the renovated RBs in each age group. Selecting
        %RBs in the group with higher than average characteristic
        %heat demand.
        for j=1:max(BS_matrix_new(:,3)) %age group
            for r=1:3 %building group
                if j==1 %age <1950
                    %number of renovated buildings based on renovation rate
                    %if Y<17
                        BS_ren_RB(Y,j,r)=round(sum(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j)*mean(renrate(64+Y:113+Y)));
                    %else
                    %    BS_ren_RB(Y,j,r)=round(sum(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j)*mean(renrate2(64+Y:113+Y)));
                    %end
                    if BS_ren_RB(Y,j,r)>0
                        %calculating average characteristic heat demand:
                        temp_chd=mean(BS_matrix_new(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j,5).*BS_matrix_new(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j,7));
                        %choosing buildings with greater than average characteristic heat demand that are not on grace period
                        temp_ind=BS_matrix_new(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j & BS_matrix_new(:,5).*BS_matrix_new(:,7)>temp_chd & BS_matrix_new(:,6)==0,1);
                        for i=1:BS_ren_RB(Y,j,r)
                            %if all appropriate buildings from the age group have been renovated or are on grace period
                            if isempty(temp_ind)
                                BS_ren_RB(Y,j,r)=i-1;
                                break
                            end
                            %choose a random building
                            temp_ind_rnd=randi(length(temp_ind));
                            %volume of the building
                            vol(Y,8+r)=vol(Y,8+r)+BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),4);
                            %set grace period
                            BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),6)=PARAMETER_matrix(5);
                            %set energy efficiency coefficient
                            BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),7)=BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),7)*(1-PARAMETER_matrix(6)/100);
                            %remove the building from the pool so it is not renovated immediately again
                            temp_ind(temp_ind_rnd)=[];
                        end
                    end
                elseif j>1 && j<8 %construction decade known
                    %number of renovated buildings based on renovation rate
                    %if Y<17
                        BS_ren_RB(Y,j,r)=round(sum(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j)*mean(renrate((7-j)*10+4+Y:(8-j)*10+3+Y)));
                    %else
                    %    BS_ren_RB(Y,j,r)=round(sum(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j)*mean(renrate2((7-j)*10+4+Y:(8-j)*10+3+Y)));
                    %end
                    if BS_ren_RB(Y,j,r)>0
                        %calculating average characteristic heat demand:
                        temp_chd=mean(BS_matrix_new(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j,5).*BS_matrix_new(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j,7));
                        %choosing buildings with greater than average characteristic heat demand that are not on grace period
                        temp_ind=BS_matrix_new(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j & BS_matrix_new(:,5).*BS_matrix_new(:,7)>temp_chd & BS_matrix_new(:,6)==0,1);
                        for i=1:BS_ren_RB(Y,j,r)
                            %if all appropriate buildings from the age group have been renovated or are on grace period
                            if isempty(temp_ind)
                                BS_ren_RB(Y,j,r)=i-1;
                                break
                            end
                            %choose a random building
                            temp_ind_rnd=randi(length(temp_ind));
                            %volume of the building
                            vol(Y,8+r)=vol(Y,8+r)+BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),4);
                            %set grace period
                            BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),6)=PARAMETER_matrix(5);
                            %set energy efficiency coefficient
                            BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),7)=BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),7)*(1-PARAMETER_matrix(6)/100);
                            %remove the building from the pool so it is not renovated immediately again
                            temp_ind(temp_ind_rnd)=[];
                        end
                    end
                else %construction year known
                    %number of renovated buildings based on renovation rate
                    %if Y<17
                        BS_ren_RB(Y,j,r)=round(sum(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j)*renrate(Y-(j-7)));
                    %else
                    %    BS_ren_RB(Y,j,r)=round(sum(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j)*renrate2(Y-(j-7)));
                    %end
                    if BS_ren_RB(Y,j,r)>0
                        %calculating average characteristic heat demand:
                        temp_chd=mean(BS_matrix_new(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j,5).*BS_matrix_new(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j,7));
                        %choosing buildings with greater than average characteristic heat demand that are not on grace period
                        temp_ind=BS_matrix_new(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j & BS_matrix_new(:,5).*BS_matrix_new(:,7)>temp_chd & BS_matrix_new(:,6)==0,1);
                        for i=1:BS_ren_RB(Y,j,r)
                            %if all appropriate buildings from the age group have been renovated or are on grace period
                            if isempty(temp_ind)
                                BS_ren_RB(Y,j,r)=i-1;
                                break
                            end
                            %choose a random building
                            temp_ind_rnd=randi(length(temp_ind));
                            %volume of the building
                            vol(Y,8+r)=vol(Y,8+r)+BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),4);
                            %set grace period
                            BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),6)=PARAMETER_matrix(5);
                            %set energy efficiency coefficient
                            BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),7)=BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),7)*(1-PARAMETER_matrix(6)/100);
                            %remove the building from the pool so it is not renovated immediately again
                            temp_ind(temp_ind_rnd)=[];
                        end
                    end
                end
            end
        end
        %total number of renovated RBs
        RBs(Y,6)=sum(BS_ren_RB(Y,:,1))+sum(BS_ren_RB(Y,:,2))+sum(BS_ren_RB(Y,:,3));
        RBs(Y,9)=sum(BS_ren_RB(Y,:,1)); %detached
        RBs(Y,12)=sum(BS_ren_RB(Y,:,2)); %row
        RBs(Y,15)=sum(BS_ren_RB(Y,:,3)); %apartment
        %volume of the renovated RBs
        vol(Y,8)=sum(vol(Y,9:11));
        %%%- NRBs -%%%
        %Calculating the number of renovated NRBs
        %NRBs(Y,3)=round((PARAMETER_matrix(4)/100)*(sum(BS_matrix_new(:,2)==4)));
        NRBs(Y,3)=round((RENO_NRB(Y)/100)*(sum(BS_matrix_new(:,2)==4)));
        %Selecting the renovated NRBs. Selecting NRBs with
        %higher than average characteristic heat demand.
        %are there renovations to be made?
        if NRBs(Y,3)>0
            %average characteristic heat demand:
            temp_chd=mean(BS_matrix_new(BS_matrix_new(:,2)==4,5).*BS_matrix_new(BS_matrix_new(:,2)==4,7));
            %buildings with greater than average characteristic heat demand that are not on grace period
            temp_ind=BS_matrix_new(BS_matrix_new(:,2)==4 & BS_matrix_new(:,5).*BS_matrix_new(:,7)>temp_chd & BS_matrix_new(:,6)==0,1);
            for i=1:NRBs(Y,3)
                %if all appropriate buildings have been renovated or are on grace period
                if isempty(temp_ind)
                    NRBs(Y,3)=i-1;
                    break
                end
                %choose a random building
                temp_ind_rnd=randi(length(temp_ind));
                %volume of the building
                vol(Y,12)=vol(Y,12)+BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),4);
                %set grace period
                BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),6)=PARAMETER_matrix(5);
                %set energy efficiency coefficient
                BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),7)=BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),7)*(1-PARAMETER_matrix(6)/100);
                %remove the building from the pool so it is not renovated immediately again
                temp_ind(temp_ind_rnd)=[];
            end
        end
    end
    %%%%%-- D E M O L I T I O N --%%%%%
    %%%- RBs -%%%
    %Calculating the volume of new RBs
    %floor area needed for current year
    areaN(Y+1)=population(Y+1)*areaP(Y+1);
    %volume needed for current year
    volN(Y+1)=PARAMETER_matrix(11)*areaN(Y+1);
    %relative volume change
    vol_chg=(volN(Y+1)-volN(Y))/volN(Y);
    %volume change of current RB building stock
    vol_new=vol_chg*sum(BS_matrix_new(BS_matrix_new(:,2)==1 | BS_matrix_new(:,2)==2 | BS_matrix_new(:,2)==3,4));
    %Calculating number of annually demolished RBs
    for j=1:max(BS_matrix_new(:,3)) %age group
        for r=1:3 %building group
            if j==1 %age <1950
                %number of demolished RBs based on demolition rate
                BS_dem_RB(Y,j,r)=round(sum(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j)-mean(demrate(64+Y:113+Y))*BS_orig_RB(r,j));
                %are there building to be demolished?
                if BS_dem_RB(Y,j,r)>0
                    %Removing demolished RBs, randomly
                    for i=1:BS_dem_RB(Y,j,r)
                        %choose buildings that have not been renovated in the last ten years
                        temp_ind=BS_matrix_new(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j & BS_matrix_new(:,6)==0,1);
                        %if all appropriate buildings have been demolished or are on grace period
                        if isempty(temp_ind)
                            BS_dem_RB(Y,j,r)=i-1;
                            break
                        end
                        %choose a random building
                        temp_ind_rnd=randi(length(temp_ind));
                        %calculate the volume of demolished buildings
                        vol(Y,13+r)=vol(Y,13+r)+BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),4);
                        %remove the demolished building
                        BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),:)=[];
                    end
                end
            elseif j>1 && j<8 %construction decade known
                %number of demolished RBs based on demolition rate
                BS_dem_RB(Y,j,r)=round(sum(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j)-mean(demrate((7-j)*10+4+Y:(8-j)*10+3+Y))*BS_orig_RB(r,j));
                %are there building to be demolished?
                if BS_dem_RB(Y,j,r)>0
                    %Removing demolished RBs, randomly
                    for i=1:BS_dem_RB(Y,j,r)
                        %choose buildings that have not been renovated in the last ten years
                        temp_ind=BS_matrix_new(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j & BS_matrix_new(:,6)==0,1);
                        %if all appropriate buildings have been demolished or are on grace period
                        if isempty(temp_ind)
                            BS_dem_RB(Y,j,r)=i-1;
                            break
                        end
                        %choose a random building
                        temp_ind_rnd=randi(length(temp_ind));
                        %calculate the volume of demolished buildings
                        vol(Y,13+r)=vol(Y,13+r)+BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),4);
                        %remove the demolished building
                        BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),:)=[];
                    end
                end
            else %construction year known
                %number of demolished RBs based on demolition rate
                BS_dem_RB(Y,j,r)=round(sum(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j)-demrate(Y-(j-7))*BS_new_RB(1+(j-8),r));
                %are there building to be demolished?
                if BS_dem_RB(Y,j,r)>0
                    %Removing demolished RBs, randomly
                    for i=1:BS_dem_RB(Y,j,r)
                        %choose buildings that have not been renovated in the last ten years
                        temp_ind=BS_matrix_new(BS_matrix_new(:,2)==r & BS_matrix_new(:,3)==j & BS_matrix_new(:,6)==0,1);
                        %if all appropriate buildings have been demolished or are on grace period
                        if isempty(temp_ind)
                            BS_dem_RB(Y,j,r)=i-1;
                            break
                        end
                        %choose a random building
                        temp_ind_rnd=randi(length(temp_ind));
                        %calculate the volume of demolished buildings
                        vol(Y,13+r)=vol(Y,13+r)+BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),4);
                        %remove the demolished building
                        BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),:)=[];
                    end
                end
            end
        end
    end
    %total number of demolished RBs
    RBs(Y,7)=sum(BS_dem_RB(Y,:,1))+sum(BS_dem_RB(Y,:,2))+sum(BS_dem_RB(Y,:,3));
    RBs(Y,10)=sum(BS_dem_RB(Y,:,1)); %detached
    RBs(Y,13)=sum(BS_dem_RB(Y,:,2)); %row
    RBs(Y,16)=sum(BS_dem_RB(Y,:,3)); %apartment
    %calculate the volume of demolished RB
    vol(Y,13)=sum(vol(Y,14:16));
    %%%- NRBs -%%%
    %Calculating the number of demolished NRBs
    NRBs(Y,4)=round((PARAMETER_matrix(10)/100)*(sum(BS_matrix_new(:,2)==4)));
    %removing demolished NRBs, randomly
    for i=1:NRBs(Y,4)
        %choose buildings that have not been renovated in the last ten years
        temp_ind=BS_matrix_new(BS_matrix_new(:,2)==4 & BS_matrix_new(:,6)==0,1);
        %if all appropriate buildings have been demolished or are on grace period
        if isempty(temp_ind)
            NRBs(Y,4)=i-1;
            break
        end
        %choose a random building
        temp_ind_rnd=randi(length(temp_ind));
        %calculate the volume of demolished buildings
        vol(Y,17)=vol(Y,17)+BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),4);
        %remove the demolished building
        BS_matrix_new(BS_matrix_new(:,1)==temp_ind(temp_ind_rnd),:)=[];
    end
    %%%%%-- N E W  B U I L D I N G S --%%%%%
    %%%- RBs -%%%
    %Calculating the volume of new RBs
    %volume of new detached houses taking into account demolition
    vol_new_RB(Y,1)=(PARAMETER_matrix(12)/100)*vol_new+vol(Y,14);
    %volume of new row houses taking into account demolition
    vol_new_RB(Y,2)=(PARAMETER_matrix(13)/100)*vol_new+vol(Y,15);
    %volume of new apartment buildings taking into account demolition
    vol_new_RB(Y,3)=(PARAMETER_matrix(14)/100)*vol_new+vol(Y,16);
    %Adding new RBs, duplicated from 2000s RBs
    L=length(BS_matrix_new(:,1));
    for r=1:3 %building group
        %if new RB volume is zero or negative or if volume of the smallest
        %building is larger than the new RB volume -> no buildings added
        if vol_new_RB(Y,r)<=0 || min(BS_matrix(BS_matrix(:,2)==r & BS_matrix(:,3)==7,4))>vol_new_RB(Y,r)
            %real added volume is zero
            vol(Y,18+r)=0;
            %number of new RBs is zero
            BS_new_RB(Y,r)=0;
        else
            temp_ind0=[];
            %volumes of all eligible buildings to be added from 2000s with lower than needed volume
            f=BS_matrix(BS_matrix(:,2)==r & BS_matrix(:,3)==7 & BS_matrix(:,4)<=vol_new_RB(Y,r),4)';
            %integers: the number of eligible buildings
            intcon=1:length(f);
            %setting inequality constraint to take into account the tolerance for volume
            A=[BS_matrix(BS_matrix(:,2)==r & BS_matrix(:,3)==7 & BS_matrix(:,4)<=vol_new_RB(Y,r),4)';-BS_matrix(BS_matrix(:,2)==r & BS_matrix(:,3)==7 & BS_matrix(:,4)<=vol_new_RB(Y,r),4)'];
            b=[(1+PARAMETER_matrix(15)/100)*vol_new_RB(Y,r);-(1-PARAMETER_matrix(15)/100)*vol_new_RB(Y,r)];
            %lower bound is zero: building is not added
            lb=zeros(1,length(f));
            %upper bound is 3: same building can be added maximum of 3 times
            ub=3*ones(1,length(f));
            %calculating added buildings utilizing linear programming
            result=intlinprog(f,intcon,A,b,[],[],lb,ub,[],lin_options);
            %if the result is zero buildings
            if sum(result)==0
                %real added volume is zero
                vol(Y,18+r)=0;
                %number of new RBs is zero
                BS_new_RB(Y,r)=0;
            else
                %real added volume
                vol(Y,18+r)=sum(BS_matrix(BS_matrix(:,2)==r & BS_matrix(:,3)==7 & BS_matrix(:,4)<=vol_new_RB(Y,r),4).*result);
                %number of new RBs
                BS_new_RB(Y,r)=round(sum(result));
                %index for RBs from 2000s
                temp_ind0(:,1)=BS_matrix(BS_matrix(:,2)==r & BS_matrix(:,3)==7 & BS_matrix(:,4)<=vol_new_RB(Y,r),1);
                %number of times the building is added
                temp_ind0(:,2)=round(result);
                %keeping only the buildings that are added: result>0
                temp_ind0=temp_ind0(temp_ind0(:,2)>0,:);
                for j=1:length(temp_ind0(:,1))
                    while temp_ind0(j,2)>0
                        L=L+1;
                        %add a duplicate of the building
                        BS_matrix_new(L,:)=BS_matrix(BS_matrix(:,1)==temp_ind0(j,1),:);
                        %add running number
                        BS_matrix_new(L,1)=length(BS_matrix(:,1))+p;
                        %add age group
                        BS_matrix_new(L,3)=7+Y;
                        %set grace period to zero
                        BS_matrix_new(L,6)=0;
                        if Y<7
                            %energy efficiency coefficient, built in 2010s
                            BS_matrix_new(L,7)=1-PARAMETER_matrix(16)/100;
                        else
                            %energy efficiency coefficient, built in 2020->
                            BS_matrix_new(L,7)=1-PARAMETER_matrix(17)/100;
                        end
                        p=p+1;
                        temp_ind0(j,2)=temp_ind0(j,2)-1;
                    end
                end
            end
        end
    end
    %total number of new RBs
    RBs(Y,8)=sum(BS_new_RB(Y,1:3));
    RBs(Y,11)=BS_new_RB(Y,1); %detached
    RBs(Y,14)=BS_new_RB(Y,2); %row
    RBs(Y,17)=BS_new_RB(Y,3); %apartment
    %total volume of new RBs
    vol(Y,18)=sum(vol(Y,19:21));
    %%%- NRBs -%%%
    %Adding new NRBs, duplicated from lower than
    %average characteristic heat demand buildings
    %calculating the volume of new NRBs
    vol_new_NRB(Y,1)=(PARAMETER_matrix(18)/100)*sum(vol_new_RB(Y,1:3));
    %if new NRB volume is zero or negative or if volume of the smallest
    %NRB is larger than the new NRB volume -> no buildings added
    if vol_new_NRB(Y,1)<=0 || min(BS_matrix(BS_matrix(:,2)==4 & BS_matrix(:,5)<temp_chdNRB,4))>vol_new_NRB(Y,1)
        %real added volume is zero
        vol(Y,22)=0;
        %number of new NRBs is zero
        NRBs(Y,5)=0;
    else
        temp_ind0=[];
        L=length(BS_matrix_new(:,1));
        %volumes of all eligible NRBs to be added with lower than average
        %characteristic heat demand and lower than needed volume
        f=BS_matrix(BS_matrix(:,2)==4 & BS_matrix(:,5)<temp_chdNRB & BS_matrix(:,4)<=vol_new_NRB(Y,1),4)';
        %integers: number of eligible buildings
        intcon=1:length(f);
        %setting inequality constraint to take into account the tolerance for volume
        A=[BS_matrix(BS_matrix(:,2)==4 & BS_matrix(:,5)<temp_chdNRB & BS_matrix(:,4)<=vol_new_NRB(Y,1),4)';-BS_matrix(BS_matrix(:,2)==4 & BS_matrix(:,5)<temp_chdNRB & BS_matrix(:,4)<=vol_new_NRB(Y,1),4)'];
        b=[(1+PARAMETER_matrix(15)/100)*vol_new_NRB(Y,1);-(1-PARAMETER_matrix(15)/100)*vol_new_NRB(Y,1)];
        %lower bound is zero: building is not added
        lb=zeros(1,length(f));
        %upper bound is 3: same building can be added maximum of 3 times
        ub=3*ones(1,length(f));
        %calculating added buildings utilizing linear programming
        result=intlinprog(f,intcon,A,b,[],[],lb,ub,[],lin_options);
        %if the result is zero buildings
        if sum(result)==0
            %real added volume is zero
            vol(Y,22)=0;
            %number of new NRBs is zero
            NRBs(Y,5)=0;
        else
            %real added volume
            vol(Y,22)=sum(BS_matrix(BS_matrix(:,2)==4 & BS_matrix(:,5)<temp_chdNRB & BS_matrix(:,4)<=vol_new_NRB(Y,1),4).*result);
            %number of new RBs
            NRBs(Y,5)=round(sum(result));
            %index for NRBs with lower than average characteristic heat
            %demand
            temp_ind0(:,1)=BS_matrix(BS_matrix(:,2)==4 & BS_matrix(:,5)<temp_chdNRB & BS_matrix(:,4)<=vol_new_NRB(Y,1),1);
            %number of times the building is added
            temp_ind0(:,2)=round(result);
            %keeping only the buildings that are added: result>0
            temp_ind0=temp_ind0(temp_ind0(:,2)>0,:);
            for j=1:length(temp_ind0(:,1))
                while temp_ind0(j,2)>0
                    L=L+1;
                    %add a duplicate of the building
                    BS_matrix_new(L,:)=BS_matrix(BS_matrix(:,1)==temp_ind0(j,1),:);
                    %add running number
                    BS_matrix_new(L,1)=length(BS_matrix(:,1))+p;
                    %add age group
                    BS_matrix_new(L,3)=7+Y;
                    %grace period
                    BS_matrix_new(L,6)=0;
                    if Y<7
                        %energy efficiency coefficient, built in 2010s
                        BS_matrix_new(L,7)=1-PARAMETER_matrix(16)/100;
                    else
                        %energy efficiency coefficient, built in 2020->
                        BS_matrix_new(L,7)=1-PARAMETER_matrix(17)/100;
                    end
                    p=p+1;
                    temp_ind0(j,2)=temp_ind0(j,2)-1;
                end
            end
        end
    end
    %initial building stock for the next year
    %next year
    RBs(Y+1,1)=RBs(Y,1)+1;
    NRBs(Y+1,1)=NRBs(Y,1)+1;
    vol(Y+1,1)=vol(Y,1)+1;
    %total number of buildings
    RBs(Y+1,2)=sum(BS_matrix_new(:,2)==1 | BS_matrix_new(:,2)==2 | BS_matrix_new(:,2)==3); %RBs
    RBs(Y+1,3)=sum(BS_matrix_new(:,2)==1); %detached
    RBs(Y+1,4)=sum(BS_matrix_new(:,2)==2); %row
    RBs(Y+1,5)=sum(BS_matrix_new(:,2)==3); %apartment
    NRBs(Y+1,2)=sum(BS_matrix_new(:,2)==4); %NRBs
    %volume
    vol(Y+1,2)=sum(BS_matrix_new(:,4)); %all
    vol(Y+1,3)=sum(BS_matrix_new(BS_matrix_new(:,2)==1 | BS_matrix_new(:,2)==2 | BS_matrix_new(:,2)==3,4)); %RBs
    vol(Y+1,4)=sum(BS_matrix_new(BS_matrix_new(:,2)==1,4)); %detached
    vol(Y+1,5)=sum(BS_matrix_new(BS_matrix_new(:,2)==2,4)); %row
    vol(Y+1,6)=sum(BS_matrix_new(BS_matrix_new(:,2)==3,4)); %apartment
    vol(Y+1,7)=sum(BS_matrix_new(BS_matrix_new(:,2)==4,4)); %NRBs
    
    temp_rateRB(Y)=RBs(Y,6)/RBs(Y,2)*100;
    
    %Saving BS_matrix_new for 2030
    if Y==16
        BS_matrix_new30=BS_matrix_new;
        BS_matrix_new30(end+1:7000,:)=0;
    end
    
end
BS_matrix_new(end+1:7000,:)=0;
%mean RB renovation rate
rates(1:PARAMETER_matrix(1),1)=RBs(1:end-1,6)./RBs(1:end-1,2)*100;
rates(PARAMETER_matrix(1)+2,1)=mean(RBs(1:end-1,6)./RBs(1:end-1,2))*100;
%mean RB demolition rate
rates(1:PARAMETER_matrix(1),2)=RBs(1:end-1,7)./RBs(1:end-1,2)*100;
rates(PARAMETER_matrix(1)+2,2)=mean(RBs(1:end-1,7)./RBs(1:end-1,2))*100;
%mean RB new building rate
rates(1:PARAMETER_matrix(1),3)=RBs(1:end-1,8)./RBs(1:end-1,2)*100;
rates(PARAMETER_matrix(1)+2,3)=mean(RBs(1:end-1,8)./RBs(1:end-1,2))*100;
%mean NRB renovation rate
rates(1:PARAMETER_matrix(1),4)=NRBs(1:end-1,3)./NRBs(1:end-1,2)*100;
rates(PARAMETER_matrix(1)+2,4)=mean(NRBs(1:end-1,3)./NRBs(1:end-1,2))*100;
%mean NRB demolition rate
rates(1:PARAMETER_matrix(1),5)=NRBs(1:end-1,4)./NRBs(1:end-1,2)*100;
rates(PARAMETER_matrix(1)+2,5)=mean(NRBs(1:end-1,4)./NRBs(1:end-1,2))*100;
%mean NRB new building rate
rates(1:PARAMETER_matrix(1),6)=NRBs(1:end-1,5)./NRBs(1:end-1,2)*100;
rates(PARAMETER_matrix(1)+2,6)=mean(NRBs(1:end-1,5)./NRBs(1:end-1,2))*100;

toc
end