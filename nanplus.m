function result = nanplus(a, b)
    a(isnan(a)) = 0;
    b(isnan(b)) = 0;
    result = a + b;
end