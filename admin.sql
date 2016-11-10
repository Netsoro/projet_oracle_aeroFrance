CREATE USER gere_billet IDENTIFIED BY gbillet;
GRANT CREATE SESSION TO gere_billet;
GRANT SELECT,INSERT ON projet_oracle_diarog.BILLET TO gere_billet;
GRANT EXECUTE ON projet_oracle_diarog.insertion_billet TO gere_billet;

CREATE USER gere_occurence IDENTIFIED BY gocc;
GRANT CREATE SESSION TO gere_occurence;
GRANT SELECT,INSERT ON PROJET_ORACLE_DIAROG.VIEW_OCCURENCE_VOL TO gere_occurence;
GRANT EXECUTE ON projet_oracle_diarog.p_insert_in_view_occ_vol TO gere_occurence;


CREATE USER gere_flash IDENTIFIED BY fcoup;
GRANT CREATE SESSION TO gere_flash;
GRANT SELECT,INSERT ON PROJET_ORACLE_DIAROG.VIEW_COUPON_VOL TO gere_flash;
GRANT EXECUTE ON projet_oracle_diarog.p_flash_coupon TO gere_flash;