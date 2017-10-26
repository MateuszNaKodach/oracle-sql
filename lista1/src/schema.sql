CREATE TABLE Funkcje
(
  funkcja VARCHAR2(10) CONSTRAINT fun_pr PRIMARY KEY,
  min_myszy NUMBER(3) CONSTRAINT fun_minmyszy_ch CHECK(min_myszy>5),
  max_myszy NUMBER(3) CONSTRAINT fun_maxmyszy_high_ch CHECK(max_myszy<200),
  CONSTRAINT fun_maxmyszy_low_ch CHECK(max_myszy>min_myszy)
);

CREATE TABLE Wrogowie (
  imie_wroga VARCHAR2(15) CONSTRAINT wrog_pr PRIMARY KEY,
  stopien_wrogosci NUMBER(2) CONSTRAINT wrog_sw_ch CHECK(stopien_wrogosci BETWEEN 1 AND 10),
  gatunek VARCHAR2(15),
  lapowka VARCHAR2(20)
);


CREATE TABLE Kocury
(
  imie VARCHAR2(15) CONSTRAINT koc_imie_nn NOT NULL,
  plec VARCHAR2(1) CONSTRAINT koc_plec_ch CHECK(plec IN ('D','M')),
  pseudo VARCHAR2(15) CONSTRAINT koc_pr PRIMARY KEY,
  funkcja VARCHAR2(10),
  szef VARCHAR2(15),
  w_stadku_od DATE DEFAULT SYSDATE,
  przydzial_myszy NUMBER(3),
  myszy_extra NUMBER(3),
  nr_bandy NUMBER(2),
  CONSTRAINT koc_fun_fk FOREIGN KEY(funkcja)
  REFERENCES Funkcje(funkcja),
  CONSTRAINT koc_szef_fk FOREIGN KEY(szef)
  REFERENCES Kocury(pseudo)
);

CREATE TABLE Bandy
(
  nr_bandy NUMBER(2) CONSTRAINT band_pr PRIMARY KEY,
  nazwa VARCHAR2(20) CONSTRAINT band_nazwa_nn NOT NULL,
  teren VARCHAR2(15) CONSTRAINT ban_teren_uq UNIQUE,
  szef_bandy VARCHAR2(15),
  CONSTRAINT band_szef_fk FOREIGN KEY(szef_bandy)
  REFERENCES Kocury(pseudo)
);

ALTER TABLE Kocury
  ADD CONSTRAINT koc_band_fk FOREIGN KEY(nr_bandy)
REFERENCES Bandy(nr_bandy);

CREATE TABLE Wrogowie_Kocurow
(
  pseudo VARCHAR2(15),
  imie_wroga VARCHAR2(15),
  data_incydentu DATE CONSTRAINT wrog_data_nn NOT NULL,
  opis_incydentu VARCHAR2(50),
  CONSTRAINT wrogkoc_pseud_fk FOREIGN KEY(pseudo)
  REFERENCES Kocury(pseudo),
  CONSTRAINT wrogkoc_imie_fk FOREIGN KEY(imie_wroga)
  REFERENCES Wrogowie(imie_wroga),
  CONSTRAINT wrogkoc_pk PRIMARY KEY(pseudo,imie_wroga)
);



