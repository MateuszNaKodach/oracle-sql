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
  <<outer_loop>> LOOP
  OPEN kursor_kocury;

<<inner_loop>>
  LOOP

    SELECT SUM(przydzial_myszy)
    INTO aktualny_przydzial_myszy
    FROM kocury;
    FETCH kursor_kocury INTO kocury_r;
    EXIT inner_loop
    WHEN kursor_kocury%NOTFOUND OR aktualny_przydzial_myszy > maksymalny_przydzial_myszy;
    EXIT outer_loop
    WHEN aktualny_przydzial_myszy > maksymalny_przydzial_myszy;


    dbms_output.PUT_LINE(
        'Aktualny przydzial: ' || aktualny_przydzial_myszy || 'Maksymalny przydzial: ' || maksymalny_przydzial_myszy);
    SELECT MAX(przydzial_myszy)
    INTO max_przydzial_dla_funkcji
    FROM kocury
    WHERE kocury.funkcja = kocury_r.funkcja;

    przydzial_po_podwyzce := kocury_r.przydzial_myszy + (0.1 * kocury_r.przydzial_myszy);
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

---WERSJA NIBY DZIALA:
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
  LOOP
    SELECT SUM(przydzial_myszy)
    INTO aktualny_przydzial_myszy
    FROM kocury;

    EXIT WHEN aktualny_przydzial_myszy > maksymalny_przydzial_myszy;

    OPEN kursor_kocury;
    LOOP

      SELECT SUM(przydzial_myszy)
      INTO aktualny_przydzial_myszy
      FROM kocury;
      FETCH kursor_kocury INTO kocury_r;
      EXIT WHEN kursor_kocury%NOTFOUND OR aktualny_przydzial_myszy > maksymalny_przydzial_myszy;


      SELECT MAX(przydzial_myszy)
      INTO max_przydzial_dla_funkcji
      FROM kocury
      WHERE kocury.funkcja = kocury_r.funkcja;

      przydzial_po_podwyzce := kocury_r.przydzial_myszy + (0.1 * kocury_r.przydzial_myszy);
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
    END LOOP;
    CLOSE kursor_kocury;
  END LOOP;
  dbms_output.PUT_LINE('Calk. przydzial w stadku ' || aktualny_przydzial_myszy || ' Zmian -  ' || liczba_zmian || '.');
END;


ROLLBACK;

---Zadanie 20 JAK TO WYPISAC!?:
DECLARE
  numer_kocura NUMBER := 1;
BEGIN
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
    dbms_output.PUT_LINE('Nr  pseudonim zjada');
    dbms_output.PUT_LINE('--------------------------');
    dbms_output.PUT_LINE(numer_kocura || '  ' || kocur_obzartuch.pseudo ||'     '|| kocur_obzartuch."Zjada");
    numer_kocura:= numer_kocura + 1;
  END LOOP;
END;




DECLARE
  l_kotow       NUMBER;
  l_z_dodatkami NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO l_kotow
  FROM kocury;
  SELECT COUNT(*)
  INTO l_z_dodatkami
  FROM kocury
  WHERE myszy_extra IS NOT NULL;


  dbms_output.PUT_LINE('*' || LPAD('*', 54, '*') || '*');
  dbms_output.PUT_LINE('*' || LPAD(' ', 54, ' ') || '*');
  dbms_output.PUT_LINE('*  W stadku ' ||
                       ROUND(l_z_dodatkami / l_kotow * 100, 2) ||
                       '% kotow ma dodatkowy przydzial myszy  *');
  dbms_output.PUT_LINE('*' || LPAD(' ', 54, ' ') || '*');
  dbms_output.PUT_LINE('*' || LPAD('*', 54, '*') || '*');
  EXCEPTION
  WHEN ZERO_DIVIDE
  THEN dbms_output.PUT_LINE('Brak kotow w stadzie!!!');
  WHEN OTHERS
  THEN dbms_output.PUT_LINE(SQLERRM);
END;
