function population  = Population(src, app)
        % Check the source variable. If it is a table, this is an input
        % array with 2 columns, the left column are the years and the
        % rights column are the population ratio. If it is 
        
        if app.PlotPopulation.Value
            plotin = 'on' ;
        else
            plotin = 'off' ;
        end
                    
        if isa(src, 'double')
            x = app.PopulationFiledata(:,1) ;
            y = app.PopulationFiledata(:,2) ;
            origtable = array2table(app.PopulationFiledata, 'VariableNames',{'Time','var1'}) ;
            if x(end) < 2050
                % Then take the data and then extrapolate
                xout(:,1) = 2013:1:2050 ;
                if length(x) < 6
                    % Fit a 1-d Gaussian
                    [fitresult, ~] = createFit(x, y, 'plotin',plotin) ;
%                     yfitresult =  fitresult.a1 .* exp(-((xout-fitresult.b1)./fitresult.c1).^2) ;
%                     data.population(:,1) = yfitresult' ;
                    fitresult.a2 = 0 ; fitresult.b2 = 1 ; fitresult.b2 = 1 ;
                else
                    % Fit a 2-d Gaussian
                    [fitresult, ~] = createFit1(x, y, 'plotin', plotin) ;
                end
                yfitresult =  fitresult.a1 .* exp(-((xout-fitresult.b1)./fitresult.c1).^2) + fitresult.a2 .* exp(-((xout-fitresult.b2)./fitresult.c2).^2);
                % Merge provided data with extrapolated data
                producedarray = array2table([xout yfitresult], 'VariableNames',{'Time','var2'}) ;
                T=outerjoin(producedarray, origtable); 
                Table1 = isnan(T.var1).*T.var2 ;
                T.var1(isnan(T.var1)) = 0 ;
                data.population(:,1) = Table1 + T.var1  ;
                
                % Calculate the other population with sensitivity ratio
%                 x_plusSens = [2013 2018 2030 2050] ;
%                 y_plusSens = [data.populationToday data.population(6,1) data.population2030*(1+normyear(2) * data.PopulationSensitivity /100) data.population2050*(1+data.PopulationSensitivity/100)] ;
            else
                % Trunc the data to 2050
            end
        else
            % In this case, this is the value input in the GUI
            % With the 3 inputs, we can plot the linear interpolation or
            % non-linear interpolation 
            data.populationToday        = str2double(app.Population2013EditField.Value) ;
            data.population2030         = str2double(app.Population2030EditField.Value) ;
            data.population2050         = str2double(app.Population2050EditField.Value) ;
            data.PopulationSensitivity  = str2double(app.PopulationSensitivityEditField.Value) ;
            % Interpolate with the existing given data
            x = [2013 2030 2050] ;
            y = [data.populationToday data.population2030 data.population2050] ;
            % Rpelot the liner or non-linear 
            yearsref = [2013 2030 2050] ;
            normyear = normalize(yearsref,'range') ;
            
            
            switch app.InterpolationmethodPopulationDropDown.Value
                case {'spline' 'linear'}
                    outputarray = lin_inter(x',y',app.InterpolationmethodPopulationDropDown.Value) ;
                    data.population = outputarray(:,2:end) ;
                    
                    % Calculate the other population with sensitivity ratio
                    x_plusSens = [2013 2018 2030 2050] ;
                    y_plusSens = [data.populationToday data.population(6,1) data.population2030*(1+normyear(2) * data.PopulationSensitivity /100) data.population2050*(1+data.PopulationSensitivity/100)] ;
                    
                    outputarray = lin_inter(x_plusSens',y_plusSens',app.InterpolationmethodPopulationDropDown.Value) ;
                    data.population(:,2) = outputarray(:,2) ;
                    
                    % Rpelot the liner or non-linear 
                    
                    x_minusSens = [2013 2018 2030 2050] ;
                    y_minusSens = [data.populationToday data.population(6,1) data.population2030*(1-normyear(2) * data.PopulationSensitivity /100) data.population2050*(1-data.PopulationSensitivity/100)] ;
 
                    outputarray = lin_inter(x_minusSens',y_minusSens',app.InterpolationmethodPopulationDropDown.Value) ;
                    data.population(:,3) = outputarray(:,2) ;
                case 'Gaussian'
                    xout = 2013:1:2050 ;
                    [fitresult, ~] = createFit(x, y, 'plotin',plotin) ;
                    yfitresult =  fitresult.a1 .* exp(-((xout-fitresult.b1)./fitresult.c1).^2) ;
                    data.population(:,1) = yfitresult' ;
                    
                    % Calculate the other population with sensitivity ratio
                    x_plusSens = [2013 2018 2030 2050] ;
                    y_plusSens = [data.populationToday data.population(6,1) data.population2030*(1+normyear(2) * data.PopulationSensitivity /100) data.population2050*(1+data.PopulationSensitivity/100)] ;
                    
                    [fitresult, ~] = createFit(x_plusSens, y_plusSens, 'plotin',plotin) ;
                    yfitresult =  fitresult.a1 .* exp(-((xout-fitresult.b1)./fitresult.c1).^2) ;
                    data.population(:,2) = yfitresult' ;
                    
                    % Rpelot the liner or non-linear 
                    x_minusSens = [2013 2018 2030 2050] ;
                    y_minusSens = [data.populationToday data.population(6,1) data.population2030*(1-normyear(2) * data.PopulationSensitivity /100) data.population2050*(1-data.PopulationSensitivity/100)] ;
                    
                    [fitresult, ~] = createFit(x_minusSens, y_minusSens, 'plotin',plotin) ;
                    yfitresult =  fitresult.a1 .* exp(-((xout-fitresult.b1)./fitresult.c1).^2) ;
                    data.population(:,3) = yfitresult' ;
            end 
        end
        population = data.population ;
        % put variable to the workspace for debugging purpose
        assignin('base','populationData',data.population);
        if app.PlotPopulation.Value
            % Plot the results
            figure( 'Name', ['Population fit: ' app.InterpolationmethodPopulationDropDown.Value]);
            h = plot(data.population,'Marker','o') ;
                xlabel('Time [years]')
                ylabel('Population [unit]')
            grid on
        end
