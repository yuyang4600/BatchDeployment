insert into t03_tp_exec_qry_seq (EXECSQLKEY, SEQ, EXECSQL)
values ('CPKY-9093', 0, '/*step2����ȡ���������Ŀͻ�*/
INSERT INTO TMP_CPKY300001_01(
    ACCT_NUM
)
SELECT
    DISTINCT T.PARTY_ID
FROM
    T47_TRANSACTION_D T  /*������ˮ��*/
WHERE
     T.CASH_TRANS_FLAG =  @s_0005:char@                  /*�ֽ�*/
AND T.RECEIVE_PAY_CD  =  @s_0009:char@                  /*��*/
AND T.CAL_IND         =  @s_0011:char@                  /*����*/
AND T.RULE_IND        IN (@s_0016:char@, @s_0017:char@) /*������ɼ�����ߴ����ɶ��������*/
AND T.CHANNEL=@s_0036:char@
AND T.CB_TX_CD IN(''2111'',''2514'')
AND T.PARTY_ID IS NOT NULL');

insert into t03_tp_exec_qry_seq (EXECSQLKEY, SEQ, EXECSQL)
values ('CPKY-9092', 0, 'TRUNCATE TABLE TMP_CPKY300001_03');

insert into t03_tp_exec_qry_seq (EXECSQLKEY, SEQ, EXECSQL)
values ('CPKY-9091', 0, 'TRUNCATE TABLE TMP_CPKY300001_02');

insert into t03_tp_exec_qry_seq (EXECSQLKEY, SEQ, EXECSQL)
values ('CPKY-9090', 0, '/*step1������м�� */
TRUNCATE TABLE TMP_CPKY300001_01');

insert into t03_tp_exec_qry_seq (EXECSQLKEY, SEQ, EXECSQL)
values ('CPKY-9094', 0, '/*step3��ͳ�ƶ����ڶԹ������˻��ʽ�����������ۼƽ�ʱ���ֵ:(�����ۼƽ�� >= 1600000*/
INSERT INTO TMP_CPKY300001_02(
    TRANSACTIONKEY,
    ACCT_NUM      ,
    PARTY_ID      ,
    TX_DT         ,
    CNY_AMT       ,
    COUNT_TRANS   
)
SELECT
    TRANSACTIONKEY,  /*ҵ���ʶ*/
    ACCT_NUM      ,  /*�˺�*/
    PARTY_ID      ,  /*�ͻ���*/
    TX_DT         ,  /*��������*/
    CNY_AMT       ,  /*������ҽ��*/
    COUNT_TRANS   
FROM
    (
    SELECT
        T.TRANSACTIONKEY,
        T.ACCT_NUM      ,
        T.PARTY_ID      ,
        T.TX_DT         ,
        T.CNY_AMT       ,
        COUNT(T.TRANSACTIONKEY) OVER (PARTITION BY T.PARTY_ID,T.TX_DT) AS COUNT_TRANS
    FROM
        T64_RULE_TRANS_S  T,
        TMP_CPKYKY0101_01 T1
    WHERE
        T.PARTY_ID        =  T1.PARTY_ID
    AND T.CASH_TRANS_FLAG =  @s_0005:char@                  /*�ֽ�*/
    AND T.RECEIVE_PAY_CD  =  @s_0009:char@                  /*��*/
    AND T.CAL_IND         =  @s_0011:char@                  /*����*/
    AND T.RULE_IND        IN (@s_0016:char@, @s_0017:char@) /*������ɼ�����ߴ����ɶ��������*/
    AND T.CHANNEL=@s_0036:char@
    AND T.CB_TX_CD IN(''2111'',''2514'')
    AND T.TX_DT           <= @data_date:date@ /*��������*/
    AND T.TX_DT           >  @s_0001:date@    /*10��ǰ����*/
    )
WHERE
    COUNT_TRANS  >=  3');

insert into t03_tp_exec_qry_seq (EXECSQLKEY, SEQ, EXECSQL)
values ('CPKY-9095', 0, '/*setp4��ͳ�ƶ����ڶԹ������˻��ʽ������������ۼƽ�ʱ���ֵ*/
INSERT INTO TMP_CPKY300001_03(
    TRANSACTIONKEY
)
SELECT TRANSACTIONKEY FROM(
SELECT
    TRANSACTIONKEY,  /*ҵ���ʶ*/
    COUNT(T.TX_DT) OVER (PARTITION BY T.PARTY_ID) AS COUNT_DT
    FROM
    TMP_CPKYKY0101_02 T) 
    WHERE COUNT_DT>=3');

insert into t03_tp_exec_qry_seq (EXECSQLKEY, SEQ, EXECSQL)
values ('CPKY-9096', 0, '/*step7��д��Ԥ����ʱ��*/
INSERT INTO T68_ALERT_TMP(
    TEMPKEY     , /*CPKY-����ָ�꣩����-�����������-������������*/
    DATEDT      , /*��������*/
    HALFRESULT  , /*�м�������һ�������ֶΣ�ͨ��Ԥ����ʱ��ˮ�ֶ��п�֪�����������*/
    FCETKEY     , /*��ע��������ֵ*/
    FCETTYPECODE, /*��ע�������ͱ���*/
    FCETNAME    , /*��ע��������*/
    ALERTDESC       /*Ԥ������*/
)
SELECT
    ''CPKY-300001-'' || ''0000-'' || T3.ACCT_NUM, /*Ԥ����ʱ��ˮ��(CPKY-|�������|0000-|��������*/
    @data_date:char@, /*��ǰ����*/
    ''501|'' || T3.TRANSACTIONKEY || ''&'' || T3.PARTY_ID || ''&'' || T3.ACCT_NUM || ''&'' || T3.CNY_AMT|| /*501���뽻��*/
        ''|502|'' || T3.PARTY_ID || /*502�ͻ�*/
        ''|503|'' || T3.ACCT_NUM || ''&'' || T3.PARTY_ID, /*503�˻�*/
    ''X'' AS FCETKEY      , /*��ע��������ֵ*/
    ''X'' AS FCETTYPECODE , /*��ע�������ͱ���*/
    ''X'' AS FCETNAME     , /*��ע��������*/
    ''�����ڶԹ������˻�'' || T3.ACCT_NUM || ''������Ƶ�������޿��޴��۴��'' /*Ԥ������*/
FROM
    TMP_CPKY300001_02 T3,
    TMP_CPKY300001_03 T1
    WHERE T3.TRANSACTIONKEY =T1.TRANSACTIONKEY');

insert into t21_pbcrule (PBCKEY, INTERFACEKEY, STCRKEY, PBCKEYTYPE, ACTIONCODE, PBC_DES, PBC_CON, FLAG, CREATE_DT, CREATE_USR, CREATE_ORG, ISTRANS, GSTYPE, MODULEFLAG, SUXFLAG, PBCTYPE)
values ('CPKY-3000', 'BS', '1119', '2', '1102', '������Ƶ�������޿��޴��۴��', '������Ƶ�������޿��޴��۴��', '1', null, 'admin', '0', '1', '2', '0', '0', '1');
insert into t21_rule (TPLAKEY, RULEKEY, RULE_DES, RULE_CON, FLAG, PARTY_CD, ORGANKEYTYPE, GSTYPE, DAY_FLAG, CREATE_DT, CREATE_USR, CREATE_ORG, INTERFACEKEY, PBCKEY, GRANULAIRTY, CURR_CD, PARTY_ACCT_CD, TYPE_DES, DEPLOYFLAG, MODIFIER, MODIFYTIME)
values ('CPKY-30000', 'CPKY-300001', '������Ƶ�������޿��޴��۽���', '������Ƶ�������޿��޴��۽���', '1', null, null, '2', null, '2013-10-15', 'admin', '8000000', 'BS', 'CPKY-KB30', '1', '1', '1', '�ͻ�', '0', null, null);
insert into t03_tp_exec_qry (EXECSQLKEY, TPLAKEY, EXECSEQ, ISMAINQUERY, RECSTAT)
values ('CPKY-9093', 'CPKY-30000', 3, '0', '1');

insert into t03_tp_exec_qry (EXECSQLKEY, TPLAKEY, EXECSEQ, ISMAINQUERY, RECSTAT)
values ('CPKY-9092', 'CPKY-30000', 2, '0', '1');

insert into t03_tp_exec_qry (EXECSQLKEY, TPLAKEY, EXECSEQ, ISMAINQUERY, RECSTAT)
values ('CPKY-9091', 'CPKY-30000', 1, '0', '1');

insert into t03_tp_exec_qry (EXECSQLKEY, TPLAKEY, EXECSEQ, ISMAINQUERY, RECSTAT)
values ('CPKY-9090', 'CPKY-30000', 0, '0', '1');

insert into t03_tp_exec_qry (EXECSQLKEY, TPLAKEY, EXECSEQ, ISMAINQUERY, RECSTAT)
values ('CPKY-9094', 'CPKY-30000', 4, '0', '1');

insert into t03_tp_exec_qry (EXECSQLKEY, TPLAKEY, EXECSEQ, ISMAINQUERY, RECSTAT)
values ('CPKY-9095', 'CPKY-30000', 5, '0', '1');

insert into t03_tp_exec_qry (EXECSQLKEY, TPLAKEY, EXECSEQ, ISMAINQUERY, RECSTAT)
values ('CPKY-9096', 'CPKY-30000', 6, '0', '1');

insert into t18_tasklist (BUSINESSKEY, TASKTYPE, DEPANDONTYPE, DSKEY, GRANULARITY, ORGANKEY, SUBTASKNUM, ORDERSEQ, ORGKEYEXEC)
values ('2CPKY-300001', 'M351', null, '100', '1', '0', null, null, null);

insert into T03_rule_entity_r (RTETTYPEKEY, TPLAKEY)
   values ('501', 'CPKY-300001');
insert into T03_rule_entity_r (RTETTYPEKEY, TPLAKEY)
   values ('502', 'CPKY-300001');
insert into T03_rule_entity_r (RTETTYPEKEY, TPLAKEY)
   values ('503', 'CPKY-300001');
update t03_tp_exec_qry_seq set EXECSQL= '/*step 1.����Ԥ�������*/
INSERT INTO T68_ALERT_TMP
  (TEMPKEY, /*CPKY-����ָ�꣩����-�����������-������������*/
   DATEDT, /*��������*/
   HALFRESULT, /*�м�������һ�������ֶΣ�ͨ��Ԥ����ʱ��ˮ�ֶ��п�֪�����������*/
   FCETKEY, /*��ע��������ֵ*/
   FCETTYPECODE, /*��ע�������ͱ���*/
   FCETNAME, /*��ע��������*/
   ALERTDESC /*Ԥ������*/)
  SELECT ''CPKY-'' || ''KY1901-'' || ''0000-'' || T.PARTY_ID AS TEMPKEY,
         @data_date:date@ AS DATEDT,
         ''501|'' || T.TRANSACTIONKEY || ''&'' || T.PARTY_ID || ''&'' ||
         T.ACCT_NUM || ''&'' || T. CNY_AMT || /*501����*/ ''|502|'' || T.PARTY_ID || /*502�ͻ�*/ ''|503|'' || T.ACCT_NUM ||''&'' || T.PARTY_ID AS HALFRESULT, /*503�˻�*/
         ''X'' AS FCETKEY,
         ''X'' AS FCETTYPECODE,
         ''X'' AS FCETNAME,
         ''�������ͻ�'' || T.PARTY_ID || ''��������'' AS ALERTDESC
    FROM T07_BLACKLIST P, T47_TRANSACTION_D T
   WHERE (P.PARTY_ID = T.PARTY_ID
         or
         P.PARTY_ID = T.Opp_Party_Id
         or 
         instr(p.obj_name,t.opp_name)>0
         or 
         instr(p.obj_name,t.party_chn_name)>0
         or 
         p.card_no=t.opp_card_no
         )
     AND T.CAL_IND = @s_0011:char@
     AND T.RULE_IND IN (@s_0016:char@, @s_0017:char@)
     AND P.ISUSE = ''0'' /*����*/
     AND P.ISCHECK = ''1'' /*����ͨ��*/
     'where EXECSQLKEY='CPKY-9049' ;
create table TMP_CPKY300001_01
(
  party_id       VARCHAR2(24)
)
tablespace TSDAT05;
create table TMP_CPKY300001_02
(
  transactionkey VARCHAR2(64),
  acct_num       VARCHAR2(32),
  party_id       VARCHAR2(24),
  tx_dt          DATE,
  cny_amt        NUMBER(20,2),
  count_trans    NUMBER(20)
)
tablespace TSDAT05;
create table TMP_CPKY300001_03
(
  transactionkey VARCHAR2(64)
)
tablespace TSDAT05;