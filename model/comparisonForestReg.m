T0 = readtable('cechy_partynice.csv', 'TextType', 'string');
cechy = ["starty_przed" "odsetek_wygranych" "odsetek_top3" "srednia_wzgl" "mediana_wzgl" ...
    "srednia_wzgl_5" "ostatnie_wzgl" "dni_od_ostatniego" "starty_rok" "ranga_srednia_wzgl" ...
    "dystans_m" "liczba_koni" "wiek" "waga_kg"];
progi = [3 5 10 15];
podzial = "zbior_2013";
proby = 10;

wyniki = zeros(numel(progi), 5);
for k = 1:numel(progi)
    T = T0(T0.starty_przed >= progi(k), :);
    if podzial == "zbior_2013"
        tren = T(T.zbior_2013 == "trening", :);
        test = T(T.zbior_2013 == "test", :);
    else
        T = T(T.kompletna == 1, :);
        tren = T(T.rok == 2013 | T.rok == 2014, :);
        test = T(T.rok == 2015, :);
    end

    Xtr = tren{:, cechy};
    Xte = test{:, cechy};
    mu = mean(Xtr);
    sg = std(Xtr);
    sg(sg == 0) = 1;
    Xtr = (Xtr - mu) ./ sg;
    Xte = (Xte - mu) ./ sg;

    mdl = fitglm(Xtr, tren.wygral, 'linear', 'Distribution', 'binomial');
    test.p = predict(mdl, Xte);

    g = findgroups(test.race_id);
    trafiona  = splitapply(@(p, w) w(find(p == max(p), 1)) == 1, test.p, test.wygral, g);
    najlepsza = splitapply(@(s, w) w(find(s == min(s), 1)) == 1, test.srednia_wzgl, test.wygral, g);
    losowo    = splitapply(@(w) sum(w) / numel(w), test.wygral, g);

    wyniki(k, :) = [progi(k) max(g) 100*mean(trafiona) 100*mean(najlepsza) 100*mean(losowo)];
end

W = array2table(wyniki, 'VariableNames', {'prog', 'gonitw_testowych', 'regresja', 'najlepsza_srednia', 'losowo'});
disp(W)

figure('Color', 'w');
bar(wyniki(:, 3:5));
xticklabels(string(progi));
legend({'regresja logistyczna', 'najlepsza średnia', 'losowo'}, 'Location', 'northwest');
xlabel('próg: co najmniej tyle wcześniejszych startów konia');
ylabel('trafione gonitwy [%]');
title(sprintf('Podział: %s', podzial));
ylim([0 70]);
grid on
