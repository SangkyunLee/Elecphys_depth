function [mSTA,mSTC,eSTA,tSTA,mSpk] = doSTA(data_spk,data_img,st,bin,plt,w,T,D,err)
%a more generic STA computation algorithm based on 'sta' script in chronux
%library. --- WW2010
%'sta' only handles one-variable-represented stimulus data,e.g.,luminance intensity
%doSTA(sta1/sta2) will expand the sta capacity to handle mulit-variable-represented
%stimulus by representing stimulus as a array of 2D images.  
%data_spk : data array (trials x samples) or struct array with field 'data'.
%           data_spk(trials).data = samples;
%data_img:  2d array (trials x samples) or 4d matrix (x,y,nsamples,trials) 

mSTA = []; mSTC=[]; tSTA = []; eSTA = []; mSpk =0; 
if isempty(data_spk); return; end;

if nargin < 3;error('Require spike, stimulus data and stimulus times');end
optional = {'bin','plt','w','T','D','err'};
nopt = length(optional);
for i = 1 : nopt
    if ~exist(optional{i},'var')
        eval([sprintf('%s=[];',optional{i})]); 
    end
end

%check if chronux is in the path
libPath = which('chronux');
if isempty(libPath)
    %fprintf('chronux not found in path \n');
    %useChx = false;
    w = []; %reset w if no chronux found.
else
    %useChx = true;
end

%check the stimulus data format
%data_img(trials,samples) for 1d sta compuation. 
%or data_img(x,y,samples,trials) for 2d sta computation.
dim = ndims(data_img);
siz = size(data_img);
nsmp = 10 ; % pops a warning msg if number of samples less than this.
switch dim
    case 2
        if siz(1) > siz(2)
            fprintf('Warning: More trials than samples in the data\n');
        end
        if siz(2) < nsmp
            fprintf('Warning: Sparse data in stimulus,samples=%d\n', siz(2));
        end
        [mSTA,mSTC,eSTA,tSTA,mSpk] = sta1(data_spk,data_img,st,bin,plt,w,T,D,err);
    case 3 %only 1 trial. 4d matrix reduces to 3d matrix.
        if siz(3) < nsmp
            fprintf('Warning: Sparse data in stimulus,samples=%d\n',siz(2));
        end
        [mSTA,mSTC,eSTA,tSTA,mSpk] = sta2(data_spk,data_img,st,bin,plt,w,T,D,err);
    case 4
        if siz(4) > siz(3)
            fprintf('Warning: More trials than samples in the data\n');
        end
        if siz(2) < nsmp
            fprintf('Warning: Sparse data in stimulus,samples=%d\n', siz(2));
        end
        [mSTA,mSTC,eSTA,tSTA,mSpk] = sta2(data_spk,data_img,st,bin,plt,w,T,D,err);
    otherwise
        fprintf('stimulus data format not accepted. quit.\n');
        %mSTA = []; tSTA = []; eSTA = [];
end

if nnz(mSTA)==0; mSTA =[]; end
if nnz(mSTC)==0; mSTC =[]; end
if nnz(eSTA)==0; eSTA =[]; end
%keyboard;


