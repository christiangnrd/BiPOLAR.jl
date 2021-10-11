""" 
    classification_report(i, yhat, y)

    Returns multiple classification metrics based on predictions yhat and 
    ground truth values y, for run i.
 """
function classification_report(i, yhat, y)
    P′ = [pdf(yhat[j], 1.0) for j ∈ 1:size(yhat)[1]]
    yₚ = [p >= 0.5 for p ∈ P′]
    out = DataFrame(
        Run = i,
        TN  = true_negative(yₚ, y),
        FP  = false_positive(yₚ, y),
        FN  = false_negative(yₚ, y),
        TP  = true_positive(yₚ, y),
        Sensitivity = sensitivity(yₚ, y),
        Specificity = specificity(yₚ, y),
        PPV = ppv(yₚ, y),
        NPV = npv(yₚ, y),
        Accuracy = accuracy(yₚ, y),
        AUC = auc(yhat, y),
        MCC = mcc(yₚ, y),
        F1  = f1score(yₚ, y),
        Brier = mean((yₚ .- float(y)).^2)
    )
    return out
end

"""
    classification_predictions(fold, train_sites, test_sites, ytrue, ypred)

    Returns a table with individual level predictions
"""
function classification_predictions(fold, train_site, test_sites, ytrue, ypred)
    return DataFrame(
        fold = fold,
        train_site = train_site,
        test_site = vec(Matrix(test_sites)),
        ytrue = int(ytrue, type=Int64) .- 1,
        ypred = map(y->pdf(y, 1.0), ypred))
end

"""
    plot_roc_curves(roc_curves; color, alpha, title, xlabel, ylabel, figsize)

    Plots ROC curves.
"""
function plot_roc_curves(
    roc_curves::Vector;
    color::Symbol=:black, 
    alpha::Float64=0.5,
    title::String="ROC Curve", 
    xlabel::String="FPR", 
    ylabel::String="TPR", 
    figsize::Tuple{Int64,Int64}=(250,250))

    fig = plot([0,1], [0,1], c=color, ls=:dash, 
                label=nothing, title=title,
                ylabel=ylabel, xlabel=xlabel, size=figsize)
    K = size(roc_curves)[1]
    for i ∈ 1:K
        plot!(roc_curves[i][1], roc_curves[i][2], 
        c=color, alpha=alpha, label=nothing)
    end
    return fig
end

"""
    store_classification_predictions(df, fold, train_sites, test_sites, ytrue, ypred)

    Returns a table with individual level predictions
"""
function store_classification_predictions(df, fold, train_site, test_sites, ytrue, ypred)
    return [df; classification_predictions(fold, train_site, test_sites, ytrue, ypred)]
end

"""
    store_classification_results(df, fold, yhat, ytrue)

    This function takes the results dataframe and adds to it a row for the 
    classification results in the current fold.
"""
function store_classification_results(df, fold, yhat, ytrue)
    return [df; classification_report(fold, yhat, coerce(ytrue, OrderedFactor))]
end
