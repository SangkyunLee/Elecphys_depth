%temp plot sta data.

%number of channels
n = length(neurons);

%preset 24ch view.
pc = 6;
%pr = 4;
pr = ceil(n/pc);
pn = pr*pc;

colors1 = {'bs-','rs-','ms-','gs-','ks-'};
colors2 = {'b','r','m','g','k'};
titles={'low Contrast', 'high Contrast'};

for c = 1 : 2
    figure('name',titles{c});
    for i = 1 : n
        subplot(pr,pc,i);
        hold on;
        num_u = length(neurons{i}.singleunit);
        if isempty(num_u); continue; end
        for j = 1 : num_u
            plot(xSTA,neurons{i}.singleunit{j}.contrast{c}.sta,colors1{j},...
                'MarkerEdgeColor','k','MarkerFaceColor',colors2{j},'MarkerSize',3);
            title(sprintf('Ch:%s',neurons{i}.name));
        end
    end
end

    