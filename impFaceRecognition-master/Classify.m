function [cClass, SCI] = Classify(y)
    global A;
    global Class;
	global TrainSize;
	RejectThreshold = 0;
    %global Test;
    
    lambda = 1000;
    %y = A*x;
    % initial guess = min energy    
    %y = zeros(size(sample,1));
    %for i =1:size(sample,1)
        %y(i,1) = sample(i,1);
    %end
    %B = A;
    %y = A'*y;
    %A = A'*A;    
    %x0 = A'*y;
    % solve the LP
    tic
    %xp = l1eq_pd(x0, A, [], y, 1e-3);
    %xp = LassoConstrained(A,y,lambda,'mode',2);
    %[xp wp iteration] = LassoBlockCoordinate(A,y,lambda);
    %[xp it] = LassoConstrained(A,y,100,'mode',2);
    %[xp it] = LassoNonNegativeSquared(A,y,lambda);
    %[xp it] = SolveLasso(A, y, size(A,2), 'lars');
    %[xp it] = SolveOMP(A, y, size(A,2));
    
    
    x0 = (A'*A )\(A'*y);
    %x0 = A'*y; bo
    xp = l1eq_pd(x0, A, [], y, 5e-2, lambda);
    toc
    
    vMax = 0;
    iMax = 0;
    Next = 0;
	MaxVector = 0;
    for i = 1: size(Class,2) % so lop
        val = 0;
        %for j = 1: Class(1,i) % so phan tu cua lop i
            %val = abs(val + xp(Next + j,1));
        %end
        %CVector = GetClassVector(Next+1,Next+ Class(1,i), xp);
		CVector = GetClassVector((i-1) * TrainSize + 1, i * TrainSize, xp);
        y0 = A * CVector;
        val = abs(1 /(pdist([y y0]')));
        if(vMax < val)
            vMax = val;
            iMax = i;			
        end
		if(sum(abs(MaxVector(:,1))) < sum(abs(CVector(:,1))))
			MaxVector = CVector;
		end
        %Next = Next+ Class(1,i);
    end
    
	%compute SCI
	SCI = (size(Class,2) * sum(abs(MaxVector(:,1))) / sum(abs(xp(:,1))) - 1) / (size(Class,2) - 1);
	if(SCI < RejectThreshold)
		cClass = -1;
	else
		cClass = iMax;
	end	
    %histmax(xp, size(A,2));
end

function [CVector] = GetClassVector(leftIndex, rightIndex, orgVector)
%     scale = 0;
%     first = 1;
%     max = 0;    
%     minVal = min(orgVector(:,1));
%     if(minVal == 0)
%         minVal = 1e-8;
%     end
%     for j = 1: size(orgVector,1)
%             if(j<leftIndex || j>rightIndex)
%                 if(first)
%                     first = 0;
%                     max = abs(orgVector(j,1));
%                 elseif(max < orgVector(j,1))
%                     max = abs(orgVector(j,1));
%                 end
%             end
%     end    
%     scale = max / minVal;
    CVector = zeros(size(orgVector,1), 1);
    CVector(leftIndex:rightIndex, 1) = orgVector(leftIndex:rightIndex, 1);
end