 clear
clc
close all

k=3



gamma=.0001*10^k;
n=10;

load("mnist","images");
load("mnist","labels");


% Sets sizes of data to variables
length=height(images);
original_size=width(images);
original_width=sqrt(original_size);


% Preprocessing training data

% Removes the top and bottom of each image in the training set
images(:,1:4*original_width)=[];
images(:,width(images)-4*original_width+1:end)=[];

% Removes the sides of the images in the training set
for j=1:original_width-8
    images(:,(1+(j-1)*(original_width-8)):(1+(j-1)*(original_width-8))+3)=[];
    images(:,j*(original_width-8)-3:j*(original_width-8))=[];

end


% Convert integer to double
images=double(images);

% Normalize the data by 255 (8-bit) and flip from black to white
images=(images./255);


% Redefine new images sizes
size=width(images);
width=sqrt(size);



% Sorting the test data from 0 to 9 
labels=double(labels);
images=[labels images];    % Appends the labels onto the test data
sorted_combined_training=sortrows(images);   % Sorts the images based on their label 
sorted_combined_training(:,1)=[];               % Removes the labeling from the images
images=sorted_combined_training;           % Sets the new sorted data to variable
sort_labels=sortrows(labels);



% Creates the DAG classification structure for 1-10
classification_num=cell(n-1,n-1);
for i=1:n-1
    counter_cell=1;
    for j=1:n-i
    classification_num{n-i,counter_cell}=[j-1,j+i-1];
    counter_cell=counter_cell+1;
    end
end


% Finds the number of images in each class
for i=1:n
    class_size(i)=sum(sort_labels==i-1);
end


% Separate out the images based on the labels into bins.
temp=[sort_labels images];
classes=cell(1,10);
sum=1;
for i=1:n
    classes{i}=images(sum:sum+class_size(i)-1,:);
    sum=sum+class_size(i);
end

%% Train the 45 classifiers with the two groups of data the classifier is
% testing for

% Reshape the classification numbers so it can read through them left ro
% right in an array
    test=reshape(classification_num',1,81);
    test = test(~cellfun('isempty',test));

A=cell(10,10);
B=cell(10,10);
% 
for i=1:45
    % Reads in the numbers the classifier needs to train on
    data=test{i};
    neg=data(1,2);
    pos=data(1,1);

    %Generate the A matrix
    m_neg=height(classes{neg+1});
    m_pos=height(classes{pos+1});


    A_hat=[-cell2mat(classes(pos+1)), ones(m_pos,1), -eye(m_pos), zeros(m_pos,m_neg);
        cell2mat(classes(neg+1)),-ones(m_neg,1), zeros(m_neg,m_pos), -eye(m_neg);
        zeros(m_pos,400), zeros(m_pos,1), -eye(m_pos), zeros(m_pos,m_neg);
        zeros(m_neg,400), zeros(m_neg,1), zeros(m_neg, m_pos), -eye(m_neg)];
    A_hat=sparse(A_hat);

    % Generate the b matrix
    b_hat=[-ones(m_pos,1);
        -ones(m_neg,1);
        zeros(m_pos,1);
        zeros(m_neg,1)
        ];
    b_hat=sparse(b_hat);

    % Generate the f matrix
    f=gamma.*[zeros(400,1);
        zeros(1,1);
        ones(m_pos,1);
        ones(m_neg,1)];
    f=sparse(f);

    % Generate the H matrix
    H=([2.*eye(400), zeros(400, 1+m_pos+m_neg);
        zeros(1+m_pos+m_neg,400+1+m_pos+m_neg)]);
    H=sparse(H);


    trained_class=quadprog(H,f,A_hat,b_hat);

    a = trained_class(1:400);
    b = trained_class(401);
            A{pos+1,neg+1} = a;
            B{pos+1,neg+1} = b;

    i
end
% 
% 
save("DAG_SprengerSmall","A","B")


