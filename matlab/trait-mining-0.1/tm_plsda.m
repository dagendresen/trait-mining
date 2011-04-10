function [k,po,k2,po2,pa,ppv,spec,sens,tp,fp,fn,tn] = tm_plsda(Xcal, Xtest, lv)
% ** PLS-DA model for trait mining (FIGS) ** 
% This function will run a PLS-DA classification
%
% Syntax: [k,po,k2,po2,pa,ppv,spec,sens,tp,fp,fn,tn] = tm_plsda(Xcal, Xtest, lv)
%
%   INPUT:
%     Xcal - Calibration set (DSO)
%     Xtest - Test set (DSO)
%     lv - number of latent varables for the calibration (scalar)
%
%   OUTPUT:   Displays on the screen a summary of the classification
%   Example:  tm_plsda(Xcal, Xtest, [4 4]);
%
% Script by: Dag Endresen (dag.endresen@gmail.com), GPL2, 3 August 2010
% See also: dso_info, tm_simca, pred2kappa, KNN, CLASSIFY, SIMCA, PLSDA
%

if isempty(Xcal), error('Warning: Xcal matrix is empty...'); end;
if isempty(Xtest), error('Warning: Xtest matrix is empty...'); end;
if isempty(lv), error('Warning: lv scalar/vector is empty...'); end;

fprintf('-----------------------------------------------\n');
fprintf(1,'-------- PLS-DA classification (LV %d) ---------\n', lv);
fprintf('-----------------------------------------------\n');

% -- Create response variable Y
Ycal = Xcal.class{1,1}; % class Y for SIMCA
Ytest = Xtest.class{1,1}; % class Y for SIMCA (and pred below)
Y_cal = class2logical(Ycal); % logical Y for PLSDA
Y_test = class2logical(Ytest); % logical Y for PLSDA

% -- Add class and label to the logical Y for PLSDA
Y_cal.class{1,1} = Xcal.class{1,1}; 
Y_cal.classname{1,1} = Xcal.classname{1,1};
Y_cal.label{1,1} = Xcal.label{1,1}; 
Y_cal.labelname{1,1} = Xcal.labelname{1,1};

Y_test.class{1,1} = Xtest.class{1,1}; 
Y_test.classname{1,1} = Xtest.classname{1,1};
Y_test.label{1,1} = Xtest.label{1,1}; 
Y_test.labelname{1,1} = Xtest.labelname{1,1};

% -- PLS-DA OPTIONS
options = plsda('options'); 
options.plots = 'none'; % 'final', 'none'
options.preprocessing = {preprocess('default','autoscale') preprocess('default','meancenter')};

% -- PLS-DA MODEL
plsda_model = plsda(Xcal, Y_cal, lv, options);

% -- PLS-DA PREDICTION (apply model)
% plsda_pred = plsda(Xtest, plsda_model, options); % no Y_test // blind test set
plsda_pred = plsda(Xtest, Y_test, plsda_model, options); % validation

% -- DISPLAY RESULTS
dso_info(Xcal); dso_info(Xtest); 
fprintf(1,'PLS-DA classification (LV %d):\n----------------------------\n', lv)

yprob = plsda_pred.detail.predprobability;
ymax = max(yprob')'; 
for i=1:(size(yprob,2)-1), ymax = cat(2, ymax, max(yprob')'); end;
yl = (yprob == ymax); % prob 2 logical (yl)
pclass = zeros(size(yprob,1),1); % empty array with zeros, one column
u = unique(Y_test.class{1,1}); % read class from the DSO
for i=1:(size(yprob,2)),  pclass(find(yl(:, i) == 1)) = u(1,i);  end;

pred = [Ytest', pclass]; % actual-c, predicted-c
[k, po, k2, po2, pa, ppv, spec, sens, tp, fp, fn, tn] = pred2kappa (pred); % Kappa

fprintf(1,'/PLS-DA classification (LV %d):\n----------------------------\n\n', lv)
return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% /tm_plsda %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

