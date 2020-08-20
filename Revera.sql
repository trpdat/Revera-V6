SELECT
E.FLIGHT_NO,
E.ISS_AIRLINE,
E.DOC_NO,
E.COUPON_NO,
E.DOC_CLASS,
E.FROM_CITY || E.TO_CITY AS SECTOR,
E.CLASS,
E.AOS,
SUM(DECODE(E.ISS_AIRLINE, 738, 
                    REVERA_OWNER.INTERNAL_CURR_CONV(E.AUDIT_PRORATE_CURRENCY,
                                                                                 'VND', 
                                                                                 E.DATE_OF_ISSUE, 
                                                                                 E.AUDIT_SECTOR_AMOUNT_SC),
                     REVERA_OWNER.INTERNAL_CURR_CONV(E.PRORATE_CURRENCY, 
                                                                                'VND', 
                                                                                E.UPLIFT_DATE, 
                                                                                E.SECTOR_VALUE))) "REVENUE-VND"
FROM
EFF_REP_TABLE E
where
uplift_date between '01-jan-2020' and '31-mar-2020'
and doc_class in ('PAX', 'FIM')
GROUP BY
E.FLIGHT_NO,
E.UPLIFT_DATE,
E.ISS_AIRLINE,
E.DOC_NO,
E.COUPON_NO,
E.DOC_CLASS,
E.FROM_CITY || E.TO_CITY,
E.CLASS,
E.AOS
