% Trafność lasu z test1.m dla różnych progów doświadczenia: 10 uruchomień na każdy próg.

T0 = readtable('cechy_partynice.csv', 'TextType', 'string');
cechy = ["starty_przed" "odsetek_wygranych" "odsetek_top3" "srednia_wzgl" "mediana_wzgl" ...
         "srednia_wzgl_5" "ostatnie_wzgl" "dni_od_ostatniego" "starty_rok" "ranga_srednia_wzgl" ...
         "dystans_m" "liczba_koni" "wiek" "waga_kg"];
progi = [3 5 10 15];
proby = 10;
trafnosc = zeros(numel(progi), proby);

for k = 1:numel(progi)
    T = T0(T0.starty_przed >= progi(k), :);
    tren = T(T.zbior_2013 == "trening", :);
    test = T(T.zbior_2013 == "test", :);
    g = findgroups(test.race_id);
    for i = 1:proby
        rng(i);
        las = TreeBagger(300, tren(:, cechy), tren.wygral, 'Method', 'classification', 'MinLeafSize', 5);
        [~, wynik] = predict(las, test(:, cechy));
        p = wynik(:, strcmp(las.ClassNames, '1'));
        trafiona = splitapply(@(p, w) w(find(p == max(p), 1)) == 1, p, test.wygral, g);
        trafnosc(k, i) = 100 * mean(trafiona);
    end
    fprintf('próg %2d: średnio %.1f%% (min %.1f, max %.1f)\n', progi(k), mean(trafnosc(k, :)), ...
        min(trafnosc(k, :)), max(trafnosc(k, :)));
end

sr = mean(trafnosc, 2);
figure('Color', 'w');
bar(sr, 'FaceColor', [0.3 0.5 0.8]); hold on
errorbar(1:numel(progi), sr, sr - min(trafnosc, [], 2), max(trafnosc, [], 2) - sr, 'k.', 'LineWidth', 1.2);
xticks(1:numel(progi)); xticklabels(string(progi));
ylim([0 70]); set(gca, 'FontSize', 10); grid on
xlabel('próg: co najmniej tyle wcześniejszych startów konia');
ylabel('trafione gonitwy [%]');
title('Las losowy, 300 drzew: średnia z 10 uruchomień (kreski: min–max)');
