# Makefile pentru Tema de Casă: Restaurarea și Clasificarea Inscripțiilor Oracol
# Metode Numerice 2026

PACKAGE_DIR := .
SUBMISSION_NAME := submission.zip

.PHONY: help check test submit clean

help:
	@echo "Comenzi disponibile pentru Tema MN:"
	@echo "  make check      - Rulează checker-ul automat în Octave"
	@echo "  make test       - Alias pentru make check"
	@echo "  make submit     - Creează arhiva submission.zip pentru trimitere"
	@echo "  make clean      - Șterge arhiva submission.zip"

check:
	@echo "Rulare checker..."
	@octave --no-gui --eval "checker"

test: check

submit:
	@echo "Creare arhivă submission $(SUBMISSION_NAME)..."
	@zip -j $(SUBMISSION_NAME) src/task1.m src/task2.m src/task3.m src/task4.m src/Dif.m src/SVD.m src/process_oracle_inscription.m
	@echo "Arhiva a fost creată cu succes."

clean:
	@echo "Curățare fișiere generate..."
	@rm -f $(SUBMISSION_NAME)
	@echo "Curățat."
