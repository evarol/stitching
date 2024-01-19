function R = nancorr(X, Y)
    % Check if X and Y are non-empty matrices
    if isempty(X) || isempty(Y)
        error('Inputs X and Y cannot be empty.')
    end

    % Get size of X and Y
    [nX, mX] = size(X);
    [nY, mY] = size(Y);

    % Make X and Y the same length by padding with NaN
    if nX > nY
        Y = [Y; nan(nX-nY, mY)];
    elseif nY > nX
        X = [X; nan(nY-nX, mX)];
    end

    % Initialize the correlation matrix
    R = zeros(mX, mY);

    % Compute the correlation for each pair of columns
    for i = 1:mX
        for j = 1:mY
            % Get the column vectors
            x = X(:, i);
            y = Y(:, j);

            % Ignore NaN values
            nanVals = isnan(x) | isnan(y);
            x(nanVals) = [];
            y(nanVals) = [];

            % Calculate correlation coefficient
            R(i, j) = corr(x, y);
        end
    end
end
