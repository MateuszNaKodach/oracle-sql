DROP TABLE objincydenty;
DROP TABLE objsludzyelit;
DROP TABLE objkocury;

DROP TYPE INCYDENT FORCE;
DROP TYPE ELITA FORCE;
DROP TYPE PLEBS FORCE;
DROP TYPE KOCUR FORCE;
DROP TYPE SLUGA_ELITY FORCE;


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

CREATE OR REPLACE TYPE BODY KOCUR AS
     MAP MEMBER FUNCTION porownajPoPseudo RETURN VARCHAR2 IS
     BEGIN
      RETURN pseudo;
     END;
    END;


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
  nr_slugi NUMBER,
  pan         REF ELITA,
  sluga       REF PLEBS,
  CONSTRUCTOR FUNCTION SLUGA_ELITY(pan REF ELITA, sluga REF PLEBS) RETURN SELF AS RESULT,
MEMBER FUNCTION dajPseudoPana RETURN VARCHAR2
);

CREATE OR REPLACE TYPE MYSZKI_NA_KONCIE AS OBJECT (
  nr_wplaty    NUMBER,
  wlasciciel   REF ELITA,
  data_wplaty  DATE,
  data_wyplaty DATE
);

CREATE OR REPLACE TYPE INCYDENT AS OBJECT (
  nr_incydentu    NUMBER,
  kot            REF KOCUR,
  imie_wroga     VARCHAR2(15),
  data_incydentu DATE,
  opis_incydentu VARCHAR2(50)
);