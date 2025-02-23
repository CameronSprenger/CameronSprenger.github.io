2
clear
clc
close all
%%
% Size of the Sudoku grid, n x n
n=9;

%%
% Finds the sum of what the rows, columns, and blocks should be
summation=n*(n+1)/2;

vec=[1:1:n];

x_tilde=[];
for i=1:n^2
    x_tilde=[x_tilde vec];
end

%%

% Takes in clue vector
if n==4
% TEST
% x_3=4  (12)
% x_5=1  (17)
% x_12=3 (47)
% x_14=1 (53)
% Manually sets the clue matrix for a 4x4
clue=zeros(1,n^3);
clue(12)=1;
clue(17)=1;
clue(47)=1;
clue(53)=1;


% Makes teh A_clue matrix for a 4x4
entries=nnz(clue);      % number of no-zero elements
A_clue=zeros(entries,n^3);
counter=1;

for i=1:n^3
    if clue(i)~=0
        A_clue(counter,i)=1;
        counter=counter+1;
    end
end
% Makes the b vector for the 4x4 Sudoku
b_clue=ones(entries,1);
end

% Sets the clue matrices provided to us
if n==9
% Clue matrices

% % MEDIUM LEVEL
MatrixInitial{1} = [0 5 0 0 2 0 3 7 0;
0 3 0 9 4 0 0 0 1;
0 0 0 7 0 0 0 0 0;
0 0 5 8 0 0 9 2 0;
3 0 0 0 0 0 0 0 5;
0 7 8 0 0 9 1 0 0;
0 0 0 0 0 2 0 0 0;
8 0 0 0 7 6 0 5 0;
0 2 1 0 8 0 0 6 0];
% EVIL LEVEL
MatrixInitial{2} = [0 6 9 7 0 0 4 3 0;
0 1 0 0 0 0 0 7 0;
3 0 0 0 0 5 0 0 2;
0 3 0 0 0 0 0 0 1;
0 0 0 0 9 0 0 0 0;
6 0 0 0 0 0 0 2 0;
7 0 0 2 0 0 0 0 3;
0 9 0 0 0 0 0 4 0;
0 4 2 0 0 3 5 1 0];
% EVIL LEVEL
MatrixInitial{3} = [4 0 0 0 3 0 9 0 7;
0 0 0 0 9 1 0 2 0;
0 3 0 0 0 0 0 6 0;
0 7 5 0 0 4 0 0 0;
0 4 0 5 0 8 0 9 0;
0 0 0 2 0 0 4 7 0;
0 2 0 0 0 0 0 5 0;
0 8 0 9 2 0 0 0 0;
7 0 3 0 5 0 0 0 8];
%EVIL LEVEL
MatrixInitial{4} = [0 9 0 4 0 8 5 0 0;
0 0 0 0 0 0 0 0 6;
2 0 1 0 7 0 9 0 0;
5 0 0 0 8 0 0 0 7;
0 0 7 9 0 4 1 0 0;
8 0 0 0 2 0 0 0 9;
0 0 2 0 3 0 4 0 5;
4 0 0 0 0 0 0 0 0;
0 0 5 8 0 7 0 9 0];
%Hardest Sudoku Ever
MatrixInitial{5} = [8 0 0 0 0 0 0 0 0;
0 0 3 6 0 0 0 0 0;
0 7 0 0 9 0 2 0 0;
0 5 0 0 0 7 0 0 0;
0 0 0 0 4 5 7 0 0;
0 0 0 1 0 0 0 3 0;
0 0 1 0 0 0 0 6 8;
0 0 8 5 0 0 0 1 0;
0 9 0 0 0 0 4 0 0];

% Additional Clue matrix for player to play
MatrixInitial{6} =[3 0 0 8 0 1 0 0 2;
        2 0 1 0 3 0 6 0 4;
        0 0 0 2 0 4 0 0 0;
        8 0 9 0 0 0 1 0 6;
        0 6 0 0 0 0 0 5 0;
        7 0 2 0 0 0 4 0 9;
        0 0 0 5 0 9 0 0 0;
        9 0 4 0 8 0 7 0 5;
        6 0 0 1 0 7 0 0 3];


%% Takes a user input to choose the playing grid
prompt="Enter a difficulty between 1 and 5";
input=input(prompt);

clue=MatrixInitial{input}';

clue=reshape(clue,1,[]);

entries=nnz(clue);      % number of no-zero elements
A_clue=zeros(entries,n^3);
counter=1;
for i=1:n^2
    if clue(i)~= 0
        index=(i-1)*n+clue(i);
        A_clue(counter,index)=1;
        counter=counter+1;
    end
end


b_clue=ones(entries,1);


end

%% ROW constraints
% Unique entries in rows
A_rows=zeros(n,n^3);
for i=1:n
    for j=1:n
        A_rows(i,(i-1)*n^2+(j-1)*n+1:(i-1)*n^2+j*n)=vec;
    end
end

temp=[];
for i=1:n
    temp=[temp eye(n)];
end

A_unique_row=[n^2,n^3];
for i=1:n
    A_unique_row((i-1)*n+1:i*n,(i-1)*n^2+1:i*n^2)=temp;
end

b_unique_row=ones(n^2,1);

%% COLUMN Constraints
% Unique entries in column
A_col=[];
temp_col=zeros(n,n^2);
for i=1:n
    temp_col(i,(i-1)*n+1:i*n)=vec;
end

for i=1:n
    A_col=[A_col temp_col];
end


temp=[];
for i=1:n
    temp=[temp eye(n)];
end

A_unique_col=[];
for i=1:n
    A_unique_col=[A_unique_col eye(n^2)];
end

b_unique_col=ones(n^2,1);

%% BLOCK Constraints
% Unique entries in blocks

% Makes the sub-pattern for the blocks
block_pat=zeros(sqrt(n),n^2);
for i=1:sqrt(n)
    for j=1:sqrt(n)
        block_pat(i,(i-1)*sqrt(n)*n+((j-1)*n+1):(i-1)*(sqrt(n))*n+(j*n))=vec;
    end
end

% Joins the sub-patterns to make full pattern
temp_block=[];
for i=1:sqrt(n)
   temp_block=[temp_block block_pat];
end

block_temp=zeros(27, 81);
for i=1:sqrt(n)
    block_temp((i-1)*n+1:i*n,(i-1)*n*sqrt(n)+1:i*n*sqrt(n))=[eye(n) eye(n) eye(n)];
end

block_temp=[block_temp block_temp block_temp];

A_unique_block=[block_temp zeros(27,243) zeros(27,243);
                zeros(27,243) block_temp zeros(27,243);
                zeros(27,243) zeros(27,243) block_temp];
%% Creates the pattern matrices for n=4 and 9

if n==4
    block_zeros=zeros(2,32);

    A_block=[temp_block block_zeros;block_zeros temp_block];
end

if n==9
    block_zeros=zeros(sqrt(n),sqrt(n)*n^2);
    A_block=[temp_block block_zeros block_zeros;...
            block_zeros temp_block block_zeros;...
            block_zeros block_zeros temp_block];
end


% Constrain values between 1 and 0
% Ax<=1  Ax>=0
A_10=[eye(n^3); -eye(n^3)];
b_10=[ones(n^3,1);zeros(n^3,1)];

% Constrains such that output is not 0
for i=1:n^2
    A_unique(i,(i-1)*n+1:i*n)=ones(1,n);
end

% Constrains the outputs to be unique

% Rows
unique_row=zeros(n^2,n^3);
unique_ones=[];
for i=1:n
    unique_ones=[unique_ones eye(n)];
end

for i=1:n          
    unique_row((i-1)*n+1:i*n,(i-1)*n^2+1:(i-1)*n^2+n^2)=unique_ones;
end

%Columns
unique_col=[];
temp_ones=eye(n^2);
for i=1:n          
    unique_col=[unique_col temp_ones];
end


% Sets feedback matrices as null, defined later if needed
% Clears the matrices of any previous data if loops again
A_feedback=zeros(1,n^3);
b_feedback=zeros(1,1);

integer=0;

while integer==0


% Combine to make A_hat and b_hat

A_hat=[eye(n^3);...     % L1 norm
    -eye(n^3);
    A_rows;...          % pos sum
    A_col;...
    A_block;...         
    -A_rows;...         % neg sum
    -A_col;...
    -A_block;...       
    A_10;...            % 0-1 constraint
    A_unique;           % >0 constraint
    -A_unique;...       
    unique_row;         % unique rows 
    -unique_row;...          
    unique_col;         % unique columns
    -unique_col;
    A_clue;
    -A_clue;
    A_unique_col;
    -A_unique_col;
    A_unique_row;
    -A_unique_row;
    A_unique_block;
    -A_unique_block
    A_feedback;
    -A_feedback];            

% Appends the aux varialbes to A_hat
append=[-eye(n^3);-eye(n^3);zeros(height(A_hat)-2*n^3,n^3)];
A_hat=[A_hat append];

b_hat=[zeros(2*n^3,1);                  % L1 norm sol
    summation.*ones(3*n,1);...          % pos sum
    -summation.*ones(3*n,1);...         % neg sum
    b_10;...                            % 0-1 sol
    ones(n^2,1);-ones(n^2,1);...        % sum of variables=1
    ones(n^2,1);-ones(n^2,1);...        % unique row
    ones(n^2,1);-ones(n^2,1);
    b_clue;-b_clue;                     % clue 
    ones(n^2,1);-ones(n^2,1);           % unique col
    ones(n^2,1); -ones(n^2,1);
    ones(n^2,1);-ones(n^2,1);
    b_feedback;-b_feedback];         % unique row

c=[zeros(n^3,1) ones(n^3,1)];


values=linprog(c,A_hat,b_hat);

if isempty(values)==1
    values=test_values;

if input==5

    
    integer=1; % Sets to true until decimal value is found

    for i=1:n^3
        if floor(values(i))~=ceil(values(i)) % Checks to see if there are any decimal values in the output of linprog
            integer=0;
        end
    end
    test_values=values;
    for i=1:n^3
        if test_values(i,1)>=.6
            test_values(i,1)=0;
        end
    end
    choices=find(test_values);
    for i=1:height(test_values)
        if floor(test_values(i))~=ceil(test_values(i))
            test_index(1,i)=1;
        end
    end

    choices_index=ceil(choices/n);
    

    % Chooses random squares to make a guess for
    rand=randperm(height(choices_index)/2,4);
    rand=rand.*2;

    for i=1:length(rand)
        rand_square(i)=choices_index(rand(i));
    end
    
    A_feedback=zeros(length(rand_square),n^3);
    b_feedback=ones(length(rand_square),1);
    
    for i=1:length(rand_square)
        true_index=choices(rand(i))-randi([0 1],1,1);
        A_feedback(i,true_index)=1;
    end
%{
    A_feedback(1,10)=1;
    A_feedback(2,397)=1;
    A_feedback(3,433)=1;
    b_feedback=ones(3,1);
%}
end
    continue
end

values=values(1:n^3);                   % Omits the aux variables

% Sets the integer checker to true
integer=1;


% Changes the integer checker to false if it finds a decimal 
counter=1;

%% Finds the index of the first value with a decimal
if input==3
decimal=1;
decimal_index=1;
while decimal==1
    if floor(values(counter))~=ceil(values(counter))
        decimal_index=counter;
        decimal=0;
        integer=0;
    end
    if counter==729     % ends the loop once at the end of X
    integer=1;
    decimal=0;
    end
    decimal_index=ceil(decimal_index/n);
    counter=counter+1;
end

new_guess=0;

A_feedback(1,(n)*(decimal_index-1)+1+new_guess)=1;
b_feedback(1,1)=1;

new_guess=new_guess+1;

end

%%
if input==5

    
    integer=1; % Sets to true until decimal value is found
    counter=1;
    for i=1:n^3
        if floor(values(i))~=ceil(values(i)) % Checks to see if there are any decimal values in the output of linprog
            integer=0;
            counter=counter+1;
        end
    end
    if counter==729
        break
    end
    test_values=values;
    for i=1:n^3
        if test_values(i,1)>=.6
            test_values(i,1)=0;
        end
    end
    choices=find(test_values);
    for i=1:height(test_values)
        if floor(test_values(i))~=ceil(test_values(i))
            test_index(1,i)=1;
        end
    end

    choices_index=ceil(choices/n);
    if isempty(choices)==1
        continue
    end

    % Chooses random squares to make a guess for
    rand=randperm(height(choices_index)/2,4);
    rand=rand.*2;

    for i=1:length(rand)
        rand_square(i)=choices_index(rand(i));
    end
    
    A_feedback=zeros(length(rand_square),n^3);
    b_feedback=ones(length(rand_square),1);
    
    for i=1:length(rand_square)
        true_index=choices(rand(i))-randi([0 1],1,1);
        A_feedback(i,true_index)=1;
    end
    

    
%{
    A_feedback(1,10)=1;
    A_feedback(2,397)=1;
    A_feedback(3,433)=1;
    b_feedback=ones(3,1);
%}
end
%}

        
end


numbers_temp=x_tilde.*values';

% converts the vectors for each number into its value
for i=1:n^2
    numbers(i)=sum(numbers_temp((i-1)*n+1:i*n));
end

% Reshapes the vector into the nxn grid
numbers=reshape(numbers,n,n);
numbers=numbers'

values_temp=zeros(n^3,1);
for i=1:n^2
   [M,I]= max(values((i-1)*n+1:n*i));
   values_temp((i-1)*n+I)=1;
end

numbers_temp=x_tilde.*values_temp';
for i=1:n^2
    numbers(i)=sum(numbers_temp((i-1)*n+1:i*n));
end

% Reshapes the vector into the nxn grid
numbers=reshape(numbers,n,n);
numbers=numbers';



answer = questdlg('Would you like to play Sudoku in the Command Window?', ...
	'Sudoku GUI', ...
	'Yes','No','No');
% Handle response
switch answer
    case 'Yes'
        clc
        % disp("Generating Playing Grid");
        play_choice = 1;


display('Here is a game board');
    Sudoku=[3 0 0 8 0 1 0 0 2;
        2 0 1 0 3 0 6 0 4;
        0 0 0 2 0 4 0 0 0;
        8 0 9 0 0 0 1 0 6;
        0 6 0 0 0 0 0 5 0;
        7 0 2 0 0 0 4 0 9;
        0 0 0 5 0 9 0 0 0;
        9 0 4 0 8 0 7 0 5;
        6 0 0 1 0 7 0 0 3]


hint_cell={'1,2=4' '4,5=7' '9,5=1' '4,5=7' '3,9=1' '9,8=4' '7,5=4' '1,7=5' '6,2=1'};

    hint_on=1;
    counter=1;
    while hint_on==1

        answer = questdlg('Would you like a hint?', ...
	'Hint GUI', ...
	'Yes','No','No');
        switch answer
            case "Yes"
                disp(hint_cell{counter});
                counter=counter+1;

                if counter==9
                    disp("Ran out of hints, you're on your own now.")
                    hint_on=0;
                    break
                end
                case "No"
                hint_on=0;
                break
        end
       
    end


    case 'No'
        clc
        play_choice = 0;
        disp('Have a Great Day!');
end



