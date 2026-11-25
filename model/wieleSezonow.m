T0 = readtable('cechy_partynice.csv', 'TextType', 'string');
cechy = ["starty_przed" "odsetek_wygranych" "odsetek_top3" "srednia_wzgl" "mediana_wzgl" ...
         "srednia_wzgl_5" "ostatnie_wzgl" "dni_od_ostatniego" "starty_rok" "ranga_srednia_wzgl" ...
         "dystans_m" "liczba_koni" "wiek" "waga_kg"];
progi = [3 5];
okno = Inf;
lata = 2014:2023;
proby = 5;
drzewa = 100;
nazwy = {'regresja logistyczna', 'las losowy', 'najlepsza średnia', 'losowo'};

tic
for ip = 1:numel(progi)
    prog = progi(ip);
    T = T0(T0.starty_przed >= prog & T0.kompletna == 1, :);
    wyniki = zeros(numel(lata), 6);

    for k = 1:numel(lata)
        tren = T(T.rok < lata(k) & T.rok >= lata(k) - okno, :);
        test = T(T.rok == lata(k), :);
        g = findgroups(test.race_id);

        Xtr = tren{:, cechy};
        Xte = test{:, cechy};
        mu = mean(Xtr);
        sg = std(Xtr);
        sg(sg == 0) = 1;
        mdl = fitglm((Xtr - mu) ./ sg, tren.wygral, 'linear', 'Distribution', 'binomial');
        p = predict(mdl, (Xte - mu) ./ sg);
        reg = 100 * mean(splitapply(@(p, w) w(find(p == max(p), 1)) == 1, p, test.wygral, g));

        lasy = zeros(1, proby);
        for i = 1:proby
            rng(i);
            las = TreeBagger(drzewa, tren(:, cechy), tren.wygral, 'Method', 'classification', 'MinLeafSize', 5);
            [~, wynik] = predict(las, test(:, cechy));
            p = wynik(:, strcmp(las.ClassNames, '1'));
            lasy(i) = 100 * mean(splitapply(@(p, w) w(find(p == max(p), 1)) == 1, p, test.wygral, g));
        end

        najlepsza = 100 * mean(splitapply(@(s, w) w(find(s == min(s), 1)) == 1, test.srednia_wzgl, test.wygral, g));
        losowo    = 100 * mean(splitapply(@(w) sum(w) / numel(w), test.wygral, g));

        wyniki(k, :) = [lata(k) max(g) reg mean(lasy) najlepsza losowo];
        fprintf('prog %d, sezon %d gotowy, %.0f s od startu\n', prog, lata(k), toc);
    end

    M = wyniki(:, 3:6);
    n = size(M, 1);
    srednia = mean(M);
    odch = std(M);
    ci = tinv(0.975, n - 1) * odch / sqrt(n);

    fprintf('\nPROG %d\n', prog);
    disp(array2table(wyniki, 'VariableNames', {'sezon', 'gonitw', 'regresja', 'las_losowy', 'najlepsza_srednia', 'losowo'}))
    disp(array2table([srednia; odch; min(M); max(M); ci], ...
        'VariableNames', {'regresja', 'las_losowy', 'najlepsza_srednia', 'losowo'}, ...
        'RowNames', {'srednia', 'odch_std', 'min', 'max', 'CI95_pol'}))

    d_reg = M(:, 1) - M(:, 3);
    d_las = M(:, 2) - M(:, 3);
    [~, p_reg] = ttest(d_reg);
    [~, p_las] = ttest(d_las);
    fprintf('regresja - najlepsza srednia: srednio %.1f pp, lepsza w %d z %d sezonow, p = %.2f\n', mean(d_reg), sum(d_reg > 0), n, p_reg);
    fprintf('las - najlepsza srednia: srednio %.1f pp, lepszy w %d z %d sezonow, p = %.2f\n', mean(d_las), sum(d_las > 0), n, p_las);

    f = figure('Color', 'w', 'Position', [50 50 1300 800]);
    tiledlayout(2, 2);

    nexttile
    plot(lata, M, '-o', 'LineWidth', 1.5);
    legend(nazwy, 'Location', 'best');
    xlabel('sezon testowy');
    ylabel('trafione gonitwy [%]');
    title(sprintf('Skuteczność w kolejnych sezonach (próg %d)', prog));
    grid on

    nexttile
    boxplot(M, 'Labels', nazwy);
    ylabel('trafione gonitwy [%]');
    title('Rozrzut skuteczności między sezonami');
    grid on

    nexttile
    bar(srednia);
    hold on
    errorbar(1:4, srednia, odch, 'k', 'LineStyle', 'none', 'LineWidth', 1.2);
    xticklabels(nazwy);
    ylabel('trafione gonitwy [%]');
    title(sprintf('Średnia z %d sezonów ± odch. std.', n));
    ylim([0 60]);
    grid on

    nexttile
    bar(lata, [d_reg d_las]);
    yline(0, 'k');
    legend({'regresja', 'las losowy'}, 'Location', 'best');
    xlabel('sezon testowy');
    ylabel('różnica względem najlepszej średniej [pp]');
    title('Czy model bije prostą regułę?');
    grid on

    exportgraphics(f, sprintf('porownanie_sezony_prog%d.png', prog), 'Resolution', 200);
    figure(f);
end