SELECT s_name,
       Count(1) AS numwait
FROM   (SELECT s_name
        FROM   (SELECT s_name,
                       t2.l_orderkey,
                       l_suppkey,
                       count_suppkey,
                       max_suppkey
                FROM   (SELECT l_orderkey,
                               Count(DISTINCT l_suppkey) AS count_suppkey,
                               Max(l_suppkey)            AS max_suppkey
                        FROM   lineitem
                        WHERE  l_receiptdate > l_commitdate
                        GROUP  BY l_orderkey) t2
                       RIGHT OUTER JOIN (SELECT s_name,
                                                l_orderkey,
                                                l_suppkey
                                         FROM   (SELECT s_name,
                                                        t1.l_orderkey,
                                                        l_suppkey,
                                                        count_suppkey,
                                                        max_suppkey
                                                 FROM   (SELECT l_orderkey,
                                                                Count(DISTINCT l_suppkey) AS count_suppkey,
                                                                Max(l_suppkey)            AS max_suppkey
                                                         FROM   lineitem
                                                         GROUP  BY l_orderkey) t1
                                                        JOIN (SELECT s_name,
                                                                     l_orderkey,
                                                                     l_suppkey
                                                              FROM   orders o
                                                                     JOIN (SELECT s_name,
                                                                                  l_orderkey,
                                                                                  l_suppkey
                                                                           FROM   nation n
                                                                                  JOIN supplier s
                                                                                    ON s.s_nationkey = n.n_nationkey
                                                                                       AND n.n_name = 'SAUDI ARABIA'
                                                                                  JOIN lineitem l
                                                                                    ON s.s_suppkey = l.l_suppkey
                                                                           WHERE  l.l_receiptdate > l.l_commitdate) l1
                                                                       ON o.o_orderkey = l1.l_orderkey
                                                                          AND o.o_orderstatus = 'F') l2
                                                          ON l2.l_orderkey = t1.l_orderkey) a
                                         WHERE  ( count_suppkey > 1 )
                                                 OR ( ( count_suppkey = 1 )
                                                      AND ( l_suppkey <> max_suppkey ) )) l3
                         ON l3.l_orderkey = t2.l_orderkey) b
        WHERE  ( count_suppkey IS NULL )
                OR ( ( count_suppkey = 1 )
                     AND ( l_suppkey = max_suppkey ) ))c
GROUP  BY s_name
ORDER  BY numwait DESC,
          s_name 
LIMIT 100;
