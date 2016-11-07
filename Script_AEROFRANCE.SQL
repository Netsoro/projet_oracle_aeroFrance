-- -----------------------------------------------------------------------------
--             Génération d'une base de données pour
--                      Oracle Version 10g
--                        (24/10/2016 13:15:01)
-- -----------------------------------------------------------------------------
--      Nom de la base : MLR3_aeroFrance
--      Projet : Accueil Win'Design version 13 démo
--      Auteur : UT1C
--      Date de dernière modification : 24/10/2016 13:14:11
-- -----------------------------------------------------------------------------

DROP TABLE COUPON_VOL CASCADE CONSTRAINTS;

DROP TABLE OCCURENCE_VOL CASCADE CONSTRAINTS;

DROP TABLE VOL CASCADE CONSTRAINTS;

DROP TABLE AEROPORT CASCADE CONSTRAINTS;

DROP TABLE RETARD CASCADE CONSTRAINTS;

DROP TABLE BILLET CASCADE CONSTRAINTS;

DROP TABLE TRAJET CASCADE CONSTRAINTS;

DROP TABLE PAYS CASCADE CONSTRAINTS;

DROP TABLE CLIENT CASCADE CONSTRAINTS;

DROP TABLE PASSERELLE CASCADE CONSTRAINTS;

DROP TABLE PARKING CASCADE CONSTRAINTS;

DROP TABLE PORTE CASCADE CONSTRAINTS;

DROP TABLE TERMINAL CASCADE CONSTRAINTS;

DROP TABLE DESSERVIR CASCADE CONSTRAINTS;

DROP TABLE CONSTITUER CASCADE CONSTRAINTS;

DROP TABLE AFFECTER_PK CASCADE CONSTRAINTS;

DROP TABLE AFFECTER_PORTE CASCADE CONSTRAINTS;

-- -----------------------------------------------------------------------------
--       CREATION DE LA BASE 
-- -----------------------------------------------------------------------------

--CREATE DATABASE MLR3_aeroFrance;

-- -----------------------------------------------------------------------------
--       TABLE : COUPON_VOL
-- -----------------------------------------------------------------------------



CREATE TABLE COUPON_VOL
   (
    COUPNUM NUMBER(4)  NOT NULL,
    OCCNUM NUMBER(4)  NOT NULL,
    BILLNUM NUMBER(4)  NOT NULL,
    COUPETAT VARCHAR2(32)   
,   CONSTRAINT PK_COUPON_VOL PRIMARY KEY (COUPNUM)  ,
    CONSTRAINT ch_COUPETAT  CHECK (COUPETAT in ('réservé','enregistré','annulé','arrivé'))
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE COUPON_VOL
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_COUPON_VOL_OCCURENCE_VOL
     ON COUPON_VOL (OCCNUM ASC)
    ;

CREATE  INDEX I_FK_COUPON_VOL_BILLET
     ON COUPON_VOL (BILLNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : OCCURENCE_VOL
-- -----------------------------------------------------------------------------

CREATE TABLE OCCURENCE_VOL
   (
    OCCNUM NUMBER(4)  NOT NULL,
    VOLNUM NUMBER(4)  NOT NULL,
    AERONUM NUMBER(4)  NOT NULL,
    OCCDATE DATE  NULL,
    OCCETAT VARCHAR2(40)  CHECK (OCCETAT in ('ouvert_reservation','ouvert_embarquement','ouvert_liste_attente','décollé','annulé','retardé','derouté','arrivé'))
,   CONSTRAINT PK_OCCURENCE_VOL PRIMARY KEY (OCCNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE OCCURENCE_VOL
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_OCCURENCE_VOL_VOL
     ON OCCURENCE_VOL (VOLNUM ASC)
    ;

CREATE  INDEX I_FK_OCCURENCE_VOL_AEROPORT
     ON OCCURENCE_VOL (AERONUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : VOL
-- -----------------------------------------------------------------------------

CREATE TABLE VOL
   (
    VOLNUM NUMBER(4)  NOT NULL,
    AERONUM_DEPART NUMBER(4)  NOT NULL,
    AERONUM_ARRIVEE NUMBER(4)  NOT NULL,
    H_DEPART NUMBER(2)  NULL,
    M_DEPART NUMBER(2)  NULL,
    H_ARRIVEE NUMBER(2)  NULL,
    M_ARRIVEE NUMBER(2)  NULL,
    VOLNBPLACES NUMBER(4)  NULL,
    NBMINUTESAVANT NUMBER(4)  NULL,
    NBMINUTESAPRES NUMBER(4)  NULL
,   CONSTRAINT PK_VOL PRIMARY KEY (VOLNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE VOL
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_VOL_AEROPORT
     ON VOL (AERONUM_DEPART ASC)
    ;

CREATE  INDEX I_FK_VOL_AEROPORT1
     ON VOL (AERONUM_ARRIVEE ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : AEROPORT
-- -----------------------------------------------------------------------------

CREATE TABLE AEROPORT
   (
    AERONUM NUMBER(4)  NOT NULL,
    PAYSNUM NUMBER(4)  NOT NULL,
    AERONOM VARCHAR2(32)  NULL
,   CONSTRAINT PK_AEROPORT PRIMARY KEY (AERONUM)  
   ) ;

COMMENT ON COLUMN AEROPORT.PAYSNUM
     IS 'PAYSNOM';

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE AEROPORT
-- -----------------------------------------------------------------------------

CREATE INDEX I_FK_AEROPORT_PAYS
     ON AEROPORT (PAYSNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : RETARD
-- -----------------------------------------------------------------------------

CREATE TABLE RETARD
   (
    RETNUM NUMBER(4)  NOT NULL,
    OCCNUM NUMBER(4)  NOT NULL,
    RETDUREE NUMBER(4)  NULL,
    RETDEPARTARRIVEE VARCHAR2(32)  NULL,
    RETRAISON VARCHAR2(32)  NULL
,   CONSTRAINT PK_RETARD PRIMARY KEY (RETNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE RETARD
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_RETARD_OCCURENCE_VOL
     ON RETARD (OCCNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : BILLET
-- -----------------------------------------------------------------------------
--drop table BILLET;
CREATE TABLE BILLET
   (
    BILLNUM NUMBER(4)  NOT NULL,
    TRANUM NUMBER(4)  NOT NULL,
    CLINUM NUMBER(4)  NOT NULL,
    BILLDATEACHAT DATE  NULL,
    BILLDATEDEPART DATE  NULL,
    BILLETAT VARCHAR2(32)  ,
    CONSTRAINT PK_BILLET PRIMARY KEY (BILLNUM),  
    CONSTRAINT ch_BILLETAT CHECK (BILLETAT in ('émis','encours','terminé')),
    CONSTRAINT ch_date_achat_billet CHECK ( BILLDATEACHAT < BILLDATEDEPART)
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE BILLET
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_BILLET_TRAJET
     ON BILLET (TRANUM ASC)
    ;

CREATE  INDEX I_FK_BILLET_CLIENT
     ON BILLET (CLINUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : TRAJET
-- -----------------------------------------------------------------------------

CREATE TABLE TRAJET
   (
    TRANUM NUMBER(4)  NOT NULL,
    AERONUM_DEPART NUMBER(4)  NOT NULL,
    AERONUM_ARRIVEE NUMBER(4)  NOT NULL,
    TRATARIFBILLET NUMBER(5,2)  NULL
,   CONSTRAINT PK_TRAJET PRIMARY KEY (TRANUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE TRAJET
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_TRAJET_AEROPORT
     ON TRAJET (AERONUM_DEPART ASC)
    ;

CREATE  INDEX I_FK_TRAJET_AEROPORT1
     ON TRAJET (AERONUM_ARRIVEE ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : PAYS
-- -----------------------------------------------------------------------------

CREATE TABLE PAYS
   (
    PAYSNUM NUMBER(4)  NOT NULL,
    PAYSNOM VARCHAR2(32)  NULL
,   CONSTRAINT PK_PAYS PRIMARY KEY (PAYSNUM)  
   ) ;

COMMENT ON COLUMN PAYS.PAYSNUM
     IS 'PAYSNOM';

-- -----------------------------------------------------------------------------
--       TABLE : CLIENT
-- -----------------------------------------------------------------------------

CREATE TABLE CLIENT
   (
    CLINUM NUMBER(4)  NOT NULL,
    CLINOM VARCHAR2(255)  NULL,
    CLITEL VARCHAR2(30)  NULL,
    CLIADRESSE VARCHAR2(255)  NULL
,   CONSTRAINT PK_CLIENT PRIMARY KEY (CLINUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       TABLE : PASSERELLE
-- -----------------------------------------------------------------------------

CREATE TABLE PASSERELLE
   (
    PASSNUM NUMBER(4)  NOT NULL,
    PKNUM NUMBER(4)  NOT NULL,
    PORTENUM NUMBER(4)  NOT NULL,
    PASSCAPACITE NUMBER(4)  NULL
,   CONSTRAINT PK_PASSERELLE PRIMARY KEY (PASSNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE PASSERELLE
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_PASSERELLE_PARKING
     ON PASSERELLE (PKNUM ASC)
    ;

CREATE  INDEX I_FK_PASSERELLE_PORTE
     ON PASSERELLE (PORTENUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : PARKING
-- -----------------------------------------------------------------------------

CREATE TABLE PARKING
   (
    PKNUM NUMBER(4)  NOT NULL,
    AERONUM NUMBER(4)  NOT NULL
,   CONSTRAINT PK_PARKING PRIMARY KEY (PKNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE PARKING
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_PARKING_AEROPORT
     ON PARKING (AERONUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : PORTE
-- -----------------------------------------------------------------------------

CREATE TABLE PORTE
   (
    PORTENUM NUMBER(4)  NOT NULL,
    TERNUM NUMBER(4)  NOT NULL,
    PORTENOM VARCHAR2(32)  NULL
,   CONSTRAINT PK_PORTE PRIMARY KEY (PORTENUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE PORTE
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_PORTE_TERMINAL
     ON PORTE (TERNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : TERMINAL
-- -----------------------------------------------------------------------------

CREATE TABLE TERMINAL
   (
    TERNUM NUMBER(4)  NOT NULL,
    AERONUM NUMBER(4)  NOT NULL,
    TERNOM VARCHAR2(32)  NULL
,   CONSTRAINT PK_TERMINAL PRIMARY KEY (TERNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE TERMINAL
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_TERMINAL_AEROPORT
     ON TERMINAL (AERONUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : DESSERVIR
-- -----------------------------------------------------------------------------

CREATE TABLE DESSERVIR
   (
    PAYSNUM NUMBER(4)  NOT NULL,
    TERNUM NUMBER(4)  NOT NULL
,   CONSTRAINT PK_DESSERVIR PRIMARY KEY (PAYSNUM, TERNUM)  
   ) ;

COMMENT ON COLUMN DESSERVIR.PAYSNUM
     IS 'PAYSNOM';

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE DESSERVIR
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_DESSERVIR_PAYS
     ON DESSERVIR (PAYSNUM ASC)
    ;

CREATE  INDEX I_FK_DESSERVIR_TERMINAL
     ON DESSERVIR (TERNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CONSTITUER
-- -----------------------------------------------------------------------------

CREATE TABLE CONSTITUER
   (
    VOLNUM NUMBER(4)  NOT NULL,
    TRANUM NUMBER(4)  NOT NULL,
    NUMORDRE NUMBER(2)  NULL,
    JOURPLUS NUMBER(2)  NULL
,   CONSTRAINT PK_CONSTITUER PRIMARY KEY (VOLNUM, TRANUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CONSTITUER
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CONSTITUER_VOL
     ON CONSTITUER (VOLNUM ASC)
    ;

CREATE  INDEX I_FK_CONSTITUER_TRAJET
     ON CONSTITUER (TRANUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : AFFECTER_PK
-- -----------------------------------------------------------------------------

CREATE TABLE AFFECTER_PK
   (
    PKNUM NUMBER(4)  NOT NULL,
    OCCNUM NUMBER(4)  NOT NULL,
    AFFPTKETAT VARCHAR2(32)   CHECK (AFFPTKETAT in ('affecté','annulé'))
,   CONSTRAINT PK_AFFECTER_PK PRIMARY KEY (PKNUM, OCCNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE AFFECTER_PK
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_AFFECTER_PK_PARKING
     ON AFFECTER_PK (PKNUM ASC)
    ;

CREATE  INDEX I_FK_AFFECTER_PK_OCCURENCE_VOL
     ON AFFECTER_PK (OCCNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : AFFECTER_PORTE
-- -----------------------------------------------------------------------------

CREATE TABLE AFFECTER_PORTE
   (
    PORTENUM NUMBER(4)  NOT NULL,
    OCCNUM NUMBER(4)  NOT NULL,
    AFFPTETAT VARCHAR2(32)  CHECK (AFFPTETAT in ('affecté','annulé'))
,   CONSTRAINT PK_AFFECTER_PORTE PRIMARY KEY (PORTENUM, OCCNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE AFFECTER_PORTE
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_AFFECTER_PORTE_PORTE
     ON AFFECTER_PORTE (PORTENUM ASC)
    ;

CREATE  INDEX I_FK_AFFECTER_PORTE_OCCURENCE_
     ON AFFECTER_PORTE (OCCNUM ASC)
    ;


-- -----------------------------------------------------------------------------
--       CREATION DES REFERENCES DE TABLE
-- -----------------------------------------------------------------------------


ALTER TABLE COUPON_VOL ADD (
     CONSTRAINT FK_COUPON_VOL_OCCURENCE_VOL
          FOREIGN KEY (OCCNUM)
               REFERENCES OCCURENCE_VOL (OCCNUM))   ;

ALTER TABLE COUPON_VOL ADD (
     CONSTRAINT FK_COUPON_VOL_BILLET
          FOREIGN KEY (BILLNUM)
               REFERENCES BILLET (BILLNUM))   ;

ALTER TABLE OCCURENCE_VOL ADD (
     CONSTRAINT FK_OCCURENCE_VOL_VOL
          FOREIGN KEY (VOLNUM)
               REFERENCES VOL (VOLNUM))   ;

ALTER TABLE OCCURENCE_VOL ADD (
     CONSTRAINT FK_OCCURENCE_VOL_AEROPORT
          FOREIGN KEY (AERONUM)
               REFERENCES AEROPORT (AERONUM))   ;

ALTER TABLE VOL ADD (
     CONSTRAINT FK_VOL_AEROPORT
          FOREIGN KEY (AERONUM_DEPART)
               REFERENCES AEROPORT (AERONUM))   ;

ALTER TABLE VOL ADD (
     CONSTRAINT FK_VOL_AEROPORT1
          FOREIGN KEY (AERONUM_ARRIVEE)
               REFERENCES AEROPORT (AERONUM))   ;

ALTER TABLE AEROPORT ADD (
     CONSTRAINT FK_AEROPORT_PAYS
          FOREIGN KEY (PAYSNUM)
               REFERENCES PAYS (PAYSNUM))   ;

ALTER TABLE RETARD ADD (
     CONSTRAINT FK_RETARD_OCCURENCE_VOL
          FOREIGN KEY (OCCNUM)
               REFERENCES OCCURENCE_VOL (OCCNUM))   ;

ALTER TABLE BILLET ADD (
     CONSTRAINT FK_BILLET_TRAJET
          FOREIGN KEY (TRANUM)
               REFERENCES TRAJET (TRANUM))   ;

ALTER TABLE BILLET ADD (
     CONSTRAINT FK_BILLET_CLIENT
          FOREIGN KEY (CLINUM)
               REFERENCES CLIENT (CLINUM))   ;

ALTER TABLE TRAJET ADD (
     CONSTRAINT FK_TRAJET_AEROPORT
          FOREIGN KEY (AERONUM_DEPART)
               REFERENCES AEROPORT (AERONUM))   ;

ALTER TABLE TRAJET ADD (
     CONSTRAINT FK_TRAJET_AEROPORT1
          FOREIGN KEY (AERONUM_ARRIVEE)
               REFERENCES AEROPORT (AERONUM))   ;

ALTER TABLE PASSERELLE ADD (
     CONSTRAINT FK_PASSERELLE_PARKING
          FOREIGN KEY (PKNUM)
               REFERENCES PARKING (PKNUM))   ;

ALTER TABLE PASSERELLE ADD (
     CONSTRAINT FK_PASSERELLE_PORTE
          FOREIGN KEY (PORTENUM)
               REFERENCES PORTE (PORTENUM))   ;

ALTER TABLE PARKING ADD (
     CONSTRAINT FK_PARKING_AEROPORT
          FOREIGN KEY (AERONUM)
               REFERENCES AEROPORT (AERONUM))   ;

ALTER TABLE PORTE ADD (
     CONSTRAINT FK_PORTE_TERMINAL
          FOREIGN KEY (TERNUM)
               REFERENCES TERMINAL (TERNUM))   ;

ALTER TABLE TERMINAL ADD (
     CONSTRAINT FK_TERMINAL_AEROPORT
          FOREIGN KEY (AERONUM)
               REFERENCES AEROPORT (AERONUM))   ;

ALTER TABLE DESSERVIR ADD (
     CONSTRAINT FK_DESSERVIR_PAYS
          FOREIGN KEY (PAYSNUM)
               REFERENCES PAYS (PAYSNUM))   ;

ALTER TABLE DESSERVIR ADD (
     CONSTRAINT FK_DESSERVIR_TERMINAL
          FOREIGN KEY (TERNUM)
               REFERENCES TERMINAL (TERNUM))   ;

ALTER TABLE CONSTITUER ADD (
     CONSTRAINT FK_CONSTITUER_VOL
          FOREIGN KEY (VOLNUM)
               REFERENCES VOL (VOLNUM))   ;

ALTER TABLE CONSTITUER ADD (
     CONSTRAINT FK_CONSTITUER_TRAJET
          FOREIGN KEY (TRANUM)
               REFERENCES TRAJET (TRANUM))   ;

ALTER TABLE AFFECTER_PK ADD (
     CONSTRAINT FK_AFFECTER_PK_PARKING
          FOREIGN KEY (PKNUM)
               REFERENCES PARKING (PKNUM))   ;

ALTER TABLE AFFECTER_PK ADD (
     CONSTRAINT FK_AFFECTER_PK_OCCURENCE_VOL
          FOREIGN KEY (OCCNUM)
               REFERENCES OCCURENCE_VOL (OCCNUM))   ;

ALTER TABLE AFFECTER_PORTE ADD (
     CONSTRAINT FK_AFFECTER_PORTE_PORTE
          FOREIGN KEY (PORTENUM)
               REFERENCES PORTE (PORTENUM))   ;

ALTER TABLE AFFECTER_PORTE ADD (
     CONSTRAINT FK_AFFECTER_PORTE_OCCURENCE_VO
          FOREIGN KEY (OCCNUM)
               REFERENCES OCCURENCE_VOL (OCCNUM))   ;


--CREATION SEQUNCES
CREATE SEQUENCE Seq_occ_vol START WITH 1  INCREMENT BY   1
 NOCACHE
 NOCYCLE;
 
 CREATE SEQUENCE Seq_coupon_vol START WITH 1  INCREMENT BY   1
 NOCACHE
 NOCYCLE;
 
 CREATE SEQUENCE Seq_billet START WITH 1  INCREMENT BY   1
 NOCACHE
 NOCYCLE;
  
 CREATE SEQUENCE Seq_vol START WITH 1  INCREMENT BY   1
 NOCACHE
 NOCYCLE;
 
-- DROP SEQUENCE Seq_coupon_vol;


--DEBUG
grant debug connect session to projet_oracle_diarog; 
grant debug any procedure to projet_oracle_diarog;

grant create view to projet_oracle_diarog;


--CREATE VIEW
CREATE OR REPLACE VIEW view_coupon_vol AS 
SELECT * FROM COUPON_VOL;

CREATE OR REPLACE VIEW view_occurence_vol AS 
SELECT * FROM OCCURENCE_VOL;


CREATE OR REPLACE VIEW VIEW_VOL AS
SELECT * FROM VOL;


-- -----------------------------------------------------------------------------
--                FIN DE GENERATION
-- -----------------------------------------------------------------------------