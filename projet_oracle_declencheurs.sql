
CREATE OR REPLACE TRIGGER DECL_INSERT_OCC_VOL
INSTEAD OF INSERT ON view_occurence_vol REFERENCING OLD AS OLS NEW AS NEW
FOR EACH ROW
DECLARE
  vOCCNUM_BIDON OCCURENCE_VOL.OCCNUM%TYPE :=0;
  vPKNUM PARKING.PKNUM%TYPE := 0;
  vPORTENUM PORTE.PORTENUM%TYPE :=0;
  vPASSNUM  PASSERELLE.PASSNUM%TYPE :=0;
  vPASSCAPACITE PASSERELLE.PASSCAPACITE%TYPE;
BEGIN
  --création de l'occurence de vol
   INSERT INTO OCCURENCE_VOL(OCCNUM,VOLNUM,AERONUM,OCCDATE,OCCETAT) 
   VALUES(:NEW.OCCNUM,:NEW.VOLNUM,:NEW.AERONUM,:NEW.OCCDATE,'ouvert_reservation');
  --On recupere l'occurence Bidon du vol s'il existe
   vOCCNUM_BIDON := f_recupere_occ_bidon(:NEW.VOLNUM);
  --On recupere le couple porte/parking de l'occurence bidon
    p_recupere_porte_pk_occ_bidon(vOCCNUM_BIDON,vPORTENUM,vPKNUM);
    DBMS_OUTPUT.PUT_LINE('OCC BIDON  =====>> ' || vOCCNUM_BIDON);
    DBMS_OUTPUT.PUT_LINE('NOUVEL OCC =====>> ' ||   :NEW.OCCNUM);
  --Si l'occurence bidon à un couple porte/parking de dispo
  IF vPORTENUM <> 0 AND  vPKNUM <> 0 THEN 
     --On selectionne la passerelle associé au couple
     BEGIN
          SELECT pass.PASSNUM, pass.PASSCAPACITE
            INTO vPASSNUM,vPASSCAPACITE
            FROM PASSERELLE pass
            WHERE pass.PORTENUM = vPORTENUM AND 
                  pass.PKNUM = vPKNUM AND 
                  ROWNUM = 1 
                  ORDER BY pass.PASSCAPACITE;
          -- Si une passerelle est associé on affecte le triplet 
          p_insert_in_affecte_porte_pk(:NEW.OCCNUM,vPORTENUM,vPKNUM);
          UPDATE PASSERELLE
            SET PORTENUM = vPORTENUM ,
                PKNUM = vPKNUM 
            WHERE  PASSNUM = vPASSNUM;  
          dbms_output.put_line('(PORTENUM, PKNUM ,PASSNUM )  ===>> ' || 
                              '('||vPORTENUM||','||vPKNUM||','||vPASSNUM||')');
     EXCEPTION 
      WHEN NO_DATA_FOUND THEN
        --Dans le cas ou il n'ya pas de passerelle de dispo on affecte 
        --quand même le couple porte/pk
        p_insert_in_affecte_porte_pk(:NEW.OCCNUM,vPORTENUM,vPKNUM);
        dbms_output.put_line('IL N''YA PAS DE PASSERELLE AFFECTATION DU COUPLE 
        (PORTENUM,PKNUM) ==> (' || vPORTENUM || ',' || vPKNUM || ')' );    
      WHEN OTHERS THEN 
        dbms_output.put_line('ERREUR DANS AFFECT BLOC PASSERELLE==>'||SQLERRM);   
     END;
  ELSE 
      --Dans le cas ou l'occurence n''a pas de couple porte/pk, on l'affecte 
      --alors ce couple par rapport au disponibilité
      p_affecte_porte_parking(:NEW.OCCNUM);        
  END IF;
END;



/


CREATE OR REPLACE TRIGGER DECL_COUPON_VOL 
INSTEAD OF UPDATE ON view_coupon_vol 
REFERENCING OLD AS OLD NEW AS NEW 
BEGIN
    DBMS_OUTPUT.PUT_LINE('<=== DEBUT UPDATE view_coupon_vol===>');
  BEGIN
    UPDATE COUPON_VOL
        SET COUPETAT = :NEW.COUPETAT
        where COUPNUM=:NEW.COUPNUM; 
  IF :NEW.COUPETAT ='enregistré' THEN
    UPDATE BILLET
      SET BILLETAT = 'encours'
      where BILLNUM=:NEW.BILLNUM ; 
    DBMS_OUTPUT.PUT_LINE('(BILLNUM,BILLETAT) ==>> ( ' || :NEW.BILLNUM || ', ' || 'encours)' );
  ELSIF :NEW.COUPETAT  = 'arrivé' THEN 
    IF f_is_all_coupons_arrive(:NEW.BILLNUM) = 1 THEN
      UPDATE BILLET
        SET BILLETAT = 'terminé'
        where BILLNUM=:NEW.BILLNUM;    
      DBMS_OUTPUT.PUT_LINE('(BILLNUM,BILLETAT) ==>> ( ' || :NEW.BILLNUM || ', ' || 'terminé)' );
    END IF;
  END IF;
 END;
 DBMS_OUTPUT.PUT_LINE('<=== FIN UPDATE view_coupon_vol ===>');
END;



/

CREATE OR REPLACE TRIGGER DECL_OCCURENCE_VOL 
INSTEAD OF UPDATE ON view_occurence_vol 
REFERENCING OLD AS OLD NEW AS NEW 
BEGIN
  DBMS_OUTPUT.PUT_LINE('<<==DEBUT UPDATE view_occurence_vol==>>');
  BEGIN    
    UPDATE OCCURENCE_VOL
       SET OCCETAT = :NEW.OCCETAT
       where OCCNUM=:NEW.OCCNUM ; 
        
    IF :NEW.OCCETAT ='décollé' THEN
      p_not_saved_coupons_to_cancel(:NEW.OCCNUM);
    ELSIF :NEW.OCCETAT  = 'arrivé' THEN 
      p_do_coupons_to_arriver(:NEW.OCCNUM);
    ELSIF :NEW.OCCETAT  = 'derouté' THEN
      p_do_coupons_to_arriver(:NEW.OCCNUM);
    END IF;
  END;
  DBMS_OUTPUT.PUT_LINE('<<==FIN UPDATE view_occurence_vol==>>');
END;

/
create or replace TRIGGER DECL_INSERTION_COUPON_VOL 
AFTER INSERT ON BILLET 
REFERENCING OLD AS OLD NEW AS NEW 
FOR EACH ROW
DECLARE
BEGIN
  genere_coupon_vole(:NEW.BILLNUM,:NEW.TRANUM,:NEW.BILLDATEDEPART);
END;

/
CREATE OR REPLACE TRIGGER DECL_INSERT_VOL 
INSTEAD OF INSERT ON VIEW_VOL
REFERENCING OLD AS OLS NEW AS NEW
FOR EACH ROW
DECLARE
  vOCCNUM OCCURENCE_VOL.OCCNUM%TYPE;
BEGIN
  --création du vol
  INSERT INTO VOL (VOLNUM, AERONUM_DEPART, AERONUM_ARRIVEE, H_DEPART, M_DEPART, 
                  H_ARRIVEE, M_ARRIVEE, VOLNBPLACES, NBMINUTESAVANT, NBMINUTESAPRES)
  VALUES (:NEW.VOLNUM, :NEW.AERONUM_DEPART, :NEW.AERONUM_ARRIVEE, :NEW.H_DEPART, 
          :NEW.M_DEPART, :NEW.H_ARRIVEE, :NEW.M_ARRIVEE, :NEW.VOLNBPLACES, 
          :NEW.NBMINUTESAVANT, :NEW.NBMINUTESAPRES);
  --création d'une occ bidon et alloc d'uneporte é cette occ
  vOCCNUM := Seq_occ_vol.nextval;
  INSERT INTO OCCURENCE_VOL(OCCNUM,VOLNUM,AERONUM,OCCDATE,OCCETAT) 
  VALUES (vOCCNUM,:NEW.VOLNUM,:NEW.AERONUM_DEPART,to_date('1/1/00','DD/MM/YY'),'ouvert_reservation');
  p_affecte_porte_parking (vOCCNUM);
  
  dbms_output.put_line('OCCNUM , VOLNUM ) ==>>  ('|| vOCCNUM || ',' ||:NEW.VOLNUM || ')');
  
END;