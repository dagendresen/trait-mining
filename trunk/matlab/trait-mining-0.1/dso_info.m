function dso_info(X)
% ** DSO_INFO ** 
% This function displays the name of the DSO and the first class.
%
% Syntax: 	dso_info(X)
%
%   INPUT:     X - Dataset Object
%   OUTPUT:    Displays on the screen a summary of the Dataset Object
%   Example:   X = usda_t_aestivum(:, 97:115);
%
% Script dso_info by: Dag Endresen (dag.endresen@gmail.com), GPL2, 30 July 2010
% See also: KAPPA, CONFUSIONMAT, KNN, CLASSIFY, SIMCA, PLSDA
%

if isempty(X), error('Warning: X matrix is empty...'); end;
fprintf('-------------------------------------------------------\n');

% -- Display DSO name and size
fprintf(1, 'Dataset Object Name: \t%s \n', X.name);
[rows, cols] = size(X);
fprintf(1, 'DSO matrix size: \tRows = %0.0f, Columns = %0.0f \n', rows, cols);

% -- Display categories (first class)
fprintf('Categories (class 1): \t');
fprintf('%s: ', X.classname{1,1});
fprintf('%0.0f ', unique(X.class{1,1}));
fprintf('\n');

% -- Count samples
clear u; clear col; clear key; clear a;
u = unique(X.class{1,1});
col = X.class{1,1};
for i = 1:size(u,2), 
    key = find(col(1,:) == u(1,i));  
    a(i,1) = u(1,i); 
    a(i,2) = size(key,2); 
end;
disp(a');
return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% /dso_info %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
