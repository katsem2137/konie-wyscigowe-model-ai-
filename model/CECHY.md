# Tabela do modelu: `cechy_partynice.csv`

1 wiersz = 1 koń w 1 gonitwie na Partynicach (2013–2023 i 2026, bez kłusaków), 8487 wierszy. Cechy konia są liczone
tylko ze startów **sprzed** danej gonitwy (z `historia_koni_PL.csv`, wszystkie tory), więc wynik gonitwy nie przecieka
do cech. Tabelę tworzy `zbuduj_cechy.py` (`python model/zbuduj_cechy.py`).

| kolumna | co znaczy |
|---|---|
| race_id, data, rok, nr_w_sezonie, horse_id, kon | identyfikacja, nie są cechami |
| kompletna | 1 = gonitwa z pełnymi wynikami (model oceniamy tylko na takich) |
| **wygral** | **cel: 1 = koń wygrał** |
| top3, miejsce, miejsce_wzgl | inne możliwe cele: miejsca 1–3, miejsce, miejsce względne (0 = zwycięzca, 1 = ostatni, nieukończony = 1) |
| rodzaj, dystans_m, liczba_koni, kategoria, pula, gonitwa_uczniowska, stan_toru, stan_toru_liczba | gonitwa, opis w `SLOWNIK.md` |
| wiek, plec, waga_kg, jezdziec_kat | koń i jeździec w tej gonitwie |
| starty_przed | liczba wcześniejszych startów konia (0 = debiut, wtedy kolumny niżej są puste) |
| wygrane_przed, odsetek_wygranych, odsetek_top3 | wygrane: liczba i odsetek; odsetek miejsc 1–3 |
| srednia_miejsca, mediana_miejsca | z wcześniejszych startów (koń bez miejsca = ostatni) |
| srednia_wzgl, mediana_wzgl | to samo dla miejsca względnego |
| srednia_wzgl_5 | średnie miejsce względne z ostatnich 5 startów |
| ostatnie_wzgl | miejsce względne w ostatnim starcie |
| dni_od_ostatniego | dni od poprzedniego startu |
| starty_rok | liczba startów w ostatnich 365 dniach |
| ranga_srednia_wzgl | pozycja konia w stawce według `srednia_wzgl` (1 = najlepsza historia w tej gonitwie) |
| zbior_2013 | podział sezonu 2013 z zajęć 28.10: `trening` (gonitwy do 22.09.2013, 61 gonitw), `test` (19 gonitw); w innych latach puste |

Konie doświadczone wybiera się filtrem, np. `starty_przed >= 10`. W 2013 r. przy progu 10 zostaje tylko 27 gonitw
z co najmniej dwoma takimi końmi, a w co trzeciej z nich wygrał koń mniej doświadczony.
