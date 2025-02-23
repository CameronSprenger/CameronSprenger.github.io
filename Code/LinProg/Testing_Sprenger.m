clear
clc
clear all

tic

% loads in the data from mnist, and trained model
load('mnist','images_test')
load('mnist','labels_test')
load('A')
load('b')

% Sets lengths based on dimensions
length=height(images_test);
original_size=784;
original_width=sqrt(original_size);

% Removes the top and bottom of each image in the testing set
images_test(:,1:original_width)=[];
images_test(:,original_size-2*original_width+1:original_size-original_width)=[];

% Removes the sides of the images in the training set
for j=1:original_width-2
    images_test(:,(1+(j-1)*(original_width-1)))=[];
    images_test(:,j*(original_width-2))=[];
end


% Convert integer to double
images_test=double(images_test);
labels_test=double(labels_test);

% Normalize the data by 255 (8-bit) and flip the value from black to white
images_test=1-(images_test./255);


% Sorts the test data with the labels
combined=[labels_test images_test];
sorted=sortrows(combined);
sorted(:,1)=[];
images_test=sorted;


% Seperates the characters onto "1 vs rest" and solves
for j=1:10
index_red=1;        % Positive Identification
index_blue=1;       % Negative Identification
sign_red=[];
sign_blue=[];
sort_labels_test=sortrows(labels_test);
for i=1:length      % Seperates the images score into "1 vs all the rest"
    if sort_labels_test(i)==j   % Bin in red if labeled positively
        temp=A{j};
        sign_red(index_red)=temp'*images_test(i,:)'-b{j};
        index_red=index_red+1;
    else                        % Bin in Blue of labeled Negatively 
        temp=A{j};
        sign_blue(index_blue)=temp'*images_test(i,:)'-b{j};
        index_blue=index_blue+1;
    end

end

% Rounds the answers to .05 and sorts for plotting purposes
% True un modified scores saved for later
v_red=round(sign_red*20)/20;
v_blue=round(sign_blue*20)/20;

% Sorts the rounded scores
v_red=sort(v_red);
v_blue=sort(v_blue);


% Create x and y axis for distribution plot
[count_red,group_red{j}]=groupcounts(v_red');
[count_blue,group_blue{j}]=groupcounts(v_blue');

% Normalize data
frac_red{j}=count_red./index_red;
frac_blue{j}=count_blue./index_blue;

% Sort data 
score_red{j}=sort(sign_red);
score_blue{j}=sort(sign_blue);
end



% New loop for checking zeros because zero is indexed in the 10th position

index_red=1;
index_blue=1;
sign_red=[];
sign_blue=[];
sort_labels_test=sortrows(labels_test);
for i=1:length      % Seperates the images score into "1 vs all the rest"
    if sort_labels_test(i)==0
        temp=A{10};
        sign_red(index_red)=temp'*images_test(i,:)'-b{10};
        index_red=index_red+1;
    else
        temp=A{10};
        sign_blue(index_blue)=temp'*images_test(i,:)'-b{10};
        index_blue=index_blue+1;
    end

end

% Rounds the answers to .05 and sorts
v_red=round(sign_red*20)/20;
v_blue=round(sign_blue*20)/20;

v_red=sort(v_red);
v_blue=sort(v_blue);


% Create x and y axis for distribution plot
[count_red,group_red{j}]=groupcounts(v_red');
[count_blue,group_blue{j}]=groupcounts(v_blue');

% Normalizes and writes scores into score cell
frac_red{j}=count_red./index_red;
frac_blue{j}=count_blue./index_blue;
score_red{10}=sign_red;
score_blue{10}=sign_blue;


% Plots the bar graphs for each classifier
for i=1:10
    hold on
    subplot(2,5,i)
    bar(group_red{i},frac_red{i},'facecolor',"#D95319"); % Positively labeled data
    alpha(.7);      % Sets value of opacity
    hold on
    bar(group_blue{i},frac_blue{i},'facecolor',"#0072BD"); % Negatively labeled data
    alpha(.7)       % Sets value of opacity
    xline(0)
    ylabel("Fraction")
    xlabel("Score")
    legend("Positive Data","All other #'s","location", "north")
    if i==10;
        i=0;
    end
    title('Classifier plot for:' ,i);

end
hold off

% Create confusion matrix for each classifier
for i=1:10 
    s_red=sign(score_red{i});
    s_blue=sign(score_blue{i});
    conf(1,1)=sum(s_red(1,:)==1);     % True Positive
    conf(2,2)=sum(s_blue(1,:)==-1);   % True Negative
    conf(2,1)=sum(s_blue(1,:)==1);    % False Positive
    conf(1,2)=sum(s_red(1,:)==-1);    % False Negative
    confusion{i}=conf;
end

for i=1:10  % Accuracy for each individial classifier
    accuracy{i}=trace(confusion{i})/length;
end


% Tests the TEST data and classifies it as a number
true_pos=0;
for i=1:length
    for j=1:10
        temp=A{j};
        dig_score(j)=temp'*sorted(i,:)'-b{j};
    end

    % Finds the largest score, and classifies it as the index of that score
    [M,I(i,1)]=max(dig_score);

    if sort_labels_test(i)==I(i)    % if guess matches label, count it
        true_pos=true_pos+1;
    end

end


tru_pos_train=0;
% Tests the TRAINING data and classifies it as a number
for i=1:60000
    for j=1:10
    temp=A{j};
    dig_score_train(j)=temp'*sorted_combined_training(i,:)'-b{j};
    end
    % Finds the largest score, and classifies it as the index of that score
    [M,I_train(i,1)]=max(dig_score_train);

    if sort_labels(i)==I_train(i)    % if guess matched=s label, count it
        true_pos_train=tru_pos_train+1;
    end

end

% Makes vector with digit guesses
sorted_guess=I(:,1);
sorted_guess_train=I_train(:,1);

% Makes new sorted lebel vector to change 0 to 10 for comparison
% TESTING Set
for i=1:length
    if sort_labels_test(i)==0
        sort_labels_test(i)=10;
    end
end

% TRAINING Set
for i=1:60000
    if sort_labels(i)==0
        sort_labels(i)=10;
    end
end


% Creates the 10x10 confusion matrix for the TESTING set
conf_mat_temp=zeros(10,10);
for i=1:length
    % Predicted compared to expected
    conf_mat_temp(sorted_guess(i),sort_labels_test(i))=conf_mat_temp(sorted_guess(i),sort_labels_test(i))+1;
end

% Creates the 10x10 confusion matrix for the TRAINING set
conf_mat_temp_train=zeros(10,10);
for i=1:60000
    % Predicted compared to expected
    conf_mat_temp_train(sorted_guess_train(i),sort_labels(i))=conf_mat_temp_train(sorted_guess_train(i),sort_labels(i))+1;
end


% Creates the total and sum for TRAINING data set
for i=1:10
total(i,1)=sum(conf_mat_temp(i,:));
end

for i=1:10
all(i,1)=sum(conf_mat_temp(:,i));
end

% Creates the total and sum for TESTING data set
for i=1:10
total_train(i,1)=sum(conf_mat_temp_train(i,:));
end

for i=1:10
all_train(i,1)=sum(conf_mat_temp_train(:,i));
end

% Adds the "totals" and "all" columns and rows to the confusion matrix
conf_mat=zeros(11,11);
conf_mat(1:10,1:10)=conf_mat_temp;
conf_mat(1:10,11)=total;
conf_mat(11,1:10)=all;
conf_mat(11,11)=length;

% Same for the training set
conf_mat_train=zeros(11,11);
conf_mat_train(1:10,1:10)=conf_mat_temp_train;
conf_mat_train(1:10,11)=total_train;
conf_mat_train(11,1:10)=all_train;
conf_mat_train(11,11)=60000;

% Finds the Fof true positive identifications 
trace(conf_mat_temp)/length*100
trace(conf_mat_temp_train)/60000*100


% Creates the image that shows which pixels that were removed
pixels=1.+zeros(28,28);
pixels(1,:)=0;
pixels(28,:)=0;
pixels(:,1)=0;
pixels(:,28)=0;

figure 
imshow(pixels);

toc