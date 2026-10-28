%% EDA ogólne: ile mamy danych, konie z największą liczbą startów, miejsca, tor po latach
% Pozostałe punkty prowadzącego (14.10): informacje ogólne, okres startów koni z największą liczbą
% startów, histogramy miejsc, warunki na torze po latach. Okno przeszłości jest w okno_przeszlosci.m.
% Uruchamianie: F5 albo sekcjami (Ctrl+Enter). Wykresy zapisują się w eda/wykresy/.

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
miesiace = ["sty" "lut" "mar" "kwi" "maj" "cze" "lip" "sie" "wrz" "paź" "lis" "gru"];

[H, S, G] = wczytaj_dane(fullfile(folderSkryptu, '..'));

%% 1. Ile mamy danych
fprintf('Historia (wszystkie tory, bez kłusaków): %d startów, %d koni, lata %d-%d\n', ...
    height(H), numel(unique(H.horse_id)), min(year(H.data)), max(year(H.data)));
fprintf('Partynice (bez kłusaków): %d gonitw, %d startów\n', height(G), height(S));

f = nowa_figura(1250, 450);
tiledlayout(1, 2, 'TileSpacing', 'compact');

nexttile
lata = (min(year(H.data)):max(year(H.data)))';
tory = ["Warszawa" "Wrocław" "Sopot"];
ile = zeros(numel(lata), numel(tory) + 1);
for r = 1:numel(lata)
    wRoku = year(H.data) == lata(r);
    for t = 1:numel(tory)
        ile(r, t) = sum(wRoku & H.tor == tory(t));
    end
    ile(r, end) = sum(wRoku & ~ismember(H.tor, tory));
end
bar(lata, ile, 'stacked');
xlabel('rok'); ylabel('liczba startów');
title('Historia koni z Partynic: starty w kolejnych latach');
legend([tory "inne tory (głównie zagranica)"], 'Location', 'southoutside', 'Orientation', 'horizontal');

nexttile
lataG = unique(year(G.data));
rodzaje = ["plaska" "ploty" "steeple"];
ileG = zeros(numel(lataG), numel(rodzaje));
for r = 1:numel(lataG)
    for k = 1:numel(rodzaje)
        ileG(r, k) = sum(year(G.data) == lataG(r) & G.rodzaj == rodzaje(k));
    end
end
bar(categorical(string(lataG)), ileG, 'stacked');
xlabel('rok (brak danych z lat 2024-2025)'); ylabel('liczba gonitw');
title('Partynice: gonitwy w kolejnych latach');
legend(["płaskie" "płotowe" "z przeszkodami"], 'Location', 'southoutside', 'Orientation', 'horizontal');
exportgraphics(f, fullfile(folderWykresow, 'eda_1_ile_danych.png'), 'Resolution', 200);

%% 2. Konie z największą liczbą startów: kiedy biegały
grupaKonia = findgroups(H.horse_id);
startyKonia = splitapply(@numel, H.horse_id, grupaKonia);
[~, kolejnosc] = sort(startyKonia, 'descend');
top = kolejnosc(1:15);

f = nowa_figura(1150, 580);
hold on
etykiety = strings(numel(top), 1);
for j = 1:numel(top)
    wiersze = find(grupaKonia == top(j));
    daty = H.data(wiersze);
    wygrane = H.wygrana(wiersze) == 1;
    y = numel(top) + 1 - j;                       % koń z największą liczbą startów na górze
    plot([min(daty) max(daty)], [y y], '-', 'Color', [0.85 0.85 0.85], 'LineWidth', 7);
    plot(daty(~wygrane), repmat(y, sum(~wygrane), 1), 'o', 'Color', [0.20 0.40 0.70], 'MarkerSize', 4);
    plot(daty(wygrane), repmat(y, sum(wygrane), 1), 'o', 'MarkerFaceColor', [0.85 0.30 0.10], ...
        'MarkerEdgeColor', 'none', 'MarkerSize', 6);
    etykiety(y) = sprintf('%s (%d)', H.kon(wiersze(1)), numel(wiersze));
end
yticks(1:numel(top)); yticklabels(etykiety); ylim([0.3 numel(top) + 0.7]); grid on
xlabel('data startu'); ylabel('koń (liczba startów)');
title('15 koni z największą liczbą startów: kiedy biegały');
subtitle('szara belka: od pierwszego do ostatniego startu, niebieskie kółka: starty, czerwone: wygrane');
exportgraphics(f, fullfile(folderWykresow, 'eda_2_konie_os_czasu.png'), 'Resolution', 200);

%% 3. Na jakich miejscach kończyły konie
ukonczyl = ~isnan(H.miejsce);
f = nowa_figura(1350, 450);
tiledlayout(1, 3, 'TileSpacing', 'compact');

nexttile
histogram(H.miejsce(ukonczyl), 'BinMethod', 'integers');
xlabel('miejsce na mecie'); ylabel('liczba startów');
title('Miejsca na mecie');
subtitle({sprintf('nieukończone: %d startów (%d%%)', sum(~ukonczyl), round(100 * mean(~ukonczyl))), ...
    'miejsca 6+ rzadsze: małe stawki'});

nexttile
histogram(H.liczba_koni, 'BinMethod', 'integers');
xlabel('liczba koni w gonitwie'); ylabel('liczba startów');
title('Liczba koni w gonitwie');

nexttile
histogram(H.wzgl, 0:0.1:1);
xlabel('miejsce względne (0 = zwycięzca, 1 = ostatni)'); ylabel('liczba startów');
title('Miejsce względne');
subtitle('nieukończone liczone jako ostatnie');
exportgraphics(f, fullfile(folderWykresow, 'eda_3_miejsca.png'), 'Resolution', 200);

f = nowa_figura(1350, 800);
uklad = tiledlayout(3, 4, 'TileSpacing', 'compact');
for j = 1:12
    wiersze = find(grupaKonia == kolejnosc(j));
    nexttile
    histogram(H.miejsce_m(wiersze), 'BinMethod', 'integers');
    title(sprintf('%s (%d st., %d wygr.)', H.kon(wiersze(1)), numel(wiersze), sum(H.wygrana(wiersze))), ...
        'FontSize', 10);
end
xlabel(uklad, 'miejsce na mecie (nieukończone = ostatnie)'); ylabel(uklad, 'liczba startów');
title(uklad, 'Na jakich miejscach kończyło 12 koni z największą liczbą startów');
exportgraphics(f, fullfile(folderWykresow, 'eda_3b_miejsca_konie_z_czolowki.png'), 'Resolution', 200);

%% 4. Warunki na torze po latach
% Tylko gonitwy płaskie: przeszkodowe mają stan innego toru (płotowego albo przeszkodowego).
P = G(G.rodzaj == "plaska" & ~ismissing(G.stan_toru), :);
stany = ["lekki" "lekko elastyczny" "elastyczny" "mocno elastyczny" "ciężki"];
lataP = unique(year(P.data));
udzial = zeros(numel(lataP), numel(stany));
for r = 1:numel(lataP)
    wRoku = year(P.data) == lataP(r);
    for k = 1:numel(stany)
        udzial(r, k) = 100 * mean(P.stan_toru(wRoku) == stany(k));
    end
end
[~, chi2, pChi2] = crosstab(year(P.data), P.stan_toru);    % czy stan toru zależy od roku
fprintf('Stan toru a rok (gonitwy płaskie): chi2 = %.1f, p = %.3g\n', chi2, pChi2);

f = nowa_figura(1150, 450);
b = bar(categorical(string(lataP)), udzial, 'stacked');
kolory = [0.99 0.90 0.65; 0.97 0.74 0.40; 0.88 0.52 0.20; 0.66 0.33 0.12; 0.38 0.18 0.06];
for k = 1:numel(b), b(k).FaceColor = kolory(k, :); end
ylim([0 100]);
xlabel('rok'); ylabel('udział gonitw płaskich [%]');
title('Stan toru na Partynicach w kolejnych latach (gonitwy płaskie)');
subtitle(sprintf('test chi-kwadrat niezależności (rok x stan toru): p = %.2g', pChi2));
legend(stany, 'Location', 'eastoutside');
exportgraphics(f, fullfile(folderWykresow, 'eda_4_stan_toru_lata.png'), 'Resolution', 200);

f = nowa_figura(1350, 450);
tiledlayout(1, 2, 'TileSpacing', 'compact');

nexttile
boxchart(categorical(string(year(P.data))), P.stan_toru_liczba);
pKW = kruskalwallis(P.stan_toru_liczba, year(P.data), 'off');
xlabel('rok'); ylabel('pomiar stanu toru (więcej = bardziej miękko)');
title('Pomiar stanu toru w kolejnych latach');
subtitle(sprintf('test Kruskala-Wallisa: p = %.2g; kropki: wartości odstające', pKW));

nexttile
m = month(P.data);
boxchart(categorical(miesiace(m)', miesiace(unique(m))), P.stan_toru_liczba);
xlabel('miesiąc'); ylabel('pomiar stanu toru (więcej = bardziej miękko)');
title('Pomiar stanu toru w kolejnych miesiącach (wszystkie lata)');
exportgraphics(f, fullfile(folderWykresow, 'eda_5_pomiar_toru.png'), 'Resolution', 200);

%% 5. Skład sezonu: dni wyścigowe w miesiącach
% Jeśli w którymś roku było więcej dni jesienią, a jesienią tor bywa bardziej miękki, różnica
% między latami może wynikać z kalendarza, a nie ze zmiany toru.
dni = unique(G.data);
lataD = unique(year(dni)); miesD = unique(month(dni));
liczbaDni = zeros(numel(lataD), numel(miesD));
for r = 1:numel(lataD)
    for k = 1:numel(miesD)
        liczbaDni(r, k) = sum(year(dni) == lataD(r) & month(dni) == miesD(k));
    end
end
f = nowa_figura(850, 520);
h = heatmap(miesiace(miesD), string(lataD), liczbaDni);
h.Title = 'Dni wyścigowe na Partynicach w kolejnych miesiącach';
h.XLabel = 'miesiąc'; h.YLabel = 'rok'; h.FontSize = 10;
exportgraphics(f, fullfile(folderWykresow, 'eda_6_dni_wyscigowe.png'), 'Resolution', 200);
