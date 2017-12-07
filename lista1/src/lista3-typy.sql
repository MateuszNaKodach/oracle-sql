DROP TABLE objincydenty FORCE;
DROP TABLE objsludzyelit FORCE;
DROP TABLE objkocury FORCE;
DROP TABLE objmyszowekonto FORCE;


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
  RETURN VARCHAR2,
MEMBER FUNCTION dajCalaLiczbeMyszy
  RETURN NUMBER,
MEMBER FUNCTION dajSzefa
  RETURN KOCUR,
MEMBER FUNCTION czyPlebs
  RETURN BOOLEAN,
MEMBER FUNCTION czyElita
  RETURN BOOLEAN
) NOT FINAL NOT INSTANTIABLE;

CREATE OR REPLACE TYPE BODY KOCUR AS
  MAP MEMBER FUNCTION porownajPoPseudo
    RETURN VARCHAR2 IS
    BEGIN
      RETURN pseudo;
    END;

  MEMBER FUNCTION dajCalaLiczbeMyszy
    RETURN NUMBER IS
    BEGIN
      RETURN NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0);
    END;

  MEMBER FUNCTION dajSzefa
    RETURN KOCUR IS
    result KOCUR;
    BEGIN
      SELECT DEREF(szef)
      INTO result
      FROM dual;
      RETURN result;
    END;

  MEMBER FUNCTION czyElita
    RETURN BOOLEAN IS
    BEGIN
      RETURN status_spoleczny = 'ELITA';
    END;

  MEMBER FUNCTION czyPlebs
    RETURN BOOLEAN IS
    BEGIN
      RETURN status_spoleczny = 'PLEBS';
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
  pan      REF ELITA,
  sluga    REF PLEBS,
  ---CONSTRUCTOR FUNCTION SLUGA_ELITY(pan REF ELITA, sluga REF PLEBS) RETURN SELF AS RESULT,
MEMBER FUNCTION dajPseudoPana
  RETURN VARCHAR2,
MEMBER FUNCTION dajPseudoSlugi
  RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY SLUGA_ELITY AS
  MEMBER FUNCTION dajPseudoPana
    RETURN VARCHAR2 IS
    result VARCHAR2(15);
    BEGIN
      SELECT DEREF(pan).pseudo
      INTO result
      FROM dual;
      RETURN result;
    END;
  MEMBER FUNCTION dajPseudoSlugi
    RETURN VARCHAR2 IS
    result VARCHAR2(15);
    BEGIN
      SELECT DEREF(sluga).pseudo
      INTO result
      FROM dual;
      RETURN result;
    END;
END;

CREATE OR REPLACE TYPE MYSZKI_NA_KONCIE AS OBJECT (
  nr_wplaty    NUMBER,
  wlasciciel   REF ELITA,
  data_wplaty  DATE,
  data_wyplaty DATE,
MEMBER FUNCTION dajPseudoWlasciciela
  RETURN VARCHAR2,
MEMBER FUNCTION czyWyplacona
  RETURN BOOLEAN,
MEMBER FUNCTION czyWyplaconaWDzienWplaty
  RETURN BOOLEAN
);

CREATE OR REPLACE TYPE BODY MYSZKI_NA_KONCIE AS
  MEMBER FUNCTION dajPseudoWlasciciela
    RETURN VARCHAR2 IS
    result VARCHAR2(15);
    BEGIN
      SELECT DEREF(wlasciciel).pseudo
      INTO result
      FROM dual;
      RETURN result;
    END;
  MEMBER FUNCTION czyWyplacona
    RETURN BOOLEAN IS
    BEGIN
      RETURN data_wyplaty IS NOT NULL;
    END;
  MEMBER FUNCTION czyWyplaconaWDzienWplaty
    RETURN BOOLEAN IS
    BEGIN
      RETURN data_wplaty = data_wyplaty;
    END;
END;

CREATE OR REPLACE TYPE INCYDENT AS OBJECT (
  nr_incydentu   NUMBER,
  kot            REF KOCUR,
  imie_wroga     VARCHAR2(15),
  data_incydentu DATE,
  opis_incydentu VARCHAR2(50),
MAP MEMBER FUNCTION porownajPoDacie
  RETURN DATE,
MEMBER FUNCTION dajKota
  RETURN KOCUR,
MEMBER FUNCTION dajPseudoKota
  RETURN VARCHAR2,
MEMBER FUNCTION dajPlecKota
  RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY INCYDENT AS
  MAP MEMBER FUNCTION porownajPoDacie
    RETURN DATE IS
    BEGIN
      RETURN data_incydentu;
    END;
  MEMBER FUNCTION dajKota
    RETURN KOCUR IS
    result KOCUR;
    BEGIN
      SELECT DEREF(kot)
      INTO result
      FROM dual;
      RETURN result;
    END;
  MEMBER FUNCTION dajPseudoKota
    RETURN VARCHAR2 IS
    BEGIN
      RETURN self.dajKota().pseudo;
    END;
  MEMBER FUNCTION dajPlecKota
    RETURN VARCHAR2 IS
    BEGIN
      RETURN self.dajKota().plec;
    END;
END;

