function MakeTest(TestMode, Partial)
if nargin < 2,
	%OptTol = 1e-5;
    Partial = 'RightEye';
end
    ws = warning('off','all'); % turn all warnings off
    if true,
        disp('The warning was turned off!')
        warning('Here is a warning that doesn''t have an id.')
    end
    
    ConfigPath;
    global A;
    global Class;
    global Test;
    global TrainSize;
    global Results;
    global TestImageSize;
    global FirstRidgeRegression;
    global ImagePath
    ImagePath = '.\Images\EYB\'
    
    FirstRidgeRegression = 1;
    %TestImageSize = [96 84];%[27 20];%[83 60];%[41 30];
    
   %--- AR
    TestImageSize = [27 20] %[13 10] %[9 6] %[6 5]      
    
    if(strcmp(TestMode,'Corruption')==1 | strcmp(TestMode,'Occlusion')==1)
       TrainSize = 18;
       [A Class Test] = ReadMatrix(TrainSize, 'Corruption');              
       %DoTest('Corruption');
       DoTest('Occlusion');
    elseif(strcmp(TestMode,'Partial')==1)
       TrainSize = 32;
       [A Class Test] = ReadMatrix(TrainSize, 'Partial', Partial);
       DoTest('Partial');
    elseif(strcmp(TestMode,'Disguise')==1)
       TrainSize = 8;
       [A Class Test] = ReadMatrixAR(TrainSize, 'Disguise');
       DoTestDisguise(0);
    elseif(strcmp(TestMode,'DisguisePart')==1)       
       TrainSize = 8;
       [A Class Test] = ReadMatrixPartition(TrainSize, 'Disguise');
       %DoTestDisguise(1);
    elseif(strcmp(TestMode,'CorruptionPart')==1)       
       TrainSize = 18;
       [A Class Test] = ReadMatrixPartition(TrainSize, 'EYBCorrupt');
       %DoTest('Occlusion', 1);
    elseif(strcmp(TestMode,'NormalAR')==1)       
       TrainSize = 7;
       %[A Class Test] = ReadMatrix(TrainSize, 'Normal');               
       [A Class Test] = ReadMatrixAR(TrainSize, 'Normal');               
       %KSVDTrainDict(TrainSize, 16);
       %RandomTrainDict(TrainSize, 16);
       %TrainSize = 16;
       %DoTest('Normal');
    else
       TrainSize = 32;
       %[A Class Test] = ReadMatrix(TrainSize, 'Normal');               
       [A Class Test] = ReadMatrix(TrainSize, 'Normal');               
       %KSVDTrainDict(TrainSize, 16);
       %RandomTrainDict(TrainSize, 16);
       %TrainSize = 16;
       %DoTest('Normal');
    end    
    warning(ws)  % restore the warning state    
end

function DoTest(TestMode, Partition)
if nargin < 2
    Partition = 0;
end
    global A;
    global Class;
    global Test;
    global TrainSize;
    global Results;
    global TestImageSize;
    global FirstRidgeRegression;
    
    if(strcmp(TestMode,'Corruption') == 1)       
       Percent = 0.5:0.1:0.5; 
    elseif(strcmp(TestMode,'Occlusion') == 1)        
       Percent = 0.4:0.1:0.4; 
    else
        Percent = 1;
    end
    SaveName = 'MyTest';
    
    for p=1:size(Percent,2)
        disp( sprintf('%s_%s_%d_Percent.mat', SaveName, TestMode, Percent(p)*100));
        Acc = 0;
        Next = 0;
        %for i = 1:size(Test,2);    
        MinThreshold = 1;
        Results = zeros(size(Test,2), 2);
        for i = 1:size(Class,2)   
            for j  = 1:Class(1,i)
               x = Test(:, Next+j);
               %RightClass = fix((i-1)/TestSize)+1;    
               RightClass = i;
               if(strcmp(TestMode,'Normal')==1 | strcmp(TestMode,'Partial')==1)
                   [ClassX SCI] = Classify(x);       
               elseif(strcmp(TestMode,'Occlusion')==1)                   
                   if(~Partition)
                       [ClassX SCI] = ClassifyOcclusion(RandomOcclusion(x, Percent(p)));
                   else
                       [ClassX SCI] = ClassifyOcclusionPart(RandomOcclusion(x, Percent(p)));
                   end
               elseif(strcmp(TestMode,'Corruption')==1)
                   [ClassX SCI] = ClassifyOcclusion(RandomCorrupt(x, Percent(p)));
               end       
               Results(Next+j, 1) = ClassX==RightClass;
               Results(Next+j, 2) = SCI;
               if(ClassX == RightClass)
                   Acc = Acc+1;
               else
                   if(MinThreshold > SCI)
                       MinThreshold = SCI;
                   end
               end
               Result = sprintf('Image %d    RightClass:    %d Classified:    %d	Acc: %d', Next + j, RightClass, ClassX, Acc);
               disp(Result) 
            end	
            Next = Next+ Class(1,i);
        end
        Acc = Acc/size(Test,2);
        disp(sprintf('Accuracy: %f      MinSCI: %f', Acc, MinThreshold));        
        save(sprintf('%s_%s_%d_Percent.mat', SaveName, TestMode, Percent(p)*100), 'Results');
    end
end

function DoTestDisguise(Partition)
    global A;
    global Class;
    global Test;
    global TrainSize;
    global Results;
    global TestImageSize;
    global FirstRidgeRegression;
        
    SaveName = 'MyTest_DisguiseAR';
        
    %disp( sprintf('%s_%s_%d_Percent.mat', SaveName, TestMode, Percent(p)*100));
    Acc1 = 0;
    Acc2 = 0;
    Next = 0;
    %for i = 1:size(Test,2);    
    MinThreshold = 1;
    Results = zeros(size(Test,2), 2);
    
    for i = 1:size(Class,2)   
        for j  = 1:Class(1,i)
           %x = Test(:, Next+j);
           %RightClass = fix((i-1)/TestSize)+1;    
           RightClass = i;
           if(~Partition)            
            [ClassX SCI] = ClassifyOcclusion(Test(:, Next+j));
           else
            [ClassX SCI] = ClassifyOcclusionPart(Test(:, Next+j));
           end
           Results(Next+j, 1) = ClassX==RightClass;
           Results(Next+j, 2) = SCI;
           if(ClassX == RightClass)
               if(j<3)
                   Acc1 = Acc1+1;
               else
                   Acc2 = Acc2+1;
               end
           else
               if(MinThreshold > SCI)
                   MinThreshold = SCI;
               end
           end
           Result = sprintf('Image %d    RightClass:    %d Classified:    %d	Acc1: %d	Acc2: %d', Next + j, RightClass, ClassX, Acc1, Acc2);
           disp(Result) 
        end	
        Next = Next+ Class(1,i);
    end
    Acc1 = Acc1/(size(Test,2) / 2);
    Acc2 = Acc2/(size(Test,2) / 2);
    disp(sprintf('Accuracy 1: %f     Accuracy 2: %f      MinSCI: %f', Acc1, Acc2, MinThreshold));        
    save(sprintf('%s', SaveName), 'Results');    
end

function RandomTrainDict(TrainSize, RepresentingAtomNumber)
    global A;
    global Class;
    Temp = 0;
    for i=1:size(Class,2)
        Temp = A(:, (i-1)*TrainSize+1:i*TrainSize);
        RandomList = randperm(TrainSize);
        for j=1:RepresentingAtomNumber
           A(:,(i-1)*RepresentingAtomNumber+j) = Temp(:,RandomList(j));
        end        
    end
    A = A(:,1: size(Class,2) * RepresentingAtomNumber);
end

function KSVDTrainDict(TrainSize, RepresentingAtomNumber)
    global A;
    global Class;
    
    param.K = RepresentingAtomNumber*size(Class,2); % number of dictionary elements
    param.L = RepresentingAtomNumber;
    param.numIteration = 50; % number of iteration to execute the K-SVD algorithm.

    param.errorFlag = 0; % decompose signals until a certain error is reached. do not use fix number of coefficients.
    %param.errorGoal = sigma;
    param.preserveDCAtom = 0;

    %%%%%%%% initial dictionary: Dictionary elements %%%%%%%%
    param.InitializationMethod =  'DataElements';

    param.displayProgress = 1;
    disp('Starting to  train the dictionary');

    [A DictOutput]  = KSVD(A,param);
end