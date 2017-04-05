function r = readmywords(fn)
%shaffle the words 
%
fd = fopen(fn,'r');

w = textscan(fd,'%s');

fn1 = [fileparts(fn),'_o.txt'];

%shaffle the words

n = length(w{:});

r = cell(1,n);

for i = 1 : n
    word = w{1}{i};
    wl = length(word);
    if wl > 2
        rl = wl - 2;
        cidx = randperm(rl);
        cidx = cidx + 1;
        cidx = [1 cidx wl];
    else
        cidx = 1 : wl;
    end
    
    r{i} = word(cidx);
end

for i = 1 : n
    fprintf('%s \n', r{i});
end
    
        
       
    


