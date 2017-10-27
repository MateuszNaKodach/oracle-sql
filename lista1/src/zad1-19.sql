/*
Zadanie 1:
*/

SELECT
  pseudo                                                                 "PSEUDO",
  REGEXP_REPLACE(REGEXP_REPLACE(pseudo, 'A', '#', 1, 1), 'L', '%', 1, 1) "Po wymianie A na # oraz L na %"
FROM kocury
WHERE pseudo LIKE '%A%' AND pseudo LIKE '%L%';


/*
Zadanie 2:
 */

SELECT
  imie                         "IMIE",
  w_stadku_od                  "W stadku",
  ROUND(przydzial_myszy / 1.1) "Zjadal",
  ADD_MONTHS(w_stadku_od, 6)   "Podwyżka",
  przydzial_myszy              "Zjada"
FROM kocury
WHERE MONTHS_BETWEEN(SYSDATE, w_stadku_od) >= 8 * 12
      AND EXTRACT(MONTH FROM w_stadku_od) BETWEEN 3 AND 9
ORDER BY przydzial_myszy DESC;


/*
Zadanie 4:
 */
SELECT
  'Liczba kotow='                                                      " ",
  COUNT(*)                                                             " ",
  'lowi jako'                                                          " ",
  funkcja                                                              " ",
  'i zjada max.'                                                       " ",
  TO_CHAR(MAX(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)), '99.00') " ",
  'myszy miesiecznie'                                                  " "
FROM kocury
WHERE funkcja != 'SZEFUNIO' AND plec = 'D'
GROUP BY funkcja
HAVING AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) > 50
ORDER BY 6 ASC;


/*
Zadanie 5:
 */
SELECT
  level    "Poziom",
  pseudo   "Pseudonim",
  funkcja  "Funkcja",
  nr_bandy "Nr bandy"
FROM kocury
WHERE plec = 'M'
CONNECT BY PRIOR pseudo = szef
START WITH funkcja = 'BANDZIOR';

/*
Zadanie 6:
 */
SELECT
  LPAD(level - 1, (level - 1) * 4 + 1, '===>') || '                ' || imie "Hierarchia",
  NVL(szef, 'Sam sobie panem')                                               "Pseudo szefa",
  funkcja                                                                    "Funkcja"
FROM kocury
WHERE myszy_extra > 0
CONNECT BY PRIOR pseudo = szef
START WITH szef IS NULL;

/*
Zadanie 7:
 */
SELECT LPAD(' ', (level - 1) * 4, ' ') || pseudo "Droga sluzbowa"
FROM kocury
CONNECT BY PRIOR szef = pseudo
START WITH plec = 'M' AND MONTHS_BETWEEN(SYSDATE, w_stadku_od) > 8 * 12
           AND NVL(myszy_extra, 0) = 0;

/*
Zadanie 8:
 */
SELECT
  k.imie        "IMIE",
  k.w_stadku_od "POLUJE OD"
FROM kocury k
  JOIN kocury j ON j.imie = 'JACEK'
WHERE k.w_stadku_od < j.w_stadku_od
ORDER BY k.w_stadku_od DESC;

/*
Zadanie 9a:
 */
SELECT
  k.imie            "Imie",
  k.funkcja         "Funkcja",
  NVL(s1.imie, ' ') "Szef 1",
  NVL(s2.imie, ' ') "Szef 2",
  NVL(s3.imie, ' ') "Szef 3"
FROM kocury k
  LEFT JOIN kocury s1 ON k.szef = s1.pseudo
  LEFT JOIN kocury s2 ON s1.szef = s2.pseudo
  LEFT JOIN kocury s3 ON s2.szef = s3.pseudo
WHERE k.funkcja IN ('KOT', 'MILUSIA');

/*
Zadanie 10:
 */
SELECT
  imie                "Imie kotki",
  nazwa               "Nazwa bandy",
  wrogowie.imie_wroga "Imie wroga",
  stopien_wrogosci    "Ocen wroga",
  data_incydentu      "Data inc."
FROM wrogowie_kocurow
  LEFT JOIN kocury ON wrogowie_kocurow.pseudo = kocury.pseudo
  LEFT JOIN wrogowie ON wrogowie_kocurow.imie_wroga = wrogowie.imie_wroga
  LEFT JOIN bandy ON kocury.nr_bandy = bandy.nr_bandy
WHERE plec = 'D' AND data_incydentu > '2007-01-01'
ORDER BY imie ASC;

/*
Zadanie 11:
 */
SELECT
  imie            "IMIE",
  funkcja         "FUNKCJA",
  przydzial_myszy "PRZYDZIAL MYSZY"
FROM kocury
WHERE przydzial_myszy >= 3 * (
  SELECT k.przydzial_myszy
  FROM kocury k
    JOIN bandy ON k.nr_bandy = bandy.nr_bandy
  WHERE funkcja = 'MILUSIA'
        AND teren IN ('SAD', 'CALOSC')
  ORDER BY k.przydzial_myszy DESC
  FETCH NEXT 1 ROWS ONLY)
ORDER BY przydzial_myszy ASC;

/*
Zadanie 12:
 */
SELECT
  funkcja                                                   "Funkcja",
  ROUND(AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) "Sr. najw. i najn. prz. myszy"
FROM kocury
WHERE funkcja != 'SZEFUNIO'
GROUP BY funkcja
HAVING AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) IN (
  (
    SELECT MAX(AVG(przydzial_myszy + NVL(myszy_extra, 0)))
    FROM kocury
    WHERE funkcja != 'SZEFUNIO'
    GROUP BY funkcja
  ),
  (
    SELECT MIN(AVG(przydzial_myszy + NVL(myszy_extra, 0)))
    FROM kocury
    WHERE funkcja != 'SZEFUNIO'
    GROUP BY funkcja
  )
)
ORDER BY 2 ASC;

/*
Zadanie 13a:
 */
SELECT
  pseudo                                  "PSEUDO",
  (przydzial_myszy + NVL(myszy_extra, 0)) "ZJADA"
FROM kocury k
WHERE (
        SELECT DISTINCT COUNT((przydzial_myszy + NVL(myszy_extra, 0)))
        FROM kocury
        WHERE (k.przydzial_myszy + NVL(k.myszy_extra, 0)) < (przydzial_myszy + NVL(myszy_extra, 0))
      ) < &n
ORDER BY "ZJADA" DESC;


/*
Zadanie 13b:
 */
SELECT
  pseudo "PSEUDO",
  (przydzial_myszy + NVL(myszy_extra, 0)) "ZJADA"
FROM Kocury k
WHERE (przydzial_myszy + NVL(myszy_extra, 0)) IN (
  SELECT * FROM (
    SELECT DISTINCT (przydzial_myszy + NVL(myszy_extra, 0)) "ZJADA"
    FROM Kocury
    ORDER BY "ZJADA" DESC
  ) WHERE ROWNUM <= n
)
ORDER BY "ZJADA" DESC;

/*
Zadanie13c:
 */
SELECT
  k1.pseudo "PSEUDO",
  MAX(k1.przydzial_myszy + NVL(k1.myszy_extra, 0)) "ZJADA"
FROM Kocury k1, Kocury k2
WHERE (k1.przydzial_myszy + NVL(k1.myszy_extra, 0)) <= (k2.przydzial_myszy + NVL(k2.myszy_extra, 0))
GROUP BY k1.pseudo
HAVING COUNT(DISTINCT (k2.przydzial_myszy + NVL(k2.myszy_extra, 0))) <= &n
ORDER BY "ZJADA" DESC;

/*
Zadanie13 d:
 */
SELECT
  "PSEUDO", "ZJADA"
FROM (
  SELECT
    pseudo "PSEUDO",
    (przydzial_myszy + NVL(myszy_extra, 0)) "ZJADA",
    DENSE_RANK() OVER (
      ORDER BY (przydzial_myszy + NVL(myszy_extra, 0)) DESC
      ) "RANK"
  FROM Kocury
)
WHERE "RANK" <= &n;


/*
Zadanie 16:
 */
SELECT
  "PSEUDO",
  "PLEC",
  "Myszy przed podw.",
  "Extra przed podw."
FROM (
  SELECT
    pseudo "PSEUDO",
    plec "PLEC",
    przydzial_myszy "Myszy przed podw.",
    NVL(myszy_extra, 0) "Extra przed podw.",
    DENSE_RANK() OVER (
      PARTITION BY nazwa
      ORDER BY w_stadku_od ASC
      ) "RANK"
  FROM Kocury
    JOIN Bandy USING(nr_bandy)
  WHERE nazwa IN ('LACIACI MYSLIWI','CZARNI RYCERZE')
  ORDER BY w_stadku_od ASC
)
WHERE "RANK" <= 3;

UPDATE Kocury k
SET
  przydzial_myszy = przydzial_myszy + (
    CASE
    WHEN plec = 'D' THEN
      0.1 * (SELECT MIN(przydzial_myszy) FROM Kocury)
    ELSE
      10
    END
  ),
  myszy_extra = NVL(myszy_extra, 0) + 0.15 * (
    SELECT AVG(NVL(myszy_extra, 0)) FROM Kocury WHERE nr_bandy = k.nr_bandy
  )
WHERE pseudo IN (
  SELECT pseudo
  FROM (
    SELECT
      pseudo,
      DENSE_RANK() OVER (
        PARTITION BY nazwa
        ORDER BY w_stadku_od ASC
        ) "RANK"
    FROM Kocury
      JOIN Bandy USING(nr_bandy)
    WHERE nazwa IN ('LACIACI MYSLIWI','CZARNI RYCERZE')
    ORDER BY w_stadku_od ASC
  )
  WHERE "RANK" <= 3
);


SELECT
  "PSEUDO",
  "PLEC",
  "Myszy po podw.",
  "Extra po podw."
FROM (
  SELECT
    pseudo "PSEUDO",
    plec "PLEC",
    przydzial_myszy "Myszy po podw.",
    NVL(myszy_extra, 0) "Extra po podw.",
    DENSE_RANK() OVER (
      PARTITION BY nazwa
      ORDER BY w_stadku_od ASC
      ) "RANK"
  FROM Kocury
    JOIN Bandy USING(nr_bandy)
  WHERE nazwa IN ('LACIACI MYSLIWI','CZARNI RYCERZE')
  ORDER BY w_stadku_od ASC
)
WHERE "RANK" <= 3;

ROLLBACK;


