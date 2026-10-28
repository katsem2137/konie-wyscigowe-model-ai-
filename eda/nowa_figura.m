function f = nowa_figura(szerokosc, wysokosc)
%NOWA_FIGURA Okno wykresu z białym tłem i jasnym motywem (także przy ciemnym motywie MATLAB-a).
f = figure('Color', 'w', 'Position', [100 100 szerokosc wysokosc]);
if ~isMATLABReleaseOlderThan("R2025a")
    theme(f, "light");
end
end
