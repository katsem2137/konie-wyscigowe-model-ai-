# Baza gonitw: Tor Partynice (Wrocław)

Dane do projektu z Metod sztucznej inteligencji: model przewiduje zwycięzcę gonitwy. Zgodnie ze wskazówkami prowadzącego
(14.10.2026, `TO DO .txt`) projekt korzysta tylko z danych polskich. Zbiory z Wielkiej Brytanii, pobrane na początku
jako zapas, nie są częścią bazy.

Główna tabela to **`starty_partynice.csv`**, w której 1 wiersz = 1 koń w 1 gonitwie. Znaczenie i typy kolumn, ich
dostępność w latach 2013–2023 i 2026, to, co jest znane przed startem, oraz znane braki opisuje **`SLOWNIK.md`**.

## Pliki

| plik | zawartość |
|---|---|
| `starty_partynice.csv` | starty koni na Partynicach: 2013–2023 z koniewyscigowe.pl, 2026 z torpartynice.pl |
| `gonitwy_partynice.csv` | 1 wiersz = 1 gonitwa (warunki, pogoda, stan toru, czas, uwagi o kompletności) |
| `program_2026_partynice.csv` | z programów 2026: numer startowy, OS (dni od ostatniego startu), ocena toru ★, konie wycofane |
| `historia_koni_PL.csv` | wszystkie starty tych samych koni ze stron koniewyscigowe.pl, 1998–2023, na każdym torze (ok. 97% polskie) |
| `pogoda_imgw_wroclaw.csv` | 1 wiersz = 1 dzień: temperatura, opad, czas deszczu i usłonecznienie ze stacji IMGW Wrocław, 2013–2023 i 2026 do 30.09 |
| `SLOWNIK.md` | opis i typy kolumn, co ujednolicono przy budowie, jak liczyć starty koni, znane braki |
| `ZRODLA.md` | skąd są dane: serwisy, adresy, lata, zasady pobierania |
| `kontrola_jakosci.txt` | liczby z ostatniej budowy tabel (zwycięzcy, braki, nieukończenia, duplikaty, dopasowania koni) |
| `TO DO .txt` | wskazówki prowadzącego do analizy danych (14.10.2026) |

Przyrostek w nazwie pliku: `_partynice` = tylko tor Partynice (Wrocław), `_PL` = starty tych koni z całej Polski
(ok. 3% to tory zagraniczne).

## Zakres

- **Lata 2013–2023 i 2026.** Lat 2024–2025 brakuje w obu źródłach: koniewyscigowe.pl kończy się na 2023,
  a torpartynice.pl pokazuje tylko bieżący sezon.
- **Sezon 2026 jest w bazie do 04.10.2026.** Ostatnie dni wyścigowe sezonu (18.10 i 11.11.2026) dojdą po przebudowie tabel.
- **`historia_koni_PL.csv` obejmuje tylko konie, które choć raz biegły na Partynicach** (2013–2023 albo 2026), za to
  z ich startami na wszystkich torach. To nie jest spis wszystkich polskich koni.
- **Pogoda z IMGW jest dla każdego dnia wyścigowego** (poza 04.10.2026, bo IMGW nie opublikował jeszcze października).
  Uzupełnia pogodę i temperaturę ze stron gonitw, których w latach 2013–2015 często brakuje. Źródłem pochodzenia tych
  danych jest Instytut Meteorologii i Gospodarki Wodnej – Państwowy Instytut Badawczy; dane zostały przetworzone.
- Kursów totalizatora nie podaje żadne z dwóch źródeł. Punktem odniesienia są gwiazdki ★ z programów 2026 (patrz `SLOWNIK.md`).

## Odczyt

Pliki są w UTF-8 ze znacznikiem BOM, separatorem jest przecinek, a w liczbach jest kropka dziesiętna.

- Python: `pd.read_csv("starty_partynice.csv")` (ścieżka względem tego folderu).
- Excel: Dane → Z pliku tekstowego/CSV. Excel sam rozpozna polskie znaki i przecinek. Dwukrotne kliknięcie na Windowsie
  z polskimi ustawieniami szuka średników zamiast przecinków i wrzuca cały wiersz do jednej kolumny.

Skąd są dane i jak je pobierano, opisuje `ZRODLA.md`.
