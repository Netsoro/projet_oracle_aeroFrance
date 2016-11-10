--Test des contraintes de domaines
--Resultat attendu :
--Erreur SQL : ORA-02290: violation de contraintes (PROJET_ORACLE_DIAROG.SYS_C0032917) de vérification
--02290. 00000 -  "check constraint (%s.%s) violated"
INSERT INTO OCCURENCE_VOL(OCCNUM,VOLNUM,AERONUM,OCCDATE,OCCETAT) VALUES  (1,1,1,sysdate,'ouvert_res');

--Test Reussi avec verification des contraintes d'intégrité
--RESULTAT attendu:
-- 1 ligne inséré.
INSERT INTO OCCURENCE_VOL(OCCNUM,VOLNUM,AERONUM,OCCDATE,OCCETAT) VALUES  (2,2,1,sysdate,'ouvert_embarquement');
INSERT INTO OCCURENCE_VOL(OCCNUM,VOLNUM,AERONUM,OCCDATE,OCCETAT) VALUES  (2,2,1,sysdate,'décollé');

--Test des contraintes de domaines pour  COUPON_VOL


--RESULTAT Attendu 
--1 ligne inséré.
INSERT INTO BILLET(BILLNUM,TRANUM,CLINUM,BILLDATEACHAT,BILLDATEDEPART,BILLETAT) VALUES (1,1,1,sysdate-1,sysdate,'émis');

--RESULTAT Attendu
--Erreur SQL : ORA-02290: violation de contraintes (PROJET_ORACLE_DIAROG.SYS_C0032917) de vérification
--02290. 00000 -  "check constraint (%s.%s) violated"
INSERT INTO BILLET(BILLNUM,TRANUM,CLINUM,BILLDATEACHAT,BILLDATEDEPART,BILLETAT) VALUES (1,1,1,sysdate-1,sysdate,'émisess');



--RESULTAT Attendu 
--1 ligne inséré.
INSERT INTO AFFECTER_PORTE(PORTENUM,OCCNUM,AFFPTETAT) VALUES (1,1,'annulé');
INSERT INTO AFFECTER_PORTE(PORTENUM,OCCNUM,AFFPTETAT) VALUES (2,1,'affecté');

--RESULTAT ATTENDU
----Erreur SQL : ORA-02290: violation de contraintes (PROJET_ORACLE_DIAROG.SYS_C0032917) de vérification
--02290. 00000 -  "check constraint (%s.%s) violated"
INSERT INTO AFFECTER_PORTE(PORTENUM,OCCNUM,AFFPTETAT) VALUES (2,1,'affectéssd');

SET SERVEROUTPUT ON;

--VERIFIE DATE BILLET
--Insert into BILLET (BILLNUM,TRANUM,CLINUM,BILLDATEACHAT,BILLDATEDEPART,BILLETAT) values (7,1,150,SYSDATE,to_date('16/09/16','DD/MM/RR'),'émis');
execute insertion_billet(1,150,to_date('16/09/16','DD/MM/RR'),'émis',1);



--INSERTION de BILLET et declechement de generation de coupons de vols

--insertion_billet(pTRANUM ,pCLINUM ,pBILLDATEDEPART,pBILLETAT ,NBBILLET , NBBILLLET /*de billet qu'on veut inserer*/)
execute insertion_billet(1,8,to_date('16/11/16','DD/MM/RR'),'émis',1);
execute insertion_billet(1,1,to_date('16/11/16','DD/MM/RR'),'émis',1);
execute insertion_billet(1,2,to_date('16/11/16','DD/MM/RR'),'émis',1);
execute insertion_billet(1,3,to_date('16/11/16','DD/MM/RR'),'émis',1);
execute insertion_billet(1,15,to_date('16/11/16','DD/MM/RR'),'émis',1);
execute insertion_billet(1,150,to_date('16/11/16','DD/MM/RR'),'émis',1);

execute insertion_billet(4,20,to_date('11/12/16','DD/MM/RR'),'émis',1);
execute insertion_billet(6,21,to_date('24/12/16','DD/MM/RR'),'émis',1);
execute insertion_billet(2,9,to_date('16/11/16','DD/MM/RR'),'émis',1);


execute reinit_datas;

--Test gestions etats coupons - billet
--p_flash_coupon(OCCNUM,COUPETAT)
execute p_flash_coupon(4, 'enregistré');
execute p_flash_coupon(6, 'enregistré');

execute p_flash_coupon(5, 'arrivé');
execute p_flash_coupon(6, 'arrivé');  

--TEST decollage de occurence de vol
execute p_start_occ_vol(5,'décollé');
execute p_start_occ_vol(6,'décollé');

--insert_in_view_vol(vAERONUM_DEPART,vAERONUM_ARRIVEE ,vH_DEPART ,vM_DEPART,vH_ARRIVEE ,vM_ARRIVEE ,vVOLNBPLACES ,vNBMINUTESAVANT ,vNBMINUTESAPRES )
--INSERTION DE VOL et TESTE DU CHEV
execute insert_in_view_vol('1', '2', '12', '52', '16', '00', '14', '10', '10');
execute insert_in_view_vol( '1', '2', '12', '45', '16', '00', '14', '10', '10');
execute insert_in_view_vol( '1', '2', '10', '05', '16', '00', '14', '10', '10');
execute insert_in_view_vol('1', '2', '10', '05', '16', '00', '14', '10', '10');
execute insert_in_view_vol('1', '2', '10', '05', '16', '00', '14', '10', '10');



execute insert_in_view_vol('1', '2', '10', '05', '16', '00', '14', '10', '10');
execute insert_in_view_vol( '1', '2', '10', '05', '16', '00', '14', '10', '10');
execute insert_in_view_vol('1', '2', '10', '05', '16', '00', '14', '10', '10');

--Aucune porte/parking trouver pour ce vol
execute insert_in_view_vol( '5', '6', '10', '05', '16', '00', '14', '10', '10');
execute insert_in_view_vol('5', '6', '10', '05', '16', '00', '14', '10', '10');


execute insert_in_view_vol('7', '6', '10', '05', '16', '00', '14', '10', '10');
execute insert_in_view_vol( '8', '9', '10', '05', '16', '00', '14', '10', '10');

--SET SERVEROUTPUT ON;
-- TEST Chevauchement des horaires pour deux occurences bidons
execute insert_in_view_vol('1', '2', '12', '52', '16', '00', '14', '10', '10');
execute insert_in_view_vol('1', '2', '12', '45', '16', '00', '14', '10', '10');
execute insert_in_view_vol( '1', '2', '10', '05', '16', '00', '14', '10', '10');

--CREATION D''OCCURENCE DE VOL
execute insert_in_view_vol('2', '1', '12', '52', '16', '00', '14', '10', '10');
execute insert_in_view_vol('1', '2', '12', '52', '16', '00', '14', '10', '10');
--p_insert_in_view_occ_vol (pVOLNUM ,pAERONUM_DEROUTER ,pOCCDATE , pNB_OCC_VOL /*NB occurence de vol q''on souhaire créeer*/)
execute p_insert_in_view_occ_vol(24,1,to_date('14/10/17','DD/MM/RR'),1);
execute p_insert_in_view_occ_vol(81,1,to_date('14/10/17','DD/MM/RR'),1);

execute p_insert_in_view_occ_vol(24,1,to_date('14/10/17','DD/MM/RR'),1);
execute insert_in_view_vol('5', '8', '12', '52', '16', '00', '14', '10', '10');

--reintialisation des données
execute reinit_datas;
execute reinit_datas_billet_couponvol;
execute reinit_affect_prte_pk_occ_vol;