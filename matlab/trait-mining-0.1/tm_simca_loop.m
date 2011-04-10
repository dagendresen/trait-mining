function pc = tm_simca_loop(Xcal, Xtest, pcs)
% ** SIMCA model for trait mining, FIGS ** 
% This function will run a SIMCA classification
%
% Syntax: pc = tm_simca_loop(Xcal, Xtest, pcs)
%
%   INPUT:
%     Xcal - Calibration set (DSO)
%     Xtest - Test set (DSO)
%     pcs - number of principal components for the last SIMCA model (loops)
%
%   OUTPUT: Displays on the screen a summary of the classification
%   Example:  tm_simca_loop(Xcal, Xtest, 20);
%
% Script by: Dag Endresen (dag.endresen@gmail.com), GPL2, 3 August 2010
% See also: dso_info, pred2kappa, KAPPA, CONFUSIONMAT, KNN, CLASSIFY, SIMCA, PLSDA
%

if isempty(Xcal), error('Warning: Xcal matrix is empty...'); end;
if isempty(Xtest), error('Warning: Xtest matrix is empty...'); end;
if isempty(pcs), error('Warning: pcs scalar is empty...'); end;

fprintf('\n');
fprintf('----------------------------------------------\n');
fprintf(1,'-------- SIMCA classification (PC 1 to PC %d) ---------\n', pcs);
fprintf('----------------------------------------------\n');

% -- DISPLAY RESULTS
dso_info(Xcal); dso_info(Xtest); 
fprintf(1,'SIMCA classification (PC 1 to PC %d):\n------------------------\n', pcs);
% -- Loop PCs for finding SIMCA model complexity
n=0; a = zeros(pcs, 12);
for i = 1:1:pcs
    n = n+1; 
    a(n, 1) = i;
    [a(n,2),a(n,3),a(n,4),a(n,5),a(n,6),a(n,7),a(n,8),a(n,9),a(n,10),a(n,11),a(n,12), a(n,13)] = tm_simca (Xcal, Xtest, i); 
end;
fprintf('PC  kappa  po      k(2x2)  po(2)   pa     pvv    spec   sens    ');
fprintf('tp    fp    fn   tn \n');
for n = 1:pcs
    fprintf('%2.0f %6.3f %6.3f %7.3f %7.3f %7.3f %6.3f %6.3f %6.3f %5.0f %5.0f %5.0f %5.0f \n', a(n,1), a(n,2), a(n,3), a(n,4), a(n,5), a(n,6), a(n,7), a(n,8), a(n,9), a(n,10), a(n,11), a(n,12), a(n,13) );
end
fprintf('\n');
bb = zeros(1,3); % initialize
% b is an array with the key(s) for the highest indicator values
% b(1) selects the first of the highest indicator values (simplest model)
% bb collects the "best" models (#pc) for PA, PVV, and Specificity
% median(bb) picks the middle/median #PC from PA, PVV, Specificity

b = find(a(:,2) == max(a(:,2))); % find key(s) for the highest Kappa
fprintf('\t Max Kappa: %6.4f   at PC: %2.0f \n', max(a(:,2)), b(1) );
b = find(a(:,6) == max(a(:,6))); bb(1,1) = b(1);
fprintf('\t Max PA   : %6.4f   at PC: %2.0f  <--- PA \n', max(a(:,6)), b(1) );
b = find(a(:,7) == max(a(:,7))); bb(1,2) = b(1);
fprintf('\t Max PVV  : %6.4f   at PC: %2.0f  <--- PPV \n', max(a(:,7)), b(1) );
b = find(a(:,8) == max(a(:,8))); bb(1,3) = b(1);
fprintf('\t Max Spec : %6.4f   at PC: %2.0f  <--- Spec \n', max(a(:,8)), b(1) );
b = find(a(:,9) == max(a(:,9)));
fprintf('\t Max Sens : %6.4f   at PC: %2.0f \n', max(a(:,9)), b(1) );
fprintf('---------------------------------------\n');
pc = median(bb);
fprintf('\t   Suggested number of PCs: %2.0f \n', median(bb) );
% -- DISPLAY indicators
fprintf('Cohen''s Kappa (K)    for PC %0.0f : %7.3f   <--- Kappa \n', pc, a(pc,2) );
fprintf('Observed Agreem (PO) for PC %0.0f : %7.3f   <--- PO \n', pc, a(pc,3) );
fprintf('True Positives (TP)  for PC %0.0f : %7.0f   <--- TP \n', pc, a(pc,10) );
fprintf('True Negatives (TN)  for PC %0.0f : %7.0f   <--- TN \n', pc, a(pc,13) );
fprintf('\n\n');
fprintf('NOTE THAT THIS IS ONLY A VERY ROUGH ESTIMATION OF MODEL COMPLEXITY\n\n');

return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% /tm_simca_loop %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

