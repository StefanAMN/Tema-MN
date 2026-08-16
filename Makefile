# Makefile pentru Tema de Casă: Restaurarea și Clasificarea Inscripțiilor Oracol
# Metode Numerice 2026

PACKAGE_DIR := .
SUBMISSION_NAME := submission.zip

.PHONY: help check test submit clean

help:
	@echo "Comenzi disponibile pentru Tema MN:"
	@echo "  make check      - Ruleaza checker-ul automat in Octave"
	@echo "  make test       - Alias pentru make check"
	@echo "  make submit     - Creeaza arhiva submission.zip pentru trimitere"
	@echo "  make clean      - Sterge arhiva submission.zip"
	@echo "  make docker-check - Construieste imaginea Docker si ruleaza checker-ul in container"

check:
	@echo "Rulare checker..."
	@octave --no-gui --eval "checker"

test: check

docker-check:
	@echo "Construire imagine Docker..."
	@docker build -t oracle-checker .
	@echo "Rulare checker în Docker..."
	@docker run --rm oracle-checker

submit:
	@echo "Creare arhiva submission $(SUBMISSION_NAME)..."
	@zip -j $(SUBMISSION_NAME) src/task1.m src/task2.m src/task3.m src/task4.m src/process_oracle_inscription.m
	@echo "Arhiva a fost creata cu succes."

clean:
	@echo "Curatare fisiere generate..."
	@rm -f $(SUBMISSION_NAME)
	@rm -rf results
	@echo "Curatat."

