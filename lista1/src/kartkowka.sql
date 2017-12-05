SELECT nr_bandy
FROM kocury
WHERE nr_bandy IN (
  SELECT k.nr_bandy
  FROM
    wrogowie_kocurow WK
    INNER JOIN kocury K ON K.pseudo = wk.pseudo
    INNER JOIN wrogowie ON wk.imie_wroga = wrogowie.imie_wroga
    GROUP BY k.nr_bandy
)
GROUP BY nr_bandy
HAVING count(*) > 4;



SELECT plec,przydzial_myszy FROM
  kocury LEFT JOIN funkcje ON kocury.funkcja = funkcje.funkcja
WHERE przydzial_myszy > funkcje.min_myszy * 1.10 AND KOCURY.funkcja IN (SELECT KOCURY.funkcja FROM kocury WHERE pseudo = 'RAFA' OR pseudo='SZYBKA')
GROUP BY plec, przydzial_myszy;


SELECT przydzial_myszy, COUNT(przydzial_myszy), AVG(NVL(myszy_extra,0))  FROM kocury
LEFT JOIN bandy ON kocury.nr_bandy = bandy.nr_bandy
  WHERE bandy.nazwa IN ('LACIACI MYSLIWI', 'BIALI LOWCY') AND przydzial_myszy < (SELECT przydzial_myszy FROM kocury WHERE kocury.imie = 'BOLEK')
GROUP BY przydzial_myszy
HAVING COUNT(przydzial_myszy)>1;
