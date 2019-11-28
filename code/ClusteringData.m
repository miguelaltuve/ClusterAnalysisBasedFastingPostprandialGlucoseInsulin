function Cluster = ClusteringData(dataoriginal,X,AttrName)
%CLUSTERINGDATA Perform the cluster of the data using the k-means
%clustering algorithm
%
%   Inputs:
%      dataoriginal: Table containing the data: age, G0, G120, I0 and I120
%      X: Array containing the data to be clustered
%      AttrName: Character array representing the name of the attributes
%      used in the clustering
%
%   Output:
%      Cluster: Struct containing the results of the clustering
%
%   Author: Miguel Altuve
%   Email: miguelaltuve@gmail.com
%   Date: November 2019
%
%   MIT License
%   Copyright (c) 2019 Miguel Altuve


% Variables initialization

% Number of clusters
k = 3;
% Squared Euclidean distance. Each centroid is the mean of the points in
% that cluster.
DISTANCE = 'sqeuclidean';

% k-means clustering using the the information contained in X
cidx = kmeans(X,k,'dist',DISTANCE,'Replicates',10,'display','final');

% This switch case is performed to replicate the results of the paper.
% The first cluster contained the majority of the subjects whereas the
% third cluster contained fewer subjects
switch AttrName
    case 'G0'
        TEMP1 = cidx==1;
        TEMP2 = cidx==2;
        cidx(TEMP1) = 2;
        cidx(TEMP2) = 1;
    case 'G0&G120&I0&I120'
        TEMP1 = cidx==1;
        TEMP2 = cidx==2;
        TEMP3 = cidx==3;
        cidx(TEMP1) = 3;
        cidx(TEMP2) = 1;
        cidx(TEMP3) = 2;
end

% Adding a column to the table with the cluster indices of each observation.
dataoriginal.cidx = cidx;


for i = 1:k
    
    % Creating a new field to the cluster structure array with the subjects of each cluster
    Cluster.subjects{i,1} = table2array(dataoriginal(dataoriginal.cidx==i,1:5));
    
    % Number of subjects per cluster
    fprintf('Number of subjects in cluster %d: %d\n', i, length(Cluster.subjects{i,1}));
    
    % Mean and standard deviation of the variables (Age, G0, G120, I0, I120 ) in each cluster
    Cluster.MeanVariab(i,:) = mean(Cluster.subjects{i,1});
    Cluster.StdVariab(i,:) = std(Cluster.subjects{i,1});
    disp(['Mean of attributes in cluster ' num2str(i)]);
    disp(Cluster.MeanVariab(i,:));
    disp(['STD of attributes in cluster ' num2str(i)]);
    disp(Cluster.StdVariab(i,:));
    
    % The Pearson correlation coefficient was used to assess the linear
    % dependence between the glucose and insulin levels per cluster.
    [Cluster.corr.rho{i,1},Cluster.corr.pval{i,1}] = corrcoef( Cluster.subjects{i,1}(:,2:5));
    
end

% Hypothesis tests of the clustered data between clusters per variable
groups = [1*ones(length(Cluster.subjects{1,1}(:,1)),1) ; 2*ones(length(Cluster.subjects{2,1}(:,1)),1); 3*ones(length(Cluster.subjects{3,1}(:,1)),1)];
groups = categorical(groups);

% For each variable
for i =1:5
    
    x1 = Cluster.subjects{1,1}(:,i);
    x2 = Cluster.subjects{2,1}(:,i);
    x3 = Cluster.subjects{3,1}(:,i);
    x = [x1;x2;x3];
    
    disp('Kruskal-Wallis nonparametric statistical test, followed by Tukey honestly significant difference');
    disp('Multiple comparison: Significant differences p<0.05');
    [~,~,stats] = kruskalwallis(x,groups);
    c = multcompare(stats); % Multiple comparison test
    disp(c);
    
    %%%Boxplots of the variable for the three clusters
    g = [ones(size(x1)); 2*ones(size(x2)); 3*ones(size(x3))];
    figure;
    boxplot(x,g);
    xlabel('Cluster');
    grid on;
    
    switch i
        case 1
            ylabel('Age');
            ylim([10 80]);
            % saving the figure in the results folder
            saveas(gcf, ['../results/BoxplotAge_Attr' AttrName '.png']);
        case 2
            ylabel('G0');
            ylim([50 420]);
            % saving the figure in the results folder
            saveas(gcf, ['../results/BoxplotG0_Attr' AttrName '.png']);
            
        case 3
            ylabel('G120');
            ylim([50 600]);
            % saving the figure in the results folder
            saveas(gcf, ['../results/BoxplotG120_Attr' AttrName '.png']);
        case 4
            ylabel('I0');
            ylim([0 90]);
            % saving the figure in the results folder
            saveas(gcf, ['../results/BoxplotI0_Attr' AttrName '.png']);
        case 5
            ylabel('I120');
            ylim([10 310]);
            % saving the figure in the results folder
            saveas(gcf, ['../results/BoxplotI120_Attr' AttrName '.png']);
    end
    
end


% Hypothesis tests of the clustered data between variables per cluster

% Glucose
[p,h] = signrank(Cluster.subjects{1,1}(:,2),Cluster.subjects{1,1}(:,3));
fprintf('Wilcoxon signed rank test: G0 vs G120, Cluster 1: p = %d, h = %d\n',p,h);

[p,h] = signrank(Cluster.subjects{2,1}(:,2),Cluster.subjects{2,1}(:,3));
fprintf('Wilcoxon signed rank test: G0 vs G120, Cluster 2: p = %d, h = %d\n',p,h);

[p,h] = signrank(Cluster.subjects{3,1}(:,2),Cluster.subjects{3,1}(:,3));
fprintf('Wilcoxon signed rank test: G0 vs G120, Cluster 3: p = %d, h = %d\n',p,h);

% Insulin
[p,h] = signrank(Cluster.subjects{1,1}(:,4),Cluster.subjects{1,1}(:,5));
fprintf('Wilcoxon signed rank test: I0 vs I120, Cluster 1: p = %d, h = %d\n',p,h);

[p,h] = signrank(Cluster.subjects{2,1}(:,4),Cluster.subjects{2,1}(:,5));
fprintf('Wilcoxon signed rank test: I0 vs I120, Cluster 2: p = %d, h = %d\n',p,h);

[p,h] = signrank(Cluster.subjects{3,1}(:,4),Cluster.subjects{3,1}(:,5));
fprintf('Wilcoxon signed rank test: I0 vs I120, Cluster 3: p = %d, h = %d\n',p,h);

close all;

end
