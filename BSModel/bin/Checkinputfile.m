function checkvar = Checkinputfile(filepath)
% Validate the input file. If this is a .csv, load it to see if
% it has the right structure. If it is a MatLab file, then load
% it to check if it has the right number of columns.
    [~,~,ext] = fileparts(filepath) ;
    switch ext
        case '.epw'
            try
                [checkvar] = EPWreader(filepath) ;
            catch
                errordlg('Could not read the EPW file. File might be corrupted.') 
                return
            end
        case '.mat'
            checkvar = load(filepath) ;
            ivarname = fieldnames(checkvar)           ;
            checkvar = checkvar.(ivarname{1}) ;

            if ~isa(checkvar, 'double')
                if isa(checkvar, 'table') 
                    for ivar = 1:length(checkvar.Properties.VariableNames)
                        ivarname = checkvar.Properties.VariableNames{ivar} ;
                        if ~isa(checkvar.(ivarname), 'double')
                            errordlg('All variable should be of type double') 
                            return
                        end
                    end
                    checkvar = table2array(checkvar);
                else
                    errordlg('Variable should be a table or a double array matrix') 
                    return
                end
            end

        otherwise
            errordlg('File format not supported') 
            return
    end
