# Słownik kolumn

Opis tabel z tego folderu. To dane polskie: tor Partynice i historia startujących tam koni. Zbiory z Wielkiej Brytanii
nie są częścią bazy (prowadzący, 14.10.2026: tylko konie z Polski).

Skąd są dane, opisuje `ZRODLA.md`. Źródło wiersza wynika z daty: 2013–2023 to koniewyscigowe.pl, 2026 to torpartynice.pl.

Pusta komórka oznacza, że źródło tego nie podaje albo pole nie dotyczy. Kolumny oznaczone **(wyliczone)** liczy skrypt.

## Zanim zbudujesz model

**Moment prognozy:** chwila startu, czyli po wycofaniach. Wtedy znane są wszystkie kolumny z rolą **cecha**.

**Role kolumn** (kolumna „rola” w tabelach niżej):
- **cecha**: znana przed startem, można jej używać w modelu.
- **wynik**: znana dopiero po biegu. Nie wolno jej używać jako cechy tej samej gonitwy. Służy jako cel (`wygral`) albo do liczenia historii z gonitw **wcześniejszych**, np. „ile razy koń wygrał przed tą datą”.
- **meta**: identyfikatory i opis jakości danych (np. `kompletna`, `uwagi`). Służą do łączenia, filtrowania i liczenia statystyk z przeszłości, a nie jako cechy wprost.

**Kolejność wierszy nic nie znaczy.** W gonitwie wiersze leżą alfabetycznie po `kon_klucz`, a nie w kolejności na mecie ani po numerze startowym. Numer to osobna cecha, a „pierwszy wiersz” nie powinien jej po cichu powtarzać. Gdy model da kilku koniom tę samą ocenę (remis), losuj albo licz trafienie jako 1/k (k = liczba koni z najwyższą oceną). Nie bierz „pierwszego z brzegu” (`idxmax`, `drop_duplicates`, `groupby().first()`).

**Ocena modelu:**
- Cel to `wygral`. Licz trafienia per gonitwa: czy koń z najwyższą oceną wygrał.
- Trening i test dziel po czasie (sezony 2023 i wcześniejsze → 2026), nie losowo.
- `gwiazdki` z programu 2026 to **punkt odniesienia na zbiorze testowym, nie cecha modelu**. Model, który nie trafia częściej niż reguła „koń z największą liczbą gwiazdek” (remisy 1/k), niczego nie wnosi.

## Typy kolumn

Typ w pliku CSV to nie zawsze typ do analizy: liczba bywa identyfikatorem, a tekst kategorią.

- **Liczby:** `dystans_m`, `pula`, `stan_toru_liczba`, `liczba_koni`, `liczba_koni_wg_listy`, `wiek`, `waga_kg`,
  `temperatura_c`, `czas_zwyciezcy_s`, `wygrana_kwota`, `os_dni`, `miejsce` (porządkowa: 1 = zwycięzca), pogoda IMGW:
  `imgw_temp_max_c`, `imgw_temp_sr_c`, `imgw_opad_mm`, `temp_max_c`, `temp_min_c`, `temp_sr_c`, `opad_mm`,
  `czas_deszczu_h`, `uslonecznienie_h`.
- **Kategorie z porządkiem:** `stan_toru` (lekki → lekko elastyczny → elastyczny → mocno elastyczny → ciężki; to samo
  liczbowo w `stan_toru_liczba`), `gwiazdki` (1–5).
- **Kategorie:** `tor`, `rodzaj`, `rasa`, `kategoria` (grupy I–IV oraz A, B, L A), `plec`, `masc`, `kraj`, `pochodzenie`,
  `pogoda`, `styl`, `jezdziec_kat`, `status`, `powod_kategoria`, `gwiazdki_zrodlo`.
- **0/1:** `gonitwa_uczniowska`, `kompletna`, `okulary`, `nie_ukonczyl`, `wygral`, `top3`, `wycofany`, `debiut`.
- **Identyfikatory:** `race_id`, `horse_id`, `jezdziec_id`, `trener_id`, `zwyciezca_id`, `kon_klucz`. To liczby (poza
  `kon_klucz`), ale nie do liczenia: średnia z `horse_id` nic nie znaczy, a model, który dostanie je jako liczby,
  znajdzie w nich fałszywy porządek.
- **Numery porządkowe:** `numer_startowy`, `nr_w_dniu`, `nr_w_sezonie`, `dzien`.
- **Daty i godziny:** `data` (RRRR-MM-DD), `data_ur`, `rok_ur`, `godzina`.
- **Tekst:** `nazwa_gonitwy`, `warunki`, `uwagi`, `powod`, `kon`, `jezdziec`, `trener`, `zwyciezca`.
- **Tekst do przeliczenia, jeśli będzie potrzebny:** `odleglosc` (½, szyja, łeb, nos…), `czas_zwyciezcy` (liczbowo
  w `czas_zwyciezcy_s`), `nagrody` (lista kwot).

## Co ujednolicono i oczyszczono przy budowie

- **Etykiety:** pogoda małymi literami („pochmurno” → „pochmurnie”, „opady przelotne” → „przelotne opady”), kraj PL → POL,
  warianty pisowni torów (np. Hoppergaten → Hoppegarten), skróty maści z programów 2026 rozwinięte do pełnych słów.
- **Zapis tekstu:** jedna postać znaków Unicode (NFC). Wcześniej np. „B. Novák” był zapisany na dwa sposoby i wyglądał
  w danych jak dwie osoby. Naprawione krzaki („S. Kov√°≈ô” → „S. Kovář”), typograficzne apostrofy, cudzysłowy i półpauzy
  zamienione na zwykłe (’ → ', – → -), literówka ze strony toru „pĺus” → „plus”. Polskie i obce litery (ą, ł, š, ř…)
  zostają; wersja nazwy konia bez znaków diakrytycznych to `kon_klucz`.
- **Jedna nazwa na jedno ID** konia, jeźdźca i trenera, np. „S. Mokrosova” → „S. Mokrošová”, „P. Poles (CZE)” → „P. Poles”,
  „A. Frontczak - Salivonchyk” → „A. Frontczak-Salivonchyk”. Nazwy koni pisane przez stronę toru wielkimi literami są
  zapisane jak w koniewyscigowe.pl („GO CANADA” → „Go Canada”).
- **Jedno ID na jedną osobę.** koniewyscigowe.pl zakładał nowy numer osoby, gdy nazwisko wpisano inaczej (spacje, krzaki,
  inny zapis litery). Takie numery scalono z głównym: trener 84 ← 232, 339 (A. Frontczak-Salivonchyk), 307 ← 362
  (S. Kovář); jeździec 88 ← 729 (B. Novák), 784 ← 865 (H. Bagiński). Dzięki temu 17 startów z 2026 dostało `trener_id`
  albo `jezdziec_id`. Jeden trener z wieloma końmi to oczywiście norma; chodziło o jedną osobę pod kilkoma numerami.
- **Pogoda:** w 2014 temperatura była wpisana w pole pogody („pogodnie; temp. +20 c”), teraz jest w `temperatura_c`.
  W 2015 siedem gonitw miało zamiast pogody samo słowo „pogoda”; te pola są puste.
- **Remis na mecie:** gdy wygrały dwa konie, `zwyciezca` ma postać „Kankan i Olimp”.
- **Jednostki** są w nazwach kolumn: metry (`dystans_m`), kilogramy (`waga_kg`), złote (`pula`, `wygrana_kwota`),
  °C (`temperatura_c`), sekundy (`czas_zwyciezcy_s`, przeliczone z zapisu 1'45.00).
- **Wartości niemożliwe:** czas zwycięzcy „0'00.00” (brak pomiaru) i czasy fizycznie niewiarygodne (średnio > 19 m/s,
  literówka na stronie) mają puste `czas_zwyciezcy_s`, a powód stoi w `uwagi`.
- **Gonitwy z dziurami w wynikach** mają `kompletna=0` (brak miejsc, dwóch zwycięzców, mniej koni niż na liście sezonu).
- **Duplikaty:** żadna para (`race_id`, `horse_id`) ani (`race_id`, `kon_klucz`) nie występuje dwa razy
  (`kontrola_jakosci.txt`).
- **Wyliczone ze źródła:** `rasa` i `rodzaj` z warunków gonitwy, `status` i `powod_kategoria` z oznaczeń na stronie,
  `stan_toru_liczba` z nawiasu przy stanie toru.

Czego **nie** zrobiono: braki nie są uzupełniane (pusta komórka = źródło tego nie podaje), wartości odstające nie są
usuwane, nic nie jest skalowane. To decyzje do analizy danych i modelu.

## Liczenie startów i wybór koni

- **Koń to `horse_id`.** W 2026 część startów nie ma `horse_id` (konia nie znaleziono w koniewyscigowe.pl). Wtedy
  zostaje `kon_klucz` (nazwa i rok urodzenia). Licząc starty na konia, nie gub tych wierszy po cichu.
- **Nie sumuj obu tabel.** Wszystkie starty z Wrocławia 2013–2023 ze `starty_partynice.csv` są drugi raz
  w `historia_koni_PL.csv`. Starty konia licz albo z historii (wszystkie tory), albo ze startów (tylko Partynice).
- **Historia to tylko konie z Partynic:** są w niej wszystkie starty koni, które choć raz biegły na Partynicach, ale nie
  ma koni spoza tej grupy.
- **Kraj konia:** w 2026 kolumna `kraj` (np. POL, IRE), w historii `pochodzenie` (słownie). Dla 2013–2023 `kraj`
  w `starty_partynice.csv` jest pusty, więc kraj bierz z historii po `horse_id`.
- **Tory polskie i zagraniczne** rozróżnia kolumna `tor` w historii (ok. 3% startów to tory zagraniczne).
- **Dyscypliny** rozdzielają `rodzaj` (`plaska`, `ploty`, `steeple`, `sulki`) i `rasa`. Kłusaki (`sulki`,
  `rasa=klusak`) ciągną sulki z powożącym, więc nie mają `waga_kg`, a `jezdziec_kat` to u nich `pow.`.
- **Warunki na torze** (`stan_toru`, `stan_toru_liczba`, `pogoda`, `temperatura_c`) są tylko w tabelach Partynic.
  Historia startów z innych torów ich nie ma. Pogoda z IMGW (`imgw_*`, `pogoda_imgw_wroclaw.csv`) też dotyczy tylko
  Wrocławia.

## starty_partynice.csv: 1 wiersz = 1 koń w 1 gonitwie (główna tabela)

Konie wycofane przed startem nie mają tu wierszy (są w `program_2026_partynice.csv` z `wycofany=1`).

| kolumna | co znaczy | 2013–2023 | 2026 | rola | przykład |
|---|---|---|---|---|---|
| race_id | ID gonitwy. 2013–2023: numer z adresu strony koniewyscigowe.pl; 2026: RRRRMMDDNN (data + nr w dniu) | tak | tak | meta | 18947, 2026100402 |
| data | data gonitwy (RRRR-MM-DD) | tak | tak | meta (czas) | 2023-04-23 |
| tor | miasto toru | tak | tak | cecha | Wrocław |
| nr_w_sezonie | kolejny numer gonitwy w sezonie (2026: kod „W73” z nagłówka) | tak | tak | meta | 3 |
| nazwa_gonitwy | nazwa nagrody; puste = bez nazwy | część | część | cecha | Nagroda z Energys |
| dystans_m | dystans w metrach; u kłusaków podstawowy (handikap 2400/2420/2440 m nie jest rozpisany na konie) | tak | tak | cecha | 1907 |
| rodzaj | `plaska`, `ploty`, `steeple`, `sulki` (kłusaki). 2013–2023: z listy sezonu; 2026: z warunków **(wyliczone)**; ta reguła na 2013–2023 zgadza się z listą w 1147/1150 (inaczej: 290, 14646, 15070) | tak | tak | cecha | ploty |
| rasa | rasa dopuszczona do gonitwy, **wyliczona z warunków**: `oo` („czystej krwi arabskiej”), `klusak`, `xx/polkrew` (warunki wymieniają półkrew), `xx` (brak wzmianki; tak piszą się warunki dla pełnej krwi) | tak | tak | cecha | xx |
| kategoria | grupa I–IV; `A`, `B` = kategorie z nazwy lub strony; puste u przeszkodowych, kłusaków i gonitw bez grupy | część | część | cecha | III |
| gonitwa_uczniowska | 1 = gonitwa uczniowska (z warunków) **(wyliczone)** | tak | tak | cecha | 0 |
| pula | pula nagród w zł | tak | tak | cecha | 14000 |
| stan_toru | stan toru słownie (u przeszkodowych: tor płotowy/przeszkodowy) | tak | bez 13.09 | cecha | elastyczny |
| stan_toru_liczba | pomiar w nawiasie przy stanie toru (wyżej = bardziej miękko) | tak | bez 13.09 | cecha | 3.9 |
| liczba_koni | liczba koni w chwili startu, po wycofaniach (= liczba wierszy gonitwy) **(wyliczone)** | tak | tak | cecha | 7 |
| kompletna | 1 = wyniki gonitwy kompletne (jeden zwycięzca, wszystkie konie, bez dziur w miejscach) **(wyliczone)** | tak | tak | meta | 1 |
| numer_startowy | numer konia w programie | nie | tak | cecha | 3 |
| horse_id | ID konia w koniewyscigowe.pl (`/horse/ID`). 2026: z linku na stronie toru, z linku innego startu tego konia, albo po nazwie i roku urodzenia; puste = nie znaleziono | tak | część | meta | 35260 |
| kon_klucz | zapasowy identyfikator konia: nazwa znormalizowana \| rok urodzenia (z wieku) **(wyliczone)** | tak | tak | meta | trurl\|2020 |
| kon | nazwa konia jak na stronie (torpartynice pisze część nazw wielkimi literami) | tak | tak | meta | Trurl |
| kraj | kraj pochodzenia (PL ujednolicone do POL) | nie | tak | cecha | FR |
| plec | ogier / klacz / wałach. 2013–2023: ze strony konia, czyli stan z dnia pobrania (10.2026) | tak | tak | cecha | ogier |
| masc | maść pełnym słowem (2013–2023: ze strony konia; 2026: skróty z legendy programu rozwinięte) | tak (97%) | tak | cecha | gniady |
| okulary | 1 = koń biegnie w okularach | nie | tak | cecha | 0 |
| wiek | wiek w latach | tak | tak | cecha | 3 |
| waga_kg | waga niesiona; u kłusaków puste (nie dotyczy) | tak | tak | cecha | 59.0 |
| jezdziec_id | ID jeźdźca w koniewyscigowe.pl (`/dzokej?d=ID`); 2026: z linku albo po nazwie | tak | część | meta | 4 |
| jezdziec_kat | `dż.` dżokej, `k. dż.` kandydat dżokejski, `pr. dż.` praktykant, `st. u.` starszy uczeń, `u.` uczeń, `am. …` amator, `pow.` powożący (kłusaki). Uwaga: patrz „Znane braki” | tak | tak | cecha | dż. |
| jezdziec | jeździec (inicjał i nazwisko) | tak | tak | meta | N. Hendzel |
| trener_id | ID trenera w koniewyscigowe.pl (`/trener?t=ID`); 2026: po nazwie, bez dopisku kraju „(CZE)” | tak | część | meta | 336 |
| trener | trener | tak | tak | meta | P. Pałczyński |
| miejsce | zajęte miejsce; puste = nie ukończył albo dyskwalifikacja | tak | tak | wynik | 1 |
| nie_ukonczyl | 1 = brak sklasyfikowanego miejsca **(wyliczone)** | tak | tak | wynik | 0 |
| status | `ukonczyl`, `nie_ukonczyl`, `dyskwalifikacja`: z oznaczenia na stronie (miejsce; „D”; „0” albo „(nie ukończył)”) | tak | tak | wynik | ukonczyl |
| powod | opis sędziów przy koniu (np. „Upadek jeźdźca”); patrz „Znane braki” | nie | tak | wynik | Upadek jeźdźca |
| powod_kategoria | ujednolicona przyczyna: upadek, zatrzymany, pomylona trasa, pozostał na starcie, zwolniony przez startera, kłusak: galop, kłusak: chód inny niż kłus, nie ukończył (bez przyczyny), inne **(wyliczone)** | nie | tak | wynik | upadek |
| odleglosc | strata do konia przed nim, w długościach (½, szyja, łeb, nos, „daleko (30)”) | tak | tak | wynik | 5½ |
| wygrana_kwota | nagroda konia w zł; 2026 **wyliczona** z podziału nagród według miejsca | tak | tak | wynik | 7000 |
| czas_zwyciezcy | czas zwycięzcy w zapisie ze strony (w sekundach: `gonitwy_partynice.csv`) | tak | tak | wynik | 2'06.50 |
| wygral | 1 = miejsce 1. **CEL MODELU** **(wyliczone)** | tak | tak | wynik | 1 |
| top3 | 1 = miejsce 1–3 **(wyliczone)** | tak | tak | wynik | 1 |

## gonitwy_partynice.csv: 1 wiersz = 1 gonitwa

Kolumny wspólne ze `starty_partynice.csv` znaczą to samo i mają tę samą rolę. Dodatkowo:

| kolumna | co znaczy | 2013–2023 | 2026 | rola |
|---|---|---|---|---|
| dzien | dzień wyścigowy sezonu (1, 2, …) | tak | tak | meta |
| nr_w_dniu | numer gonitwy w dniu | nie | tak | meta |
| godzina | godzina startu | nie | tak | cecha |
| nagrody | podział puli na miejsca, zwykle 5 kwot, raz 7 | nie | tak | cecha |
| pogoda | pogoda słownie, małymi literami („pochmurno” ujednolicone do „pochmurnie”) | tak (2013: 57%, 2015: 94%) | tak | cecha |
| temperatura_c | temperatura powietrza w °C | od 2016 (2013: 7%, 2014: 43%, 2015: 35%) | tak | cecha |
| liczba_koni_wg_listy | „l.koni” z listy sezonu; porównaj z `liczba_koni` | tak | nie | meta |
| czas_zwyciezcy_s | czas zwycięzcy w sekundach **(wyliczone)**; puste, gdy strona podaje 0'00.00 (brak pomiaru) albo czas fizycznie niewiarygodny (średnio > 19 m/s, literówka na stronie); powód jest w `uwagi` | tak | tak | wynik |
| styl | styl wygranej (łatwo, pewnie, wysyłany…) | tak | tak | wynik |
| zwyciezca, zwyciezca_id | nazwa i ID zwycięzcy | tak | tak | wynik |
| uwagi | problemy z wynikami (to one dają `kompletna=0`) oraz drobne braki i notatki (np. „strona nie podaje stanu toru”, „8 z 9 koni bez miejsca”) | tak | tak | meta |
| warunki | pełny tekst warunków gonitwy | tak | tak | cecha (tekst) |
| imgw_temp_max_c | maksymalna temperatura dnia gonitwy, stacja IMGW Wrocław (z `pogoda_imgw_wroclaw.csv`) | tak | bez 04.10 | cecha* |
| imgw_temp_sr_c | średnia temperatura dnia gonitwy, IMGW | tak | bez 04.10 | cecha* |
| imgw_opad_mm | suma dobowa opadu w dniu gonitwy, IMGW | tak | bez 04.10 | cecha* |

\* Wartości dobowe IMGW obejmują też godziny po gonitwie (np. deszcz wieczorem). Jako cecha to przybliżenie prognozy
pogody; ściśle „przed startem” są dni poprzednie z `pogoda_imgw_wroclaw.csv`.

## program_2026_partynice.csv: 1 wiersz = 1 koń zgłoszony w programie 2026 (także wycofany)

Łączenie ze `starty_partynice.csv` po parze (`race_id`, `numer_startowy`). Wiersze w gonitwie leżą alfabetycznie po `kon_klucz`.

| kolumna | co znaczy | rola |
|---|---|---|
| race_id, data, nr_w_dniu, nr_w_sezonie, numer_startowy | jak wyżej | meta |
| horse_id, kon_klucz, kon, kraj | jak w `starty_partynice.csv` | meta / cecha (kraj) |
| wycofany | 1 = wycofany przed startem (nie ma go w `starty_partynice.csv`) | meta |
| os_dni | „OS”: liczba dni od ostatniego startu (z programu PDF); puste = debiut albo nieodczytane | cecha |
| debiut | 1 = „OS: -” (pierwszy start), 0 = jest liczba dni, puste = nieodczytane z PDF | cecha |
| gwiazdki | ocena toru ★ 1–5 („im więcej, tym koń ma więcej szans na zwycięstwo”) z programu PDF wydanego przed gonitwą | **punkt odniesienia na zbiorze testowym, nie cecha** |
| gwiazdki_zrodlo | `pdf` albo `strona` (zapas, gdy z PDF nie dało się odczytać); na 558 wpisach z obu źródeł wartości są równe | meta |

## historia_koni_PL.csv: 1 wiersz = 1 start konia na dowolnym torze z jego strony

Źródło: strony koni koniewyscigowe.pl (`/horse/ID`), starty z lat 1998–2023 (ok. 97% w Polsce: Warszawa, Wrocław, Sopot;
reszta za granicą). Starty z Wrocławia 2013–2023 są tu drugi raz, te same co w `starty_partynice.csv`. Konie, które zaczęły po 2023,
mają puste strony (ID istnieje, danych nie ma). W 2026 to 156 koni i 337 z 578 startów: ich formy sprzed 2026 baza nie zna.
To materiał do budowania cech z **przeszłości** (forma, liczba startów, wygrane). Licz je zawsze tylko ze startów sprzed
daty prognozowanej gonitwy.

| kolumna | co znaczy |
|---|---|
| horse_id, kon | koń |
| rasa | z metryczki: `xx`, `oo`, `klusak`, `polkrew` (inne opisy zostają słownie) |
| pochodzenie, data_ur, rok_ur, plec | kraj słownie; data urodzenia (pusta, gdy strona podaje tylko rok); rok urodzenia; płeć (stan z dnia pobrania strony) |
| data, tor, race_id, dystans_m | start: data, miasto toru (warianty pisowni ujednolicone, np. Hoppergaten → Hoppegarten), ID gonitwy, dystans |
| kategoria | kolumna „kat.” ze strony konia: grupa (I–IV, A…) albo płoty / steeple / sulki |
| jezdziec_id, jezdziec_kat, jezdziec, waga_kg, trener_id, trener | jak w `starty_partynice.csv` |
| miejsce, nie_ukonczyl, liczba_koni, wygrana_kwota | wynik tamtego startu (strona pisze „miejsce / liczba koni”) |

## pogoda_imgw_wroclaw.csv: 1 wiersz = 1 dzień (stacja IMGW Wrocław)

Wszystkie dni lat 2013–2023 i 2026 do 30.09 (październik 2026 IMGW jeszcze nie opublikował). Łączenie z gonitwami po
kolumnie `data`. Dni przed gonitwą pozwalają policzyć np. opad z kilku poprzednich dni, który może wpływać na stan toru.
Status IMGW „8” (brak pomiaru) = puste pole, „9” (brak zjawiska) = 0.

| kolumna | co znaczy |
|---|---|
| data | dzień (RRRR-MM-DD) |
| temp_max_c, temp_min_c, temp_sr_c | maksymalna, minimalna i średnia dobowa temperatura powietrza [°C] |
| opad_mm | suma dobowa opadu [mm] |
| czas_deszczu_h | czas trwania opadu deszczu [h] |
| uslonecznienie_h | usłonecznienie [h]; 4 dni bez pomiaru |

Kontrola dopasowania: na 980 gonitwach, które mają też temperaturę ze strony toru, korelacja `temperatura_c`
z `imgw_temp_max_c` wynosi 0,96. Tor podaje średnio o 2,4 °C mniej niż maksimum dnia, co pasuje do gonitw w ciągu dnia.
Stacja stoi ok. 10 km od toru.

## Znane braki i niespójności

- **2013–2023: 1152 gonitwy z list sezonów.** Dwie mają na serwerze pustą stronę (18514, 18958), 28 ma `kompletna=0`
  (dziury w miejscach albo mniej koni niż „l.koni”), a 14152 ma dwa konie na 1. miejscu. Pełna lista jest w `kontrola_jakosci.txt`.
- Strony klaczy i ogierów z potomstwem mają dwie tabele o tym samym `id="wykaz"`: wykaz startów i potomstwo. Skrypt bierze
  tylko wykaz startów (nagłówek „data, tor”). Kontrola liczy wiersze historii z datą spoza formatu; ma być 0.
- **2023: lista sezonu ma 96 gonitw** (numery 1–97, bez nr 20). Gonitwa nr 14 (race_id 18958, 01.05.2023, 9 koni) ma na
  serwerze pustą stronę, więc jej koni nie ma (`kompletna=0`).
- **2023: w 7 gonitwach baza ma o 1–2 konie mniej niż „l.koni” z listy** (19004, 19006, 19008, 19010, 19084, 19091, 19092;
  `kompletna=0`). Miejsca mają tam dziury, a `miejsce` bywa większe niż liczba wierszy (19008: miejsca do 6 przy 5 wierszach;
  19092: do 5 przy 4).
- `odleglosc` u zwycięzcy jest pusta, u nieukończonych zwykle też, ale w 2023 bywa wpisana (19010, 19225, 19226, 19461).
- `status` pochodzi z oznaczenia na stronie, a `powod` to opis sędziów i może mówić co innego. Przykład: kłusak oznaczony
  „(nie ukończył)” z powodem „Dyskwalifikacja za galop…”. Do analiz używaj `status` albo `powod_kategoria`.
- **Gonitwy uczniowskie** (`gonitwa_uczniowska=1`, 8 w 2023 i 8 w 2026): w 2023 `jezdziec_kat` jest tam prawdopodobnie klasą
  ulgi wagi, nie kategorią jeźdźca. Np. M. Zholchubekov ma „k. dż.” w gonitwach uczniowskich 19012 i 19014, a „u.”
  w 19013, 19015 i 19016.
- `kraj` dla 2013–2023 jest pusty, bo strony gonitw koniewyscigowe go nie podają (kraj słownie jest w `historia_koni_PL.csv`
  jako `pochodzenie`).
- 13.09.2026: strona toru nie podaje stanu toru (8 gonitw; w `uwagi`).
- 2026052405: lista odległości nie zgadza się z liczbą koni na mecie, więc odległości są puste (w `uwagi`).
- 2026060406: 8 z 9 koni bez miejsca, większość pomyliła trasę (w `uwagi`).
- Ten sam koń bywa na stronie toru raz z linkiem do koniewyscigowe, raz bez. Skrypt przenosi wtedy ID z innego startu
  (ta sama nazwa i rok urodzenia albo ta sama nazwa i kraj). Testy spójności dają w 2026 zero rozjazdów.
  Wyjątek: Jogurt w gonitwie 2026050105 ma na stronie kraj FR i 5 lat, a w pozostałych startach POL i 7 lat (ten sam
  powożący i trener). To najpewniej błąd strony, ale dane się różnią, więc skrypt nie łączy go automatycznie
  i ten start zostaje bez `horse_id`.
- Wypłaty totalizatora (ZWC, PDK…) są puste na wszystkich stronach 2023. Kursów nie ma w żadnym źródle.
