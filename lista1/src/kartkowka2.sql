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
    dbms_output.PUT_LINE('Znaleziono kota o funkcji ' || szukana_funkcja);
  END IF;
END;

BEGIN
  FOR grubas IN (
  SELECT *
  FROM (SELECT *
        FROM kocury
        ORDER BY NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) DESC)
  WHERE rownum <= 3)
  LOOP
    dbms_output.PUT_LINE(grubas.pseudo);
  END LOOP;
END;

CREATE OR REPLACE TRIGGER banda_sie_zgadza
BEFORE INSERT ON bandy
  BEGIN
    SELECT NVL(MAX(nr_bandy), 0)
    INTO :new.nr_bandy
    FROM bandy;
  END;


CREATE OR REPLACE FUNCTION k_calkowity_przydzial_myszy
  RETURN NUMBER IS
  result NUMBER := 0;
  BEGIN
    RETURN SELECT NVL(SUM(NVL(przydzial_myszy, 0)), 0)
    INTO RESULT
    FROM kocury;
  END;

BEGIN
  dbms_output.put_line(calkowity_przydzial_myszy());
END;


CREATE OR REPLACE PROCEDURE koty_o_funkcji(funkcja_kota VARCHAR2) IS
  CURSOR kot_kursor IS SELECT *
                       FROM kocury
                       WHERE funkcja = funkcja_kota;
  kot kocury%ROWTYPE;
  BEGIN
    OPEN kot_kursor;
    LOOP
      EXIT WHEN kot_kursor%NOTFOUND;
      FETCH kot_kursor INTO kot;
      dbms_output.put_line(kot.pseudo || ' ' || kot.funkcja);
    END LOOP;
    CLOSE kot_kursor;
  END;

BEGIN
  koty_o_funkcji('MILUSIA');
END;


CREATE OR REPLACE TRIGGER nie_dla_burzujow
BEFORE INSERT OR UPDATE ON kocury
  BEGIN


  END;


CREATE OR REPLACE FUNCTION najwiekszy_przychod
  RETURN NUMBER IS
  result NUMBER := 0;
  BEGIN
    FOR kot IN (SELECT *
                FROM kocury)
    LOOP
      IF (kot.przydzial_myszy > result)
      THEN
        result := kot.przydzial_myszy;
      END IF;
    END LOOP;

    RETURN result;
  END;

BEGIN
  dbms_output.put_line(najwiekszy_przychod());
END;

CREATE OR REPLACE FUNCTION myszy_extra_w_stadzie
  RETURN NUMBER IS
  result INTEGER := 0;
  kot    kocury%ROWTYPE;
  CURSOR kot_kursor IS SELECT *
                       FROM kocury
                       WHERE myszy_extra IS NOT NULL;
  BEGIN
    OPEN kot_kursor;
    LOOP
      EXIT WHEN kot_kursor%NOTFOUND;
      FETCH kot_kursor INTO kot;
      result := result + kot.myszy_extra;
    END LOOP;

    CLOSE kot_kursor;

    RETURN result;
  END;

BEGIN
  dbms_output.put_line(myszy_extra_w_stadzie());
END;

CREATE OR REPLACE FUNCTION myszy_extra_w_stadzie
  RETURN NUMBER IS
  result NUMBER := 0;
  BEGIN
  FOR kot IN (SELECT *
                       FROM kocury
                       WHERE myszy_extra IS NOT NULL)
  LOOP
    result := result + kot.przydzial_myszy;
  END LOOP;
  END;


