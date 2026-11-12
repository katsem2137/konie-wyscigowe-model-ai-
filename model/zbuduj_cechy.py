"""Tabela do modelu: 1 wiersz = 1 koń w 1 gonitwie na Partynicach, z cechami liczonymi TYLKO z wcześniejszych startów.

Wejście: starty_partynice.csv i historia_koni_PL.csv z katalogu wyżej. Bez kłusaków (jak w eda/wczytaj_dane.m).
Wyjście: model/cechy_partynice.csv (opis kolumn: model/CECHY.md).
Uruchomienie: python model/zbuduj_cechy.py
"""
from pathlib import Path

import numpy as np
import pandas as pd

KATALOG = Path(__file__).resolve().parent.parent
WYJSCIE = Path(__file__).resolve().parent / "cechy_partynice.csv"
UDZIAL_TRENINGU_2013 = 0.75   # ustalenie z zajęć 28.10: 3/4 sezonu trening, 1/4 test

H = pd.read_csv(KATALOG / "historia_koni_PL.csv", encoding="utf-8-sig", low_memory=False, parse_dates=["data"])
S = pd.read_csv(KATALOG / "starty_partynice.csv", encoding="utf-8-sig", low_memory=False, parse_dates=["data"])
H = H[(H.rasa != "klusak") & (~H.kategoria.isin(["kłusaki", "sulki"]))].copy()
S = S[S.rodzaj != "sulki"].copy()


def miejsce_wzgledne(miejsce, liczba_koni):
    """0 = zwycięzca, 1 = ostatni; koń bez miejsca liczy się jako ostatni."""
    m = miejsce.fillna(liczba_koni)
    return ((m - 1) / (liczba_koni - 1)).where(liczba_koni > 1)


H["miejsce_m"] = H.miejsce.fillna(H.liczba_koni)
H["wzgl"] = miejsce_wzgledne(H.miejsce, H.liczba_koni)
H = H.sort_values(["horse_id", "data"])
historia = {h: (g.data.values, g.miejsce_m.values, g.wzgl.values, (g.miejsce == 1).values, (g.miejsce <= 3).values)
            for h, g in H.groupby("horse_id")}

ROK = np.timedelta64(365, "D")
wiersze = []
for h, d in zip(S.horse_id.values, S.data.values):
    w = {"starty_przed": 0}
    if pd.notna(h) and h in historia:
        daty, miejsca, wzgl, wygrane, top3 = historia[h]
        n = np.searchsorted(daty, d, side="left")            # starty ściśle przed tą gonitwą
        if n > 0:
            w = {
                "starty_przed": n,
                "wygrane_przed": int(wygrane[:n].sum()),
                "odsetek_wygranych": wygrane[:n].mean(),
                "odsetek_top3": top3[:n].mean(),
                "srednia_miejsca": np.nanmean(miejsca[:n]),
                "mediana_miejsca": np.nanmedian(miejsca[:n]),
                "srednia_wzgl": np.nanmean(wzgl[:n]),
                "mediana_wzgl": np.nanmedian(wzgl[:n]),
                "srednia_wzgl_5": np.nanmean(wzgl[max(0, n - 5):n]),
                "ostatnie_wzgl": wzgl[n - 1],
                "dni_od_ostatniego": int((d - daty[n - 1]) / np.timedelta64(1, "D")),
                "starty_rok": int(n - np.searchsorted(daty, d - ROK, side="left")),
            }
    wiersze.append(w)
C = pd.DataFrame(wiersze, index=S.index)
S = S.join(C)
S["ranga_srednia_wzgl"] = S.groupby("race_id").srednia_wzgl.rank(method="min")   # 1 = najlepsza w gonitwie
S["miejsce_wzgl"] = miejsce_wzgledne(S.miejsce, S.liczba_koni)
S["rok"] = S.data.dt.year

# Podział sezonu 2013: pierwsze 3/4 gonitw (całymi dniami wyścigowymi) to trening, reszta to test
S["zbior_2013"] = ""
g13 = S[(S.rok == 2013) & (S.kompletna == 1)].groupby("race_id").data.first().sort_values()
dzien_ciecia = g13.iloc[int(np.ceil(UDZIAL_TRENINGU_2013 * len(g13))) - 1]
maska = (S.rok == 2013) & (S.kompletna == 1)
S.loc[maska & (S.data <= dzien_ciecia), "zbior_2013"] = "trening"
S.loc[maska & (S.data > dzien_ciecia), "zbior_2013"] = "test"

KOLUMNY = ["race_id", "data", "rok", "nr_w_sezonie", "horse_id", "kon", "kompletna",
           "wygral", "top3", "miejsce", "miejsce_wzgl",
           "rodzaj", "dystans_m", "liczba_koni", "kategoria", "pula", "gonitwa_uczniowska", "stan_toru", "stan_toru_liczba",
           "wiek", "plec", "waga_kg", "jezdziec_kat",
           "starty_przed", "wygrane_przed", "odsetek_wygranych", "odsetek_top3", "srednia_miejsca", "mediana_miejsca",
           "srednia_wzgl", "mediana_wzgl", "srednia_wzgl_5", "ostatnie_wzgl", "dni_od_ostatniego", "starty_rok",
           "ranga_srednia_wzgl", "zbior_2013"]
T = S.sort_values(["data", "race_id", "miejsce"])[KOLUMNY]
T["data"] = T.data.dt.strftime("%Y-%m-%d")
T.to_csv(WYJSCIE, index=False, encoding="utf-8-sig", float_format="%.4f", lineterminator="\n")

print(f"zapisano {WYJSCIE.name}: {len(T)} wierszy, {T.race_id.nunique()} gonitw, lata {T.rok.min()}-{T.rok.max()}")
print(f"2013: dzień cięcia {dzien_ciecia.date()}; " + ", ".join(
    f"{z}: {T[T.zbior_2013 == z].race_id.nunique()} gonitw / {(T.zbior_2013 == z).sum()} startów" for z in ["trening", "test"]))
print("\nkonie doświadczone (starty_przed >= N), gonitwy z pełnymi wynikami:")
for zakres, M in (("2013", T[(T.rok == 2013) & (T.kompletna == 1)]), ("2013-2023", T[(T.rok <= 2023) & (T.kompletna == 1)])):
    for n in (10, 5, 3, 1):
        D = M[M.starty_przed >= n]
        gon = D.groupby("race_id").agg(koni=("kon", "size"), zwyciezca=("wygral", "max"))
        gon2 = gon[gon.koni >= 2]
        print(f"  {zakres:9s} N>={n:2d}: startów {len(D):5d} z {len(M)} ({100 * len(D) / len(M):3.0f}%), "
              f"gonitw z >=2 takimi końmi {len(gon2):4d} z {M.race_id.nunique()}, "
              f"w nich zwycięzca jest doświadczony: {100 * gon2.zwyciezca.mean():3.0f}%")
