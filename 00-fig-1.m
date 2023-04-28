files=dir("./mosaic_data/*tab");
files=files([2,3,5,7,14,16]);
blh=[320,100,410,180,290,90];
zg=0:10:1200;
%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 27);

% Specify range and delimiter
opts.DataLines = [51, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["DateTime", "z", "p", "Tc", "RH", "TTechC", "RHTech", "N8", "N12", "N150", "Var11", "Var12", "Var13", "Var14", "Var15", "Var16", "Var17", "Var18", "Var19", "Var20", "Var21", "Var22", "Var23", "Var24", "Var25", "Var26", "Var27"];
opts.SelectedVariableNames = ["DateTime", "z", "p", "Tc", "RH", "TTechC", "RHTech", "N8", "N12", "N150"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Var11", "Var12", "Var13", "Var14", "Var15", "Var16", "Var17", "Var18", "Var19", "Var20", "Var21", "Var22", "Var23", "Var24", "Var25", "Var26", "Var27"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var11", "Var12", "Var13", "Var14", "Var15", "Var16", "Var17", "Var18", "Var19", "Var20", "Var21", "Var22", "Var23", "Var24", "Var25", "Var26", "Var27"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "DateTime", "InputFormat", "yyyy-MM-dd'T'HH:mm:ss");
opts = setvaropts(opts, ["z", "p", "Tc", "RH", "TTechC", "RHTech", "N8", "N12", "N150"], "ThousandsSeparator", ",");

opts2 = delimitedTextImportOptions("NumVariables", 7);

% Specify range and delimiter
opts2.DataLines = [34, Inf];
opts2.Delimiter = "\t";

% Specify column names and types
opts2.VariableNames = ["DateTime", "p", "Tc", "RH", "u", "dir", "z"];
opts2.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts2.ExtraColumnsRule = "ignore";
opts2.EmptyLineRule = "read";

% Specify variable properties
opts2 = setvaropts(opts2, "DateTime", "InputFormat", "yyyy-MM-dd'T'HH:mm:ss");
opts2 = setvaropts(opts2, ["p", "Tc", "RH", "u", "dir", "z"], "ThousandsSeparator", ",");

figure
t=tiledlayout(1,2,'TileSpacing','tight');
a1=nexttile;
hold on

a2=nexttile;
hold on
for i=1:length(files)
    file=[files(i).folder,'\',files(i).name];
    % Import the data
    tbdata = readtable(file, opts);

    file2=dir(strcat("C:\Users\aigel\Desktop\MOSAiC_meteorology\datasets\*",files(i).name(1:13),'*'));

    met = readtable([file2(1).folder,'\',file2(1).name], opts2);
    met = met(met.DateTime>tbdata.DateTime(1) & met.DateTime<tbdata.DateTime(end),:);
    met.theta=(met.Tc+273.15).*(1000./met.p).^(287/1004);


    tbdata.theta=(tbdata.Tc+273.15).*(1000./tbdata.p).^(287/1004);
    [~,~,bin]=histcounts(tbdata.z,zg);
    Tavg=accumarray(bin,tbdata.Tc,[length(zg) 1],@nanmean,NaN);
    Navg=accumarray(bin,tbdata.N12,[length(zg) 1],@nanmean,NaN);

    if any(~isnan(met.z))
        [~,~,bin]=histcounts(met.z,zg);
        Tavg2=accumarray(bin,met.theta,[length(zg) 1],@nanmean,NaN);
        RHavg2=accumarray(bin,met.RH,[length(zg) 1],@nanmean,NaN);

        axes(a1)
        set(gca,'ColorOrderIndex',i)
        plot(Tavg2,zg)
        h=plot(Tavg2(zg==blh(i)),blh(i),'ko','MarkerFaceColor','k');

        axes(a2)
        set(gca,'ColorOrderIndex',i)
        plot(Navg,zg,'DisplayName',replace(files(i).name(1:13),'_','-'))
        h=plot(Navg(zg==blh(i)),blh(i),'ko','MarkerFaceColor','k');
        legendlabel(h,'off')
    end
end
axes(a1)
xlabel('Potential Temperature (K)')
grid on
plotlabel('(a)')
axes(a2)
xlabel('N12 Concentration (# cm^{-3})')
grid on
plotlabel('(b)','upperright')
set(a2,'XMinorTick','on')
ylabel(t,'Height (m)','FontSize',15.4);
ylim([a1,a2],[0 500])
xlim(a1,[269 280])
lgd=legend(a2,'Location','southeast');
uistack(lgd,'top')
