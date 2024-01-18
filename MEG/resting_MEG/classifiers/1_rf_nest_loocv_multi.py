
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 21 22:07:14 2023
Build random forest classifier from static MEG data, optimise parameters, select important features, plot ROC curves,
save feature importances for plotting
@author: mtrubshaw
"""

import numpy as np
import pandas as pd
import os

import matplotlib.pyplot as plt

from sklearn.model_selection import train_test_split, cross_val_score, cross_val_predict
from sklearn.model_selection import StratifiedKFold
from sklearn.model_selection import GridSearchCV, KFold, RandomizedSearchCV

from sklearn.metrics import roc_auc_score, multilabel_confusion_matrix, roc_curve, auc, f1_score, balanced_accuracy_score
from sklearn.metrics import accuracy_score, confusion_matrix, precision_score, recall_score, ConfusionMatrixDisplay, precision_recall_curve
from sklearn.utils.class_weight import compute_class_weight

from sklearn.preprocessing import LabelBinarizer
from sklearn.preprocessing import StandardScaler

from sklearn.decomposition import PCA
from sklearn.tree import plot_tree

import seaborn as sns

from sklearn.ensemble import RandomForestClassifier

from osl_dynamics.analysis import power

#%% load and format predictors and outcomes


os.makedirs('plots',exist_ok=True)
os.makedirs('data',exist_ok=True)


# Load dynamics data
mean = np.load("/home/mtrubshaw/Documents/ALS_dyn/dynamic/dynemo_runs_new/analysis_full_dynemo/summary_stats_short/data/mean.npy")
sd = np.load("/home/mtrubshaw/Documents/ALS_dyn/dynamic/dynemo_runs_new/analysis_full_dynemo/summary_stats_short/data/std.npy")
sd = np.mean(sd,axis=1).reshape(sd.shape[0],1)
kurt = np.load("/home/mtrubshaw/Documents/ALS_dyn/dynamic/dynemo_runs_new/analysis_full_dynemo/summary_stats_short/data/kurt.npy")
fc_alp_vec = np.load("/home/mtrubshaw/Documents/ALS_dyn/dynamic/dynemo_runs_new/analysis_full_dynemo/alpha_cor/data/fc_alp_vec.npy")
coe = np.load("/home/mtrubshaw/Documents/ALS_dyn/data/static/coe.npy")

exp = np.load("/home/mtrubshaw/Documents/ALS_dyn/data/static/aperiodic_exponents.npy")
exp= np.mean(exp,axis=1).reshape(exp.shape[0],1)
#get power
f = np.load("../data/static/f.npy")
psd = np.load("../data/static/p.npy")

frequency_bands = [[1, 4], [4, 7], [7, 13], [13, 30], [30, 48], [52, 80]]
p = []
for frequency_range in frequency_bands:
    p.append(power.variance_from_spectra(f, psd, frequency_range=frequency_range))
p = np.array(p)
power = np.swapaxes(p, 0, 1)
power_ = p.reshape(power.shape[0], -1)

#  get aec
aec = np.load("../dynamic/dynemo_runs_new/analysis_full_dynemo/coherence/data/coh.npy")
aec_ = np.mean(aec,axis=2)
aec_ = aec_.reshape(aec_.shape[0],-1)



data_all = np.concatenate((kurt,mean,sd,fc_alp_vec,coe,power_,aec_,exp),axis=1)


# Load regressor data
demographics = pd.read_csv("../demographics/demographics_als_dyn.csv")

category_list = demographics["Group"].values
category_list[category_list == "HC"] = 1
category_list[category_list == "ALS"] = 2
category_list[category_list == "rALS"] = 2
category_list[category_list == "AC9"] = 5
category_list[category_list == "ADCT"] = 2
category_list[category_list == "AFIG"] = 2
category_list[category_list == "rAFIG"] = 2
category_list[category_list == "ASOD"] = 2
category_list[category_list == "PC9"] = 3
category_list[category_list == "PSOD"] = 4

hc_idxs = np.where(category_list==1)
pc9_idxs = np.where(category_list==3)
sod_idxs = np.where(category_list==4)
# ac9_idxs = np.where(category_list==5)

data_hc = data_all[hc_idxs]
data_pc9 = data_all[pc9_idxs]
data_sod = data_all[sod_idxs]

# age = demographics["Age"].values
# age_pc9 = age[pc9_idxs]
# age_sod = age[sod_idxs]
# age_pre = np.hstack((age_pc9,age_sod))

# hc_id = []
# for a in range(len(age_pre)):
#     condition = ((category_list == 1) & (age < (age_pre[a] + 1)) & ((age_pre[a] - 1) > age))
#     indices = np.where(condition)[0]
#     hc_id.append(indices)

# hc_id=np.concatenate(hc_id)
# hc_id = np.unique(hc_id)
# hc_id = np.random.choice(hc_id,40)

# data_hc = data_all[hc_id]

# data_ac9 = data_all[ac9_idxs]

data = np.concatenate((data_hc,data_pc9,data_sod),axis=0)


labels = np.hstack((np.zeros(len(data_hc)),np.ones(len(data_pc9)),(np.ones(len(data_sod))+1)))
# np.random.shuffle(labels)

lb = LabelBinarizer()

cv = 3


all_true_labels = []
all_predicted_probabilities = []
kf = KFold(n_splits=cv, shuffle=True, random_state=1)

fold = 0

# Calculate class weights
class_weights = compute_class_weight(class_weight='balanced', classes=np.unique(labels), y=labels)
class_weight_dict = dict(zip(np.unique(labels), class_weights))

for train_index, test_index in kf.split(labels):
    fold = fold+1
    print('')
    print('')
    print(f'^^^^^^^^^^^^^^^ Fold {fold} ^^^^^^^^^^^^^^^')
    # Split the data into training and testing sets
    # X_train, X_test, y_train, y_test = train_test_split(data, labels, test_size=0.3, random_state=rs)
    X_train, X_test, y_train, y_test = data[train_index], data[test_index], labels[train_index], labels[test_index]
    

    
    
    scaler = StandardScaler()
    scaler.fit(X_train)
    X_train = scaler.transform(X_train)
    X_test = scaler.transform(X_test)
    



    
    # Initialize Logistic Regression model
    rf_classifier = RandomForestClassifier(random_state=0,n_jobs=-1, class_weight=class_weight_dict
                                            ,bootstrap=True,max_depth=5,max_features=None,min_samples_leaf=2,min_samples_split=5,
                                            n_estimators=100)
    

    
    param_grid = {
        'n_estimators': [50,100, 200],  # Varying the number of trees
        'max_depth': [None, 5, 10, 20],  # Controlling tree depth
        'min_samples_split': [2, 5, 10],
        'min_samples_leaf': [1, 2, 4],
        'max_features': [None, 'sqrt'],
        'bootstrap': [True, False]
    }
    
    
    # grid_search_rf = GridSearchCV(rf_classifier, param_grid, cv=cv, scoring='r2',n_jobs=-1)
    grid_search_rf = RandomizedSearchCV(rf_classifier, param_grid, cv=cv, scoring='roc_auc_ovr',n_jobs=-1, verbose=1, n_iter=10,random_state=0)
    # grid_search_rf = GridSearchCV(rf_classifier, param_grid, cv=cv, scoring='roc_auc',n_jobs=-1, verbose=1)
    grid_search_rf.fit(X_train, y_train)
    hyp_model = grid_search_rf.best_estimator_
    hyp_params = grid_search_rf.best_params_
    

    
    # # Train the model
    # hyp_model = rf_classifier.fit(X_train, y_train)
    
    
    # Evaluate the model 
    accuracy = hyp_model.score(X_test, y_test)
    print(f"Accuracy on test set: {accuracy:.2f}")
    
    # cross-validation
    cv_scores = cross_val_score(hyp_model, X_train, y_train, cv=cv,scoring='roc_auc_ovr')  # 5-fold cross-validation
    print(f"Cross-validation scores: {cv_scores}")
    print(f"Mean cross-validation score: {np.mean(cv_scores):.2f}")

    #%% optimise the number of features used by the model
    # Get feature importances
    importances = hyp_model.feature_importances_
    
    
    # Sort indices of importances in descending order
    sorted_indices = np.argsort(importances)[::-1]
    sorted_indices_ = np.argsort(importances)
    
    # Cumulative sum of sorted importances
    cumulative_importance = np.cumsum(importances[sorted_indices])
    min_imp = cumulative_importance[0]*100+1
    
    #iteratively add important features and evaluate cv accuracy.
    cv_accuracies = []
    test_accuracies = []
    pvals = []
    ps = []
    xs= np.arange(min_imp, 100, 5)
    for i_ in xs:
        i = i_/100
        print('')
        print(f'{i:.2f}%')
        selected_indices = sorted_indices[cumulative_importance <= i]
        top = len(selected_indices)
        
        # Sort indices based on feature importance scores
        sorted_indices = np.argsort(importances)[::-1]
        
        hyp_feat_model = hyp_model.fit(X_train[:,sorted_indices[:top]], y_train)
        cv_scores = cross_val_score(hyp_feat_model, X_train[:,sorted_indices[:top]], y_train, cv=cv,scoring='roc_auc_ovr')  # 5-fold cross-validation
        print(f"CV score: {np.mean(cv_scores):.2f}")
        cv_accuracies.append(np.mean(cv_scores))
        
        test_accuracy = hyp_feat_model.score(X_test[:,sorted_indices[:top]], y_test)
        print(f"ROC AUC test set: {test_accuracy:.2f}")
        test_accuracies.append(test_accuracy)
        
        ps.append(i_)
        
        

    
    # choose the model with the highest cv accuracy
    print('')
    print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    print('SELECTED: importances',ps[np.argmax(cv_accuracies)],' -- % ROC AUC cv:',cv_accuracies[np.argmax(cv_accuracies)],' --AUC unseen:', test_accuracies[np.argmax(cv_accuracies)])
    print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    print('')
    

    # Plot ROC for CV data in chosen model
    i = ps[np.argmax(cv_accuracies)]/100
    print('Selecting top',i*100,'% importances')
    selected_indices = sorted_indices[cumulative_importance <= i]
    top = len(selected_indices)
    
    # Sort indices based on feature importance scores
    sorted_indices = np.argsort(importances)[::-1]
    
    best_model = hyp_feat_model.fit(X_train[:, selected_indices[:top]], y_train)

    y_pred_proba = best_model.predict_proba(X_test[:, selected_indices[:top]])
    all_true_labels.extend(lb.fit_transform(y_test))
    all_predicted_probabilities.extend(y_pred_proba)


#%% 
all_true_labels = np.array(all_true_labels)
all_predicted_probabilities = np.array(all_predicted_probabilities)

# Calculate multilabel confusion matrix
confusion_matrices = multilabel_confusion_matrix(all_true_labels, (all_predicted_probabilities > 0.5).astype(int))

# Plot confusion matrix
labels = ['HC', 'AC9', 'ASOD']
fig, axes = plt.subplots(nrows=1, ncols=len(labels), figsize=(15, 5))

for i, (conf_matrix, label) in enumerate(zip(confusion_matrices, labels)):
    sns.heatmap(conf_matrix, annot=True, fmt='d', cmap='Blues', cbar=False, ax=axes[i])
    axes[i].set_title(f'Confusion Matrix - {label}')
    axes[i].set_xlabel('Predicted')
    axes[i].set_ylabel('True')

plt.tight_layout()
plt.savefig('plots/conf_multi.png', dpi=1000)
plt.show()

# Plot ROC curve for each class
plt.figure(figsize=(8, 8))
for i , name in zip(range(confusion_matrices.shape[0]),labels):
    fpr, tpr, _ = roc_curve(all_true_labels[:, i], all_predicted_probabilities[:, i])
    roc_auc = auc(fpr, tpr)
    plt.plot(fpr, tpr, label=f'{name} (AUC = {roc_auc:.2f})')

plt.plot([0, 1], [0, 1], color='navy', linestyle='--')
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title(f'ROC curve for unseen data across {fold} folds')
plt.legend(loc='best')
plt.savefig('plots/ROC_multi.png', dpi=1000)
plt.show()

# Convert multilabel format to multiclass format
predicted_classes = np.argmax(all_predicted_probabilities, axis=1)
predicted_classes = lb.fit_transform(predicted_classes)
# Calculate metrics
for c , name in enumerate(labels):
    accuracy = balanced_accuracy_score(all_true_labels[:,c], predicted_classes[:,c])
    precision = precision_score(all_true_labels[:,c], predicted_classes[:,c], average='weighted')
    recall = recall_score(all_true_labels[:,c], predicted_classes[:,c], average='weighted')
    f1 = f1_score(all_true_labels[:,c], predicted_classes[:,c], average='weighted')
    
    print(name)
    print(f"Accuracy: {accuracy:.2f}")
    print(f"Precision: {precision:.2f}")
    print(f"Recall: {recall:.2f}")
    print(f"F1-Score: {f1:.2f}")
    print('')

# Plot AUC-PR curve for each class
plt.figure(figsize=(8, 8))
for i, name in zip(range(confusion_matrices.shape[0]), labels):
    precision, recall, _ = precision_recall_curve(all_true_labels[:, i], all_predicted_probabilities[:, i])
    pr_auc = auc(recall, precision)
    plt.plot(recall, precision, label=f'{name} (AUC-PR = {pr_auc:.2f})')

plt.xlabel('Recall')
plt.ylabel('Precision')
plt.title(f'AUC-PR curve for unseen data across {fold} folds')
plt.legend(loc='best')
plt.savefig('plots/AUC_PR_multi.png', dpi=1000)
plt.show()