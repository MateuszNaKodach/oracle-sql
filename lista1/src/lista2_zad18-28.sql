SET serveroutput on;
SET VERIFY OFF;

---ZADANIE 18 -----------------------------------------------------------------------------------------------------------------------------------------------------------
---Czemu nie działa '&fun' jak w przykladach? Musze wspiac np. 'MILUSIA'
DECLARE
  szukana_funkcja    kocury.funkcja%TYPE := &fun;
  znalezionych_kotow NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO znalezionych_kotow
  FROM kocury
  WHERE funkcja = szukana_funkcja;

  IF (znalezionych_kotow > 0)
  THEN
    dbms_output.PUT_LINE('Znaleziono kota o funkcji ' || szukana_funkcja || '.');
  ELSE
    dbms_output.PUT_LINE('W stadzie nie ma kota kota z taką funkcją!');
  END IF;
END;

---ZADANIE 19 -----------------------------------------------------------------------------------------------------------------------------------------------------------
SET AUTOCOMMIT OFF;

CREATE OR REPLACE FUNCTION calkowity_przydzial_myszy
  RETURN NUMBER IS
  result NUMBER := 0;
  BEGIN
    SELECT NVL(SUM(NVL(przydzial_myszy, 0)), 0)
    INTO result
    FROM kocury;

    RETURN result;
  END;

BEGIN
  dbms_output.put_line(calkowity_przydzial_myszy());
END;

DECLARE
  CURSOR kursor_kocury IS
    SELECT *
    FROM kocury
    ORDER BY kocury.przydzial_myszy ASC
    FOR UPDATE OF przydzial_myszy;
  kocury_row                 kursor_kocury%ROWTYPE;
  kocur_funkcja              funkcje%ROWTYPE;
  myszy_po_podwyzce          NUMBER := 0;
  maksymalny_przydzial_myszy NUMBER := 1050;
  nr_zmiany                  NUMBER := 0;
BEGIN
  LOOP
    EXIT WHEN calkowity_przydzial_myszy() > maksymalny_przydzial_myszy;
    OPEN kursor_kocury;
    LOOP
      FETCH kursor_kocury INTO kocury_row;
      EXIT WHEN kursor_kocury%NOTFOUND OR calkowity_przydzial_myszy() > maksymalny_przydzial_myszy;

      SELECT *
      INTO kocur_funkcja
      FROM funkcje
      WHERE funkcja = kocury_row.funkcja;

      myszy_po_podwyzce := kocury_row.przydzial_myszy + (0.1 * kocury_row.przydzial_myszy);
      IF myszy_po_podwyzce > kocur_funkcja.max_myszy
      THEN
        myszy_po_podwyzce := kocur_funkcja.max_myszy;
      END IF;

      IF myszy_po_podwyzce != kocury_row.przydzial_myszy
      THEN
        UPDATE kocury
        SET przydzial_myszy = myszy_po_podwyzce
        WHERE CURRENT OF kursor_kocury;

        nr_zmiany := nr_zmiany + 1;
      END IF;

    END LOOP;
    CLOSE kursor_kocury;
  END LOOP;
  dbms_output.PUT_LINE('Calk. przydzial w stadku : ' || calkowity_przydzial_myszy() || '  Zmian : ' || nr_zmiany);
END;

SELECT
  imie,
  NVL(przydzial_myszy,0) "Myszk po podwyzce"
FROM kocury
ORDER BY przydzial_myszy DESC;

ROLLBACK;


---Zadanie 20 -----------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE
  numer_kocura NUMBER := 1;
BEGIN
  dbms_output.PUT_LINE('Nr Pseudonim      Zjada');
  dbms_output.PUT_LINE('--------------------------');
  FOR kocur_obzartuch IN (
  SELECT *
  FROM (
    SELECT
      pseudo,
      przydzial_myszy + NVL(myszy_extra, 0) "Zjada"
    FROM kocury
    ORDER BY 2 DESC
  )
  WHERE rownum <= 5
  )
  LOOP
    dbms_output.PUT_LINE(
        numer_kocura || '  ' || RPAD(kocur_obzartuch.pseudo, 10) || '     ' || LPAD(kocur_obzartuch."Zjada", 4));
    numer_kocura := numer_kocura + 1;
  END LOOP;
END;

---ZADANIE 21 -----------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE
  liczba_przelozonych NUMBER := &ile_przelozonych;
    niepoprawna_lizcba_szefow EXCEPTION;
BEGIN
  IF liczba_przelozonych < 0
  THEN
    RAISE niepoprawna_lizcba_szefow;
  END IF;

  dbms_output.PUT(RPAD('Imie', 10));
  FOR i IN 1..liczba_przelozonych LOOP
    dbms_output.PUT('  |  ' || RPAD('Szef ' || i, 10));
  END LOOP;
  dbms_output.PUT_LINE('');
  dbms_output.PUT('----------');
  FOR i IN 1..liczba_przelozonych LOOP
    dbms_output.PUT(' --- ----------');
  END LOOP;
  dbms_output.PUT_LINE('');

  FOR kocur_lizus IN ( SELECT *
                       FROM kocury
                       WHERE funkcja IN ('KOT', 'MILUSIA'))
  LOOP
    dbms_output.PUT(RPAD(kocur_lizus.imie, 10));
    wypisz_szefow(kocur_lizus, liczba_przelozonych);
  END LOOP;

  EXCEPTION
  WHEN niepoprawna_lizcba_szefow THEN
  dbms_output.PUT('Liczba przełożonych do wyświetlenia nie może być mniejsza od zera!');
END;

CREATE OR REPLACE PROCEDURE wypisz_szefow(kocur kocury%ROWTYPE, ilu_szefow NUMBER)
IS
  szef_kocura kocury%ROWTYPE;
  BEGIN
    IF kocur.szef IS NULL OR ilu_szefow = 0
    THEN
      IF (ilu_szefow = 0)
      THEN
        dbms_output.PUT_LINE('');
        RETURN;
      END IF;
      dbms_output.PUT('  |  ' || RPAD(' ', 10));
    ELSE
      SELECT *
      INTO szef_kocura
      FROM kocury
      WHERE kocury.pseudo = kocur.szef;
      dbms_output.PUT('  |  ' || RPAD(szef_kocura.imie, 10));
    END IF;
    wypisz_szefow(szef_kocura, ilu_szefow - 1);
  END;

---ZADANIE 22 -----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE zadanie22(liczba_przelozonych NUMBER)
IS
    niepoprawna_lizcba_szefow EXCEPTION;
  BEGIN
    IF liczba_przelozonych < 0
    THEN
      RAISE niepoprawna_lizcba_szefow;
    END IF;

    dbms_output.PUT(RPAD('Imie', 10));
    FOR i IN 1..liczba_przelozonych LOOP
      dbms_output.PUT('  |  ' || RPAD('Szef ' || i, 10));
    END LOOP;
    dbms_output.PUT_LINE('');
    dbms_output.PUT('----------');
    FOR i IN 1..liczba_przelozonych LOOP
      dbms_output.PUT(' --- ----------');
    END LOOP;
    dbms_output.PUT_LINE('');

    FOR kocur_lizus IN ( SELECT *
                         FROM kocury
                         WHERE funkcja IN ('KOT', 'MILUSIA'))
    LOOP
      dbms_output.PUT(RPAD(kocur_lizus.imie, 10));
      wypisz_szefow(kocur_lizus, liczba_przelozonych);
    END LOOP;

    EXCEPTION
    WHEN niepoprawna_lizcba_szefow THEN
    dbms_output.PUT('Liczba przełożonych do wyświetlenia nie może być mniejsza od zera!');
  END;


BEGIN
  zadanie22(4);
END;

---ZADANIE 23 -----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER porzadek_w_papierach_band
BEFORE INSERT ON bandy
FOR EACH ROW
  BEGIN
    SELECT NVL(MAX(bandy.nr_bandy), 0) + 1
    INTO :new.nr_bandy
    FROM bandy;
  END;

SET AUTOCOMMIT OFF;

INSERT INTO bandy VALUES (23, 'OSZOŁOMY', 'KUCHNIA', NULL);

SELECT nr_bandy
FROM bandy
WHERE nazwa = 'OSZOŁOMY';

ROLLBACK;
SET AUTOCOMMIT ON;

---ZADANIE 26 -----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE podatki AS

  PROCEDURE zadanie22(liczba_przelozonych NUMBER);

  FUNCTION podatek_kota(kot_pseudo kocury.pseudo%TYPE)
    RETURN NUMBER;

END podatki;

CREATE OR REPLACE PACKAGE BODY podatki AS

  ---Skopiowane z zadania 22
  PROCEDURE zadanie22(liczba_przelozonych NUMBER)
  IS
      niepoprawna_lizcba_szefow EXCEPTION;
    BEGIN
      IF liczba_przelozonych < 0
      THEN
        RAISE niepoprawna_lizcba_szefow;
      END IF;

      dbms_output.PUT(RPAD('Imie', 10));
      FOR i IN 1..liczba_przelozonych LOOP
        dbms_output.PUT('  |  ' || RPAD('Szef ' || i, 10));
      END LOOP;
      dbms_output.PUT_LINE('');
      dbms_output.PUT('----------');
      FOR i IN 1..liczba_przelozonych LOOP
        dbms_output.PUT(' --- ----------');
      END LOOP;
      dbms_output.PUT_LINE('');

      FOR kocur_lizus IN ( SELECT *
                           FROM kocury
                           WHERE funkcja IN ('KOT', 'MILUSIA'))
      LOOP
        dbms_output.PUT(RPAD(kocur_lizus.imie, 10));
        wypisz_szefow(kocur_lizus, liczba_przelozonych);
      END LOOP;

      EXCEPTION
      WHEN niepoprawna_lizcba_szefow THEN
      dbms_output.PUT('Liczba przełożonych do wyświetlenia nie może być mniejsza od zera!');
    END;

  ---Funkcje pomocniczne do obliczenia podatku:
  FUNCTION calk_przydz_myszy_sufit(kot kocury%ROWTYPE, procent DECIMAL)
    RETURN NUMBER IS
    BEGIN
      RETURN CEIL(procent * (NVL(kot.przydzial_myszy, 0) + NVL(kot.myszy_extra, 0)));
    END;

  FUNCTION posiada_podwladnych(kot kocury%ROWTYPE)
    RETURN BOOLEAN IS
    liczba_podwladnych NUMBER := 0;
    BEGIN
      SELECT NVL(COUNT(*), 0)
      INTO liczba_podwladnych
      FROM kocury
      WHERE kocury.szef = kot.pseudo;

      RETURN liczba_podwladnych > 0;
    END;

  FUNCTION jest_ugodowy(kot kocury%ROWTYPE)
    RETURN BOOLEAN IS
    liczba_wrogow NUMBER := 0;
    BEGIN
      SELECT NVL(COUNT(*), 0)
      INTO liczba_wrogow
      FROM wrogowie_kocurow
      WHERE wrogowie_kocurow.pseudo = kot.pseudo;

      RETURN liczba_wrogow = 0;
    END;

  FUNCTION przydzial_powyzej_sredniej(kot kocury%ROWTYPE)
    RETURN BOOLEAN IS
    sredni_przydzial NUMBER := 0;
    BEGIN
      SELECT AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))
      INTO sredni_przydzial
      FROM kocury;

      RETURN (NVL(kot.przydzial_myszy, 0) + NVL(kot.myszy_extra, 0)) > sredni_przydzial;
    END;
  ---Koniec funkcji pomocniczych do obliczenia podatku


  FUNCTION podatek_kota(kot_pseudo kocury.pseudo%TYPE)
    RETURN NUMBER IS
    kot     kocury%ROWTYPE;
    podatek NUMBER := 0;
    BEGIN
      SELECT *
      INTO kot
      FROM kocury
      WHERE kocury.pseudo = kot_pseudo;

      ---Podatek TYGRYSA wynosi 0!
      IF kot.pseudo = 'TYGRYS'
      THEN
        RETURN 0;
      END IF;

      ---Podatek 5% myszowych przychodów
      podatek := podatek + calk_przydz_myszy_sufit(kot, 0.05);

      IF NOT posiada_podwladnych(kot)
      THEN
        podatek := podatek + 2;
      END IF;

      IF jest_ugodowy(kot)
      THEN
        podatek := podatek + 1;
      END IF;

      IF przydzial_powyzej_sredniej(kot)
      THEN
        podatek := podatek + 3;
      END IF;

      RETURN podatek;
    END;

END podatki;

---Podatki wszystkich kotów:
SELECT
  imie,
  pseudo,
  podatki.podatek_kota(pseudo) "Podatek"
FROM kocury
ORDER BY 3 DESC;

---ZADANIE 28 -----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE myszowa_korupcja (
  przestepca VARCHAR2(255) CONSTRAINT mkor_przestepca_nn NOT NULL,
  data       DATE          CONSTRAINT mkor_data_nn NOT NULL,
  imie_kota  VARCHAR2(15)  CONSTRAINT mkor_imiekota_nn NOT NULL,
  operacja   VARCHAR2(9) CONSTRAINT mkor_operacja_check CHECK (operacja IN ('INSERTING', 'UPDATING'))
);

CREATE OR REPLACE FUNCTION czy_w_przedziale_funkcji(nazwa_funkcji VARCHAR2, nowy_przydzial NUMBER)
  RETURN BOOLEAN
IS
  funkcja_kota funkcje%ROWTYPE;
  BEGIN
    SELECT *
    INTO funkcja_kota
    FROM funkcje
    WHERE funkcje.funkcja = nazwa_funkcji;

    RETURN nowy_przydzial BETWEEN funkcja_kota.min_myszy AND funkcja_kota.max_myszy;
  END;

---TEST FUNKCJI---
/*DECLARE
  czy_w_przedziale BOOLEAN;
BEGIN
  czy_w_przedziale := czy_w_przedziale_funkcji('MILUSIA', 25);
  IF czy_w_przedziale
  THEN
    dbms_output.put_line('W przedziale');
  ELSE
    dbms_output.put_line('NIE w przedziale');
  END IF;
END;*/

CREATE OR REPLACE TRIGGER monitorowanie_przydzialu
BEFORE INSERT OR UPDATE OF przydzial_myszy
  ON kocury
FOR EACH ROW
  DECLARE
    operacja VARCHAR2(9) := '';
      niepoprawny_przydzial EXCEPTION;
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF NOT czy_w_przedziale_funkcji(:new.funkcja, :new.przydzial_myszy)
    THEN

      :new.przydzial_myszy := :old.przydzial_myszy;

      IF INSERTING
      THEN operacja := 'INSERTING';
      ELSE IF UPDATING
      THEN operacja := 'UPDATING'; END IF;
      END IF;

      INSERT INTO myszowa_korupcja VALUES (USER, SYSDATE, :new.imie, operacja);
      COMMIT;
      RAISE niepoprawny_przydzial;

    END IF;

    EXCEPTION
    WHEN niepoprawny_przydzial THEN dbms_output.put_line(
      'Niepoprawny przydzial myszy dla funkcji: ' || :new.funkcja || '!');
  END;


UPDATE kocury
SET przydzial_myszy = 25
WHERE pseudo = 'LOLA';
COMMIT;

INSERT INTO kocury VALUES ('KOTEK', 'M', 'POZERACZ', 'LOWCZY', 'LYSY', '2008-12-01', 200, NULL, 2);
ROLLBACK;


SELECT *
FROM myszowa_korupcja;


SELECT *
FROM kocury;

DELETE FROM kocury
WHERE kocury.imie = 'KOTEK';
COMMIT;

SELECT *
FROM user_objects
WHERE object_type = 'TRIGGER';

DROP TRIGGER monitorowanie_przydzialu;