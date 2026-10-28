function [H, S, G] = wczytaj_dane(folderDanych)
%WCZYTAJ_DANE Wczytuje bazę wyścigów z repo, bez kłusaków.
%   H - historia_koni_PL.csv:  1 wiersz = 1 start konia na dowolnym torze (całe kariery koni z Partynic)
%   S - starty_partynice.csv:  1 wiersz = 1 koń w 1 gonitwie na Partynicach
%   G - gonitwy_partynice.csv: 1 wiersz = 1 gonitwa na Partynicach
%   Do historii dopisuje kolumny do analizy: miejsce_m, wzgl, wygrana.

opcje = {'TextType', 'string', 'VariableNamingRule', 'preserve'};
H = readtable(fullfile(folderDanych, 'historia_koni_PL.csv'), opcje{:});
S = readtable(fullfile(folderDanych, 'starty_partynice.csv'), opcje{:});
G = readtable(fullfile(folderDanych, 'gonitwy_partynice.csv'), opcje{:});

% Kłusaki to inna dyscyplina (sulki, powożący) i inne konie, więc nie wchodzą do analizy
H = H(H.rasa ~= "klusak" & ~ismember(H.kategoria, ["kłusaki" "sulki"]), :);
S = S(S.rodzaj ~= "sulki", :);
G = G(G.rodzaj ~= "sulki", :);

% Koń, który nie ukończył (puste miejsce), liczy się jako ostatni w gonitwie
H.miejsce_m = H.miejsce;
nieUkonczyl = isnan(H.miejsce);
H.miejsce_m(nieUkonczyl) = H.liczba_koni(nieUkonczyl);

% Miejsce względne: 0 = zwycięzca, 1 = ostatni. Pozwala porównać gonitwy o różnej liczbie koni
% (4. miejsce na 5 koni to co innego niż 4. na 14).
H.wzgl = (H.miejsce_m - 1) ./ (H.liczba_koni - 1);
H.wygrana = double(H.miejsce == 1);
end
