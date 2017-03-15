function [ A Class Test] = ReadMatrixPartition(TrainSize, ReadMode, Partial)
    %ReadMode = 'Corruption';    
if nargin < 3,
	%OptTol = 1e-5;
    Partial = 'RightEye';
end            
    global TestImageSize;
    if(strcmp(ReadMode,'Disguise') == 1 )
        [A Class Test] = ReadDisguisePartition(TrainSize);
        return;    
    elseif(strcmp(ReadMode,'EYBCorrupt') == 1 )
        [A Class Test] = ReadCorruption(TrainSize);
        return;
    end
end
	
function [ A Class Test] = ReadDisguisePartition(TrainSize)   
    global TestImageSize;
    ImagePath = '.\Images\AR\';        
    FileListFileName = 'file.lst';
    ReducingMode = 'DownSample';
    A = PartitionDict;
    Class = 0;
    Test = 0;
    
    OriDimension = 19800;
    RandomProject = 0;
    nTotalSubset = 100;
    %nScale = 4;
    if (ReducingMode == 'RandomFace')        
        RD = TestImageSize(1) * TestImageSize(2);%2016;%8064
        RandomProject = zeros(RD, OriDimension); %d X m m = 32256;
        for i = 1:RD
            RandomProject(i,:) = normrnd(0,1, 1, OriDimension);
            RandomProject(i,:) = RandomProject(i,:)./norm(RandomProject(i,:));
            %RandomProject(i,:) = (RandomProject(i,:)-min(RandomProject(i,:)))./(max(RandomProject(i,:))-min(RandomProject(i,:))) ;
        end
    elseif (ReducingMode == 'DownSample')        
        
    end        
    
    Class  = zeros(1, nTotalSubset);	
    for i = 1:nTotalSubset        
        disp(sprintf('Reading subset %d', i)); 
        FileList = ReadSubsets (i, 'Disguise');
        if(~iscell(FileList) | FileList{1}==0)
            A = 0;
            return;
        end        
		Class(1, i) = size(FileList,2)  - TrainSize;
		%RandomList = randperm(size(FileList,2));
        for j = 1:size(FileList,2)
            File = FileList{j};
            %disp(File);
			%File = strcat(File, FileList{j});
            [tmp0, map] = imread(File);
            tmp0 = rgb2gray(tmp0);
            %[coefs, sizes] = MyDWT(tmp1);
            %tmp1 = VisualizeDWT(coefs, sizes, sizes(size(sizes, 1),:));                
			            
			%tmp1 = imresize(tmp1, fix(size(tmp1)/nScale));                                
			tmp0 = imresize(tmp0, TestImageSize);
			tmp1(:,:) = cast(tmp0(:,:), 'double');
			tmp1(:,:) = tmp1(:,:)./255;						
                        
            %if(j<=size(FileList,2) - TestSize)
			if(j<=TrainSize)
				%partition
				A = A.AddElement(tmp1);                                
            else
                if Test == 0
                    Test = tmp1(:);
                else Test(:, end+1) = tmp1(:);
                end            
            end
            clear tmp;
        end        
    end    
end

function [ A Class Test] = ReadCorruption(TrainSize)   
    global TestImageSize;
    global ImagePath;
    %ImagePath = '.\Images\EYB\';    
    TrainFileName = 'Subset12.txt';
	TestFileName = 'Subset3.txt';    
    ReducingMode = 'DownSample';
    A = PartitionDict;
    Class = 0;
    Test = 0;        

    DirListFileName = 'dir.lst';
    DirList = ReadList(DirListFileName);
    if(~iscell(DirList) | DirList{1}==0)
        A = 0;
        return;
    end
    
    OriDimension = 32256;
    RandomProject = 0;
    %nScale = 4;    
    
    Class  = zeros(1, size(DirList,2));	
    for i = 1:size(DirList,2)        
        Dir = strcat(ImagePath, DirList{i});
        disp(Dir);                
        FileList1 = ReadList(sprintf('%s\\%s', Dir,TrainFileName));
        if(~iscell(FileList1) | FileList1{1}==0)
            A = 0;
            return;
        end
		FileList2 = ReadList(sprintf('%s\\%s', Dir,TestFileName));
		if(~iscell(FileList2) | FileList2{1}==0)
            A = 0;
            return;
        end
		
        %Class(1, i) = size(FileList,2)  - TestSize;
		Class(1, i) = size(FileList2,2);
		%RandomList = randperm(size(FileList,2));
		for k = 1:2
			if(k==1)
				FileList = FileList1;
			else FileList = FileList2; 
			end
			
			for j = 1:size(FileList,2)
                if(k==1 & j>TrainSize)
                    continue;
                end
				File = strcat( Dir, '\');
				%File = strcat(File, FileList{RandomList(j)});
				%disp(File);
				File = strcat(File, FileList{j});
				%tmp1 = imread(File);
                tmp0 = imread(File);
                tmp0 = imresize(tmp0, TestImageSize);
                tmp1(:,:) = cast(tmp0(:,:), 'double');
                tmp1(:,:) = tmp1(:,:)./255;	
				
				if(k==1)
					A = A.AddElement(tmp1);
				else
                    if Test == 0
                        Test = tmp1(:);
                    else Test(:, end+1) = tmp1(:);
                    end
				end
				clear tmp;
			end        
		end
    end    
end

function [List] =  ReadSubsets (nSubset, Feature)
    if(nSubset<10)
        FileName = sprintf('Subset00%d.lst', nSubset);
    elseif(nSubset<100)
        FileName = sprintf('Subset0%d.lst', nSubset);
    else
        FileName = sprintf('Subset%d.lst', nSubset);
    end
    FileList = ReadList(FileName);
    if(~iscell(FileList) | FileList{1}==0)
        List = 0;
        return;
    end
    %Class(1, i) = size(FileList,2)  - TrainSize;
    %RandomList = randperm(size(FileList,2));
    List = '';
    if(strcmp(Feature,'Normal') == 1)
        for j = 1:size(FileList,2)        
            if(j < 8 | (j>13 & j<21))
                List{end+1} = FileList{j};
            end       
        end        
    end
    if(strcmp(Feature,'Disguise') == 1)
        for j = 1:size(FileList,2)        
            if(j < 5 | (j>13 & j<18))
                List{end+1} = FileList{j};
            end       
        end        
        %sun glass
        List{end+1} = FileList{8};
        List{end+1} = FileList{21};
        %scarf
        List{end+1} = FileList{11};
        List{end+1} = FileList{24};
    end
end

