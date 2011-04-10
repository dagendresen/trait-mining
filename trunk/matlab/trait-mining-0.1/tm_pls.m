function [k, po, k2, po2, pa, ppv, spec, sens, tp, fp, fn, tn] = tm_pls(Xcal, Xtest, lv)
% ** PLS-DA model for the Stem Rust dataset (Ug99) ** 
% This function will run a PLS-DA classification
%
% Syntax: 	[k, po, k2, po2, pa, ppv, spec, sens, tp, fp, fn, tn] = tm_pls(Xcal, Xtest, lv)
%
%   INPUT:
%     Xcal - Calibration set (DSO)
%     Xtest - Test set (DSO)
%     lv - number of latent variables for the regression (scalar)
%
%   OUTPUT:
%     Displays on the screen a summary of the regression --> class
%
%   Example: 
%       tm_pls(Xcal, Xtest, [4 4]);
%
% What-To-Look-For:
%     ... todo
%
% Script by:
%     Dag Endresen (dag.endresen@gmail.com), GPL2, August 15, 2010
%
%
% See also: dso_info sr_plsda sr_simca pred2kappa KAPPA, CONFUSIONMAT, KNN, CLASSIFY, SIMCA, PLSDA, MODELVIEWER
%

if isempty(Xcal)
    error('Warning: Xcal matrix is empty...')
end

if isempty(Xtest)
    error('Warning: Xtest matrix is empty...')
end

if isempty(lv)
    error('Warning: lv scalar/vector is empty...')
end




fprintf('\n')
disp('-----------------------------------------------');
fprintf(1,'------- PLS regression --> class (LV %d) -------\n', lv);
disp('-----------------------------------------------');
fprintf('\n')


% -- Test set --
fprintf('Calibration set: %s \n', Xcal.name);
u = unique(Xtest.class{1,1}); 
col = Xtest.class{1,1};
for i = 1:size(u,2), key = find(col(1,:) == u(1,i));  
%    a(i,1) = u(1,i); a(i,2) = size(key,2); 
    a1(1,i) = u(1,i); a1(2,i) = size(key,2); % horizontal list
end;
disp(a1);

% -- Calibration set --
fprintf('Test set: %s \n', Xtest.name);
u = unique(Xcal.class{1,1}); col = Xcal.class{1,1};
for i = 1:size(u,2), key = find(col(1,:) == u(1,i));  
%    a2(i,1) =u(1,i); a2(i,2) = size(key,2); % vertical list
    a2(1,i) = u(1,i); a2(2,i) = size(key,2); % horizontal list
end;
disp(a2);



% -- Display size...
%[rows, cols] = size(Xtest);
%fprintf(1, 'Test matrix size: \tRows = %0.0f, Columns = %0.0f \n', rows, cols)


% -- Create response variable Y
Ycal = Xcal.class{1,1}; % class Y for SIMCA
Ytest = Xtest.class{1,1}; % class Y for SIMCA

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



% -- PLS OPTIONS
options_pls = pls('options'); 
options_pls.display = 'off';
options_pls.plots = 'none';
options_pls.preprocessing{1} = preprocess('default','autoscale'); % X-data, climate
options_pls.preprocessing{2} = preprocess('default','mean center'); % Y-data, trait


% -- PLS MODEL
pls_model = pls(Xcal, Y_cal, lv, options_pls);
pls_model = pls(Xcal, Ycal', lv, options_pls); % build model



% -- PLS PREDICTION (apply model)
pls_pred = pls(Xtest, Ytest', pls_model, options_pls); % apply model (validation)
% pls_pred = pls(Xtest, pls_model, options_pls); % no Y_test // Yemen set



% -- DISPLAY RESULTS
dso_info(Xcal); dso_info(Xtest); 
fprintf(1,'PLS regression --> class (LV %d):\n---------------------------------\n', lv)
ypred = pls_pred.pred{1,2};
pclass = round(ypred);
Ymax = max(Ytest); Ymin = min(Ytest);
key = find (pclass < Ymin); pclass(key) = Ymin; % find replace values below min(Y)
key = find (pclass > Ymax); pclass(key) = Ymax; % find replace values above max(Y)


pred = [Ytest', pclass]; % actual-class, predicted-class



% -----------
% -- Kappa --
%pred2kappa (pred); % ConfMatrix and Kappa // kappa(C), kappa(C,1)
[k, po, k2, po2, pa, ppv, spec, sens, tp, fp, fn, tn] = pred2kappa (pred);


fprintf(1,'/PLS regression --> class (LV %d):\n---------------------------------\n', lv)
fprintf('\n')

return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% /tm_pls %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
