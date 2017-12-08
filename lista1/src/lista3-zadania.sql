---Znajdz pseudonim najbardziej niezdecydowanego kota z całego stada, który najczęściej wpłacane na konto myszy wypłacał tego samego dnia.


SELECT *
FROM (
  SELECT value(p).dajPseudoWlasciciela() "Najbardzej niezdecydowana",
    COUNT(value(p).dajPseudoWlasciciela()) "Wyplacala w dniu wpłaty razy:"
  FROM objmyszowekonto p
  WHERE value(p).data_wplaty = value(p).data_wyplaty
  GROUP BY value(p).dajPseudoWlasciciela())
WHERE rownum <= 1;