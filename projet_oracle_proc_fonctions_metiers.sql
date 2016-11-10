
CREATE OR REPLACE PROCEDURE genere_coupon_vole(
  pBILLNUM  BILLET.BILLNUM%TYPE,
  pTRANUM TRAJET.TRANUM%TYPE,
  pBILLDATEDEPART BILLET.BILLDATEDEPART%TYPE) AS
  
  -- On recupère les occurences de vol associés au trajet à la date de départ du vol
  --En même temps on recupère le nombre de places du vol 
  --On vérifie aussi que les occurences de vol sont bien ouvert à la reservation
CURSOR c_occurence_vol IS
  SELECT OCCNUM, VOLNBPLACES,occ_v.VOLNUM,v.AERONUM_DEPART,v.AERONUM_ARRIVEE,const.NUMORDRE
  FROM OCCURENCE_VOL occ_v,CONSTITUER const, VOL v
  WHERE occ_v.VOLNUM = const.VOLNUM AND
        occ_v.OCCDATE = pBILLDATEDEPART+const.JOURPLUS AND
        const.TRANUM = pTRANUM AND 
        v.VOLNUM = occ_v.VOLNUM AND
        occ_v.OCCETAT = 'ouvert_reservation';
  
  vCOUPNUM  COUPON_VOL.COUPNUM%TYPE;
  vOCCNUM OCCURENCE_VOL.OCCNUM%TYPE;
  vNBPLACESRESERVE VOL.VOLNBPLACES%TYPE;
   is_data_found BOOLEAN := false; 
BEGIN
     DBMS_OUTPUT.PUT_LINE('=== DEBUT GENERATION COUPON VOL ===');
  BEGIN
    FOR r_occurence_vol in c_occurence_vol LOOP
    
      is_data_found := true;
  --Pour chaque ccurence de vol On recupère le nombre de place reservé 
      SELECT COUNT(*)  INTO vNBPLACESRESERVE
      FROM COUPON_VOL coup_v
      WHERE coup_v.OCCNUM = r_occurence_vol.OCCNUM;
      
  -- On compare le nombre de places reservé à la capacité du vol 
  -- S'il est supérieur dans ce cas on arrete le programme, et l'insertion du billet est annulé
      IF vNBPLACESRESERVE >= r_occurence_vol.VOLNBPLACES THEN
        raise_application_error(-20011,'OCCNUM = ' ||r_occurence_vol.OCCNUM || ' Ce vol est déjà rempli ... ' );
      END IF;
    -- Pour chaque occurence de vol du billet on insert un coupoun de vol
    -- Pour chaque occurence de vol du billet on insert un coupoun de vol
      vCOUPNUM := Seq_coupon_vol.nextval;
      vOCCNUM :=r_occurence_vol.OCCNUM;
      INSERT INTO COUPON_VOL(COUPNUM,OCCNUM,BILLNUM,COUPETAT) VALUES (vCOUPNUM,vOCCNUM,pBILLNUM,'réservé');
      DBMS_OUTPUT.PUT_LINE('(OCCUNM, VOLNUM, COUPON) ==> '  || 
      '(' || vOCCNUM ||',' || r_occurence_vol.VOLNUM ||',' ||vCOUPNUM ||')' );
      
      DBMS_OUTPUT.PUT_LINE('--(AERO_DEPART, VOLNUM, AERO_ARRIVE) ==> '  || 
      '(' || r_occurence_vol.AERONUM_DEPART ||',' || r_occurence_vol.VOLNUM ||',' 
      ||r_occurence_vol.AERONUM_ARRIVEE ||')' );
      DBMS_OUTPUT.PUT_LINE('ORDRE == '||r_occurence_vol.NUMORDRE);
    END LOOP;
    IF not is_data_found THEN
            raise_application_error(-20012,'Il n''ya aucun vol associé au trejet à cette date, donc pas de billet !!' );
    END IF;
  END;
     DBMS_OUTPUT.PUT_LINE('=== FIN GENERATION COUPON VOL ===');
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Aucune occurence de vole n''est associé au trejet à cette date');
END;


/

/*
Cette procedure prend en parametre une occurence de vol et l'affecte un couple
porte/parking pour le vol de depart.
*/


CREATE OR REPLACE PROCEDURE p_affecte_porte_parking(pOCCNUM OCCURENCE_VOL.OCCNUM%TYPE) IS
vPORTENUM PORTE.PORTENUM%TYPE;
vPKNUM PARKING.PKNUM%TYPE;
vPASSNUM PASSERELLE.PASSNUM%TYPE;
vDATE_DEPART VARCHAR2(40);
vDATE_ARRIVE VARCHAR2(40);
BEGIN
  dbms_output.put_line('<<==== DEBUT PROCEDURE affecte_porte_parking   ... ==>> ');
  BEGIN
  SELECT  p.portenum, pk.pknum, pa.passnum,
         to_char(ov1.occdate+v1.h_depart/24+ v1.M_DEPART/(24*60)-
         v1.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss') as debut,
         to_char(ov1.occdate+v1.h_depart/24+ v1.M_DEPART/(24*60)+
         v1.nbminutesapres/(24*60),'dd/mm/yy hh24:mi:ss') as fin       
         INTO vPORTENUM,vPKNUM,vPASSNUM,vDATE_DEPART,vDATE_ARRIVE 
  FROM OCCURENCE_VOL ov1, VOL v1, TERMINAL t, PORTE p, PASSERELLE pa, PARKING pk, 
       DESSERVIR d, AEROPORT a
  WHERE ov1.volnum = v1.volnum AND v1.aeronum_depart = t.aeronum
  AND p.ternum = t.ternum
  AND p.portenum = pa.portenum
  AND v1.volnbplaces <= pa.passcapacite
  AND pa.pknum = pk.pknum
  AND ov1.occnum = pOCCNUM
  AND p.ternum = d.ternum
  AND d.paysnum= a.paysnum
  AND v1.aeronum_arrivee=a.aeronum
  AND p.portenum not in ( SELECT ap.portenum
                          FROM affecter_porte ap, occurence_vol ov, vol v
                          WHERE ap.occnum=ov.occnum and ov.volnum=v.volnum and ov.occnum<>pOCCNUM 
                                AND ap.affptetat='affecté'
                                AND to_char(ov.occdate+v.h_depart/24+ v.M_DEPART/(24*60)-
                                    v.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
                                    < to_char(ov1.occdate+v1.h_depart/24+ v1.M_DEPART/(24*60)+
                                    v1.nbminutesapres/(24*60),'dd/mm/yy hh24:mi:ss')
                                AND to_char(ov.occdate+v.h_depart/24+v.M_DEPART/(24*60)-
                                    v.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
                                     > to_char(ov1.occdate+v1.h_depart/24+v1.M_DEPART/(24*60)-
                                     v1.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
                        )
  AND p.portenum not in ( SELECT ap.portenum
                          FROM affecter_porte ap, occurence_vol ov, vol v
                          WHERE ap.occnum=ov.occnum and ov.volnum=v.volnum 
                          AND ov.occnum<>pOCCNUM and ap.affptetat='affecté'
                          AND to_char(ov.occdate+v.h_depart/24+ 
                              v.M_DEPART/(24*60)+v.nbminutesapres/(24*60),'dd/mm/yy hh24:mi:ss')
                              > to_char(ov1.occdate+v1.h_depart/24+ v1.M_DEPART/(24*60)-
                              v1.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
                         AND to_char(ov.occdate+v.h_depart/24+v.M_DEPART/(24*60)-
                             v.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
                             < to_char(ov1.occdate+v1.h_depart/24+v1.M_DEPART/(24*60)-
                            v1.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
                        )
  AND ROWNUM = 1
  ORDER BY PASSCAPACITE DESC;
  
    dbms_output.put_line('(PORTENUM, PKNUM ,PASSNUM )  ===>> ' || 
                         '('|| vPORTENUM||','||vPKNUM||','||vPASSNUM||')');
    dbms_output.put_line('DATE_DEPART == ' || vDATE_DEPART);
    dbms_output.put_line('DATE_ARRIVE == ' || vDATE_ARRIVE);
    
    p_insert_in_affecte_porte_pk(pOCCNUM,vPORTENUM,vPKNUM);
   EXCEPTION
       WHEN NO_DATA_FOUND THEN 
          vPORTENUM := f_get_porte(pOCCNUM);
          vPKNUM := f_get_parking(pOCCNUM); 
          dbms_output.put_line('(PORTENUM, PKNUM)  ===>> ' || '('|| vPORTENUM||','||vPKNUM ||')');

          IF vPORTENUM <> 0  AND vPKNUM <>  0 THEN
            dbms_output.put_line('On n''a pas touvé de triplet (porte, parking, passerelle) , 
                                 on vous propose un BUS à la place de la passerelle');
            p_insert_in_affecte_porte_pk(pOCCNUM,vPORTENUM,vPKNUM);
          ELSE 
            RAISE_APPLICATION_ERROR(-20015, 'Aucun couple porte/parking n''est 
                                    disponible pour cette occurence de vol');
          END IF;
       WHEN others THEN
        dbms_output.put_line('ERREUR DANS affecte_porte_parking ==> ' || SQLERRM);
  END;
  dbms_output.put_line('<<====FIN PROCEDURE affecte_porte_parking ====>>');
END;


/

/*
Cette function prend une occurence de vol et retunr 0 si cette occ vol n'a pas
de porte disponible sinon elle retourne la porte disponible trier par ordre
decroissant
*/

CREATE OR REPLACE FUNCTION f_get_porte(pOCCNUM OCCURENCE_VOL.OCCNUM%TYPE) 
RETURN PORTE.PORTENUM%TYPE IS
vPORTENUM PORTE.PORTENUM%TYPE  := 0;
BEGIN
 BEGIN
    SELECT distinct p.portenum  INTO vPORTENUM
    FROM occurence_vol ov1, vol v1, terminal t, porte p, desservir d,aeroport a
    WHERE ov1.volnum = v1.volnum
    AND v1.aeronum_depart = t.aeronum
    AND p.ternum = t.ternum
    AND ov1.occnum = pOCCNUM
    AND p.ternum = d.ternum
    AND d.paysnum= a.paysnum
    AND v1.aeronum_arrivee=a.aeronum
    AND p.portenum not in (SELECT distinct portenum from passerelle)
    AND p.portenum not in 
    ( SELECT ap.portenum
        FROM affecter_porte ap, occurence_vol ov, vol v
        WHERE ap.occnum=ov.occnum and ov.volnum=v.volnum 
        AND ov.occnum<>pOCCNUM and ap.affptetat='affecté'
        AND to_char(ov.occdate+v.h_depart/24+ v.M_DEPART/(24*60)-
            v.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
            < to_char(ov1.occdate+v1.h_depart/24+ 
            v1.M_DEPART/(24*60)+v1.nbminutesapres/(24*60),'dd/mm/yy hh24:mi:ss')
        AND to_char(ov.occdate+v.h_depart/24+v.M_DEPART/(24*60)-
            v.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
            > to_char(ov1.occdate+v1.h_depart/24+v1.M_DEPART/(24*60)-
            v1.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
    )
    AND p.portenum not in 
    ( SELECT ap.portenum
        FROM affecter_porte ap, occurence_vol ov, vol v
        WHERE ap.occnum=ov.occnum 
        AND ov.volnum=v.volnum and ov.occnum<>pOCCNUM
        AND ap.affptetat='affecté'
        AND to_char(ov.occdate+v.h_depart/24+ v.M_DEPART/(24*60)+
            v.nbminutesapres/(24*60),'dd/mm/yy hh24:mi:ss')
            > to_char(ov1.occdate+v1.h_depart/24+ v1.M_DEPART/(24*60)-
            v1.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
        AND to_char(ov.occdate+v.h_depart/24+v.M_DEPART/(24*60)-
            v.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
            < to_char(ov1.occdate+v1.h_depart/24+v1.M_DEPART/(24*60)-
            v1.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
    ) 
    AND ROWNUM = 1
    ORDER BY  p.portenum DESC;
 EXCEPTION 
  WHEN no_data_found THEN
      DBMS_OUTPUT.PUT_LINE('AUCUNE PORTE DISPONIBLE ');
   WHEN others THEN
      DBMS_OUTPUT.PUT_LINE('ERREUR DANS F_GET_PORTE ==>' || SQLERRM);
 END;
 RETURN vPORTENUM;
END;

/

/*
Cette function prend une occurence de vol et retunr 0 si cette occ vol n'a pas
de parking disponible sinon elle retourne le pk disponible trier par ordre
decroissant
*/

CREATE OR REPLACE FUNCTION f_get_parking(pPKNUM PARKING.PKNUM%TYPE)  
RETURN PARKING.PKNUM%TYPE IS
vPKNUM PARKING.PKNUM%TYPE := 0;
BEGIN
  BEGIN
  SELECT distinct pk.pknum INTO vPKNUM
    FROM occurence_vol ov1, vol v1,terminal t,desservir d,aeroport a,parking pk
    WHERE ov1.volnum = v1.volnum
    AND v1.aeronum_depart = t.aeronum
    AND ov1.occnum = pPKNUM
    AND t.ternum = d.ternum
    AND d.paysnum= a.paysnum
    AND v1.aeronum_arrivee=a.aeronum
    AND v1.aeronum_depart = pk.aeronum
    AND pk.pknum not in (select distinct pknum from passerelle)
    AND pk.pknum not in 
    ( select ap.pknum
          FROM affecter_pk ap, occurence_vol ov, vol v
          WHERE ap.occnum=ov.occnum and ov.volnum=v.volnum 
          AND ov.occnum<>pPKNUM and ap.AFFPTKETAT='affecté'
          AND to_char(ov.occdate+v.h_depart/24+ v.M_DEPART/(24*60)-
              v.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
              < to_char(ov1.occdate+v1.h_depart/24+ v1.M_DEPART/(24*60)+
              v1.nbminutesapres/(24*60),'dd/mm/yy hh24:mi:ss')
          
         AND to_char(ov.occdate+v.h_depart/24+v.M_DEPART/(24*60)-
             v.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
             > to_char(ov1.occdate+v1.h_depart/24+v1.M_DEPART/(24*60)-
             v1.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
        )                        
    AND pk.pknum not in 
    ( SELECT ap.pknum
          FROM affecter_pk ap, occurence_vol ov, vol v
          WHERE ap.occnum=ov.occnum and ov.volnum=v.volnum 
          AND ov.occnum<>pPKNUM and AFFPTKETAT='affecté'
          AND to_char(ov.occdate+v.h_depart/24+ v.M_DEPART/(24*60)+
              v.nbminutesapres/(24*60),'dd/mm/yy hh24:mi:ss')
              >to_char(ov1.occdate+v1.h_depart/24+ v1.M_DEPART/(24*60)-
              v1.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
         AND to_char(ov.occdate+v.h_depart/24+v.M_DEPART/(24*60)-
             v.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
             <to_char(ov1.occdate+v1.h_depart/24+v1.M_DEPART/(24*60)-
             v1.nbminutesavant/(24*60),'dd/mm/yy hh24:mi:ss')
        )
  AND ROWNUM = 1
  ORDER BY   pk.pknum DESC;
 EXCEPTION 
   WHEN no_data_found THEN
       DBMS_OUTPUT.PUT_LINE('AUCUN PARKING DISPONIBLE');
   WHEN others THEN
      DBMS_OUTPUT.PUT_LINE('ERREUR DANS F_GET_PARKING ==> ' || SQLERRM);
 END;
    RETURN vPKNUM;
END;

/

/*
Cette function prend un vol et return l'occurence bidon qui lui ait associé 
sinon 0 si le vol n'a pas d'occurence bidon
*/


CREATE OR REPLACE FUNCTION f_recupere_occ_bidon(pVOLNUM VOL.VOLNUM%TYPE)
RETURN   OCCURENCE_VOL.OCCNUM%TYPE IS
vOCCNUM_BIDON  OCCURENCE_VOL.OCCNUM%TYPE :=0;
BEGIN
  BEGIN
    SELECT OCCNUM 
      INTO vOCCNUM_BIDON
      FROM OCCURENCE_VOL occ_v
      WHERE occ_v.VOLNUM = pVOLNUM AND 
            occ_v.OCCDATE = to_date('1/1/00','DD/MM/YY');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Pas d''occ bidon correspondant pour ce vol');
    WHEN OTHERS THEN 
        dbms_output.put_line('ERREUR DANS f_recupere_occ_bidon  ==> '||SQLERRM);
  END;
  RETURN vOCCNUM_BIDON;
END;


/

/*
Cette procedure prend une occ bidon et retourn la porte et le parking 
qui lui ait associé 
*/


CREATE OR REPLACE PROCEDURE p_recupere_porte_pk_occ_bidon 
                            (pOCCNUM_BIDON IN OCCURENCE_VOL.OCCNUM%TYPE, 
                             pPORTENUM OUT PORTE.PORTENUM%TYPE,
                             pPKNUM OUT PARKING.PKNUM%TYPE) IS
BEGIN
    BEGIN
    SELECT ap.PORTENUM,apk.PKNUM
      INTO pPORTENUM,pPKNUM
      FROM AFFECTER_PORTE ap, AFFECTER_PK apk
      WHERE ap.OCCNUM = apk.OCCNUM AND 
          ap.OCCNUM = pOCCNUM_BIDON AND 
          ROWNUM = 1
          ORDER BY  ap.PORTENUM;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('PAS DE COUPLE PORTE/PK POUR CETTE OCC BIDON');  
    WHEN OTHERS THEN
        dbms_output.put_line('ERREUR  DAND LE BLOC RECUP PORTE/PK==>'||SQLERRM);  
  END;
END;



/

/*
Cette procedure prend une occurence de vol et met ses coupons de vol 
qui ne sont pas à arrivé à annulé
*/


CREATE OR REPLACE PROCEDURE p_not_saved_coupons_to_cancel(
                            pOCCNUM OCCURENCE_VOL.OCCNUM%TYPE) AS
CURSOR c_occ_non_enregistrer IS 
  SELECT occ_v.OCCNUM,coup_v.COUPNUM 
  FROM OCCURENCE_VOL occ_v, COUPON_VOL coup_v
  WHERE occ_v.OCCNUM=coup_v.OCCNUM  AND
        occ_v.OCCNUM=pOCCNUM AND
        coup_v.COUPETAT != 'enregistré' AND 
        coup_v.COUPETAT != 'arrivé' FOR UPDATE OF COUPETAT ;
BEGIN
  FOR r_occ_non_enregistrer in c_occ_non_enregistrer LOOP
    UPDATE COUPON_VOL
    SET COUPETAT = 'annulé'
    WHERE OCCNUM = r_occ_non_enregistrer.OCCNUM;
    DBMS_OUTPUT.PUT_LINE('(COUPNUM,COUPETAT) ==>> ( ' || r_occ_non_enregistrer.COUPNUM || ', ' || 'annulé)' );
  END LOOP;
END;


/

/*
Cette procedure prend une occurence de vol et met ses coupons de vol qui ne sont 
pas a l'etat annulé a arriver 
*/

CREATE OR REPLACE PROCEDURE p_do_coupons_to_arriver (pOCCNUM OCCURENCE_VOL.OCCNUM%TYPE) AS
CURSOR c_occ_non_enregistrer IS 
  SELECT occ_v.OCCNUM ,coup_v.COUPNUM
  FROM OCCURENCE_VOL occ_v, COUPON_VOL coup_v
  WHERE occ_v.OCCNUM=coup_v.OCCNUM  AND
        occ_v.OCCNUM=pOCCNUM AND 
        coup_v.COUPETAT <> 'annulé' FOR UPDATE OF COUPETAT;
BEGIN
  FOR r_occ_non_enregistrer in c_occ_non_enregistrer LOOP
    UPDATE COUPON_VOL
    SET COUPETAT = 'arrivé'
    WHERE OCCNUM = r_occ_non_enregistrer.OCCNUM;
    DBMS_OUTPUT.PUT_LINE('(COUPNUM,COUPETAT) ==>> ( ' || r_occ_non_enregistrer.COUPNUM || ', ' || 'arrivé)' );
  END LOOP;
END;

/

/*
Cette function prend billet et compte le nombre de ses coupons qui sont dans l'état
arriver, si ce nombre est egale au nombre de coupons du billet elle retourne 1 sinon 0
*/
CREATE OR REPLACE FUNCTION f_is_all_coupons_arrive (pBILLNUM BILLET.BILLNUM%TYPE) 
RETURN NUMBER AS
vNB_OCC_VOL_ARRIVE NUMBER;
vNB_OCC_VOL_BILLET NUMBER;
BEGIN
  SELECT COUNT(OCCNUM) INTO vNB_OCC_VOL_ARRIVE FROM COUPON_VOL coup_v
  WHERE coup_v.BILLNUM = pBILLNUM AND COUPETAT= 'arrivé';
  
  SELECT COUNT(OCCNUM) INTO vNB_OCC_VOL_BILLET FROM COUPON_VOL coup_v
  WHERE coup_v.BILLNUM = pBILLNUM ;  
  IF vNB_OCC_VOL_ARRIVE = vNB_OCC_VOL_BILLET THEN 
    RETURN 1;
  END IF;
  RETURN 0;
END;
/


CREATE OR REPLACE PROCEDURE regere_coupon_vol (pAERONUM_DEROUTER OCCURENCE_VOL.AERONUM%TYPE) IS 

  CURSOR c_occ_vol IS SELECT OCCNUM
  FROM OCCURENCE_VOL occ_v, VOL v
  WHERE v.AERONUM_DEPART = pAERONUM_DEROUTER 
        AND v.VOLNUM = occ_v.VOLNUM 
        AND v.AERONUM_ARRIVEE = (SELECT AERONUM_ARRIVEE FROM VOL v1 WHERE v1.VOLNUM = v.VOLNUM);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Affecter les occ');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('PAS DE VOL DISPONIBLE POUR CET AEROPORT');  
    WHEN OTHERS THEN
        dbms_output.put_line('ERREUR  DAND LA PROCEDURE regere_coupon_vol==>'||SQLERRM);  
        
END;