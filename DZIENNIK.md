# Dziennik projektu

Model przewidujący zwycięzcę gonitwy na torze Partynice we Wrocławiu. Metody sztucznej inteligencji, II semestr
studiów magisterskich.

## Lab 1 – 7.10.2026: temat projektu

- Temat: model, który przed gonitwą szacuje szansę wygranej każdego konia i na tej podstawie typuje zwycięzcę.
  Dane z toru Partynice.
- Rozpoznanie źródeł danych: koniewyscigowe.pl (archiwum wyników do 2023 r.), torpartynice.pl (bieżący sezon),
  zbiory z Wielkiej Brytanii z Kaggle jako zapas.
- Narzędzie dowolne, prowadzący polecał Pythona i MATLAB-a.

## Lab 2 – 14.10.2026: przygotowanie bazy danych

**Przed zajęciami**

- Pobrane wyniki gonitw z Partynic z lat 2013–2023 (koniewyscigowe.pl) i z sezonu 2026 (torpartynice.pl) oraz
  całe kariery koni, które tam biegały, ze wszystkich torów (1998–2023).
- Baza w plikach CSV: `starty_partynice.csv` (1 wiersz = 1 koń w 1 gonitwie), `gonitwy_partynice.csv`
  (1 wiersz = 1 gonitwa), `program_2026_partynice.csv` (z programów PDF: numer startowy, dni od ostatniego startu,
  gwiazdki ★) i `historia_koni_PL.csv` (starty tych koni na wszystkich torach).
- Kontrola jakości (`kontrola_jakosci.txt`): jeden zwycięzca w gonitwie, brakujące miejsca, duplikaty, spójność
  identyfikatorów koni, wiarygodność czasów.

**Uwagi prowadzącego** (`TO DO .txt`)

- Tylko konie z Polski, więc zbiory z Wielkiej Brytanii zostały odłożone.
- Wybrać konie z największą liczbą startów.
- EDA z dużą liczbą wykresów: liczba startów na konia, okres startów, histogramy miejsc, stan toru w kolejnych
  latach.
- Okno przeszłości konia (3 lata, 100 startów albo pół sezonu) i statystyka z tego okna (średnia, mediana,
  dominanta).

**Po zajęciach**

- Ujednolicony zapis: kodowanie znaków, nazwy koni i osób, scalone identyfikatory tej samej osoby zapisanej
  na różne sposoby.
- Pogoda z IMGW (stacja Wrocław-Strachowice) dla każdego dnia wyścigowego. Zgodność z temperaturą podawaną
  przez tor: r = 0,96.
- Opis bazy: `README.md`, `SLOWNIK.md` (kolumny, typy, co jest znane przed startem, znane braki) i `ZRODLA.md`.
- Repozytorium na GitHubie.

**Ograniczenia bazy**: w obu źródłach brakuje lat 2024–2025, a kursów totalizatora nie podaje żadne źródło.
W 2026 r. punktem odniesienia mogą być gwiazdki ★ z programów.

## Lab 3 – 28.10.2026: wizualizacje (EDA)

**Przed zajęciami**

- Poprawki bazy: usunięte duplikaty startów w historii koni, odpięte starty „imienników” (koń miałby wtedy ponad
  20 lat) i wyczyszczony sprzeczny stan toru z 8.07.2020. Opis w `SLOWNIK.md`, w części „Znane braki”.
- Skrypty MATLAB-a w `eda/` i 13 wykresów w `eda/wykresy/`.
- Prezentacja z wykresami.

**Wnioski z danych**

- Połowa koni ma najwyżej 6 startów, typowa kariera trwa krócej niż rok, a koń startuje mniej więcej co 3 tygodnie.
- Najczęściej w gonitwie biegnie 7 koni. Do porównań lepsze jest miejsce względne (0 = zwycięzca, 1 = ostatni).
- Stan toru wyraźnie zmienia się z roku na rok. Pomiar toru skacze w 2016 r., a jesienią tor jest bardziej miękki.
- Okno przeszłości: pół sezonu (105 dni) zostawia 31% startów bez historii konia, 3 lata to prawie cała historia,
  a 100 startów to cała historia.
- Punkt odniesienia: koń z najlepszą średnią albo medianą miejsca z przeszłości wygrywa w ok. 30% gonitw,
  a losowe typowanie trafia w 13,2%.
- Sezon 2026: przez lukę 2024–2025 historię konia sprzed 2026 r. ma tylko 110 z 515 startów.
