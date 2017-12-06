DROP TYPE INCYDENT FORCE;
DROP TYPE ELITA FORCE;
DROP TYPE PLEBS FORCE;
DROP TYPE KOCUR FORCE;
DROP TYPE sluga_elity FORCE ;

DROP TABLE objincydenty;
DROP TABLE objsludzyelit;
DROP TABLE objkocury;


CREATE OR REPLACE TYPE KOCUR AS OBJECT (
  imie             VARCHAR2(15),
  plec             VARCHAR2(1),
  pseudo           VARCHAR2(15),
  szef             REF KOCUR,
  w_stadku_od      DATE,
  przydzial_myszy  NUMBER(3),
  myszy_extra      NUMBER(3),
  status_spoleczny VARCHAR2(5),

MAP MEMBER FUNCTION porownajPoPseudo
  RETURN VARCHAR2
) NOT FINAL NOT INSTANTIABLE;

CREATE OR REPLACE TYPE PLEBS UNDER KOCUR(
  CONSTRUCTOR FUNCTION PLEBS(imie            VARCHAR2,
                             plec            VARCHAR2,
                             pseudo          VARCHAR2,
                             szef            REF KOCUR,
                             w_stadku_od     DATE,
                             przydzial_myszy NUMBER,
                             myszy_extra     NUMBER) RETURN SELF AS RESULT
);

CREATE OR REPLACE TYPE BODY PLEBS AS
  CONSTRUCTOR FUNCTION PLEBS(imie            VARCHAR2,
                             plec            VARCHAR2,
                             pseudo          VARCHAR2,
                             szef            REF KOCUR,
                             w_stadku_od     DATE,
                             przydzial_myszy NUMBER,
                             myszy_extra     NUMBER)
  RETURN SELF AS RESULT
  AS
    BEGIN
      self.imie := imie;
      self.plec := plec;
      self.pseudo := pseudo;
      self.szef := szef;
      self.w_stadku_od := w_stadku_od;
      self.przydzial_myszy := przydzial_myszy;
      self.myszy_extra := myszy_extra;
      self.status_spoleczny := 'PLEBS';
      RETURN;
    END;
END;

CREATE OR REPLACE TYPE ELITA UNDER KOCUR(
  sluga REF PLEBS,
  CONSTRUCTOR FUNCTION ELITA(imie            VARCHAR2,
                             plec            VARCHAR2,
                             pseudo          VARCHAR2,
                             szef            REF KOCUR,
                             w_stadku_od     DATE,
                             przydzial_myszy NUMBER,
                             myszy_extra     NUMBER) RETURN SELF AS RESULT
);

CREATE OR REPLACE TYPE BODY ELITA AS
  CONSTRUCTOR FUNCTION ELITA(imie            VARCHAR2,
                             plec            VARCHAR2,
                             pseudo          VARCHAR2,
                             szef            REF KOCUR,
                             w_stadku_od     DATE,
                             przydzial_myszy NUMBER,
                             myszy_extra     NUMBER)
  RETURN SELF AS RESULT
  AS
    BEGIN
      self.imie := imie;
      self.plec := plec;
      self.pseudo := pseudo;
      self.szef := szef;
      self.w_stadku_od := w_stadku_od;
      self.przydzial_myszy := przydzial_myszy;
      self.myszy_extra := myszy_extra;
      self.status_spoleczny := 'ELITA';
      RETURN;
    END;
END;

CREATE OR REPLACE TYPE SLUGA_ELITY AS OBJECT (
  pan   REF elita,
  sluga REF PLEBS
);

CREATE OR REPLACE TYPE MYSZKI_NA_KONCIE AS OBJECT (
  nr_wplaty    NUMBER,
  wlasciciel   REF ELITA,
  data_wplaty  DATE,
  data_wyplaty DATE
);

CREATE OR REPLACE TYPE INCYDENT AS OBJECT (
  kot            REF kocur,
  imie_wroga     VARCHAR2(15),
  data_incydentu DATE,
  opis_incydentu VARCHAR2(50)
);


CREATE TABLE objkocury OF KOCUR (
CONSTRAINT obj_kocury_pk PRIMARY KEY (pseudo),
CONSTRAINT obj_kocury_im CHECK (imie IS NOT NULL ),
CONSTRAINT obj_kocury_pl CHECK (plec IN ('M', 'D')),
CONSTRAINT obj_kocury_status CHECK (status_spoleczny IN ('PLEBS', 'ELITA')),
CONSTRAINT obj_kocury_szef szef SCOPE IS objkocury,
  w_stadku_od DEFAULT (SYSDATE)
);

CREATE TABLE objincydenty OF incydent (
CONSTRAINT obj_incydenty_data CHECK (data_incydentu IS NOT NULL ),
data_incydentu DEFAULT (SYSDATE),
CONSTRAINT obj_incydenty_kot kot SCOPE IS objkocury
);

CREATE TABLE objsludzyelit OF sluga_elity (
CONSTRAINT obj_sludzyelit_pan pan SCOPE IS objkocury,
CONSTRAINT obj_sludzyelit_sluga sluga SCOPE IS objkocury,
CONSTRAINT obj_sludzyelit_sluga_nn CHECK (sluga IS NOT NULL ),
CONSTRAINT obj_sludzyelit_sluga_nn CHECK (pan IS NOT NULL )
);

DELETE FROM objkocury;

COMMIT;
INSERT INTO objkocury VALUES (elita('MRUCZEK', 'M', 'TYGRYS', NULL, '2002-01-01', 103, 33));
INSERT INTO objkocury VALUES (plebs('RUDA', 'D', 'MALA', (SELECT REF(k) FROM objkocury k WHERE k.pseudo='TYGRYS'), '2006-09-17', 22, 42));
INSERT INTO objkocury VALUES (plebs('MICKA', 'D', 'LOLA', (SELECT REF(k) FROM objkocury k WHERE k.pseudo='TYGRYS'), '2009-10-14', 25, 47));
INSERT INTO objkocury VALUES (plebs('PUCEK', 'M', 'RAFA', (SELECT REF(k) FROM objkocury k WHERE k.pseudo='TYGRYS'), '2006-10-15', 65, NULL));

---INSERT INTO objkocury VALUES(plebs('BARI', 'M', 'RURA', (SELECT REF(k) FROM objkocury k WHERE k.pseudo='TYGRYS'), '2009-09-01', 56, NULL))
COMMIT;


---FUNKCJA TREAT: http://psoug.org/definition/TREAT.htm
INSERT INTO objsludzyelit VALUES (
  (SELECT TREAT ((SELECT REF(p) FROM objkocury p WHERE p.pseudo = 'TYGRYS') AS REF elita) FROM dual),
  (SELECT TREAT ((SELECT REF(p) FROM objkocury p WHERE p.pseudo = 'LOLA') AS REF plebs) FROM dual)
);
COMMIT;

SELECT value(p)
FROM objkocury p
WHERE VALUE(p) IS OF (elita);
COMMIT;


SELECT TREAT(value(k) AS elita)
FROM objkocury k
WHERE value(k) is of (elita);
