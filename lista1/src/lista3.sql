DROP TYPE PLEBS;
DROP TYPE KOCUR;
DROP TYPE INCYDENT;

CREATE OR REPLACE TYPE KOCUR AS OBJECT (
  imie            VARCHAR2(15),
  plec            VARCHAR2(1),
  pseudo          VARCHAR2(15),
  szef            REF KOCUR,
  w_stadku_od     DATE,
  przydzial_myszy NUMBER(3),
  myszy_extra     NUMBER(3),

MAP MEMBER FUNCTION porownajPoPseudo
  RETURN VARCHAR2
) NOT FINAL NOT INSTANTIABLE;

CREATE OR REPLACE TYPE PLEBS UNDER KOCUR();

CREATE OR REPLACE TYPE ELITA UNDER KOCUR(
  sluga REF PLEBS
);

CREATE OR REPLACE TYPE MYSZKA AS OBJECT (
  wlasciciel   REF ELITA,
  data_wplaty  DATE,
  data_wyplaty DATE
);

CREATE OR REPLACE TYPE INCYDENT AS OBJECT (
  kocur          REF KOCUR,
  imie_wroga     VARCHAR2(15),
  data_incydentu DATE,
  opis_incydentu VARCHAR2(50)
);

CREATE TABLE plebsy OF PLEBS (
  CONSTRAINT ob_pk PRIMARY KEY (pseudo)
);

CREATE TABLE koty OF kocur (
  CONSTRAINT koty_pk PRIMARY KEY (pseudo)
);

CREATE TABLE elity OF elita (
  CONSTRAINT elity_pk PRIMARY KEY (pseudo)
);
INSERT INTO koty
    VALUES(elita('plebs1','K','pseudo2',NULL,SYSDATE, 0,1,NULL));

COMMIT;
