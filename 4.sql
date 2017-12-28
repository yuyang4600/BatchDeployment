insert into t03_tp_exec_qry_seq (EXECSQLKEY, SEQ, EXECSQL)
values ('CPKY-9093', 0, '/*step2、抽取满足条件的客户*/
INSERT INTO TMP_CPKY300001_01(
    ACCT_NUM
)
SELECT
    DISTINCT T.PARTY_ID
FROM
    T47_TRANSACTION_D T  /*当天流水表*/
WHERE
     T.CASH_TRANS_FLAG =  @s_0005:char@                  /*现金*/
AND T.RECEIVE_PAY_CD  =  @s_0009:char@                  /*收*/
AND T.CAL_IND         =  @s_0011:char@                  /*计算*/
AND T.RULE_IND        IN (@s_0016:char@, @s_0017:char@) /*参与可疑计算或者大额可疑都参与计算*/
AND T.CHANNEL=@s_0036:char@
AND T.CB_TX_CD IN(''2111'',''2514'')
AND T.PARTY_ID IS NOT NULL');

insert into t03_tp_exec_qry_seq (EXECSQLKEY, SEQ, EXECSQL)
values ('CPKY-9092', 0, 'TRUNCATE TABLE TMP_CPKY300001_03');

insert into t03_tp_exec_qry_seq (EXECSQLKEY, SEQ, EXECSQL)
values ('CPKY-9091', 0, 'TRUNCATE TABLE TMP_CPKY300001_02');

insert into t03_tp_exec_qry_seq (EXECSQLKEY, SEQ, EXECSQL)
values ('CPKY-9090', 0, '/*step1、清除中间表： */
TRUNCATE TABLE TMP_CPKY300001_01');

insert into t03_tp_exec_qry_seq (EXECSQLKEY, SEQ, EXECSQL)
values ('CPKY-9094', 0, '/*step3、统计短期内对公本币账户资金流入次数、累计金额、时间均值:(流入累计金额 >= 1600000*/
INSERT INTO TMP_CPKY300001_02(
    TRANSACTIONKEY,
    ACCT_NUM      ,
    PARTY_ID      ,
    TX_DT         ,
    CNY_AMT       ,
    COUNT_TRANS   
)
SELECT
    TRANSACTIONKEY,  /*业务标识*/
    ACCT_NUM      ,  /*账号*/
    PARTY_ID      ,  /*客户号*/
    TX_DT         ,  /*交易日期*/
    CNY_AMT       ,  /*折人民币金额*/
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
    AND T.CASH_TRANS_FLAG =  @s_0005:char@                  /*现金*/
    AND T.RECEIVE_PAY_CD  =  @s_0009:char@                  /*收*/
    AND T.CAL_IND         =  @s_0011:char@                  /*计算*/
    AND T.RULE_IND        IN (@s_0016:char@, @s_0017:char@) /*参与可疑计算或者大额可疑都参与计算*/
    AND T.CHANNEL=@s_0036:char@
    AND T.CB_TX_CD IN(''2111'',''2514'')
    AND T.TX_DT           <= @data_date:date@ /*计算日期*/
    AND T.TX_DT           >  @s_0001:date@    /*10天前日期*/
    )
WHERE
    COUNT_TRANS  >=  3');

insert into t03_tp_exec_qry_seq (EXECSQLKEY, SEQ, EXECSQL)
values ('CPKY-9095', 0, '/*setp4、统计短期内对公本币账户资金流出次数、累计金额、时间均值*/
INSERT INTO TMP_CPKY300001_03(
    TRANSACTIONKEY
)
SELECT TRANSACTIONKEY FROM(
SELECT
    TRANSACTIONKEY,  /*业务标识*/
    COUNT(T.TX_DT) OVER (PARTITION BY T.PARTY_ID) AS COUNT_DT
    FROM
    TMP_CPKYKY0101_02 T) 
    WHERE COUNT_DT>=3');

insert into t03_tp_exec_qry_seq (EXECSQLKEY, SEQ, EXECSQL)
values ('CPKY-9096', 0, '/*step7、写入预警临时表*/
INSERT INTO T68_ALERT_TMP(
    TEMPKEY     , /*CPKY-规则（指标）编码-触发主体类别-触发主体主键*/
    DATEDT      , /*数据日期*/
    HALFRESULT  , /*中间结果：是一个复合字段：通过预警临时流水字段中可知触发主体类别*/
    FCETKEY     , /*关注主体主键值*/
    FCETTYPECODE, /*关注主体类型编码*/
    FCETNAME    , /*关注主体名称*/
    ALERTDESC       /*预警描述*/
)
SELECT
    ''CPKY-300001-'' || ''0000-'' || T3.ACCT_NUM, /*预警临时流水号(CPKY-|规则编码|0000-|申请书编号*/
    @data_date:char@, /*当前日期*/
    ''501|'' || T3.TRANSACTIONKEY || ''&'' || T3.PARTY_ID || ''&'' || T3.ACCT_NUM || ''&'' || T3.CNY_AMT|| /*501流入交易*/
        ''|502|'' || T3.PARTY_ID || /*502客户*/
        ''|503|'' || T3.ACCT_NUM || ''&'' || T3.PARTY_ID, /*503账户*/
    ''X'' AS FCETKEY      , /*关注主体主键值*/
    ''X'' AS FCETTYPECODE , /*关注主体类型编码*/
    ''X'' AS FCETNAME     , /*关注主体名称*/
    ''短期内对公本币账户'' || T3.ACCT_NUM || ''短期内频繁发生无卡无存折存款'' /*预警描述*/
FROM
    TMP_CPKY300001_02 T3,
    TMP_CPKY300001_03 T1
    WHERE T3.TRANSACTIONKEY =T1.TRANSACTIONKEY');

insert into t21_pbcrule (PBCKEY, INTERFACEKEY, STCRKEY, PBCKEYTYPE, ACTIONCODE, PBC_DES, PBC_CON, FLAG, CREATE_DT, CREATE_USR, CREATE_ORG, ISTRANS, GSTYPE, MODULEFLAG, SUXFLAG, PBCTYPE)
values ('CPKY-3000', 'BS', '1119', '2', '1102', '短期内频繁发生无卡无存折存款', '短期内频繁发生无卡无存折存款', '1', null, 'admin', '0', '1', '2', '0', '0', '1');
insert into t21_rule (TPLAKEY, RULEKEY, RULE_DES, RULE_CON, FLAG, PARTY_CD, ORGANKEYTYPE, GSTYPE, DAY_FLAG, CREATE_DT, CREATE_USR, CREATE_ORG, INTERFACEKEY, PBCKEY, GRANULAIRTY, CURR_CD, PARTY_ACCT_CD, TYPE_DES, DEPLOYFLAG, MODIFIER, MODIFYTIME)
values ('CPKY-30000', 'CPKY-300001', '短期内频繁发生无卡无存折交易', '短期内频繁发生无卡无存折交易', '1', null, null, '2', null, '2013-10-15', 'admin', '8000000', 'BS', 'CPKY-KB30', '1', '1', '1', '客户', '0', null, null);
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
update t03_tp_exec_qry_seq set EXECSQL= '/*step 1.插入预警结果表*/
INSERT INTO T68_ALERT_TMP
  (TEMPKEY, /*CPKY-规则（指标）编码-触发主体类别-触发主体主键*/
   DATEDT, /*数据日期*/
   HALFRESULT, /*中间结果：是一个复合字段：通过预警临时流水字段中可知触发主体类别*/
   FCETKEY, /*关注主体主键值*/
   FCETTYPECODE, /*关注主体类型编码*/
   FCETNAME, /*关注主体名称*/
   ALERTDESC /*预警描述*/)
  SELECT ''CPKY-'' || ''KY1901-'' || ''0000-'' || T.PARTY_ID AS TEMPKEY,
         @data_date:date@ AS DATEDT,
         ''501|'' || T.TRANSACTIONKEY || ''&'' || T.PARTY_ID || ''&'' ||
         T.ACCT_NUM || ''&'' || T. CNY_AMT || /*501交易*/ ''|502|'' || T.PARTY_ID || /*502客户*/ ''|503|'' || T.ACCT_NUM ||''&'' || T.PARTY_ID AS HALFRESULT, /*503账户*/
         ''X'' AS FCETKEY,
         ''X'' AS FCETTYPECODE,
         ''X'' AS FCETNAME,
         ''黑名单客户'' || T.PARTY_ID || ''发生交易'' AS ALERTDESC
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
     AND P.ISUSE = ''0'' /*启用*/
     AND P.ISCHECK = ''1'' /*审批通过*/
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