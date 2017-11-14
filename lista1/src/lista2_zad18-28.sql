SET serveroutput on;
SET VERIFY OFF;

---ZADANIE 18:
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

---ZADANIE 19:
SET AUTOCOMMIT OFF;

DECLARE
  CURSOR kursor_kocury IS
    SELECT
      przydzial_myszy,
      funkcja
    FROM kocury
    ORDER BY kocury.przydzial_myszy ASC
    FOR UPDATE OF przydzial_myszy;

  kocury_r                   kursor_kocury%ROWTYPE;
  maksymalny_przydzial_myszy NUMBER := 1050;
  liczba_zmian               NUMBER := 0;
  aktualny_przydzial_myszy   NUMBER := 0;
  max_przydzial_dla_funkcji  NUMBER := 0;
  przydzial_po_podwyzce      NUMBER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Poczatek programu, aktualny przydzial myszy: ' || aktualny_przydzial_myszy);

  <<outer_loop>> LOOP

  OPEN kursor_kocury;

  DBMS_OUTPUT.PUT_LINE('Petla zewnetrzna start, aktualny przydzial myszy: ' || aktualny_przydzial_myszy);
<<inner_loop>>
  LOOP

    SELECT SUM(przydzial_myszy)
    INTO aktualny_przydzial_myszy
    FROM kocury;

    DBMS_OUTPUT.PUT_LINE('Petla wewnetrzna, liczba zmian: ' || liczba_zmian);
    DBMS_OUTPUT.PUT_LINE('Petla wewnetrzna, aktualny przydzial myszy: ' || aktualny_przydzial_myszy);

    FETCH kursor_kocury INTO kocury_r;


    EXIT outer_loop
    WHEN aktualny_przydzial_myszy > maksymalny_przydzial_myszy;
    EXIT inner_loop
    WHEN kursor_kocury%NOTFOUND;


    SELECT MAX(przydzial_myszy)
    INTO max_przydzial_dla_funkcji
    FROM kocury
    WHERE kocury.funkcja = kocury_r.funkcja;

    przydzial_po_podwyzce := kocury_r.przydzial_myszy + (0.1 * kocury_r.przydzial_myszy);

    DBMS_OUTPUT.PUT_LINE('Przydzial po podwyzce: ' || przydzial_po_podwyzce);
    DBMS_OUTPUT.PUT_LINE('Max dla funkcji ' || kocury_r.funkcja || ' wynosi: '|| max_przydzial_dla_funkcji );

    IF przydzial_po_podwyzce > max_przydzial_dla_funkcji
    THEN
      UPDATE kocury
      SET przydzial_myszy = max_przydzial_dla_funkcji
      WHERE CURRENT OF kursor_kocury;
    ELSE
      UPDATE kocury
      SET przydzial_myszy = przydzial_po_podwyzce
      WHERE CURRENT OF kursor_kocury;
    END IF;

    liczba_zmian := liczba_zmian + 1;
  END LOOP inner_loop;
  CLOSE kursor_kocury;
END LOOP outer_loop;
  dbms_output.PUT_LINE('Calk. przydzial w stadku ' || aktualny_przydzial_myszy || ' Zmian -  ' || liczba_zmian || '.');
END;


ROLLBACK;


---Zadanie 20
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
    dbms_output.PUT_LINE(numer_kocura || '  ' || RPAD(kocur_obzartuch.pseudo,10) ||'     '|| LPAD(kocur_obzartuch."Zjada",4));
    numer_kocura:= numer_kocura + 1;
  END LOOP;
END;

---ZADANIE 23
CREATE OR REPLACE TRIGGER porzadek_w_papierach_band
  BEFORE INSERT ON bandy
  


DECLARE
  liczba_przelozonych NUMBER:= &ile_przelozonych;
BEGIN

END;