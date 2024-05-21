function [coef, pVal] = fitLMEForVertex(vertexData)

    lmeFormula = 'Response ~ 1 + Sex + Age + PTA_mean + AgeSq + Hemisphere + TinnitusStatus + (1|SubjectID)';

    if all(vertexData.Response == 0)
        coef = NaN;
        pVal = NaN;
        return;
    end

    % Fit the LME model to the data
    lmeModel = fitlme(vertexData, lmeFormula);
    coef = lmeModel.Coefficients.Estimate;
    pVal = lmeModel.Coefficients.pValue;
end