
CREATE OR REPLACE PROCEDURE p_insert_in_view_occ_vol 
                            (pVOLNUM VOL.VOLNUM%TYPE,
                             pAERONUM_DEROUTER AEROPORT.AERONUM%TYPE,
                             pOCCDATE OCCURENCE_VOL.OCCDATE%TYPE, 
                             pNB_OCC_VOL INT) IS
i INT := 0;
BEGIN
    --création de l'occurence de vol
   WHILE i < pNB_OCC_VOL LOOP
      INSERT INTO view_occurence_vol(OCCNUM,VOLNUM,AERONUM,OCCDATE) 
      VALUES (Seq_occ_vol.nextval,pVOLNUM,pAERONUM_DEROUTER,pOCCDATE);
      i := i+1;
   END LOOP;
END;

/

CREATE OR REPLACE PROCEDURE p_insert_in_affecte_porte_pk 
                            (pOCCNUM OCCURENCE_VOL.OCCNUM%TYPE,
                             pPORTENUM PORTE.PORTENUM%TYPE,
                             pPKNUM PARKING.PKNUM%TYPE)IS
BEGIN
    INSERT INTO AFFECTER_PORTE(OCCNUM,PORTENUM,AFFPTETAT) 
      VALUES (pOCCNUM, pPORTENUM,'affecté');
    INSERT INTO AFFECTER_PK(OCCNUM,PKNUM,AFFPTKETAT) 
      VALUES (pOCCNUM, pPKNUM,'affecté');  
END;
/
CREATE OR REPLACE PROCEDURE insert_in_view_vol(vAERONUM_DEPART AEROPORT.AERONUM%TYPE,
                                              vAERONUM_ARRIVEE AEROPORT.AERONUM%TYPE,
                                              vH_DEPART VOL.H_DEPART%TYPE,
                                              vM_DEPART VOL.M_DEPART%TYPE,
                                              vH_ARRIVEE VOL.H_ARRIVEE%TYPE,
                                              vM_ARRIVEE VOL.M_ARRIVEE%TYPE,
                                              vVOLNBPLACES VOL.VOLNBPLACES%TYPE,
                                              vNBMINUTESAVANT VOL.NBMINUTESAVANT%TYPE,
                                              vNBMINUTESAPRES VOL.NBMINUTESAPRES%TYPE) IS

BEGIN
  --création du vol
  INSERT INTO VIEW_VOL (VOLNUM, AERONUM_DEPART, AERONUM_ARRIVEE, H_DEPART, M_DEPART, 
                       H_ARRIVEE, M_ARRIVEE, VOLNBPLACES, NBMINUTESAVANT, NBMINUTESAPRES)
  VALUES (Seq_vol.nextval, vAERONUM_DEPART, vAERONUM_ARRIVEE, vH_DEPART, vM_DEPART, 
          vH_ARRIVEE, vM_ARRIVEE,vVOLNBPLACES, vNBMINUTESAVANT, vNBMINUTESAPRES);
END;

/
CREATE OR REPLACE PROCEDURE reinit_datas_billet_couponvol IS
BEGIN
  DELETE  FROM COUPON_VOL 
  WHERE 1=1;
  DELETE FROM BILLET
  WHERE 1=1;  

END;
/
  
CREATE OR REPLACE PROCEDURE reinit_affect_prte_pk_occ_vol IS
BEGIN
  DELETE FROM AFFECTER_PORTE
  WHERE OCCNUM > 15;
  DELETE FROM AFFECTER_PK
  WHERE OCCNUM > 15;
  COMMIT;
  
  DELETE FROM OCCURENCE_VOL
  WHERE OCCNUM > 15;
  
  DELETE FROM VOL
  WHERE VOLNUM >23;
  
END;
/

CREATE OR REPLACE PROCEDURE insertion_billet(
                        pTRANUM TRAJET.TRANUM%TYPE,
                        pCLINUM CLIENT.CLINUM%TYPE,
                        pBILLDATEDEPART BILLET.BILLDATEDEPART%TYPE,
                        pBILLETAT BILLET.BILLETAT%TYPE,
                        NBBILLET INT -- NOMBRE de billet qu'on veut inserer
                    ) IS
i INT :=0;
BEGIN
  WHILE  i < NBBILLET LOOP
    Insert into BILLET (BILLNUM,TRANUM,CLINUM,BILLDATEACHAT,BILLDATEDEPART,BILLETAT) 
    values (Seq_billet.nextval,pTRANUM,pCLINUM,SYSDATE,pBILLDATEDEPART,pBILLETAT);
    i:=i+1;
  END LOOP;
  COMMIT;
END;


/

CREATE OR REPLACE PROCEDURE reinit_datas IS
BEGIN
  BEGIN
    reinit_datas_billet_couponvol;
    reinit_affect_prte_pk_occ_vol;
    EXECUTE IMMEDIATE 'DROP SEQUENCE Seq_occ_vol';
    EXECUTE IMMEDIATE 'DROP SEQUENCE Seq_coupon_vol';
    EXECUTE IMMEDIATE 'DROP SEQUENCE Seq_billet';
    EXECUTE IMMEDIATE 'DROP SEQUENCE  Seq_vol';
    EXECUTE IMMEDIATE 'DROP SEQUENCE  Seq_porte';
    EXECUTE IMMEDIATE 'DROP SEQUENCE  Seq_parking';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE Seq_occ_vol START WITH 16  INCREMENT BY   1 NOCACHE NOCYCLE';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE Seq_coupon_vol START WITH 1  INCREMENT BY   1 NOCACHE NOCYCLE';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE Seq_billet START WITH 1  INCREMENT BY   1 NOCACHE NOCYCLE';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE Seq_vol START WITH 24  INCREMENT BY   1 NOCACHE NOCYCLE';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE Seq_porte START WITH 17  INCREMENT BY   1 NOCACHE NOCYCLE';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE Seq_parking START WITH 16  INCREMENT BY   1 NOCACHE NOCYCLE';
  EXCEPTION
    WHEN others THEN
      EXECUTE IMMEDIATE 'CREATE SEQUENCE Seq_occ_vol START WITH 20  INCREMENT BY   1 NOCACHE NOCYCLE';
      EXECUTE IMMEDIATE 'CREATE SEQUENCE Seq_coupon_vol START WITH 1  INCREMENT BY   1 NOCACHE NOCYCLE';
      EXECUTE IMMEDIATE 'CREATE SEQUENCE Seq_billet START WITH 1  INCREMENT BY   1 NOCACHE NOCYCLE';
      EXECUTE IMMEDIATE 'CREATE SEQUENCE Seq_vol START WITH 24  INCREMENT BY   1 NOCACHE NOCYCLE';
      EXECUTE IMMEDIATE 'CREATE SEQUENCE Seq_porte START WITH 16  INCREMENT BY   1 NOCACHE NOCYCLE';
      EXECUTE IMMEDIATE 'CREATE SEQUENCE Seq_parking START WITH 16  INCREMENT BY   1 NOCACHE NOCYCLE';
  END;
  DBMS_OUTPUT.PUT_LINE('Les données inserées automatiquement ont été reinitialisées, 
                        vous pouvez commencer un nouveau essai');
END;

/
CREATE OR REPLACE PROCEDURE p_flash_coupon (
                                            pCOUPNUM COUPON_VOL.COUPNUM%TYPE,
                                            pCOUPETAT COUPON_VOL.COUPETAT%TYPE) IS
BEGIN
  UPDATE view_coupon_vol
    SET COUPETAT =pCOUPETAT
    WHERE COUPNUM =pCOUPNUM;
END;

/

CREATE OR REPLACE PROCEDURE p_start_occ_vol (
                                            pOCCNUM OCCURENCE_VOL.OCCNUM%TYPE,
                                            pOCCETAT OCCURENCE_VOL.OCCETAT%TYPE) IS
BEGIN
  UPDATE view_occurence_vol
    SET OCCETAT =pOCCETAT
    WHERE OCCNUM =pOCCNUM;
END;


/


CREATE OR REPLACE PROCEDURE p_reinite_porte_pk (pt_pk_num NUMBER) IS
BEGIN
  IF pt_pk_num > 14 THEN
    DELETE FROM  PORTE WHERE PORTENUM>pt_pk_num;
    DELETE FROM  PARKING WHERE PKNUM>pt_pk_num;
  END IF;
END;

/
CREATE OR REPLACE PROCEDURE p_genere_porte IS
vPORTENOM VARCHAR2(30);
vPORTENUM PORTE.PORTENUM%TYPE;
BEGIN
  FOR i IN 1..10 LOOP
    FOR j IN 1..8 LOOP
     vPORTENUM :=Seq_porte.nextval;
     vPORTENOM := 'PORTE ';
     vPORTENOM := vPORTENOM || vPORTENUM;
     dbms_output.put_line(vPORTENUM || '==='||vPORTENOM);
     INSERT INTO PORTE(PORTENUM,TERNUM,PORTENOM) VALUES (vPORTENUM,j,vPORTENOM);
     vPORTENOM := '';
    END LOOP;
  END LOOP;
END;
/
CREATE OR REPLACE PROCEDURE p_genere_parking IS
vPKNUM PARKING.PKNUM%TYPE;
BEGIN
  FOR i IN 1..10 LOOP
    FOR j IN 1..10 LOOP
     vPKNUM :=Seq_parking.nextval;
     dbms_output.put_line(vPKNUM || '==='||j);
     INSERT INTO PARKING(PKNUM,AERONUM) VALUES (vPKNUM,j);
    END LOOP;
  END LOOP;
END;

/
CREATE OR REPLACE PROCEDURE p_set_desservir IS
BEGIN
  FOR i IN 1..10 LOOP
    FOR j IN 13..40 LOOP
       INSERT INTO DESSERVIR(PAYSNUM,TERNUM) VALUES (i,j);
    END LOOP;
  END LOOP;
END;

/*
execute p_flash_coupon(4, 'enregistré');
execute p_flash_coupon(6, 'enregistré');

*/
--execute p_flash_coupon(5, 'arrivé');
--execute p_flash_coupon(6, 'arrivé');  

--execute p_start_occ_vol(5,'décollé');
--execute reinit_datas;


-- PORTENUM == 13
--PKNUM == 11
--PASSNUM == 14


--execute  p_porte_parking_old(1); 

--execute  p_porte_parking(15); 

--execute  p_porte_parking(18); 

--OCCNUM 14 15
--execute dbms_output.put_line( f_get_porte(16));


--OCCNUM  14 15 
/*
execute dbms_output.put_line( f_get_porte(14));
execute dbms_output.put_line( f_get_parking(14));
execute p_affecte_porte_parking(14);
*/
--PARKING DISPO     
/*
execute dbms_output.put_line( f_get_parking(3));
execute dbms_output.put_line( f_get_porte(3));
execute dbms_output.put_line( f_get_parking(5));
execute dbms_output.put_line( f_get_porte(5));
*/

--execute  p_porte_parking_old(1); 


-- 1 5 6 

--execute porte_parking(2);
--execute p_reinite_porte_pk(255);
-- execute p_set_desservir
-- execute p_genere_parking
--execute p_genere_porte

