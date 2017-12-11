---Znajdz pseudonim najbardziej niezdecydowanego kota z całego stada, który najczęściej wpłacane na konto myszy wypłacał tego samego dnia.


SELECT *
FROM (
  SELECT
    value(p).dajPseudoWlasciciela()        "Najbardzej niezdecydowana",
    COUNT(value(p).dajPseudoWlasciciela()) "Wyplacala w dniu wpłaty razy:"
  FROM objmyszowekonto p
  WHERE value(p).data_wplaty = value(p).data_wyplaty
  GROUP BY value(p).dajPseudoWlasciciela())
WHERE rownum <= 1;

---Znajdz pseudonimy kotów, które dołączyły do stada po Tygrysie.


SELECT value(k).pseudo
FROM objkocury k
WHERE value(k).w_stadku_od > (SELECT value(k1).w_stadku_od
                              FROM objkocury k1
                              WHERE value(k1).pseudo = 'TYGRYS');


/*
SELECT value(k)
FROM objkocury k
WHERE value(k).w_stadku_od > '2002-05-05' AND value(k).pseudo IN (SELECT value(mk.wlasciciel).pseudo
                                                                  FROM objmyszowekonto mk
                                                                  GROUP BY value(wlasciciel).pseudo);
 */
---Kot ktory ma najwiecej na koncie i nie jest Tygrysem:
/*
SELECT pseudo
FROM (
  SELECT
    DEREF(mk.wlasciciel).pseudo AS pseudo,
    COUNT(1)
  FROM objmyszowekonto mk
  WHERE value(mk).data_wyplaty IS NULL
  GROUP BY DEREF(mk.wlasciciel).pseudo
  ORDER BY 2
)
WHERE rownum <= 1;
*/
---SELECT DEREF(value(mk).wlasciciel).pseudo
---FROM objmyszowekonto mk;

---Zadania - Lista 1:

/*
2. Wyświetlić imiona kotów z co najmniej ośmioletnim stażem (które dodatkowo przystępowały do stada od 1 marca do 30 września),
daty ich przystąpienia do stada, początkowy przydział myszy (obecny przydział, ze względu na podwyżkę po pół roku członkostwa,
jest o 10% wyższy od początkowego) , datę wspomnianej podwyżki o 10% oraz aktualnym przydział myszy.
Wykorzystać odpowiednie funkcje działające na datach. W poniższym rozwiązaniu datą bieżącą jest 11.07.2017
 */

SELECT
  value(k).imie                         "Imie",
  value(k).w_stadku_od                  "W stadku",
  ROUND(value(k).przydzial_myszy / 1.1) "Zjadal",
  ADD_MONTHS(value(k).w_stadku_od, 6)   "Podwyzka",
  value(k).przydzial_myszy              "Zjada"
FROM objkocury k
WHERE
  MONTHS_BETWEEN(SYSDATE, value(k).w_stadku_od) > 8 * 12 AND EXTRACT(MONTH FROM value(k).w_stadku_od) BETWEEN 3 AND 9
ORDER BY 5 DESC;

/*
Zad. 4. Znaleźć maksymalny całkowity przydział myszy dla wszystkich grup funkcyjnych
(z pominięciem SZEFUNIA i kotów płci męskiej) o średnim całkowitym przydziale
(z uwzględnieniem dodatkowych przydziałów – myszy_extra) większym  od 50.
 */
SELECT
  'Liczba kotow='                                                                        " ",
  COUNT(value(k).pseudo)                                                                 " ",
  'lowi jako'                                                                            " ",
  value(k).funkcja                                                                       " ",
  'i zjada max.'                                                                         " ",
  TO_CHAR(MAX(NVL(value(k).przydzial_myszy, 0) + NVL(value(k).myszy_extra, 0)), '99.00') " ",
  'myszy miesiecznie'                                                                    " "
FROM objkocury k
WHERE value(k).funkcja != 'SZEFUNIO' AND value(k).plec = 'D'
GROUP BY value(k).funkcja
HAVING AVG(NVL(value(k).przydzial_myszy, 0) + NVL(value(k).myszy_extra, 0)) > 50
ORDER BY 6 ASC;
