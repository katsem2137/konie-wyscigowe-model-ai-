% Czas uczenia lasu losowego w porównaniu z trafnością dla różnej liczby drzew.
% Dla każdej liczby drzew las uczy się 10 razy; z 10 prób liczymy średnią i rozrzut.

T = readtable('cechy_partynice.csv', 'TextType', 'string');
N = 5;                                          % próg: liczba wcześniejszych startów konia
T = T(T.starty_przed >= N, :);

cechy = ["starty_przed" "odsetek_wygranych" "odsetek_top3" "srednia_wzgl" "mediana_wzgl" ...
         "srednia_wzgl_5" "ostatnie_wzgl" "dni_od_ostatniego" "starty_rok" "ranga_srednia_wzgl" ...
         "dystans_m" "liczba_koni" "wiek" "waga_kg"];
tren = T(T.zbior_2013 == "trening", :);
test = T(T.zbior_2013 == "test", :);
g = findgroups(test.race_id);                   % numer gonitwy dla każdego wiersza testu

liczby_drzew = [50 100 200 300 500];
proby = 10;
czas = zeros(numel(liczby_drzew), proby);       % wiersz = liczba drzew, kolumna = próba
trafnosc = zeros(numel(liczby_drzew), proby);

rng(1);                                         % raz na początku: próby różnią się między sobą, ale całość da się powtórzyć
TreeBagger(10, tren(:, cechy), tren.wygral, 'Method', 'classification');  % rozgrzewka: pierwsze wywołanie jest wolniejsze (ładowanie funkcji), nie liczymy go
for k = 1:numel(liczby_drzew)
    for i = 1:proby
        tic
        las = TreeBagger(liczby_drzew(k), tren(:, cechy), tren.wygral, ...
            'Method', 'classification', 'MinLeafSize', 5);   % bez OOB, żeby mierzyć samo uczenie
        czas(k, i) = toc;

        [~, wynik] = predict(las, test(:, cechy));
        p = wynik(:, strcmp(las.ClassNames, '1'));          % szansa wygranej każdego konia
        trafiona = splitapply(@(p, w) w(find(p == max(p), 1)) == 1, p, test.wygral, g);
        trafnosc(k, i) = 100 * mean(trafiona);
    end
    fprintf('%3d drzew: czas %.2f s, trafność %.1f%% (min %.1f, max %.1f)\n', liczby_drzew(k), ...
        mean(czas(k, :)), mean(trafnosc(k, :)), min(trafnosc(k, :)), max(trafnosc(k, :)));
end

% wykres: średni czas (oś X) i średnia trafność (oś Y), kreski = odchylenie standardowe z 10 prób
sr_czas = mean(czas, 2);  sd_czas = std(czas, 0, 2);
sr_traf = mean(trafnosc, 2);  sd_traf = std(trafnosc, 0, 2);

figure('Color', 'w');
errorbar(sr_czas, sr_traf, sd_traf, sd_traf, sd_czas, sd_czas, 'o-', 'LineWidth', 1.2);
text(sr_czas + 0.01, sr_traf + 1.5, liczby_drzew + " drzew", 'FontSize', 10);
yline(14, '--', 'losowe typowanie', 'FontSize', 10);
yline(31, '--', 'koń z najlepszą średnią miejsca', 'FontSize', 10);
ylim([0 60]); xlim([0 0.5]);
set(gca, 'FontSize', 10);
xlabel('średni czas uczenia [s]'); ylabel('średnia trafność [% gonitw]');
title('Czas uczenia a trafność lasu losowego (10 prób na liczbę drzew)');
grid on
