% Cluster Analysis Based on Fasting and Postprandial Plasma Glucose and
% Insulin Concentrations 
% Plasma glucose and insulin concentrations are clinical markers used in
% the diagnosis of metabolic diseases, particularly prediabetes and
% diabetes. In this work, we carried out a cluster analysis using plasma
% glucose and insulin data in fasting and two-hour postprandial. Different
% clustering experiments were performed by changing the attributes, from
% one (fasting glucose) to four (fasting and postprandial glucose and
% insulin) attribute input to a k-means clustering algorithm. Based on the
% elbow and silhouette methods, three clusters were chosen to carry out the
% clustering experiments. The Pearson correlation coefficient was used to
% assess the dependence between the glucose and insulin levels for each
% cluster created.          
%
% Author: Miguel Altuve, PhD
% Email: miguelaltuve@gmail.com
% Date: November 2019
%
% MIT License
% Copyright (c) 2019 Miguel Altuve


% Loading data into workspace
cd ../data/
load('data');

% dataoriginal is a Table (2835x5) containing the data.
% It is composed of 2835 women (rows in the Table) and five variables
% (columns in the Table): 
%   Age: age of the subject
%   G0: fasting glucose levels
%   G120: postprandial glucose levels
%   I0: fasting insulin levels
%   I120: postprandial insulin levels

rng(1); % For reproducibility

% Convert table to homogeneous array
data = table2array(dataoriginal);

% Setting the data with different attribute combination

% Only fasting glucose levels (G0)
X_G0 = data(:,2);

% Fasting and postprandial glucose levels (G0&G120)
X_G0G120 = data(:,2:3);

% Fasting glucose and insulin levels (G0&I0)
X_G0I0 = data(:,2:4);
X_G0I0(:,2)=[]; % deleting second column (G120)

% Fasting and postprandial glucose and insulin levels (G0&G120&I0&I120)
X_G0G120I0I120 = data(:,2:5);


% Finding the optimal number of clusters k according to the elbow and silhouette methods
findingOptimalNumberClusters(X_G0,X_G0G120,X_G0I0,X_G0G120I0I120)

% Clustering the data using the k-means clustering algorithm
Cluster.G0 = ClusteringData(dataoriginal,X_G0,'G0');
Cluster.G0G120 = ClusteringData(dataoriginal,X_G0G120,'G0&G120');
Cluster.G0I0 = ClusteringData(dataoriginal,X_G0I0,'G0&I0');
Cluster.G0G120I0I120 = ClusteringData(dataoriginal,X_G0G120I0I120,'G0&G120&I0&I120');

% saving the results
cd ../results/
save('ClusterResults','Cluster');
