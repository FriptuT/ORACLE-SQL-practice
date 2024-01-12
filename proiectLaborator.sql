DROP TABLE articole;
DROP TABLE furnizor;
DROP TABLE intrari;
DROP TABLE vanzari;

CREATE TABLE articole (
    COD_ARTICOL NUMBER DEFAULT cheie_articole.nextval PRIMARY KEY,
    DENUMIRE_ARTICOL VARCHAR2(100),
    STOC NUMBER,
    UM VARCHAR2(10),
    PRETUNITAR NUMBER(10,2)
);

CREATE TABLE furnizor (
    COD_FURNIZOR NUMBER DEFAULT cheie_furnizor.nextval PRIMARY KEY,
    NUME_FURNIZOR VARCHAR2(100),
    ADRESA VARCHAR2(100)
);

CREATE TABLE vanzari (
    CODFACTURA NUMBER DEFAULT cheie_vanzari.nextval PRIMARY KEY,
    COD_ARTICOL NUMBER,
    CANTITATE NUMBER,
    DATA_VANZARII DATE,
    COST NUMBER(10,2),
    FOREIGN KEY (COD_ARTICOL) REFERENCES articole(COD_ARTICOL)
);

CREATE TABLE intrari (
    ID NUMBER DEFAULT cheie_intrari.nextval PRIMARY KEY,
    CODF NUMBER ,
    COD_ARTICOL NUMBER,
    CANTITATE_FURNIZATA NUMBER,
    FOREIGN KEY (CODF) REFERENCES furnizor(COD_FURNIZOR),
    FOREIGN KEY (COD_ARTICOL) REFERENCES articole(COD_ARTICOL)
);

--2. Construiti o secventa pentru generarea de chei primare
CREATE SEQUENCE cheie_articole START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cheie_furnizor START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cheie_vanzari START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cheie_intrari START WITH 1 INCREMENT BY 1 NOCACHE;


-- instantiere articole
INSERT INTO articole (DENUMIRE_ARTICOL, STOC, UM, PRETUNITAR) VALUES('tastatura-wireless', 10, 'buc', 15.99);--
INSERT INTO articole (DENUMIRE_ARTICOL, STOC, UM, PRETUNITAR) VALUES ('mouse-wireless', 25, 'buc', 10.15);--
INSERT INTO articole (DENUMIRE_ARTICOL, STOC, UM, PRETUNITAR) VALUES ('camera-wireless', 25, 'buc', 10.15);--
INSERT INTO articole (DENUMIRE_ARTICOL, STOC, UM, PRETUNITAR) VALUES ('boxa-wireless', 50, 'buc', 22.15);--
INSERT INTO articole (DENUMIRE_ARTICOL, STOC, UM, PRETUNITAR) VALUES ('pix-gel', 150, 'buc', 1.15);--
INSERT INTO articole (DENUMIRE_ARTICOL, STOC, UM, PRETUNITAR) VALUES ('faina-ovaz', 100, 'kg', 3.15);--
INSERT INTO articole (DENUMIRE_ARTICOL, STOC, UM, PRETUNITAR) VALUES ('faina-grau', 200, 'kg', 2.15);--
INSERT INTO articole (DENUMIRE_ARTICOL, STOC, UM, PRETUNITAR) VALUES ('fulgi-ovaz', 300, 'kg', 4.25);--

ALTER SEQUENCE cheie_articole RESTART;

DELETE FROM articole WHERE COD_ARTICOL = 3;
SELECT * FROM articole;

--instantiere furnizor
INSERT INTO furnizor (NUME_FURNIZOR, ADRESA) VALUES ('PC-Garage', 'Bucuresti, Str. Vlad Tepes, nr.8');
INSERT INTO furnizor (NUME_FURNIZOR, ADRESA) VALUES ('CerealeSRL', 'Craiova, Str. Sfintii Apostoli , nr.3');
INSERT INTO furnizor (NUME_FURNIZOR, ADRESA) VALUES ('LuceafarulSRL', 'Craiova, Str. Henri Coanda , nr.8');

ALTER SEQUENCE cheie_furnizor RESTART;
SELECT * FROM furnizor;

--instantiere vanzari
INSERT INTO vanzari (COD_ARTICOL, CANTITATE, DATA_VANZARII) VALUES (1, 5, TO_DATE('2024-01-01', 'YYYY-MM-DD'));
INSERT INTO vanzari (COD_ARTICOL, CANTITATE, DATA_VANZARII) VALUES (2, 10, TO_DATE('2024-01-02', 'YYYY-MM-DD'));
INSERT INTO vanzari (COD_ARTICOL, CANTITATE, DATA_VANZARII) VALUES (3, 8, TO_DATE('2024-01-03', 'YYYY-MM-DD'));
INSERT INTO vanzari (COD_ARTICOL, CANTITATE, DATA_VANZARII) VALUES (4, 21, TO_DATE('2024-01-04', 'YYYY-MM-DD'));
INSERT INTO vanzari (COD_ARTICOL, CANTITATE, DATA_VANZARII) VALUES (5, 80, TO_DATE('2024-01-15', 'YYYY-MM-DD'));
INSERT INTO vanzari (COD_ARTICOL, CANTITATE, DATA_VANZARII) VALUES (6, 70, TO_DATE('2024-01-16', 'YYYY-MM-DD'));
INSERT INTO vanzari (COD_ARTICOL, CANTITATE, DATA_VANZARII) VALUES (7, 72, TO_DATE('2024-01-22', 'YYYY-MM-DD'));
INSERT INTO vanzari (COD_ARTICOL, CANTITATE, DATA_VANZARII) VALUES (8, 150, TO_DATE('2024-01-25', 'YYYY-MM-DD'));
    
ALTER SEQUENCE cheie_vanzari RESTART;

SELECT * FROM articole;
SELECT * FROM vanzari;

--instantiere intrari
INSERT INTO intrari (CODF, COD_ARTICOL, CANTITATE_FURNIZATA) VALUES (1,1,20);
INSERT INTO intrari (CODF, COD_ARTICOL, CANTITATE_FURNIZATA) VALUES (2,2,30);
INSERT INTO intrari (CODF, COD_ARTICOL, CANTITATE_FURNIZATA) VALUES (3,3,15);
INSERT INTO intrari (CODF, COD_ARTICOL, CANTITATE_FURNIZATA) VALUES (1,4,40);
INSERT INTO intrari (CODF, COD_ARTICOL, CANTITATE_FURNIZATA) VALUES (2,5,100);
INSERT INTO intrari (CODF, COD_ARTICOL, CANTITATE_FURNIZATA) VALUES (3,6,50);
INSERT INTO intrari (CODF, COD_ARTICOL, CANTITATE_FURNIZATA) VALUES (1,7,60);
INSERT INTO intrari (CODF, COD_ARTICOL, CANTITATE_FURNIZATA) VALUES (2,8,120);


ALTER SEQUENCE cheie_intrari RESTART;

SELECT * FROM intrari;

DELETE FROM articole;
DELETE FROM intrari;
DELETE FROM vanzari;
DELETE FROM furnizor;


UPDATE articole
SET STOC = (SELECT CANTITATE_FURNIZATA FROM intrari WHERE articole.COD_ARTICOL = intrari.COD_ARTICOL);

SELECT * FROM articole;

-----------------------CERINTE----------------------------
--3. Calculati campul COST (vanzari.CANTITATE x articole.PRETUNITAR) cu un trigger
CREATE OR REPLACE TRIGGER calculate_cost_trigger
BEFORE INSERT ON vanzari
FOR EACH ROW
BEGIN
    SELECT a.PRETUNITAR * :NEW.CANTITATE
    INTO :NEW.COST
    FROM articole a
    WHERE a.COD_ARTICOL = :NEW.COD_ARTICOL;
END;
/
SELECT * FROM vanzari;

--4. Procedura care determina stocul si cantitatea vanduta pentru articolul 'x'

