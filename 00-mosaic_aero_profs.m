metdir = ".\data\MOSAiC\MOSAiC_meteorology\datasets\*";
raddir = '.\data\MOSAiC\MOSAiC_BELUGA_terrestrial_radiation\datasets\Flight_';
vipsdir = '.\data\MOSAiC\MOSAiC_BELUGA_VIPS\datasets\Flight_';

files=dir(".\data\MOSAiC\MOSAiC_aerosol_particle_microphysics\datasets\*tab");

%files to actually use
files = files([2,3,5,7,13,14,15,16]);

%corresponding flights with useful ancillary data
flights=[1,4,8,10,22,24,28,30];

%Notes on when the "flights" occur relative to the aerosol data files
%Flight 1 (subset times), 4(just after), 8 (few hours before), 10
%(immediately_before), 24(immediately_before), 27 (immediately after or use 28 for VIPS), 30 (few
%hours before)

blh = [320,100,410,180,510,300,910,80]; %mixed layer tops, meters
zg=0:10:1200;
%% Set up the Import Options 
opts = delimitedTextImportOptions("NumVariables", 27);
opts.DataLines = [51, Inf];
opts.Delimiter = "\t";
diams=[151,166,182,200,219,249,296,391,530,774,1143,1455,1875,2480];
opts.VariableNames = ["DateTime", "z", "p", "Tc", "RH", "TTechC", "RHTech", ...
    "N8", "N12", "N150", "Var11", "Var12", "Var13", "Var14", "Var15", "Var16",...
    "Var17", "Var18", "Var19", "Var20", "Var21", "Var22", "Var23", "Var24", "Var25", "Var26", "Var27"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", ...
    "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", ...
    "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts = setvaropts(opts, ["Var11", "Var12", "Var13", "Var14", "Var15", "Var16",...
    "Var17", "Var18", "Var19", "Var20", "Var21", "Var22", "Var23", "Var24", "Var25", "Var26", "Var27"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "DateTime", "InputFormat", "yyyy-MM-dd'T'HH:mm:ss");
opts = setvaropts(opts, ["z", "p", "Tc", "RH", "TTechC", "RHTech", "N8", "N12", "N150"], "ThousandsSeparator", ",");

opts2 = delimitedTextImportOptions("NumVariables", 7);
opts2.DataLines = [34, Inf];
opts2.Delimiter = "\t";
opts2.VariableNames = ["DateTime", "p", "Tc", "RH", "u", "dir", "z"];
opts2.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double"];
opts2.ExtraColumnsRule = "ignore";
opts2.EmptyLineRule = "read";
opts2 = setvaropts(opts2, "DateTime", "InputFormat", "yyyy-MM-dd'T'HH:mm:ss");
opts2 = setvaropts(opts2, ["p", "Tc", "RH", "u", "dir", "z"], "ThousandsSeparator", ",");

opts3 = delimitedTextImportOptions("NumVariables", 9);
opts3.DataLines = [33, Inf];
opts3.Delimiter = "\t";
opts3.VariableNames = ["DateTime", "LWD", "LWU", "z", "P", "T", "TTTC", "RH", "FlagIcing"];
opts3.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double"];
opts3.ExtraColumnsRule = "ignore";
opts3.EmptyLineRule = "read";
opts3 = setvaropts(opts3, "DateTime", "InputFormat", "yyyy-MM-dd'T'HH:mm:ss.SSS");
opts3 = setvaropts(opts3, ["LWD", "LWU", "z", "P", "T", "TTTC", "RH", "FlagIcing"], "ThousandsSeparator", ",");

%available for flights 8 & 10 only
opts4 = delimitedTextImportOptions("NumVariables", 3);
opts4.DataLines = [28, Inf];
opts4.Delimiter = "\t";
opts4.VariableNames = ["DateTime", "z", "FlagWater"];
opts4.VariableTypes = ["datetime", "double", "double"];
opts4.ExtraColumnsRule = "ignore";
opts4.EmptyLineRule = "read";
opts4 = setvaropts(opts4, "DateTime", "InputFormat", "yyyy-MM-dd'T'HH:mm:ss.SSS");
opts4 = setvaropts(opts4, ["z", "FlagWater"], "ThousandsSeparator", ",");

%% Make the figure
blh = [320,100,410,180,510,300,910,80]; %mixed layer tops, meters

figure('position',[700 300 1140 600])
t=tiledlayout(2,3,'TileSpacing','tight');
a1=nexttile; hold on
a2=nexttile; hold on
a3=nexttile; hold on
a4=nexttile; hold on
a5=nexttile; hold on
a6=nexttile; hold on

colors=get(0,'defaultAxesColorOrder');
for i=1:length(files)
    zg=0:10:1200;
    
    file=fullfile(files(i).folder,files(i).name);
    file2=dir(strcat(metdir,files(i).name(1:13),'*'));
    file3=[raddir,num2str(flights(i)),'_terrestrial_radiation.tab'];
    
    if ~isempty(file2)
        tbdata = readtable(file, opts);
        met = readtable(fullfile(file2(1).folder,file2(1).name), opts2);
        met = met(met.DateTime>tbdata.DateTime(1) & met.DateTime<tbdata.DateTime(end),:);
        tbdata = tbdata(tbdata.DateTime>met.DateTime(1) & tbdata.DateTime<met.DateTime(end),:);
        dNdlogD=table2array(tbdata(:,11:24));
        
        tbdata.theta=(tbdata.Tc+273.15).*(1000./tbdata.p).^(287/1004);
        [~,~,bin]=histcounts(tbdata.z,zg);
        Navg12=accumarray(bin,tbdata.N12,[length(zg) 1],@nanmean,NaN);
        Navg150=accumarray(bin,tbdata.N150,[length(zg) 1],@nanmean,NaN);
        for ibin=1:size(dNdlogD,2)
            dNavg(:,ibin)=accumarray(bin,dNdlogD(:,ibin),[length(zg) 1],@nanmean,NaN);
        end
        
        met.theta=(met.Tc+273.15).*(1000./met.p).^(287/1004);
        ind=~isnan(met.z);
        [~,~,bin]=histcounts(met.z(ind),zg);
        THavg=accumarray(bin,met.theta(ind),[length(zg) 1],@nanmean,NaN);
        RHavg=accumarray(bin,met.RH(ind),[length(zg) 1],@nanmean,NaN);
        
        if all(isnan(THavg))
            %file format variant - RH is missing, z values are in dir
            ind=~isnan(met.dir);
            [~,~,bin]=histcounts(met.dir(ind),zg);
            THavg=accumarray(bin,met.theta(ind),[length(zg) 1],@nanmean,NaN);
        end
        
        if flights(i) == 10 || flights(i) == 28 %i=4
            file4=[vipsdir,num2str(flights(i)),'_VIPS.tab'];
            flag = readtable(file4,opts4);
            ind=~isnan(flag.z);
            [~,~,bin]=histcounts(flag.z(ind),zg);
            FLAGavg = accumarray(bin,flag.FlagWater(ind),[length(zg) 1],@nanmean,NaN);
            %flight 10 has occasional clouds
            %flight 28 has a layer of cloud all the time above a layer which is
            %sometimes cloudy. Looks like this sometimes cloudy layer might
            %just be particles falling out of the all the time cloudy layer.
            %Only plot the all-the-time layer. This makes the cloud layer
            %consistent with the radiation data.
            if flights(i)==10
                cbot = find(FLAGavg>0.5,1,'first');
                ctop = find(FLAGavg>0.5,1,'last');
            else
                cbot = find(FLAGavg>0.9,1,'first');
                ctop = find(FLAGavg>0.9,1,'last');
            end
        elseif flights(i) == 8 %i=3
            %radiation and VIPS are available, but ~9 hours before the aerosol
            %data. Will use RH to determine cloud top and base. The answer is
            %consistent with the radiation and VIPS data but with a higher
            %cloud top that looks consistent with the BL top
            %RHavg=accumarray(bin,met.RH,[length(zg) 1],@nanmean,NaN);
            cbot=find(RHavg==100,1,'first');
            ctop=find(RHavg==100,1,'last');
        elseif i==1 || i==7
            %use radiation
            %for i==1, if we subset to only include overlapping times with
            %aerosol data, then only a fog
            rad = readtable(file3, opts3);
            ind=~isnan(rad.z);
            [~,~,bin]=histcounts(rad.z(ind),zg);
            LWDavg = accumarray(bin,rad.LWD(ind),[length(zg) 1],@nanmean,NaN);
            LWUavg = accumarray(bin,rad.LWU(ind),[length(zg) 1],@nanmean,NaN);
            LWnetG = gradient(smooth(LWDavg - LWUavg,7));
            
            [~,cbot] = max(LWnetG);
            [~,ctop] = min(LWnetG(cbot:end));
            ctop = (cbot-1)+ctop+3; %+3 based on visual inspection
        elseif i==6
            %radiation profiles suggest multi-layer clouds - difficult to
            %determine objectively
            cbot = 4;
            ctop = 31;
            
            cbot2 = 62;
            ctop2 = 91;
            
        elseif i==8
            %radiation profiles suggest multi-layer clouds - difficult to
            %determine objectively
            cbot = 1;
            ctop = 7;
            
            cbot2 = 59;
            ctop2 = 96;
            
            cbot3 = 23;
            ctop3 = 26;
        elseif i==2 || i==5
            %use radiation, find cloud top first
            rad = readtable(file3, opts3);
            ind=~isnan(rad.z);
            [~,~,bin]=histcounts(rad.z(ind),zg);
            LWDavg = accumarray(bin,rad.LWD(ind),[length(zg) 1],@nanmean,NaN);
            LWUavg = accumarray(bin,rad.LWU(ind),[length(zg) 1],@nanmean,NaN);
            LWnetG = gradient(smooth(LWDavg - LWUavg,7));
            
            [~,ctop] = min(LWnetG);
            [~,cbot] = max(LWnetG(1:ctop));
            ctop = ctop+2; %+2 based on visual inspection
            
            if i==5
                cbot = 42;
            end
        end        
        
        axes(a1)
        set(gca,'ColorOrderIndex',i)
        color=get(gca,'ColorOrderIndex');
        
        zg = zg-blh(i);
        blh(i)=0;
        plot(THavg,zg,'DisplayName',replace(files(i).name(1:13),'_','-'))
        h=plot(THavg(cbot:ctop),zg(cbot:ctop),'k-','LineWidth',1);
        legendlabel(h,'off')
        if i==6 || i==8
            h=plot(THavg(cbot2:ctop2),zg(cbot2:ctop2),'k-','LineWidth',1);
            legendlabel(h,'off')
            if i==8
                h=plot(THavg(cbot3:ctop3),zg(cbot3:ctop3),'k-','LineWidth',1);
                legendlabel(h,'off')
            end
        end
        %h=plot(THavg(zg==blh(i)),blh(i),'ko','MarkerFaceColor',colors(color,:),'LineWidth',1);
        %legendlabel(h,'off')
        
        axes(a2)
        set(gca,'ColorOrderIndex',i)
        plot(Navg12,zg)
        plot(Navg12(cbot:ctop),zg(cbot:ctop),'k-','LineWidth',1);
        if i==6 || i==8
            plot(Navg12(cbot2:ctop2),zg(cbot2:ctop2),'k-','LineWidth',1);
            if i==8; plot(Navg12(cbot3:ctop3),zg(cbot3:ctop3),'k-','LineWidth',1);end
        end
        %plot(Navg12(zg==blh(i)),blh(i),'ko','MarkerFaceColor',colors(color,:),'LineWidth',1);
                
        if i~=6 %missing data for this one
            axes(a3)
            set(gca,'ColorOrderIndex',i)
            plot(Navg150,zg)
            plot(Navg150(cbot:ctop),zg(cbot:ctop),'k-','LineWidth',1);
            %plot(Navg150(zg==blh(i)),blh(i),'ko','MarkerFaceColor',colors(color,:),'LineWidth',1);
            if i==8
                plot(Navg150(cbot2:ctop2),zg(cbot2:ctop2),'k-','LineWidth',1);
                plot(Navg150(cbot3:ctop3),zg(cbot3:ctop3),'k-','LineWidth',1)
            end            
            
            axes(a4)            
            set(gca,'ColorOrderIndex',i)            
            ind=find(zg==blh(i));
            avgAbove=mean(dNavg(ind+1:ind+10,:)./Navg150(ind+1:ind+10,:));
            avgBelow=mean(dNavg(max(ind-9,1):ind,:)./Navg150(max(ind-9,1):ind,:));
            plot(diams,avgAbove,'DisplayName',replace(files(i).name(1:13),'_','-'))
            
            axes(a5)
            set(gca,'ColorOrderIndex',i)   
            plot(diams,avgAbove-avgBelow)
            
            axes(a6)
            set(gca,'ColorOrderIndex',i)
            rat=Navg150./Navg12;
            plot(rat,zg)
            plot(rat(cbot:ctop),zg(cbot:ctop),'k-','LineWidth',1);
            %plot(rat(zg==blh(i)),blh(i),'ko','MarkerFaceColor',colors(color,:),'LineWidth',1);
            if i==8
                plot(rat(cbot2:ctop2),zg(cbot2:ctop2),'k-','LineWidth',1)
                plot(rat(cbot3:ctop3),zg(cbot3:ctop3),'k-','LineWidth',1)
            end             
        end
    end
end

axes(a1)
xlabel('Potential Temperature (K)')
grid on
plotlabel('(a)')

axes(a2)
xlabel('N12 Conc. (# cm^{-3})')
grid on
plotlabel('(b)','upperright')
set(a2,'XMinorTick','on','xlim',[0 1500])
ylabel([a1,a2,a3,a6],'Height w.r.t. BL Top (m)','FontSize',15.4);

axes(a3)
xlabel('N150 Conc. (# cm^{-3})')
grid on
plotlabel('(c)','upperright')
set(a3,'XMinorTick','on','xlim',[0 100])

%ylim([a1,a2,a3],[0 1000])
ylim([a1,a2,a3,a6],[-400 200])

axes(a4)
set(gca,'xscale','log')
grid on
plotlabel('(d)')
xlabel('Diameter (nm)')
ylabel('Normalized dN/dlogD_p')
lgd=legend(a1);
lgd.Layout.Tile='east';

axes(a5)
set(gca,'xscale','log')
grid on
plotlabel('(e)','upperright')
xlabel('Diameter (nm)')
ylabel('\Delta Normalized dN/dlogD_p')

axes(a6)
grid on
plotlabel('(f)','upperright')
xlabel('N150/N12')

xlim([a4,a5],[150 800])
