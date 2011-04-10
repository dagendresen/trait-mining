function [k,po,k2,po2,pa,ppv,spec,sens,tp,fp,fn,tn] = tm_simca(Xcal, Xtest, pc)
% ** SIMCA model for trait mining (FIGS) ** 
% This function will run a SIMCA classification
%
% Syntax: [k,po,k2,po2,pa,ppv,spec,sens,tp,fp,fn,tn] = tm_simca(Xcal, Xtest, pc)
%
%   INPUT:
%     Xcal - Calibration set (DSO)
%     Xtest - Test set (DSO)
%     pc - number of principal components for the calibration
%        - can be a scalar or a vector with the PC for each class
%
%   OUTPUT: Displays on the screen a summary of the classification
%   Example: tm_simca(Xcal, Xtest, [4 4]);
%
% Script by: Dag Endresen (dag.endresen@gmail.com), GPL2, 3 August 2010
% See also: dso_info, pred2kappa, KAPPA, CONFUSIONMAT, KNN, CLASSIFY, SIMCA, PLSDA
%

if isempty(Xcal), error('Warning: Xcal matrix is empty...'); end;
if isempty(Xtest), error('Warning: Xtest matrix is empty...'); end;
if isempty(pc), error('Warning: pc scalar/vector is empty...'); end;

fprintf('----------------------------------------------\n');
fprintf(1,'-------- SIMCA classification (PC %d) ---------\n', pc);
fprintf('----------------------------------------------\n\n');

% -- Create response variable Y
Ycal = Xcal.class{1,1}; % class Y for SIMCA
Ytest = Xtest.class{1,1}; % class Y for SIMCA

% -- SIMCA OPTIONS
options = simca('options');
options.display = 'off'; % on/off
options.plots = 'final'; % final/none
options.preprocessing = { preprocess('default','autoscale') };

% -- SIMCA MODEL
simca_model = simca(Xcal, [pc], options); 

% -- SIMCA PREDICTION (apply model)
simca_pred = simca(Xtest, simca_model);

% -- DISPLAY RESULTS
dso_info(Xcal); dso_info(Xtest); 
fprintf(1,'SIMCA classification (PC %d):\n----------------------------\n', pc);
pclass = simca_pred.nclass'; pred = [Ytest', pclass];
[k, po, k2, po2, pa, ppv, spec, sens, tp, fp, fn, tn] = pred2kappa (pred); % Kappa
fprintf(1,'/SIMCA classification (PC %d)\n----------------------------\n', pc);

return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% /tm_simca %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
