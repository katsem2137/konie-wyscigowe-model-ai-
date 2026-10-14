# Źródła danych

| serwis | adres | co z niego jest | lata |
|---|---|---|---|
| koniewyscigowe.pl („Baza Koni Wyścigowych”, nieoficjalna) | https://koniewyscigowe.pl | Partynice: lista gonitw sezonu `/wyniki_gonitw?miasto=2&sezon=RRRR` i strony gonitw `/wyscig?w=ID`; strony koni `/horse/ID` (wszystkie starty konia, płeć, maść, pochodzenie) | 2013–2023 (historia koni 1998–2023) |
| torpartynice.pl (strona toru) | https://torpartynice.pl | sezon 2026: strony dni wyścigowych `/gonitwy/RRRR-MM-DD/` i programy PDF | 2026 |
| IMGW-PIB (dane publiczne) | https://danepubliczne.imgw.pl | dane dobowe ze stacji synoptycznej Wrocław (kod 351160424, Strachowice, ok. 10 km od toru): `dane_meteorologiczne/dobowe/synop/` | 2013–2023, 2026 do 30.09 |

## Z którego źródła jest wiersz

Wynika z daty, dlatego tabele nie mają osobnej kolumny ze źródłem.

- `starty_partynice.csv`, `gonitwy_partynice.csv`: 2013–2023 to koniewyscigowe.pl, a 2026 to torpartynice.pl. Widać to też
  po `race_id`: z koniewyscigowe.pl jest to numer z adresu strony (np. 18947), z torpartynice.pl RRRRMMDDNN, czyli data
  i numer gonitwy w dniu (np. 2026100402).
- `program_2026_partynice.csv`: programy PDF z torpartynice.pl. Gdy z PDF nie dało się odczytać gwiazdek, wzięto je ze
  strony toru (kolumna `gwiazdki_zrodlo`).
- `historia_koni_PL.csv`: strony koni z koniewyscigowe.pl.
- `pogoda_imgw_wroclaw.csv` i kolumny `imgw_*` w `gonitwy_partynice.csv`: IMGW-PIB. Kolumny `pogoda` i `temperatura_c`
  pochodzą ze stron gonitw (tor), nie z IMGW.

Źródłem pochodzenia danych jest Instytut Meteorologii i Gospodarki Wodnej – Państwowy Instytut Badawczy.
Dane Instytutu Meteorologii i Gospodarki Wodnej – Państwowego Instytutu Badawczego zostały przetworzone
(wybrana stacja i kolumny; status „8” = brak pomiaru → puste pole, status „9” = brak zjawiska → 0).

Wyniki w koniewyscigowe.pl kończą się na 2023, a torpartynice.pl pokazuje tylko bieżący sezon, stąd brak lat 2024–2025.
Dane koniewyscigowe.pl mają według samego serwisu „charakter nieoficjalny”.

## Jak pobierano

Strony pobrano w październiku 2026 (sezon 2026 do dnia wyścigowego 04.10.2026). Tabele zbudowały z nich skrypty
w Pythonie. Skrypty i pobrane strony (ok. 1,6 GB) zostają lokalnie, poza repozytorium.

Zasady: User-Agent `projekt-studencki-wyscigi/0.1 (niekomercyjny)`, co najmniej 5 s przerwy między żądaniami, do 3 ponowień
przy błędach sieci, każda strona pobierana tylko raz. robots.txt obu serwisów na to pozwala.
