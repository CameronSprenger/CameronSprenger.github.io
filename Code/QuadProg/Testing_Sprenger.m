clear
clc
close all 

% Loads in the data and trained model
load mnist.mat

images_test=double(images_test);
labels_test=double(labels_test);

A=cell(10,10);
B=cell(10,10);
load("DAG_SprengerSmall.mat")


% Sets sizes of data to variables
length=height(images_test);
original_size=width(images_test);
original_width=sqrt(original_size);


% Preprocessing training data

% Removes the top and bottom of each image in the training set
images_test(:,1:4*original_width)=[];
images_test(:,width(images_test)-4*original_width+1:end)=[];

% Removes the sides of the images in the training set
for j=1:original_width-8
    images_test(:,(1+(j-1)*(original_width-8)):(1+(j-1)*(original_width-8))+3)=[];
    images_test(:,j*(original_width-8)-3:j*(original_width-8))=[];

end


% Convert integer to double
images_test=double(images_test);

% Normalize the data by 255 (8-bit) and flip from black to white
images_test=(images_test./255);


% Redefine new images sizes
size=width(images_test);
width=sqrt(size);


% sort the data based on the labels
temp=[labels_test images_test];
temp=sortrows(temp);
labels_test=temp(:,1);
images_test=temp(:,2:end);

% Creates the testing loop that trickels down the DAG

for j=1:10000;
    row=1;
    column=10;
    for i=1:9;
        score=A{row,column}'*images_test(j,:)'-B{row,column};
        if score>=0
            column=column-1;
        else
            row=row+1;
        end
        guess(j,1)=row-1;
    end
end

corerct=10000-sum(guess~=labels_test);

% Makes the confusion Matrix
conf_mat=zeros(10,10);

for i=1:10000
conf_mat(guess(i,1)+1,labels_test(i,1)+1)=conf_mat(guess(i,1)+1,labels_test(i,1)+1)+1;
end

accuracy =100*trace(conf_mat)/10000

guess_tot=zeros(10,1);
expected_tot=zeros(1,10);

 for i=1:10
    guess_tot(i,1)=sum(conf_mat(i,:));
    expected_tot(1,i)=sum(conf_mat(:,i));
 end

 conf_mat=[conf_mat guess_tot;expected_tot 10000];

conf_mat=array2table(conf_mat);
table2latex(conf_mat,'ConfusionMat')



function table2latex(T, filename)
    
    % Error detection and default parameters
    if nargin < 2
        filename = 'table.tex';
        fprintf('Output path is not defined. The table will be written in %s.\n', filename); 
    elseif ~ischar(filename)
        error('The output file name must be a string.');
    else
        if ~strcmp(filename(end-3:end), '.tex')
            filename = [filename '.tex'];
        end
    end
    if nargin < 1, error('Not enough parameters.'); end
    if ~istable(T), error('Input must be a table.'); end
    
    % Parameters
    n_col = size(T,2);
    col_spec = [];
    for c = 1:n_col, col_spec = [col_spec 'l']; end
    col_names = strjoin(T.Properties.VariableNames, ' & ');
    row_names = T.Properties.RowNames;
    if ~isempty(row_names)
        col_spec = ['l' col_spec]; 
        col_names = ['& ' col_names];
    end
    
    % Writing header
    fileID = fopen(filename, 'w');
    fprintf(fileID, '\\begin{tabular}{%s}\n', col_spec);
    fprintf(fileID, '%s \\\\ \n', col_names);
    fprintf(fileID, '\\hline \n');
    
    % Writing the data
    try
        for row = 1:size(T,1)
            temp{1,n_col} = [];
            for col = 1:n_col
                value = T{row,col};
                if isstruct(value), error('Table must not contain structs.'); end
                while iscell(value), value = value{1,1}; end
                if isinf(value), value = '$\infty$'; end
                temp{1,col} = num2str(value);
            end
            if ~isempty(row_names)
                temp = [row_names{row}, temp];
            end
            fprintf(fileID, '%s \\\\ \n', strjoin(temp, ' & '));
            clear temp;
        end
    catch
        error('Unknown error. Make sure that table only contains chars, strings or numeric values.');
    end
    
    % Closing the file
    fprintf(fileID, '\\hline \n');
    fprintf(fileID, '\\end{tabular}');
    fclose(fileID);
end
