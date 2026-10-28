%% Okno przeszłości konia: ile historii mamy i które okno wybrać
% Pytania prowadzącego (14.10): w jakim zakresie analizować przeszłość konia (3 lata / 100 startów /
% pół sezonu) i która statystyka jest najlepsza (średnia / mediana / dominanta).
% Sekcje 1-3: ile historii koń w ogóle ma. Sekcje 4-6: sprawdzenie okien wprost. W każdej gonitwie
% z Partynic typujemy konia z najlepszą statystyką z jego przeszłości i liczymy, jak często wygrał.
% Uruchamianie: F5 albo sekcjami (Ctrl+Enter). Wykresy i tabela zapisują się w eda/wykresy/.

%% 0. Ustawienia i dane
clear; close all;
folderSkryptu = fileparts(mfilename('fullpath'));
if isempty(folderSkryptu), folderSkryptu = pwd; end      % przy uruchamianiu sekcjami
folderWykresow = fullfile(folderSkryptu, 'wykresy');
if ~isfolder(folderWykresow), mkdir(folderWykresow); end

% Wygląd wykresów: jednolite czcionki, napisy bez interpretera TeX
set(groot, 'defaultAxesFontSize', 11, 'defaultTextFontSize', 11, 'defaultLegendFontSize', 10, ...
    'defaultAxesTitleFontSizeMultiplier', 1, 'defaultAxesLabelFontSizeMultiplier', 1, ...
    'defaultTextInterpreter', 'none', 'defaultAxesTickLabelInterpreter', 'none', ...
    'defaultLegendInterpreter', 'none');

[H, S] = wczytaj_dane(fullfile(folderSkryptu, '..'));
H = sortrows(H, {'horse_id', 'data'});      % starty każdego konia po kolei w czasie

%% 1. Ile startów ma koń
[grupaKonia, idKoni] = findgroups(H.horse_id);
startyKonia = splitapply(@numel, H.horse_id, grupaKonia);
fprintf('Historia bez kłusaków: %d koni, %d startów\n', numel(idKoni), height(H));
fprintf('Starty na konia: mediana %g, średnia %.1f, maksimum %d\n', ...
    median(startyKonia), mean(startyKonia), max(startyKonia));

f = nowa_figura(1100, 420);
tiledlayout(1, 2, 'TileSpacing', 'compact');

nexttile
histogram(startyKonia, 'BinMethod', 'integers');
set(gca, 'YScale', 'log'); ylim([0.5 Inf]);     % od 0,5, żeby było widać słupki z jednym koniem
xline(median(startyKonia), 'r--', sprintf('mediana: %g', median(startyKonia)), 'LineWidth', 1.5);
xlabel('liczba startów konia'); ylabel('liczba koni (skala logarytmiczna)');
title('Rozkład liczby startów na konia');

nexttile
k = 1:max(startyKonia);
koniCoNajmniejK = arrayfun(@(x) sum(startyKonia >= x), k);
loglog(k, koniCoNajmniejK, 'LineWidth', 1.5); hold on; grid on
for prog = [10 20 50 100]
    n = sum(startyKonia >= prog);
    plot(prog, n, 'ko', 'MarkerFaceColor', 'k');
    text(prog, n, sprintf(' %d+ startów: %d ', prog, n), 'VerticalAlignment', 'bottom', ...
        'HorizontalAlignment', 'right');
end
xlabel('k (skala logarytmiczna)'); ylabel('liczba koni z co najmniej k startami (skala log.)');
title('Ile koni ma co najmniej k startów');
exportgraphics(f, fullfile(folderWykresow, 'okno_1_starty_na_konia.png'), 'Resolution', 200);

%% 2. Jak długo koń biega i ile trwa sezon
pierwszyStart = splitapply(@min, H.data, grupaKonia);
ostatniStart  = splitapply(@max, H.data, grupaKonia);
karieraLata = years(ostatniStart - pierwszyStart);

% Sezon: od pierwszej do ostatniej gonitwy w roku na torach polskich, lata 2013-2023 (pełne dane)
polskie = ismember(H.tor, ["Warszawa" "Wrocław" "Sopot"]) & year(H.data) >= 2013;
grupaRoku = findgroups(year(H.data(polskie)));
dlugoscSezonu = splitapply(@(d) days(max(d) - min(d)), H.data(polskie), grupaRoku);
polSezonuDni = round(median(dlugoscSezonu) / 2);
fprintf('Sezon trwa (mediana 2013-2023) %d dni, pół sezonu to %d dni\n', ...
    round(median(dlugoscSezonu)), polSezonuDni);

f = nowa_figura(1000, 420);
histogram(karieraLata, 0:0.25:ceil(max(karieraLata)));
xline(polSezonuDni / 365.25, 'k--', 'pół sezonu', 'LineWidth', 1.2);
xline(1, 'k--', '1 rok', 'LineWidth', 1.2);
xline(3, 'k--', '3 lata', 'LineWidth', 1.2);
xlabel('długość kariery [lata], od pierwszego do ostatniego startu'); ylabel('liczba koni');
title(sprintf('Długość kariery: mediana %s roku, %d%% koni biega krócej niż 3 lata', ...
    strrep(sprintf('%.1f', median(karieraLata)), '.', ','), round(100 * mean(karieraLata < 3))));
subtitle('Koń z jednym startem ma karierę 0. Kariery koni, które biegały jeszcze w 2023 r., ucina koniec danych.');
exportgraphics(f, fullfile(folderWykresow, 'okno_2_dlugosc_kariery.png'), 'Resolution', 200);

%% 3. Co ile dni koń startuje
przerwa = [NaN; days(diff(H.data))];
przerwa([true; diff(H.horse_id) ~= 0]) = NaN;    % pierwszy start konia nie ma poprzednika
przerwa = przerwa(~isnan(przerwa));
wSezonie = przerwa(przerwa <= 120);               % dłuższa przerwa to zima albo pauza w karierze
fprintf('Przerwa między startami w sezonie: mediana %g dni\n', median(wSezonie));

f = nowa_figura(1000, 420);
histogram(wSezonie, 0:7:126);
xline(median(wSezonie), 'r--', sprintf('mediana: %g dni', median(wSezonie)), 'LineWidth', 1.5);
xlabel('dni od poprzedniego startu konia (słupek = tydzień)'); ylabel('liczba startów');
title('Co ile dni koń startuje (przerwy do 120 dni)');
subtitle(sprintf('Przerw dłuższych niż 120 dni (zima, pauza w karierze): %d%%', round(100 * mean(przerwa > 120))));
exportgraphics(f, fullfile(folderWykresow, 'okno_3_przerwy_miedzy_startami.png'), 'Resolution', 200);

%% 4. Przeszłość konia przed każdym startem na Partynicach
% Gonitwy z Partynic 2013-2023 z kompletnymi wynikami: tylko tam znamy wszystkie konie w gonitwie,
% więc da się sprawdzić, czy wskazany koń wygrał. Przeszłość konia to jego starty z historii
% (wszystkie tory) ściśle przed datą gonitwy, żeby wynik gonitwy nie przeciekł do jej oceny.
E = S(year(S.data) <= 2023 & S.kompletna == 1, :);
gonitwa = findgroups(E.race_id);

oknaN  = [1 2 3 5 10 20 50 100 Inf];                     % ostatnie N startów
nazwyN = ["1" "2" "3" "5" "10" "20" "50" "100" "cała"];
oknaT  = [30 61 polSezonuDni 183 365 730 1096 36525];     % ostatnie T dni (36525 dni = cała historia)
nazwyT = ["1 mies." "2 mies." "pół sezonu" "6 mies." "1 rok" "2 lata" "3 lata" "cała"];
nazwyStat = ["średnia miejsca" "mediana miejsca" "dominanta miejsca" ...
    "średnia miejsca względnego" "mediana miejsca względnego" "odsetek wygranych"];
nN = numel(oknaN); nT = numel(oknaT); nStat = numel(nazwyStat); nE = height(E);

% Statystyki z wybranych startów konia, zawsze „mniej = lepiej”, dlatego odsetek wygranych ze znakiem
% minus. Przy remisie dominanty MATLAB bierze mniejszą wartość, czyli lepsze miejsce.
% Z pustego okna wychodzi NaN, czyli brak historii.
miejsce = H.miejsce_m; wzgl = H.wzgl; wygrana = H.wygrana;
statystyki = @(idx) [mean(miejsce(idx), 'omitnan'), median(miejsce(idx), 'omitnan'), mode(miejsce(idx)), ...
    mean(wzgl(idx), 'omitnan'), median(wzgl(idx), 'omitnan'), -mean(wygrana(idx))];

V = NaN(nE, nN + nT, nStat);     % wartość statystyki: start x okno x statystyka
ileWOknie = zeros(nE, nN + nT);  % ile wcześniejszych startów konia weszło do okna
koniH = H.horse_id; dataH = H.data; koniE = E.horse_id; dataE = E.data;
for i = 1:nE
    przeszlosc = find(koniH == koniE(i) & dataH < dataE(i));    % wiersze H po kolei w czasie
    for w = 1:nN
        idx = przeszlosc(max(1, end - oknaN(w) + 1):end);
        V(i, w, :) = statystyki(idx);
        ileWOknie(i, w) = numel(idx);
    end
    for w = 1:nT
        idx = przeszlosc(dataH(przeszlosc) >= dataE(i) - days(oknaT(w)));
        V(i, nN + w, :) = statystyki(idx);
        ileWOknie(i, nN + w) = numel(idx);
    end
end

%% 5. Ile historii naprawdę mieści się w oknie
% Okna z pytania prowadzącego (100 startów, pół sezonu, 3 lata) i kilka innych do porównania
wybrane = [find(oknaN == 5), find(oknaN == 100), nN + find(nazwyT == "pół sezonu"), ...
    nN + find(nazwyT == "1 rok"), nN + find(nazwyT == "3 lata"), find(isinf(oknaN))];
etykiety = ["ostatnie 5 startów" "ostatnie 100 startów" sprintf("pół sezonu (%d dni)", polSezonuDni) ...
    "1 rok" "3 lata" "cała historia"];
krawedzie = [0 1 3 6 11 21 Inf];
przedzialy = ["0 (brak historii)" "1-2" "3-5" "6-10" "11-20" "ponad 20"];
udzial = zeros(numel(wybrane), numel(przedzialy));
for j = 1:numel(wybrane)
    udzial(j, :) = 100 * histcounts(ileWOknie(:, wybrane(j)), krawedzie) / nE;
end

f = nowa_figura(1150, 420);
b = barh(udzial, 'stacked');
kolory = [0.80 0.80 0.80; 0.78 0.86 0.94; 0.55 0.71 0.86; 0.32 0.53 0.76; 0.16 0.36 0.62; 0.05 0.19 0.42];
for c = 1:numel(b), b(c).FaceColor = kolory(c, :); end
for j = 1:numel(wybrane)                     % procenty na odcinkach szerszych niż 7%
    lewo = 0;
    for c = 1:numel(przedzialy)
        if udzial(j, c) >= 7
            kolorTekstu = 'k'; if c >= 4, kolorTekstu = 'w'; end
            text(lewo + udzial(j, c) / 2, j, sprintf('%.0f%%', udzial(j, c)), ...
                'HorizontalAlignment', 'center', 'Color', kolorTekstu);
        end
        lewo = lewo + udzial(j, c);
    end
end
set(gca, 'YTickLabel', etykiety, 'YDir', 'reverse'); xlim([0 100]);
xlabel('udział startów na Partynicach 2013-2023 [%]'); ylabel('okno');
title('Ile wcześniejszych startów konia naprawdę mieści się w oknie');
legend(przedzialy, 'Location', 'eastoutside');
exportgraphics(f, fullfile(folderWykresow, 'okno_4_ile_historii_w_oknie.png'), 'Resolution', 200);

%% 6. Które okno i która statystyka najlepiej wskazują zwycięzcę
% W każdej gonitwie typujemy konia z najlepszą statystyką (zasady w trafienie.m) i sprawdzamy, czy
% wygrał. Trafność = odsetek trafionych gonitw. Niepewność = odchylenie standardowe / sqrt(liczba gonitw).
trafnosc = zeros(nN + nT, nStat); niepewnosc = zeros(nN + nT, nStat);
for w = 1:nN + nT
    for s = 1:nStat
        t = splitapply(@trafienie, V(:, w, s), E.wygral, gonitwa);
        trafnosc(w, s) = mean(t);
        niepewnosc(w, s) = std(t) / sqrt(numel(t));
    end
end
losowo = mean(splitapply(@(x) 1 / numel(x), E.wygral, gonitwa));
fprintf('Gonitwy do oceny: %d, starty: %d. Losowe typowanie trafia w %.1f%% gonitw\n', ...
    max(gonitwa), nE, 100 * losowo);

f = nowa_figura(1250, 480);
uklad = tiledlayout(1, 2, 'TileSpacing', 'compact');
styl = {'-o', '-s', '-^', '--o', '--s', ':d'};

nexttile; hold on; grid on
for s = 1:nStat
    errorbar(1:nN, 100 * trafnosc(1:nN, s), 100 * niepewnosc(1:nN, s), styl{s}, 'LineWidth', 1.2);
end
yline(100 * losowo, 'k:', 'losowe typowanie', 'LineWidth', 1.2);
xticks(1:nN); xticklabels(nazwyN); xlim([0.5 nN + 0.5]);
xlabel('okno: ostatnie N startów'); ylabel('trafność [% gonitw]');
title('Okno liczone w startach');

nexttile; hold on; grid on
for s = 1:nStat
    errorbar(1:nT, 100 * trafnosc(nN + 1:end, s), 100 * niepewnosc(nN + 1:end, s), styl{s}, 'LineWidth', 1.2);
end
yline(100 * losowo, 'k:', 'losowe typowanie', 'LineWidth', 1.2);
xticks(1:nT); xticklabels(nazwyT); xlim([0.5 nT + 0.5]);
xlabel('okno: ostatnie T dni przed gonitwą'); ylabel('trafność [% gonitw]');
title('Okno liczone w czasie');

lg = legend(nazwyStat, 'NumColumns', 3); lg.Layout.Tile = 'south';
title(uklad, 'Jak często koń z najlepszą statystyką z przeszłości wygrał gonitwę');
subtitle(uklad, 'Gonitwy z Partynic 2013-2023, słupki: niepewność standardowa');
exportgraphics(f, fullfile(folderWykresow, 'okno_5_trafnosc.png'), 'Resolution', 200);

% Tabela: wszystkie okna i statystyki na jednej mapie
nazwyOkien = ["N = " + nazwyN, "T = " + nazwyT];
f = nowa_figura(950, 720);
h = heatmap(nazwyStat, nazwyOkien, round(100 * trafnosc, 1));
h.Title = sprintf('Trafność [%% gonitw], losowe typowanie: %.1f%%', 100 * losowo);
h.XLabel = 'statystyka z przeszłości konia';
h.YLabel = 'okno (N: ostatnie starty, T: ostatnie dni)';
h.FontSize = 10;
exportgraphics(f, fullfile(folderWykresow, 'okno_6_mapa_trafnosci.png'), 'Resolution', 200);

wyniki = array2table(round(100 * trafnosc, 1), 'VariableNames', nazwyStat);
wyniki = addvars(wyniki, nazwyOkien', 'Before', 1, 'NewVariableNames', 'okno');
writetable(wyniki, fullfile(folderWykresow, 'okno_trafnosc.xlsx'));
disp(wyniki)
