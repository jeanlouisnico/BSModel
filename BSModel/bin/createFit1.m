function [fitresult, gof] = createFit1(xdata, ydata, varargin)
%CREATEFIT(XDATA,YDATA)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : xdata
%      Y Output: ydata
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%% Define input data
% plotin: Set Whether to plot or not. Default value is 'off'
   defaultplotin    = 'off' ;
   
   p = inputParser;
   
   addParameter(p,'plotin',defaultplotin,@ischar);
   
   parse(p, varargin{:});
   
   results = p.Results ; 
   
%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( xdata, ydata );

% Set up fittype and options.
ft = fittype( 'gauss2' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares');
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0 -Inf -Inf 0];
opts.Robust = 'LAR';
% opts.StartPoint = [153508 2037 16.0870846881926 118080.493757217 2013 4.33398984402036];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );


if strcmp(results.plotin, 'on')
    % Create a figure for the plots.
    figure( 'Name', 'Gaussian fit of the ' );

    % Plot fit with data.
    subplot( 2, 1, 1 );
    h = plot( fitresult, xData, yData );
    legend( h, 'ydata vs. xdata', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
    % Label axes
    xlabel( 'xdata', 'Interpreter', 'none' );
    ylabel( 'ydata', 'Interpreter', 'none' );
    grid on

    % Plot residuals.
    subplot( 2, 1, 2 );
    h = plot( fitresult, xData, yData, 'residuals' );
    legend( h, 'untitled fit 1 - residuals', 'Zero Line', 'Location', 'NorthEast', 'Interpreter', 'none' );
    % Label axes
    xlabel( 'Time [years]', 'Interpreter', 'none' );
    ylabel( 'ydata', 'Interpreter', 'none' );
    grid on
end


