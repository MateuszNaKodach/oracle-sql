DROP TABLE objincydenty;
DROP TABLE objsludzyelit;
DROP TABLE objkocury;

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












---INSERT INTO objkocury VALUES(plebs('BARI', 'M', 'RURA', (SELECT REF(k) FROM objkocury k WHERE k.pseudo='TYGRYS'), '2009-09-01', 56, NULL))
COMMIT;

---FUNKCJA TREAT: http://psoug.org/definition/TREAT.htm
INSERT INTO objsludzyelit VALUES (
  (SELECT TREAT((SELECT REF(p)
                 FROM objkocury p
                 WHERE p.pseudo = 'TYGRYS') AS REF ELITA)
   FROM dual),
  (SELECT TREAT((SELECT REF(p)
                 FROM objkocury p
                 WHERE p.pseudo = 'LOLA') AS REF PLEBS)
   FROM dual)
);
COMMIT;

SELECT value(p)
FROM objkocury p
WHERE VALUE(p) IS OF (ELITA);
COMMIT;


SELECT TREAT(value(k) AS ELITA)
FROM objkocury k
WHERE value(k) IS OF (ELITA);
