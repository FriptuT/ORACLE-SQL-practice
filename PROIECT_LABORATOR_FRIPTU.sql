-- Creare tabela "articole"
CREATE TABLE articole (
    COD_ARTICOL NUMBER DEFAULT cheie_articole.nextval PRIMARY KEY,
    DENUMIRE_A VARCHAR2(255) NOT NULL,
    STOC NUMBER,
    UM VARCHAR2(50),
    PRETUNITAR NUMBER
);

-- Creare tabela "furnizor"
CREATE TABLE furnizor (
    CODF NUMBER DEFAULT cheie_furnizor.nextval PRIMARY KEY,
    NUMEF VARCHAR2(255) NOT NULL,
    ADRESA VARCHAR2(255)
);

-- Creare tabela "vanzari"
CREATE TABLE vanzari (
    CODFACTURA NUMBER DEFAULT cheie_vanzari.nextval PRIMARY KEY,
    COD_ARTICOL NUMBER,
    CANTIT NUMBER,
    DATA DATE,
    COST NUMBER,
    CONSTRAINT fk_vanzari_articole FOREIGN KEY (COD_ARTICOL) REFERENCES articole (COD_ARTICOL)
);

-- Creare tabela "intrari"
CREATE TABLE intrari (
    CODF NUMBER DEFAULT cheie_intrari_furnizor.nextval,
    COD_ARTICOL NUMBER DEFAULT cheie_intrari_articole.nextval,
    CANTITATE_FURNIZATA NUMBER,
    CONSTRAINT pk_intrari PRIMARY KEY (CODF, COD_ARTICOL),
    CONSTRAINT fk_intrari_furnizor FOREIGN KEY (CODF) REFERENCES furnizor (CODF),
    CONSTRAINT fk_intrari_articole FOREIGN KEY (COD_ARTICOL) REFERENCES articole (COD_ARTICOL)
);

CREATE SEQUENCE cheie_articole START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cheie_furnizor START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cheie_vanzari START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cheie_intrari_furnizor START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cheie_intrari_articole START WITH 1 INCREMENT BY 1 NOCACHE;

-- inserari furnizor
INSERT INTO furnizor (NUMEF, ADRESA) VALUES ('pcGarage', 'Bucuresti');
INSERT INTO furnizor (NUMEF, ADRESA) VALUES ('cerealeSRL', 'Craiova');

ALTER SEQUENCE cheie_furnizor RESTART;
select * from furnizor;

-- inserari articole
INSERT INTO articole (DENUMIRE_A, UM, PRETUNITAR) VALUES ('monitor', 'buc', 500.99);
INSERT INTO articole (DENUMIRE_A, UM, PRETUNITAR) VALUES ('procesor', 'buc', 777.99);

ALTER SEQUENCE cheie_articole RESTART;
select * from articole;

-- inserari intrari
INSERT INTO intrari (CANTITATE_FURNIZATA) VALUES (50);
INSERT INTO intrari (CANTITATE_FURNIZATA) VALUES (100);

ALTER SEQUENCE cheie_intrari_furnizor RESTART;
ALTER SEQUENCE cheie_intrari_articole RESTART;
select * from intrari;

--3 trigger calculare COST (vanzari) (vanzari.cantit x articole.pretunitar)
CREATE OR REPLACE TRIGGER calculeaza_cost_trigger
BEFORE INSERT ON vanzari
FOR EACH ROW
BEGIN
    SELECT a.PRETUNITAR * :NEW.CANTIT
    INTO :NEW.COST
    FROM articole a
    WHERE a.COD_ARTICOL = :NEW.COD_ARTICOL;
END;
/

-- inserare vanzari
INSERT INTO vanzari (COD_ARTICOL, CANTIT, DATA) VALUES (1, 20, TO_DATE('2024-01-07', 'YYYY-MM-DD'));
INSERT INTO vanzari (COD_ARTICOL, CANTIT, DATA) VALUES (2, 30, TO_DATE('2024-01-08', 'YYYY-MM-DD'));


ALTER SEQUENCE cheie_vanzari RESTART;
select * from vanzari;

-- actualizare STOC articol
CREATE OR REPLACE PROCEDURE actualizeaza_stoc(p_cod_articol NUMBER) AS
    v_intrari NUMBER;
    v_vanzari NUMBER;
BEGIN
    SELECT COALESCE(SUM(CANTITATE_FURNIZATA), 0) INTO v_intrari FROM intrari WHERE COD_ARTICOL = p_cod_articol;
    SELECT COALESCE(SUM(CANTIT), 0) INTO v_vanzari FROM vanzari WHERE COD_ARTICOL = p_cod_articol;

    UPDATE articole SET STOC = v_intrari - v_vanzari WHERE COD_ARTICOL = p_cod_articol;
END;
/

-- apelarea procedurii pentru actualizarea stocului
BEGIN 
    actualizeaza_stoc(p_cod_articol => 1);
    actualizeaza_stoc(p_cod_articol => 2);
END;

select * from articole;

--4.Procedura care determina stocul si cantit vanduta pentru articolul ' x '
CREATE OR REPLACE PROCEDURE determina_stoc_si_vanzari(p_cod_articol NUMBER) IS
    v_stoc NUMBER;
    v_cantitate_vanduta NUMBER;
BEGIN
    SELECT STOC INTO v_stoc FROM articole WHERE COD_ARTICOL = p_cod_articol;
    
    SELECT NVL(SUM(CANTIT), 0) INTO v_cantitate_vanduta
    FROM vanzari
    WHERE COD_ARTICOL = p_cod_articol;
    
    DBMS_OUTPUT.PUT_LINE('Stocul pentru produsul ' || p_cod_articol || ' este: ' || v_stoc);
    DBMS_OUTPUT.PUT_LINE('Cantitatea vanduta pentru produsul ' || p_cod_articol || ' este ' || v_cantitate_vanduta);
END determina_stoc_si_vanzari;
/

BEGIN
    determina_stoc_si_vanzari(1);
    determina_stoc_si_vanzari(2);
END;

--5.Determinati produsele care nu s-au vandut deloc intr-o perioada cu o functie
CREATE OR REPLACE FUNCTION produse_nevandute_in_perioada(p_data_inceput DATE, p_data_sfarsit DATE) RETURN SYS_REFCURSOR IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT a.COD_ARTICOL, a.DENUMIRE_A
        FROM articole a
        WHERE NOT EXISTS (
            SELECT 1
            FROM vanzari v
            WHERE v.COD_ARTICOL = a.COD_ARTICOL
            AND v.DATA BETWEEN p_data_inceput AND p_data_sfarsit
        );
        
    RETURN v_cursor;
END produse_nevandute_in_perioada;
/

DECLARE
    v_cursor SYS_REFCURSOR;
    var_cod_articol articole.COD_ARTICOL%TYPE;
    var_denumire_a articole.DENUMIRE_A%TYPE;
BEGIN
    -- perioada de testare
    v_cursor := produse_nevandute_in_perioada(TO_DATE('2024-01-15', 'YYYY-MM-DD'), TO_DATE('2024-01-22', 'YYYY-MM-DD'));
    
    -- Afisare rezultate
    DBMS_OUTPUT.PUT_LINE('Produsele nevandute in perioada specificata sunt: ');
    LOOP
        FETCH v_cursor INTO var_cod_articol, var_denumire_a;
        EXIT WHEN v_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Cod Articol: ' || var_cod_articol || ', Denumire: ' || var_denumire_a);
    END LOOP;
    
    CLOSE v_cursor;
END;
/

-- 6. Determinati numarul de bucati vandute pe fiecare produs in toata perioada
SELECT a.COD_ARTICOL, a.DENUMIRE_A, NVL(SUM(v.CANTIT), 0) AS BUCATI_VANDUTE
FROM articole a
LEFT JOIN vanzari v ON a.COD_ARTICOL = v.COD_ARTICOL
GROUP BY a.COD_ARTICOL, a.DENUMIRE_A;


