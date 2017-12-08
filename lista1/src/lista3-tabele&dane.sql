DROP TABLE objincydenty;
DROP TABLE objsludzyelit;
DROP TABLE objkocury;
DROP TABLE objmyszowekonto FORCE;

DROP TYPE INCYDENT FORCE;
DROP TYPE ELITA FORCE;
DROP TYPE PLEBS FORCE;
DROP TYPE KOCUR FORCE;
DROP TYPE SLUGA_ELITY FORCE;


CREATE TABLE objkocury OF KOCUR (
CONSTRAINT obj_kocury_pk PRIMARY KEY (pseudo),
CONSTRAINT obj_kocury_im CHECK (imie IS NOT NULL),
CONSTRAINT obj_kocury_pl CHECK (plec IN ('M', 'D')),
CONSTRAINT obj_kocury_status CHECK (status_spoleczny IN ('PLEBS', 'ELITA')),
CONSTRAINT obj_kocury_szef szef SCOPE IS objkocury,  w_stadku_od DEFAULT (SYSDATE)
);

CREATE TABLE objmyszowekonto OF myszki_na_koncie (
CONSTRAINT obj_myszowekonto_pk PRIMARY KEY (nr_wplaty),
CONSTRAINT obj_myszowekonto_wl wlasciciel SCOPE IS objkocury,
CONSTRAINT obj_wyplata_po_wpalcie_chck CHECK (data_wplaty<=data_wyplaty),
  data_wplaty DEFAULT (SYSDATE)
);

CREATE TABLE objincydenty OF INCYDENT (
CONSTRAINT obj_incydenty_pk PRIMARY KEY (nr_incydentu),
CONSTRAINT obj_incydenty_data CHECK (data_incydentu IS NOT NULL),
  data_incydentu DEFAULT (SYSDATE),
CONSTRAINT obj_incydenty_kot kot SCOPE IS objkocury
);

CREATE TABLE objsludzyelit OF SLUGA_ELITY (
CONSTRAINT obj_sludzyelit_pk PRIMARY KEY (nr_slugi),
CONSTRAINT obj_sludzyelit_pan pan SCOPE IS objkocury,
CONSTRAINT obj_sludzyelit_sluga sluga SCOPE IS objkocury,
CONSTRAINT obj_sludzyelit_sluga_nn CHECK (sluga IS NOT NULL),
CONSTRAINT obj_sludzyelit_pan_nn CHECK (pan IS NOT NULL)
);

---TRIGGER NA TYLKO JEDNEGO SLUGE DLA ELITY
--ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

CREATE OR REPLACE TRIGGER jeden_sluga_dla_elity
  BEFORE INSERT OR UPDATE ON objsludzyelit
  FOR EACH ROW
  DECLARE
    ile_slug INTEGER;
    nadmiar_slug EXCEPTION;
    BEGIN

    SELECT COUNT(*) INTO ile_slug
    FROM objkocury K
    WHERE K.pseudo =DEREF(:NEW.pan).pseudo;

    IF(ile_slug>1)
      THEN
      RAISE nadmiar_slug;
    END IF;

  END;

--select * from user_errors;
---WYPELNIENIE TABELI objkocury-----------------------------------------------------------------------------------------
INSERT INTO objkocury VALUES (elita('MRUCZEK', 'M', 'TYGRYS', NULL, '2002-01-01', 103, 33));
INSERT INTO objkocury VALUES (elita('RUDA', 'D', 'MALA', (SELECT REF(k)
                                                          FROM objkocury k
                                                          WHERE k.pseudo = 'TYGRYS'), '2006-09-17', 22, 42));
INSERT INTO objkocury VALUES (elita('MICKA', 'D', 'LOLA', (SELECT REF(k)
                                                           FROM objkocury k
                                                           WHERE k.pseudo = 'TYGRYS'), '2009-10-14', 25, 47));
INSERT INTO objkocury VALUES (elita('PUCEK', 'M', 'RAFA', (SELECT REF(k)
                                                           FROM objkocury k
                                                           WHERE k.pseudo = 'TYGRYS'), '2006-10-15', 65, NULL));
INSERT INTO objkocury VALUES (elita('CHYTRY', 'M', 'BOLEK', (SELECT REF(k)
                                                             FROM objkocury k
                                                             WHERE k.pseudo = 'TYGRYS'), '2002-05-05', 50, NULL));
INSERT INTO objkocury VALUES (elita('KOREK', 'M', 'ZOMBI', (SELECT REF(k)
                                                            FROM objkocury k
                                                            WHERE k.pseudo = 'TYGRYS'), '2004-03-16', 75, 13));
INSERT INTO objkocury VALUES (elita('BOLEK', 'M', 'LYSY', (SELECT REF(k)
                                                           FROM objkocury k
                                                           WHERE k.pseudo = 'TYGRYS'), '2006-08-15', 72, 21));
INSERT INTO objkocury VALUES (plebs('KSAWERY', 'M', 'MAN', (SELECT REF(k)
                                                            FROM objkocury k
                                                            WHERE k.pseudo = 'RAFA'), '2008-07-12', 51, NULL));
INSERT INTO objkocury VALUES (plebs('MELA', 'D', 'DAMA', (SELECT REF(k)
                                                          FROM objkocury k
                                                          WHERE k.pseudo = 'RAFA'), '2008-11-01', 51, NULL));
INSERT INTO objkocury VALUES (plebs('LATKA', 'D', 'UCHO', (SELECT REF(k)
                                                           FROM objkocury k
                                                           WHERE k.pseudo = 'RAFA'), '2011-01-01', 40, NULL));
INSERT INTO objkocury VALUES (plebs('DUDEK', 'M', 'MALY', (SELECT REF(k)
                                                           FROM objkocury k
                                                           WHERE k.pseudo = 'RAFA'), '2011-05-15', 40, NULL));
INSERT INTO objkocury VALUES (plebs('ZUZIA' ,'D', 'SZYBKA', (SELECT REF(k)
                                                             FROM objkocury k
                                                             WHERE k.pseudo = 'LYSY'), '2006-07-21', 65, NULL));
INSERT INTO objkocury VALUES (plebs('BELA', 'D', 'LASKA', (SELECT REF(k)
                                                           FROM objkocury k
                                                           WHERE k.pseudo = 'LYSY'), '2008-02-01', 24, 28));
INSERT INTO objkocury VALUES (plebs('JACEK', 'M', 'PLACEK', (SELECT REF(k)
                                                             FROM objkocury k
                                                             WHERE k.pseudo = 'LYSY'), '2008-12-01', 67, NULL));
INSERT INTO objkocury VALUES (plebs('BARI', 'M', 'RURA', (SELECT REF(k)
                                                          FROM objkocury k
                                                          WHERE k.pseudo = 'LYSY'), '2009-09-01', 56, NULL));
INSERT INTO objkocury VALUES (plebs('PUNIA', 'D', 'KURKA', (SELECT REF(k)
                                                            FROM objkocury k
                                                            WHERE k.pseudo = 'ZOMBI'), '2008-01-01', 61, NULL));
INSERT INTO objkocury VALUES (plebs('SONIA', 'D', 'PUSZYSTA', (SELECT REF(k)
                                                               FROM objkocury k
                                                               WHERE k.pseudo = 'ZOMBI'), '2010-11-18', 20, 35));
INSERT INTO objkocury VALUES (plebs('LUCEK', 'M', 'ZERO', (SELECT REF(k)
                                                           FROM objkocury k
                                                           WHERE k.pseudo = 'KURKA'), '2010-03-01', 43, NULL));
COMMIT;

---WYPELNIENIE TABELI objsludzyelit-----------------------------------------------------------------------------------------
---FUNKCJA TREAT: http://psoug.org/definition/TREAT.htm
INSERT INTO objsludzyelit VALUES (
  1,
  (SELECT TREAT((SELECT REF(p)
                 FROM objkocury p
                 WHERE p.pseudo = 'TYGRYS') AS REF ELITA)
   FROM dual),
  (SELECT TREAT((SELECT REF(p)
                 FROM objkocury p
                 WHERE p.pseudo = 'DAMA') AS REF PLEBS)
   FROM dual)
);

INSERT INTO objsludzyelit VALUES (
  2,
  (SELECT TREAT((SELECT REF(p)
                 FROM objkocury p
                 WHERE p.pseudo = 'MALA') AS REF ELITA)
   FROM dual),
  (SELECT TREAT((SELECT REF(p)
                 FROM objkocury p
                 WHERE p.pseudo = 'MAN') AS REF PLEBS)
   FROM dual)
);

INSERT INTO objsludzyelit VALUES (
  3,
  (SELECT TREAT((SELECT REF(p)
                 FROM objkocury p
                 WHERE p.pseudo = 'LOLA') AS REF ELITA)
   FROM dual),
  (SELECT TREAT((SELECT REF(p)
                 FROM objkocury p
                 WHERE p.pseudo = 'UCHO') AS REF PLEBS)
   FROM dual)
);

INSERT INTO objsludzyelit VALUES (
  4,
  (SELECT TREAT((SELECT REF(p)
                 FROM objkocury p
                 WHERE p.pseudo = 'RAFA') AS REF ELITA)
   FROM dual),
  (SELECT TREAT((SELECT REF(p)
                 FROM objkocury p
                 WHERE p.pseudo = 'MALY') AS REF PLEBS)
   FROM dual)
);

COMMIT;

---WSZYSCY SLUDZY ELIT:

SELECT DEREF(s.pan).pseudo "Pan",
  DEREF(s.sluga).pseudo "Sługa"
FROM objsludzyelit s;

---WYPELNIENIE TABELI objincydenty-----------------------------------------------------------------------------------------
INSERT INTO objincydenty VALUES(1,(SELECT REF(k)
                                   FROM objkocury k
                                   WHERE k.pseudo = 'TYGRYS'),'KAZIO','2004-10-13','USILOWAL NABIC NA WIDLY');
INSERT INTO objincydenty VALUES(2,(SELECT REF(k)
                                   FROM objkocury k
                                   WHERE k.pseudo = 'ZOMBI'),'SWAWOLNY DYZIO','2005-03-07','WYBIL OKO Z PROCY');
INSERT INTO objincydenty VALUES(3,(SELECT REF(k)
                                   FROM objkocury k
                                   WHERE k.pseudo = 'BOLEK'),'KAZIO','2005-03-29','POSZCZUL BURKIEM');
INSERT INTO objincydenty VALUES(4,(SELECT REF(k)
                                   FROM objkocury k
                                   WHERE k.pseudo = 'SZYBKA'),'GLUPIA ZOSKA', '2006-09-12', 'UZYLA KOTA JAKO SCIERKI');
INSERT INTO objincydenty VALUES(5,(SELECT REF(k)
                                   FROM objkocury k
                                   WHERE k.pseudo = 'MALA'),'CHYTRUSEK', '2007-03-07', 'ZALECAL SIE');
INSERT INTO objincydenty VALUES(6,(SELECT REF(k)
                                   FROM objkocury k
                                   WHERE k.pseudo = 'TYGRYS'),'DZIKI BILL', '2007-06-12', 'USILOWAL POZBAWIC ZYCIA');
INSERT INTO objincydenty VALUES(7,(SELECT REF(k)
                                   FROM objkocury k
                                   WHERE k.pseudo = 'BOLEK'),'DZIKI BILL', '2007-11-10', 'ODGRYZL UCHO');
INSERT INTO objincydenty VALUES(8,(SELECT REF(k)
                                   FROM objkocury k
                                   WHERE k.pseudo = 'LASKA'),'DZIKI BILL', '2008-12-12', 'POGRYZL ZE LEDWO SIE WYLIZALA');
INSERT INTO objincydenty VALUES(9,(SELECT REF(k)
                                   FROM objkocury k
                                   WHERE k.pseudo = 'LASKA'),'KAZIO', '2009-01-07', 'ZLAPAL ZA OGON I ZROBIL WIATRAK');
INSERT INTO objincydenty VALUES(10,(SELECT REF(k)
                                   FROM objkocury k
                                   WHERE k.pseudo = 'DAMA'),'KAZIO', '2009-02-07', 'CHCIAL OBEDRZEC ZE SKORY');
INSERT INTO objincydenty VALUES(11,(SELECT REF(k)
                                    FROM objkocury k
                                    WHERE k.pseudo = 'MAN'), 'REKSIO', '2009-04-14', 'WYJATKOWO NIEGRZECZNIE OBSZCZEKAL');
INSERT INTO objincydenty VALUES(12,(SELECT REF(k)
                                    FROM objkocury k
                                    WHERE k.pseudo = 'LYSY'), 'BETHOVEN', '2009-05-11', 'NIE PODZIELIL SIE SWOJA KASZA');
INSERT INTO objincydenty VALUES(13,(SELECT REF(k)
                                    FROM objkocury k
                                    WHERE k.pseudo = 'RURA'), 'DZIKI BILL','2009-09-03', 'ODGRYZL OGON');
INSERT INTO objincydenty VALUES(14,(SELECT REF(k)
                                    FROM objkocury k
                                    WHERE k.pseudo = 'PLACEK'), 'BAZYLI', '2010-07-12', 'DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA');
INSERT INTO objincydenty VALUES(15,(SELECT REF(k)
                                    FROM objkocury k
                                    WHERE k.pseudo = 'PUSZYSTA'), 'SMUKLA', '2010-11-19', 'OBRZUCILA SZYSZKAMI');
INSERT INTO objincydenty VALUES(16,(SELECT REF(k)
                                    FROM objkocury k
                                    WHERE k.pseudo = 'KURKA'), 'BUREK', '2010-12-14', 'POGONIL');
INSERT INTO objincydenty VALUES(17,(SELECT REF(k)
                                    FROM objkocury k
                                    WHERE k.pseudo = 'MALY'), 'CHYTRUSEK', '2011-07-13', 'PODEBRAL PODEBRANE JAJKA');
INSERT INTO objincydenty VALUES(18,(SELECT REF(k)
                                    FROM objkocury k
                                    WHERE k.pseudo = 'UCHO'), 'SWAWOLNY DYZIO', '2011-07-14', 'OBRZUCIL KAMIENIAMI');

COMMIT;


---WYPELNIENIE TABELI objmyszowekonto-----------------------------------------------------------------------------------------

INSERT INTO objmyszowekonto VALUES(1,(SELECT TREAT((SELECT REF(p)
                                                    FROM objkocury p
                                                    WHERE p.pseudo = 'TYGRYS') AS REF ELITA)FROM dual),'2017-01-01',NULL);
INSERT INTO objmyszowekonto VALUES(2,(SELECT TREAT((SELECT REF(p)
                                                    FROM objkocury p
                                                    WHERE p.pseudo = 'TYGRYS') AS REF ELITA)FROM dual),'2017-01-02',NULL);
INSERT INTO objmyszowekonto VALUES(3,(SELECT TREAT((SELECT REF(p)
                                                    FROM objkocury p
                                                    WHERE p.pseudo = 'TYGRYS') AS REF ELITA)FROM dual),'2017-01-03','2017-01-04');
INSERT INTO objmyszowekonto VALUES(4,(SELECT TREAT((SELECT REF(p)
                                                    FROM objkocury p
                                                    WHERE p.pseudo = 'TYGRYS') AS REF ELITA)FROM dual),'2017-01-05',NULL);
INSERT INTO objmyszowekonto VALUES(5,(SELECT TREAT((SELECT REF(p)
                                                    FROM objkocury p
                                                    WHERE p.pseudo = 'LOLA') AS REF ELITA)FROM dual),'2017-03-05',NULL);
INSERT INTO objmyszowekonto VALUES(6,(SELECT TREAT((SELECT REF(p)
                                                    FROM objkocury p
                                                    WHERE p.pseudo = 'LOLA') AS REF ELITA)FROM dual),'2017-03-05','2017-03-06');
INSERT INTO objmyszowekonto VALUES(7,(SELECT TREAT((SELECT REF(p)
                                                    FROM objkocury p
                                                    WHERE p.pseudo = 'LOLA') AS REF ELITA)FROM dual),'2017-03-07','2017-03-07');
INSERT INTO objmyszowekonto VALUES(8,(SELECT TREAT((SELECT REF(p)
                                                    FROM objkocury p
                                                    WHERE p.pseudo = 'LYSY') AS REF ELITA)FROM dual),'2017-03-08','2017-03-10');
INSERT INTO objmyszowekonto VALUES(9,(SELECT TREAT((SELECT REF(p)
                                                    FROM objkocury p
                                                    WHERE p.pseudo = 'LYSY') AS REF ELITA)FROM dual),'2017-03-12','2017-03-15');
INSERT INTO objmyszowekonto VALUES(10,(SELECT TREAT((SELECT REF(p)
                                                    FROM objkocury p
                                                    WHERE p.pseudo = 'LYSY') AS REF ELITA)FROM dual),'2017-03-18','2017-03-21');
INSERT INTO objmyszowekonto VALUES(11,(SELECT TREAT((SELECT REF(p)
                                                    FROM objkocury p
                                                    WHERE p.pseudo = 'LOLA') AS REF ELITA)FROM dual),'2017-05-05','2017-05-05');
INSERT INTO objmyszowekonto VALUES(12,(SELECT TREAT((SELECT REF(p)
                                                     FROM objkocury p
                                                     WHERE p.pseudo = 'LOLA') AS REF ELITA)FROM dual),'2017-05-12','2017-05-12');
INSERT INTO objmyszowekonto VALUES(13,(SELECT TREAT((SELECT REF(p)
                                                     FROM objkocury p
                                                     WHERE p.pseudo = 'LOLA') AS REF ELITA)FROM dual),'2017-05-15','2017-05-15');
INSERT INTO objmyszowekonto VALUES(14,(SELECT TREAT((SELECT REF(p)
                                                     FROM objkocury p
                                                     WHERE p.pseudo = 'LYSY') AS REF ELITA)FROM dual),'2017-03-18','2017-03-18');
COMMIT;



SELECT value(p)
FROM objkocury p
WHERE VALUE(p) IS OF (ELITA);


SELECT TREAT(value(k) AS ELITA)
FROM objkocury k
WHERE value(k) IS OF (ELITA);
