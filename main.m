clear all
clc
close all


%% tift loading utilities
addpath ./tiff_loading/utilities
addpath(genpath('./tiff_loading/Fiji.app'));
javaaddpath('./tiff_loading/Fiji.app/mij.jar');

%% loading tiff stacks
folders=dir('/Users/erdem/Downloads/JY180_in_vivo/jy*');

for f=1:length(folders)
    files=dir([folders(f).folder '/' folders(f).name '/*.tif']);
    for i=1:length(files)
%         I{f}{i}=load_tiff([files(i).folder '/' files(i).name]); %enable if using fiji
        I{f}{i}=imread([files(i).folder '/' files(i).name]); %faster for single stack
        tmp=strsplit(files(i).name,'.');
        tmp=strsplit(tmp{1},'_');
        zslice{f}(i)=str2num(tmp{end});
%         MIJ.run('Close All'); %enable if using fiji
        [f i]
    end
end

%% generating volumes from series of 2D images
for j=1:length(I)
    V{j}=zeros(size(I{j}{1},1),size(I{j}{1},2),length(I{j}));
    for i=1:length(I{j})
        V{j}(:,:,i)=I{j}{i};
        [j i]
    end
    [~,idx]=sort(zslice{j});
    V{j}=V{j}(:,:,idx);
end

%% decentralized displacement estimation
for i=1:length(V)
    for j=1:length(V)
        if i>j
            [tmp,C(i,j)]=displacementEstimator(V{i},V{j});
            C(j,i)=C(i,j);
            DX(i,j)=tmp(1);DX(j,i)=-DX(i,j);
            DY(i,j)=tmp(2);DY(j,i)=-DY(i,j);
            DZ(i,j)=tmp(3);DZ(j,i)=-DZ(i,j);
        end
    end
end
%% filter D if necessary

DX(C<0.7)=nan;
DY(C<0.7)=nan;
DZ(C<0.7)=nan;

%% solve p: the relative shifts
px=psolver(DX);
py=psolver(DY);
pz=psolver(DZ);

%% learning global shifts

padX=max(abs(px));
padY=max(abs(py));
padZ=max(abs(pz));

for i=1:length(V)
    i
    paddedV{i}=padarray(V{i},ceil([padX padY padZ]),0,'both');
end
for i=1:length(V)
    i
    translatedV{i} = imtranslate(paddedV{i}, -[px(i) py(i) pz(i)], 'FillValues', 0, 'OutputView', 'same');
end

for i=1:length(translatedV)
translatedVnan{i}=double(translatedV{i});
translatedVnan{i}(translatedVnan{i}==0)=nan;
end


%% stitching

s=zeros(size(translatedVnan{1}));
c=zeros(size(translatedVnan{1}));
for i=1:length(translatedVnan)
s=nanplus(s,translatedVnan{i});
c=c+~isnan(translatedVnan{i});
i
end


%% final stitched volume

v = s./c;

imagesc(threepanelfig(s./c));axis equal;axis tight
set(gca,'FontSize',14,'FontWeight','bold');
set(gcf,'color','w');



