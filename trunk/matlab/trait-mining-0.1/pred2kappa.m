function [k, po, k2, po2, pa, ppv, spec, sens, tp, fp, fn, tn] = pred2kappa(pred)
% ** PRED2KAPPA ** 
% This function computes and displays the Cohen's kappa coefficient
% To calculate the KAPPA coefficient we first need a Confusion Matrix
% Array of actual class against predicted class as a cross-tab
%
% Syntax: [k,po, k2,po2, pa,ppv, spec,sens, tp,fp,fn,tn] = pred2kappa(pred)
%
%   INPUT:
%     pred - array of actual, and predicted_class: [a p; a p; ...; a p]
%
%     From the classification models, the predicted class is extracted,
%     and combined as the second column together with the actual class.
%     This new array has the samples down as rows and two columns.
%
%   OUTPUT:
%     Displays on the screen a summary including the confusion matrix and
%     the KAPPA coefficient output from the script created by 
%     Giuseppe Cardillo (giuseppe.cardillo-edta@poste.it). 
%     Available online from:
%     http://www.mathworks.com/matlabcentral/fileexchange/15365
%     Cardillo G. (2007) Cohen's kappa: compute the Cohen's kappa ratio 
%     on a 2x2 matrix.
%
%     Cohen's Kappa (k), Observed Agreement (po)
%
%     And for the matrix collapsed to a 2x2 confusion matrix:
%      Positive Agreement (pa), Positive Predictive Value (ppv), 
%      Specificity (spec), Sensitivity (sens), True Positives (tp), 
%      False Positives (fp), False Negatives (fn), True Negatives (tn)
%
%   Example: 
%       pred=[2 1; 3 3; 1 1; 1 1; 1 3; 2 1; 2 2; 3 2];
%       pred2kappa(pred)
%
% Script pred2kappa by: Dag Endresen (dag.endresen@gmail.com), GPL2, 30 July 2010
% See also: KAPPA, CONFUSIONMAT, KNN, CLASSIFY, SIMCA, PLSDA, dso_info
%

if isempty(pred), error('Warning: PRED matrix is empty...'); end;
if isvector(pred), error('Warning: PRED must be a matrix not a vector'); end;

% Confusion matrix // error matrix
[C, order] = confusionmat (pred(:,2)', pred(:,1)');
disp('Confusion matrix:');
disp(C);
disp('Class agreement (per class):');
class_agreement = cat(1,order',(diag(C) ./ sum(C')')'); % ratio per class
disp(class_agreement);

% kappa(C,n) % 0=unweighted, 1=linear weighted, 2=quadratic, -1=all
[k1, po1] = kappa_less(C,0); % kappa_less based on Cardillo (2007)
[k, po] = kappa_less(C,1);

agreement_no = sum(diag(C)); % sum samples agree
agreement_po = sum(diag(C)) / sum(sum(C)); % ratio agree
fprintf('Observed agreement (Num)     = %0.0f samples \n',agreement_no);
fprintf('Observed agreement (PO)      = %0.3f\n',agreement_po);
fprintf('Cohen''s kappa, no wgt (k)    = %0.3f\n',k1);
fprintf('-- Linear Weighted --\n');
fprintf('Cohen''s kappa, weighted (k)  = %0.3f  <--- Kappa (weighted)\n',k);
fprintf('Observed agreement (po)      = %0.3f  <--- PO (weighted)\n',po);

% -----------------
% Collapse C to 2x2
% -----------------
if (size(C,1)==3),
    disp('--------------------------------------------------------------');
    disp('Confusion matrix collapsed from 3x3 to 2x2:');
    C2 = [C(1,1), sum(C(1,2:3));
        sum(C(2:3,1)), sum(sum(C(2:3,2:3)))];
    disp(C2);
elseif (size(C,1)==9), 
    disp('--------------------------------------------------------------');
    disp('Confusion matrix collapsed from 9x9 to 2x2:');
    C2 = [sum(sum(C(1:3,1:3))), sum(sum(C(1:3,4:9)));
        sum(sum(C(4:9,1:3))), sum(sum(C(4:9,4:9)))];
    disp(C2);
elseif (size(C,1)==2), 
    C2 = C;
    disp(C2);
elseif (size(C,1)>=5), 
    disp('--------------------------------------------------------------');
    disp('---------- WARNING: missing categories -----------------------');
    disp('- Make sure that categories 1, 2, 3 are NOT missing!!!');
    disp('- Calculations will ONLY be valid with three categories!!!');
    disp('--------------------------------------------------------------');
    disp('Confusion matrix collapsed from NxN to 2x2:');
    C2 = [sum(sum(C(1:3,1:3))), sum(sum(C(1:3,4:end)));
        sum(sum(C(4:end,1:3))), sum(sum(C(4:end,4:end)))];
    disp(C2);
else
    disp('--------- WARNING: Problem with the Confusion matrix -------');
    C2 = [1 1; 1 1]; % Dummy C to avoid the script crashing below
end;

if ~isempty(C2)
    tp = C2(1,1); % True Positives
    tn = C2(2,2); % True Negatives
    fp = C2(1,2); % False Positives
    fn = C2(2,1); % False Negatives
    po2 = sum(diag(C2)) / sum(sum(C2)); % PO
    pa = 2*tp / ( 2*tp + fp + fn ); % PA
    ppv = tp / ( tp + fp ); % PPV
    sens = tp / ( tp + fn ); % Sensitivity
    spec = tn / ( fp + tn ); % Specificity
    [k2, po2_k] = kappa_less(C2, 1);
    % -- DISPLAY indicators
    fprintf('Cohen''s kappa       (k, 2x2) = %0.3f\n',k2);
    fprintf('Observed agreement (PO, 2x2) = %0.3f\n',po2);
    fprintf('Observed pos. agr. (PA, 2x2) = %0.3f  <--- PA \n',pa);
    fprintf('Positive pred. val (PPV,2x2) = %0.3f  <--- PPV \n',ppv);
    fprintf('Specificity       (Spec,2x2) = %0.3f  <--- Specificity \n',spec);
    fprintf('Sensitivity       (Sens,2x2) = %0.3f \n',sens);
    fprintf('----------------------------------------------------------\n');
    fprintf('Cohen''s kappa, weighted (k)  = %7.3f  <--- Kappa (weighted)\n',k);
    fprintf('Observed agreement wgt (po)  = %7.3f  <--- PO (weighted)\n',po);
    fprintf('True Positives     (TP, 2x2) = %7.0f  <--- TP \n',tp);
    fprintf('True Negatives     (TN, 2x2) = %7.0f  <--- TN \n',tn);
    fprintf('\n');
else
    tp = NaN; tn = NaN; fp = NaN; fn = NaN;
    pa = NaN; ppv = NaN; sens = NaN; spec = NaN; po2 = NaN; k2 = NaN;
end;

return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% /pred2kappa %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
