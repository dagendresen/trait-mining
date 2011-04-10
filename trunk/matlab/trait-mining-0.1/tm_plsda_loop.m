function lv = tm_plsda_loop(Xcal, Xtest, lvs)
% ** PLS-DA model for trait mining (FIGS) ** 
% This function will run a series PLS-DA classification to estimate the
% optimal complecity
%
% Syntax: 	lv = tm_plsda_loop(Xcal, Xtest, lvs)
%
%   INPUT:
%     Xcal - Calibration set (DSO)
%     Xtest - Test set (DSO)
%     lvs - number of latent variables for the last PLS-DA model
%
%   OUTPUT:
%     Displays on the screen a summary of the classification
%
%   Example: 
%       tm_plsda_loop(Xcal, Xtest, 20);
%
% What-To-Look-For:
%     ... todo
%
% Script by:
%     Dag Endresen (dag.endresen@gmail.com), GPL2, August 3, 2010
%
%
% See also: dso_info pred2kappa KAPPA, CONFUSIONMAT, KNN, CLASSIFY, SIMCA, PLSDA, MODELVIEWER
%

if isempty(Xcal)
    error('Warning: Xcal matrix is empty...');
end
if isempty(Xtest)
    error('Warning: Xtest matrix is empty...');
end

if isempty(lvs)
    error('Warning: lvs scalar is empty...');
    %lvs = 20;
end




fprintf('\n')
disp('-----------------------------------------------');
fprintf(1,'-------- PLS-DA classification (LV 1 to LV %d) ---------\n', lvs);
disp('-----------------------------------------------');
fprintf('\n')



% -- DISPLAY RESULTS
dso_info(Xcal); dso_info(Xtest); 
fprintf(1,'PLS-DA classification (LV 1 to LV %d):\n----------------------------\n', lvs)


% -- Loop LVs for finding PLS-DA model complexity
% clear a; clear loops; 
n=0; 
%loops = 3;
a = zeros(lvs, 12);

for i = 1:1:lvs
    n = n+1; 
    a(n, 1) = i;
    [a(n,2), a(n,3), a(n,4), a(n,5), a(n,6), a(n,7), a(n,8), a(n,9), a(n,10), a(n,11), a(n,12), a(n,13)] = tm_plsda (Xcal, Xtest, i); 
    % -- a(n,6) = 0.446; % DEBUG
end
fprintf('LV  kappa  po      k(2x2)  po(2)   pa     pvv    spec   sens    tp    fp    fn   tn \n');

for n = 1:lvs
    fprintf('%2.0f %6.3f %6.3f %7.3f %7.3f %7.3f %6.3f %6.3f %6.3f %5.0f %5.0f %5.0f %5.0f \n', a(n,1), a(n,2), a(n,3), a(n,4), a(n,5), a(n,6), a(n,7), a(n,8), a(n,9), a(n,10), a(n,11), a(n,12), a(n,13) );
end


fprintf('\n');


bb = zeros(1,3); % initialize
% b is an array with the key(s) for the highest indicator values
% b(1) selects the first of the highest indicator values (simplest model)
% bb collects the "best" models (#LVs) for PA, PVV, and Specificity
% median(bb) picks the middle/median #LV from "the best" PA, PVV, Specificity
% --
b = find(a(:,2) == max(a(:,2))); % find key(s) for the highest Kappa
fprintf('\t Max Kappa: %6.4f   at LV: %2.0f \n', max(a(:,2)), b(1) );
b = find(a(:,6) == max(a(:,6))); bb(1,1) = b(1);
fprintf('\t Max PA   : %6.4f   at LV: %2.0f  <--- PA \n', max(a(:,6)), b(1) );
b = find(a(:,7) == max(a(:,7))); bb(1,2) = b(1);
fprintf('\t Max PVV  : %6.4f   at LV: %2.0f  <--- PPV \n', max(a(:,7)), b(1) );

b = find(a(:,8) == max(a(:,8))); bb(1,3) = b(1);
fprintf('\t Max Spec : %6.4f   at LV: %2.0f  <--- Spec \n', max(a(:,8)), b(1) );
b = find(a(:,9) == max(a(:,9)));
fprintf('\t Max Sens : %6.4f   at LV: %2.0f \n', max(a(:,9)), b(1) );



fprintf('--------------------------------------- \n');
fprintf('\t   Suggested number of LVs: %2.0f \n', median(bb) );
lv = median(bb);
fprintf('\n');
% -- DISPLAY indicators
% --
fprintf('Cohen''s Kappa (K)    for LV %0.0f = %7.3f   <--- Kappa \n', lv, a(lv,2) );
fprintf('Observed Agreem (PO) for LV %0.0f = %7.3f   <--- PO \n', lv, a(lv,3) );
fprintf('\n');
fprintf('True Positives (TP)  for LV %0.0f = %7.0f   <--- TP \n', lv, a(lv,10) );
fprintf('True Negatives (TN)  for LV %0.0f = %7.0f   <--- TN \n', lv, a(lv,13) );
fprintf('\n');



fprintf('\n\n');
fprintf(1,'/PLS-DA classification (LV 1 to LV %d)\n------------------------------------\n', lvs)
fprintf('\n')

return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% /tm_plsda_loop %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
