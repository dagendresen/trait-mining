function tm_pre_study(Xcal, Xtest)
% ** PRE-study ** 
% This function calibrate different classification and discrimination
% models and displays the results on screen
%
% Syntax: 	tm_pre_study(Xcal, Xtest)
%
%   INPUT:
%     Xcal  - Dataset Object, independent/predictor data for calibration
%     Xtest - Dataset Object, independent/predictor data for validation
%
%   OUTPUT:
%     Displays on the screen a summary of the pre-study classification and
%     discrimination tests (kNN, SIMCA, LDA, DA-DL, PLS-DA, and PLS)
%
%   Example: 
%     X = data(:, 1:48); % climate data (prec, tmax, tmin, pet, ...)
%     X = data(:, 85:103); % BioClim climate data
%
%     X = X(find(str2num(X.label{1,16}) == 11) ); % subset from label 16
%     X = X(find(str2num(X.label{1,16}) == 21) ); % subset from label 16
%
%     -- SPLIT in two subsets, Xcal, Xtest (predictor dataset, as DSO)
%     -- SET CLASS, the first class of the DSOs is used as Y (response)
%
%     tm_pre_study (Xcal, Xtest); % performs KNN, SIMCA, LDA, DA-DL, PLS-DA, and PLS
%
% Script by: Dag Endresen (dag.endresen@gmail.com), GPL2, 20 August 2010
% See also: pred2kappa, KAPPA, CONFUSIONMAT, KNN, CLASSIFY, SIMCA, PLSDA
%

if isempty(Xcal), error('Warning: Xcal matrix is empty...'); end;
if isempty(Xtest), error('Warning: Xtest matrix is empty...'); end;

fprintf ('---------------------------------------------------------\n');
fprintf ('---------------- NEW PRE-STUDY TEST ---------------------\n');
fprintf ('---------------------------------------------------------\n\n');

Ycal = Xcal.class{1,1}; % Y response class for SIMCA
Ytest = Xtest.class{1,1}; % Y response class for SIMCA
dso_info(Xcal); % number of samples for the Training set
dso_info(Xtest); % number of samples for the Test set

fprintf('\n\n');
fprintf('-----------------------------------------------------------\n');
fprintf('---------------- PRESS SPACE TO CONTINUE ------------------\n');
fprintf('-----------------------------------------------------------\n\n\n'); pause;
fprintf (' ---------------------- \n');
fprintf (' -- RANDOM selection -- \n');
fprintf (' ---------------------- \n\n\n');
fprintf('A rough test to select random samples\n\n');
clear r; r = randperm(size(Xtest,1)); % random permutation
clear Xr; Xr = Xtest(r, :); % random order all test samples
clear pclass; pclass = Xr.class{1,1}';
fprintf(1,'RANDOM classification:\n-------------------\n')
Ytest = Xtest.class{1,1};
clear pred; pred = [Ytest', pclass]; pred2kappa (pred); clear Xr; 

fprintf('\n\n');
fprintf('---------------------------------------------------------\n');
fprintf('---------------- PRESS SPACE TO CONTINUE ----------------\n');
fprintf('---------------------------------------------------------\n\n\n'); pause;
fprintf (' --------- \n');
fprintf (' -- kNN -- \n');
fprintf (' --------- \n\n\n');
clear pclass; pclass = knn(Xcal, Xtest, 1); 
fprintf(1,'kNN classification:\n-------------------\n')
clear pred; pred = [Ytest', pclass]; pred2kappa (pred);

fprintf('\n\n');
fprintf('-----------------------------------------------------------\n');
fprintf('---------------- PRESS SPACE TO CONTINUE ------------------\n');
fprintf('-----------------------------------------------------------\n\n\n'); pause;
fprintf (' ----------- \n');
fprintf (' -- SIMCA -- \n');
fprintf (' ----------- \n\n\n');
fprintf(1,'SIMCA classification:\n---------------------\n');
% tm_simca (Xcal, Xtest, 7); % last input is the number of PCs
tm_simca_loop (Xcal, Xtest, 15); % last input is the number of loops

fprintf('\n\n');
fprintf('-----------------------------------------------------------\n');
fprintf('---------------- PRESS SPACE TO CONTINUE ------------------\n');
fprintf('-----------------------------------------------------------\n\n\n'); pause;
fprintf (' ------------ \n');
fprintf (' -- PLS-DA -- \n');
fprintf (' ------------ \n\n\n');
fprintf(1,'PLS-DA classification:\n----------------------\n');
tm_plsda (Xcal, Xtest, 7); % last input is the number of LVs
% tm_plsda_loop (Xcal, Xtest, 15); % last input is the number of loops

fprintf('\n\n');
fprintf('-----------------------------------------------------------\n');
fprintf('---------------- PRESS SPACE TO CONTINUE ------------------\n');
fprintf('-----------------------------------------------------------\n\n\n'); pause;
fprintf (' -------- \n');
fprintf (' -- DA -- \n');
fprintf (' -------- \n\n\n');
% -- LDA is LAST because it often makes the script to crash 
% -- //Error using ==> classify at 245
% -- //The pooled covariance matrix of TRAINING must be positive definite.
% -- diag-covar-matrix TYPE: 'linear' LDA, 'diaglinear' DA-DL, 'diagquadratic' DA-DQ
fprintf(1,'LDA classification:\n--------------------\n');
pclass=classify(Xtest.data,Xcal.data,Ycal,'linear'); 
pred=[Ytest',pclass]; pred2kappa(pred); % LDA

fprintf('\n\n');
fprintf('-----------------------------------------------------------\n');
fprintf('---------------- PRESS SPACE TO CONTINUE ------------------\n');
fprintf('-----------------------------------------------------------\n\n\n'); pause;

fprintf('\n\n');
dso_info(Xcal); dso_info(Xtest); 

% plotscores(plsda_model, plsda_pred);
% plotsloads(plsda_model, plsda_pred);
% ploteigen(plsda_model, plsda_pred);
% plotgui(plsda_model, plsda_pred);

fprintf('\n\n');
fprintf('-----------------------------------------------------------\n');
fprintf('---------------- PRE-STUDY TEST COMPLETED -----------------\n');
fprintf('-----------------------------------------------------------\n\n\n');

return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% /tm_pre_study %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

