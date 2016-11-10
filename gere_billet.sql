SET SERVEROUTPUT ON;
execute projet_oracle_diarog.insertion_billet(1,8,to_date('16/11/16','DD/MM/RR'),'émis',1);
SELECT * FROM projet_oracle_diarog.BILLET;
