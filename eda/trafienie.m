function t = trafienie(v, wygral)
%TRAFIENIE Trafienie reguły „typuj konia z najlepszą statystyką” w jednej gonitwie.
%   v      - statystyka każdego konia w gonitwie (mniej = lepiej; NaN = brak historii w oknie)
%   wygral - 1 dla zwycięzcy, 0 dla pozostałych koni
%   t      - 1 = wskazany koń wygrał, 0 = nie wygrał, 1/k = remis k koni z najlepszą wartością,
%            1/liczba koni = nikt w gonitwie nie ma historii, więc typujemy losowo.
%   Konie bez historii w oknie nie są typowane, dopóki ktoś w gonitwie ją ma.
if all(isnan(v))
    t = 1 / numel(v);
else
    najlepsze = v == min(v);            % min pomija NaN, a NaN nigdy nie jest równe min
    t = sum(najlepsze & wygral == 1) / sum(najlepsze);
end
end
