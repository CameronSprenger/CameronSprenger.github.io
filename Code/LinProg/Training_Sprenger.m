clear
clc
close all

tic
mu=1000;


% Reading in the data from the mat file
load("mnist","images");
load("mnist","labels");


% Sets sizes of data to variables
length=height(images);
original_size=width(images);
original_width=sqrt(original_size);


% Preprocessing training data

% Removes the top and bottom of each image in the training set
images(:,1:original_width)=[];
images(:,original_size-2*original_width+1:original_size-original_width)=[];

% Removes the sides of the images in the training set
for j=1:original_width-2
    images(:,(1+(j-1)*(original_width-1)))=[];
    images(:,j*(original_width-2))=[];

end


% Convert integer to double
images=double(images);

% Normalize the data by 255 (8-bit) and flip from black to white
images=1-(images./255);


% Redefine new images sizes
size=width(images);
width=sqrt(size);


% Sorting the test data from 0-9
labels=double(labels);
images=[labels images];    % Appends the labels onto the test data
sorted_combined_training=sortrows(images);   % Sorts the images based on their label 
sorted_combined_training(:,1)=[];               % Removes the labeling from the images
images=sorted_combined_training;           % Sets the new sorted data to variable


% Generate the A and B matrices 

neg=-1.+zeros(height(images),1);
A_hat=[images, neg; sqrt(mu).*eye(size), zeros(size,1)];


% Make a B vector for each classifier using sorted label vector

sort_labels=sortrows(labels);

for i=0:9
    temp=[];
    count=0;
    for j=1:length
        if sort_labels(j,1)==i
            temp(j,1)=1;
            count=count+1;
        else
            temp(j,1)=-1;
        end
    end
    counter(i+1)=count;             % Counts the number of each character
    c{i+1}=[temp;zeros(size,1)];    % Appends zeros to the end of the vector 
end

% Moves Bfor zero to the end for indexing reasons
b_hat=circshift(c,9);
counter=circshift(counter,9);


% Solves for x with pseudo inverse
for i=1:10
    x_hat{i}=pinv(A_hat)*b_hat{i};
end


% Decompose x_hat into A and b
for i=1:10;
    temp=x_hat{i};
    b{i}=temp(size+1);
    A{i}=temp(1:size);
end

% Plots the beta for each classifier
hold on 
for i=1:10
    subplot(5,2,i);
    I=reshape(A{i},width,width);
    imshow(I')
    colormap default
    clim([min(A{i}) max(A{i})])
    colorbar
end
hold off
toc

% Saves the trained A and b as .mat
save('A');
save('b');
A=cell2mat(A)';
b=cell2mat(b)';
save('Hyperplanes_Sprenger','A','b')