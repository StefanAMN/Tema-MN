# Set de Date: Inscripții pe Oase de Oracol (Oracle-MNIST)

Acest director conține imaginile autentice utilizate pentru evaluarea temei de casă **Restaurarea și Clasificarea Inscripțiilor Oracol**, extrase din setul de date academic de referință **Oracle-MNIST** (Wang & Deng, *Scientific Data*, 2024 / ICONIP 2025).

---

## 1. Structura Directoarelor

```text
data/
├── known_symbols/                 # Dicționarul de referință (10 caractere oracol prototip)
│   ├── symbol_01.png ... symbol_10.png
│
├── practice/                      # DATASET PUBLIC (Pachetul Studentului)
│   ├── tier1/                     # 10 imagini reale cu contrast optim
│   ├── tier2/                     # 10 imagini reale cu zgomot de textură de piatră/os
│   ├── tier3/                     # 10 imagini reale cu zgomot de înaltă frecvență și eroziune
│   └── practice_labels.csv        # Etichetele Ground Truth (1..10) pentru auto-verificare
│
└── competition/                   # DATASET PRIVAT / SECRET (Evaluarea Oficială a Echipei)
    ├── tier1/                     # 10 mostre noi cu zgomot redus
    ├── tier2/                     # 10 mostre noi cu zgomot mediu
    ├── tier3/                     # 10 mostre noi cu zgomot sever
    ├── extra_hard/                # 10 mostre noi cu iluminare neuniformă
    └── secret_labels.csv          # Ground Truth secret pentru calculul notelor finale
```

---

## 2. Nivelurile de Dificultate (Tiers)

- **Tier 1 (Warm-up):** Imagini reale cu contrast clar și zgomot natural minim. Verifică funcționarea de bază a algoritmilor.
- **Tier 2 (Texture & Inscriptions):** Zgomot gaussian aditiv și textură de piatră/os, simulând frecarea tușului la copierea de pe artefacte.
- **Tier 3 (Severe Erosion):** Zgomot de înaltă frecvență de tip speckle și întreruperi parțiale ale trăsăturilor (eroziune mecanică). Necesită filtrarea Fourier (Task 1) și descompunerea Wavelet (Task 2) pentru a recupera forma corectă.
- **Extra Hard (Competition Only):** Gradient bi-dimensional neliniar de iluminare și contrast scăzut.

---

## 3. Utilizare în Checker

Pentru a rula verificarea automată pe setul de practică (student):
```bash
make check
```
sau în Octave:
```matlab
checker('data/practice')
```

Pentru evaluarea oficială pe setul secret:
```matlab
checker('data/competition')
```
