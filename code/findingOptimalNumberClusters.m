function findingOptimalNumberClusters(X_G0,X_G0G120,X_G0I0,X_G0G120I0I120)
%FINDINGOPTIMALNUMBERCLUSTERS find the optimal number of clusters k
%according to the elbow and silhouette methods. In the case of the elbow
%method, for different values of k, after running the clustering process,
%the percentage of variance explained is compute. Then, the optimal number
%of clusters corresponds to the lowest k that gives 90% of the percentage
%of variance explained. The elbow method by considering the total within
%cluster sum of squares (WCSS) as a function of the number of clusters is
%also computed. In the case of the Silhouette clustering evaluation
%criterion, again for different values of k, after running the clustering
%process, the average Silhouette of observations is computed. Then, the
%optimal number of clusters is the one that provides the highest average
%Silhouette value.            
%
%   Inputs:
%      X_G0: Fasting glucose levels (G0) data
%      X_G0G120: Fasting and postprandial glucose levels (G0&G120) data
%      X_G0I0: Fasting glucose and insulin levels (G0&I0) data
%      X_G0G120I0I120: Fasting and postprandial glucose and insulin levels
%      (G0&G120&I0&I120) data  
%
%   Author: Miguel Altuve
%   Email: miguelaltuve@gmail.com
%   Date: November 2019
%
%   MIT License
%   Copyright (c) 2019 Miguel Altuve


% Variables initialization

% Maximum number of clusters
MaxNumberClusters = 10;
% index of cluster
k = 2:MaxNumberClusters;
% Cutoff of the percentage of variance explained
CutoffVariance = 0.9;
% Squared Euclidean distance. Each centroid is the mean of the points in
% that cluster. 
DISTANCE = 'sqeuclidean';

% Elbow method based on percentage of variance explained

% Using G0 as attribute
[~,~,~,~,PC]=kmeans_opt(X_G0,MaxNumberClusters,CutoffVariance);
figure; plot(k,100*PC);

% Using G0&G120 as attributes
[~,~,~,~,PC]=kmeans_opt(X_G0G120,MaxNumberClusters,CutoffVariance);
hold on;
plot(k,100*PC);

% Using G0&I0 as attributes
[~,~,~,~,PC]=kmeans_opt(X_G0I0,MaxNumberClusters,CutoffVariance);
plot(k,100*PC);

% Using G0&G120&I0&I120 as attributes
[~,~,~,~,PC]=kmeans_opt(X_G0G120I0I120,MaxNumberClusters,CutoffVariance);
plot(k,100*PC);
legend('G0','G0&G120','G0&I0','G0&G120&I0&I120','Location','southeast');
ylabel('Percentage of variance explained');
xlabel('Cluster');
ylim([0 100]);
xlim([2 10]);
grid on;

% saving the figure in the results folder
saveas(gcf, '../results/ElbowVarianceExplained.png');


% Silhouette method and Elbow method based on the total within cluster sum
% of squares (WCSS) 

for i = 1:length(k)
    % k-means clustering using G0 as attribute
    [cidx{i},~,sumd{i}] = kmeans(X_G0,k(i),'dist',DISTANCE,'Replicates',10,'display','final');
    % total within cluster sum of squares (WCSS)
    WCSS_G0(i) = sum(sumd{i});
    % cluster silhouette
    [silh_G0(:,i),~] = silhouette(X_G0,cidx{i},DISTANCE);
    close all;
    
    % k-means clustering using G0&G120 as attributes
    [cidx{i},~,sumd{i}] = kmeans(X_G0G120,k(i),'dist',DISTANCE,'Replicates',10,'display','final');
    % total within cluster sum of squares (WCSS)
    WCSS_G0G120(i) = sum(sumd{i});
    % cluster silhouette
    [silh_G0G120(:,i),~] = silhouette(X_G0G120,cidx{i},DISTANCE);
    close all;
    
    % k-means clustering using G0&I0 as attributes
    [cidx{i},~,sumd{i}] = kmeans(X_G0I0,k(i),'dist',DISTANCE,'Replicates',10,'display','final');
    % total within cluster sum of squares (WCSS)
    WCSS_G0I0(i) = sum(sumd{i});
    % cluster silhouette
    [silh_G0I0(:,i),~] = silhouette(X_G0I0,cidx{i},DISTANCE);
    close all;
    
    % k-means clustering using G0&G120&I0&I120 as attributes
    [cidx{i},~,sumd{i}] = kmeans(X_G0G120I0I120,k(i),'dist',DISTANCE,'Replicates',10,'display','final');
    % total within cluster sum of squares (WCSS)
    WCSS_G0G120I0I120(i) = sum(sumd{i});
    % cluster silhouette
    [silh_G0I0G120(:,i),~] = silhouette(X_G0G120I0I120,cidx{i},DISTANCE);
    close all;
end


% Plot of the mean of the Silhouettes as a function of the number of clusters
figure; plot(k,mean(silh_G0));
hold on;
plot(k,mean(silh_G0G120));
plot(k,mean(silh_G0I0));
plot(k,mean(silh_G0I0G120));
legend('G0','G0&G120','G0&I0','G0&G120&I0&I120');
ylabel('Average Silhouette'); xlabel('Cluster');
grid on;
ylim([0 1]);

% saving the figure in the results folder
saveas(gcf, '../results/AverageSilhouette.png');

% Plot of WCSS as a function of the number of clusters
figure, plot(k,WCSS_G0/max(WCSS_G0));
hold on;
plot(k,WCSS_G0I0/max(WCSS_G0I0));
plot(k,WCSS_G0G120/max(WCSS_G0G120));
plot(k,WCSS_G0G120I0I120/max(WCSS_G0G120I0I120));
legend('G0','G0&G120','G0&I0','G0&G120&I0&I120');
ylabel('WCSS/max(WCSS)'); xlabel('Cluster');
grid on;

% saving the figure in the results folder
saveas(gcf, '../results/ElbowWCSS.png');

close all;
end
