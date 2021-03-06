SELECT ALL
TO_CHAR(F.DATE_OF_ISSUE,'DD-Mon-YY') AS DATE_OF_ISSUE,
TO_CHAR(F.UPLIFT_DATE, 'MM') FLT_MONTH,
TO_CHAR(F.UPLIFT_DATE, 'yyyy') FLT_YEAR,
F.FROM_CITY||F.TO_CITY Sector,
DECODE(UPC.COUNTRY_CODE, TOC.COUNTRY_CODE, 'D', 'I') "DOM-INT",
SUM(NVL(F.PAX_COUNT, 0)) Pax_cnt,
SUM(DECODE(F.NON_REV_FLAG, 'Y', 1, 0)*NVL(F.PAX_COUNT, 0)) Foc,
CASE
    WHEN (DECODE(UPC.COUNTRY_CODE, TOC.COUNTRY_CODE, 'D', 'I') = 'I' AND NVL(DECODE(F.ISS_AIRLINE, 738, F.AUDIT_PRORATE_CURRENCY, F.PRORATE_CURRENCY),F.PRORATE_CURRENCY) = 'VND')
    THEN 'USD'
    ELSE NVL(DECODE(F.ISS_AIRLINE, 738, F.AUDIT_PRORATE_CURRENCY, F.PRORATE_CURRENCY),F.PRORATE_CURRENCY)
END AS EQUIV_CURR,
SUM(
    CASE 
        WHEN (DECODE(UPC.COUNTRY_CODE, TOC.COUNTRY_CODE, 'D', 'I') = 'I' AND NVL(DECODE(F.ISS_AIRLINE, 738, F.AUDIT_PRORATE_CURRENCY, F.PRORATE_CURRENCY),F.PRORATE_CURRENCY) = 'VND')
        THEN INTERNAL_CURR_CONV('VND','USD',F.DATE_OF_ISSUE,DECODE (F.ISS_AIRLINE,'738',DECODE (NVL (F.MATCHED_FLAG,'N'),'N',F.REVENUE,INTERNAL_CURR_CONV(NVL(F.AUDIT_PRORATE_CURRENCY,F.PRORATE_CURRENCY),'VND',NVL(F.DATE_OF_ISSUE,F.ORIG_DATE_OF_ISSUE),1)*F.AUDIT_SECTOR_AMOUNT_SC),F.REVENUE))
        ELSE DECODE(F.ISS_AIRLINE, 738, DECODE (NVL (F.MATCHED_FLAG,'N'),'N',F.SECTOR_VALUE,F.AUDIT_SECTOR_AMOUNT_SC), F.SECTOR_VALUE)
    END
) AS EQUIV_REV_NTE,   
SUM(T.YQ_NTE) AS YQ_NTE,
SUM(T.YR_NTE) AS YR_NTE,
UPC.COUNTRY_CODE ORI_COUNTRY,
TOC.COUNTRY_CODE DES_COUNTRY
FROM
CITY_MASTER UPC,
CITY_MASTER TOC,
REVERA_OWNER.EFF_REP_TABLE F
LEFT JOIN
(
    SELECT
    ISS_AIRLINE,
    DOC_NO,
    COUPON_NO,
    SUM(DECODE(TAX_CODE,'YQ',AUDIT_TAX_AMOUNT,NULL)) AS YQ_NTE,
    SUM(DECODE(TAX_CODE,'YR',AUDIT_TAX_AMOUNT,NULL)) AS YR_NTE,
    SUM(DECODE(TAX_CODE, 'YQ', AUDIT_TAX_AMOUNT_LC)) AS YQ_VND,
    SUM(DECODE(TAX_CODE, 'YR', AUDIT_TAX_AMOUNT_LC)) AS YR_VND
    FROM
    TICKET_TAX_DETAIL
    WHERE
    TAX_CODE IN ('YQ','YR')
    AND UTIL_TYPE = 'U'
    AND MATCHED_FLAG = 'Y'
    GROUP BY
    ISS_AIRLINE,
    DOC_NO,
    COUPON_NO
) T
ON
(
F.ISS_AIRLINE = T.ISS_AIRLINE
AND F.DOC_NO = T.DOC_NO
AND F.COUPON_NO = T.COUPON_NO
)
WHERE
--F.UPLIFT_DATE >= '01-JUN-2020' 
--AND F.UPLIFT_DATE <= '07-JUN-2020'
F.UPLIFT_DATE >= TO_DATE(CONCAT(:F_DATE,01), 'yyyymmdd')
AND F.UPLIFT_DATE <= TO_DATE(CONCAT(:F_DATE,07), 'yyyymmdd')
AND  ((F.UPLIFT_STATION=UPC.CITY_CODE_ALPHA)
AND (F.TO_CITY=TOC.CITY_CODE_ALPHA))
AND F.FLIGHT_NO <8000
--AND ROWNUM =1
GROUP BY
TO_CHAR(F.DATE_OF_ISSUE,'DD-Mon-YY'),
TO_CHAR(F.UPLIFT_DATE, 'MM'),
TO_CHAR(F.UPLIFT_DATE, 'yyyy'),
F.FROM_CITY||F.TO_CITY,
DECODE(UPC.COUNTRY_CODE, TOC.COUNTRY_CODE, 'D', 'I'), 
NVL(DECODE(F.ISS_AIRLINE, 738, F.AUDIT_PRORATE_CURRENCY, F.PRORATE_CURRENCY),F.PRORATE_CURRENCY),
UPC.COUNTRY_CODE, 
TOC.COUNTRY_CODE
