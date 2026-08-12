# Temă de casă: Restaurarea și Clasificarea Inscripțiilor Oracol prin Analiză Spectrală și Diferențiere Numerică

## Descriere generală
Scopul acestei teme este implementarea unui flux de procesare numerică a semnalelor pentru extragerea trăsăturilor geometrice dintr-o imagine degradată a unui caracter antic și generarea unei semnături binare pentru clasificare.

---

## Structura Proiectului (Organizare pe foldere)

```text
Tema-MN/
├── src/                          # Implementarea algoritmilor și stubs (Task-urile 1-4 & dependențe)
│   ├── task1.m                   # Subtask 1.1 - 1.3: Filtrare frecvențe spațiale Fourier 2D (30p)
│   ├── task2.m                   # Subtask 2.1 - 2.2: Transformata Wavelet Haar (20p)
│   ├── task3.m                   # Subtask 3.1 - 3.2: Extragere asimetrică trăsături / Diferențiere (20p)
│   ├── task4.m                   # Subtask 4.1 - 4.3: SVD, Hashing & Clasificare Hamming (20p)
│   ├── Dif.m                     # Dependență Lab 10: Derivare numerică 1D
│   ├── SVD.m                     # Dependență Lab 7: Descompunere în valori singulare
│   └── process_oracle_inscription.m # Wrapper integrat al întregului flux de procesare
├── evaluation/                   # Evaluare și calcul punctaj parțial
│   └── compute_score.m           # Calculare scor (90p total)
├── docs/                         # Documentația și enunțul oficial
│   └── Tema_Restaurarea_Inscriptiilor_Oracol.pdf
├── checker.m                     # Script principal de evaluare și punctare
├── Makefile                      # Reguli de automatizare (make check, make submit, make clean)
└── README.md                     # Ghidul proiectului
```

---

## Comenzi rapide

### 1. Evaluare / Testare
Pentru a rula verificarea automată pe scheletul de cod:
```bash
make check
```
sau direct în Octave / MATLAB:
```matlab
checker
```

### 2. Generare arhivă de trimitere
Pentru a crea arhiva `submission.zip` cu toate fișierele de cod din `src/`:
```bash
make submit
```

### 3. Evaluare cu Docker
Dacă doriți să rulați evaluarea într-un mediu izolat și reproductibil (container), puteți utiliza Docker.

Folosind Makefile:
```bash
make docker-check
```

Sau executând comenzile Docker manual:
```bash
docker build -t oracle-checker .
docker run --rm oracle-checker
```

---

## Punctaj și Cerințe
- **Task 1 (30p)**: Reconstrucție imagine filtrată cu transformata Fourier 2D ($F$, $M$, $X_f$, $\tilde{A}$).
- **Task 2 (20p)**: Descompunere Wavelet Haar 2D ($H$, $W$, submatrice $W_{LH}$ și $W_{HL}$).
- **Task 3 (20p)**: Derivare asimetrică (`Dif.m`) pe linii/coloane și calcul magnificare gradient ($G_x$, $G_y$, $S$).
- **Task 4 (20p)**: SVD (`SVD.m`), extragere valori singulare $v$, cod binar hash $b$, clasificare prin distanță Hamming.
- **Punctaj total parțial**: 90 puncte.
