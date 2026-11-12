T = readtable('cechy_partynice.csv', 'TextType', 'string');
N = 5;                                          % próg: liczba wcześniejszych startów konia
T = T(T.starty_przed >= N, :);

cechy = ["starty_przed" "odsetek_wygranych" "odsetek_top3" "srednia_wzgl" "mediana_wzgl" ...
         "srednia_wzgl_5" "ostatnie_wzgl" "dni_od_ostatniego" "starty_rok" "ranga_srednia_wzgl" ...
         "dystans_m" "liczba_koni" "wiek" "waga_kg"];
tren = T(T.zbior_2013 == "trening", :);
test = T(T.zbior_2013 == "test", :);

las = TreeBagger(300, tren(:, cechy), tren.wygral, 'Method', 'classification', ...
    'MinLeafSize', 5, 'OOBPrediction', 'on', 'OOBPredictorImportance', 'on');

[~, wynik] = predict(las, test(:, cechy));
test.p = wynik(:, strcmp(las.ClassNames, '1'));  % szansa wygranej każdego konia

% typ w gonitwie = koń z największą szansą
g = findgroups(test.race_id);
trafiona = splitapply(@(p, w) w(find(p == max(p), 1)) == 1, test.p, test.wygral, g);
fprintf('Trafione gonitwy: %.1f%%\n', 100 * mean(trafiona));

figure('Color', 'w');                            % ważność cech
bar(las.OOBPermutedPredictorDeltaError);
set(gca, 'TickLabelInterpreter', 'none'); xticks(1:numel(cechy)); xticklabels(cechy);
xlabel('cecha'); ylabel('wzrost błędu po przemieszaniu cechy'); title('Ważność cech w lesie losowym');

figure('Color', 'w');
plot(oobError(las));
xlabel('liczba drzew'); ylabel('błąd OOB'); title('Błąd lasu w zależności od liczby drzew');

view(las.Trees{1}, 'Mode', 'graph')