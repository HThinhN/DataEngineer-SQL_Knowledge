﻿-- Knowledge 5: Truy vấn lồng nâng cao
USE SCHOOL_MANAGEMENT
----------------------------------------------------------------------------------------
-- 1. Các phép toán tập hợp 

-- 1.1. Phép trừ:
-- Cách làm:
-- + Sử dụng toán tử EXCEPT
-- + Truy vấn lồng với NOT EXISTS hoặc NOT IN

-- Ví dụ 2: Tìm các giáo viên không tham gia đề tài nào 
-- EXCEPT
SELECT *
FROM GIAOVIEN 
EXCEPT
SELECT DISTINCT GV.*
FROM GIAOVIEN AS GV, THAMGIADT AS TGDT
WHERE GV.MAGV = TGDT.MAGV

-- NOT EXISTS
SELECT GV.*
FROM GIAOVIEN AS GV 
WHERE NOT EXISTS(SELECT *
				 FROM THAMGIADT AS TGDT
				 WHERE TGDT.MAGV = GV.MAGV)

-- NOT IN
SELECT GV.*
FROM GIAOVIEN AS GV
WHERE GV.MAGV NOT IN (SELECT DISTINCT TGDT.MAGV
					  FROM THAMGIADT AS TGDT)

-- 1.2. Phép giao
-- Cách làm:
-- + Sử dụng toán tử INTERSECT
-- + Truy vấn lồng với EXISTS hoặc IN
-- + Sử dụng phép kết thông thường

-- Ví dụ 3: Tìm các giáo viên vừa tham gia đề tài vừa là trưởng bộ môn
-- INTERSECT
SELECT GV.*
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MAGV = BM.TRUONGBM
INTERSECT
SELECT GV.*
FROM GIAOVIEN AS GV, THAMGIADT AS TGDT
WHERE GV.MAGV = TGDT.MAGV

-- EXISTS (Có thể dùng luôn 2 EXISTS)
SELECT GV.*
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MAGV = BM.TRUONGBM 
AND EXISTS (SELECT *
			FROM THAMGIADT AS TGDT
			WHERE TGDT.MAGV = GV.MAGV)

-- IN (Có thể dùng luôn 2 IN)
SELECT DISTINCT GV.*
FROM GIAOVIEN AS GV, THAMGIADT AS TGDT
WHERE GV.MAGV = TGDT.MAGV
AND GV.MAGV IN (SELECT BM.TRUONGBM
				FROM BOMON AS BM)

-- Phép kết thông thường
SELECT DISTINCT GV.*
FROM GIAOVIEN AS GV, BOMON AS BM, THAMGIADT AS TGDT
WHERE GV.MAGV = BM.TRUONGBM AND GV.MAGV = TGDT.MAGV

-- 1.3. Phép hội 
-- Cách làm: 
-- + Sử dụng toán tử UNION (Các dòng trùng lặp sẽ được bỏ đi) 
-------------------- UNION ALL (Lấy tất cả các dòng của các bảng)
-- + Truy vấn lồng với EXISTS hoặc IN

-- Ví dụ 4: Liệt kê những giáo viên có tham gia đề tài và những giáo viên là trưởng bộ môn
-- UNION 
SELECT GV.*
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MAGV = BM.TRUONGBM
UNION
SELECT GV.*
FROM GIAOVIEN AS GV, THAMGIADT AS TGDT
WHERE GV.MAGV = TGDT.MAGV

-- EXISTS (Có thể dùng 2 EXISTS)
SELECT DISTINCT GV.*
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MAGV = BM.TRUONGBM 
OR EXISTS (SELECT *
			FROM THAMGIADT AS TGDT
			WHERE TGDT.MAGV = GV.MAGV)

-- IN (Có thể dùng luôn 2 IN)
SELECT DISTINCT GV.*
FROM GIAOVIEN AS GV, THAMGIADT AS TGDT
WHERE GV.MAGV = TGDT.MAGV
OR GV.MAGV IN (SELECT BM.TRUONGBM
				FROM BOMON AS BM)

----------------------------------------------------------------------------------------
-- 2. Phép chia
-- 2.1 Sử dụng EXCEPT:
-- Cú pháp:
-- + SELECT R1.A, R1.B, R1.C
-- + FROM R AS R1
-- + WHERE NOT EXISTS( (SELECT S.D, S.E DROM S)
--						EXCEPT
--					   (SELECT R2.D, R2.E
--					    FROM R AS R2
--						WHERE R1.A = R2.A AND R1.B = R2.B
--						AND R1.C = R2.C) )

-- Ví dụ 5: Tìm các giáo viên (MAGV) mà tham gia tất cả các đề tài 
-- EXCEPT
SELECT TGDT1.MAGV
FROM THAMGIADT AS TGDT1
WHERE NOT EXISTS ( (SELECT DT.MADT FROM DETAI AS DT)
					EXCEPT 
				   (SELECT TGDT2.MADT
					FROM THAMGIADT AS TGDT2
					WHERE TGDT1.MAGV = TGDT2.MAGV))

-- 2.2. Sử dụng NOT EXISTS
-- Cú pháp:
-- + SELECT R1.A, R1.B, R1.C
-- + FROM R AS R1
-- + WHERE NOT EXISTS ( SELECT *
--						FROM S
--						WHERE NOT EXISTS (SELECT *
--										  FROM R AS R2
--										  WHERE R2.D = S.D AND R2.E = S.E
--										  AND R1.A = R2.A AND R1.B = R2.B AND R1.C = R2.C)

-- Ví dụ 6: Tìm các giáo viên (MAGV) mà tham gia tất cả các đề tài (Dùng NOT EXISTS) 
SELECT TGDT1.MAGV
FROM THAMGIADT AS TGDT1
WHERE NOT EXISTS ( SELECT *
				   FROM DETAI AS DT
				   WHERE NOT EXISTS (SELECT *
									 FROM THAMGIADT AS TGDT2
									 WHERE TGDT2.MADT = DT.MADT AND TGDT2.MAGV = TGDT1.MAGV))

-- 2.3. Sử dụng gom nhóm
-- Cú pháp:
-- + SELECT R.A
-- + FROM R
-- + [WHERE R.B IN (SELECT S.B FROM S [WHERE <ĐK>]]
-- + GROUP BY R.A
-- + HAVING COUNT(DISTINCT R.B) = (SELECT COUNT(S.B)
--								   FROM S
--								   [WHERE <ĐK>])

-- Ví dụ 7: Tìm các giáo viên (MAGV) mà tham gia tất cả các đề tài (Dùng gom nhóm)
SELECT TGDT.MAGV
FROM THAMGIADT AS TGDT
WHERE TGDT.MADT IN ( SELECT DT.MADT
					 FROM DETAI AS DT)
GROUP BY TGDT.MAGV
HAVING COUNT(DISTINCT TGDT.MADT) = (SELECT COUNT(DT.MADT)
									FROM DETAI AS DT)

-- Thực hiện Update dữ liệu để Test phép chia:
SELECT *
FROM THAMGIADT

SELECT *
FROM CONGVIEC

SELECT *
FROM DETAI

INSERT INTO THAMGIADT VALUES ('003', '006', 1, 1, N'Đạt')

-- (Sửa lại thành tất cả đề tài có trong công việc)
-- Test: 
-- EXCEPT
SELECT DISTINCT TGDT1.MAGV
FROM THAMGIADT AS TGDT1
WHERE NOT EXISTS ( (SELECT CV.MADT
				    FROM CONGVIEC AS CV)
				    EXCEPT 
				   (SELECT TGDT2.MADT
				    FROM THAMGIADT AS TGDT2
					WHERE TGDT1.MAGV = TGDT2.MAGV))
-- NOT EXISTS
SELECT DISTINCT TGDT1.MAGV
FROM THAMGIADT AS TGDT1
WHERE NOT EXISTS ( SELECT * 
				   FROM CONGVIEC AS CV
				   WHERE NOT EXISTS (SELECT * 
									 FROM THAMGIADT AS TGDT2
									 WHERE TGDT2.MAGV = TGDT1.MAGV 
									 AND TGDT2.MADT = CV.MADT))
-- Gom nhóm
SELECT TGDT.MAGV
FROM THAMGIADT AS TGDT
WHERE TGDT.MADT IN (SELECT MADT FROM CONGVIEC)
GROUP BY TGDT.MAGV
HAVING COUNT (DISTINCT TGDT.MADT) = (SELECT COUNT(DISTINCT CV.MADT) 
									 FROM CONGVIEC AS CV)

----------------------------------------------------------------------------------------
-- 3. Một số ví dụ khác cho phép chia

-- Ví dụ 9: Tìm tên các giáo viên 'HTTT' mà tham gia tất cả các đề tài thuộc chủ đề 'QLGD'
-- Xem thông tin bảng CONGVIEC:
SELECT *
FROM CONGVIEC

-- Update dữ liệu:
INSERT INTO CONGVIEC VALUES ('007', 1, N'Xác định yêu cầu', '2009-10-12', N'2010-03-12')
INSERT INTO THAMGIADT VALUES ('003', '007', 1, 1, N'Đạt')

-- EXCEPT:
SELECT DISTINCT GV.HOTEN
FROM GIAOVIEN AS GV, THAMGIADT AS TGDT1 
WHERE GV.MAGV = TGDT1.MAGV 
AND NOT EXISTS ( (SELECT DT.MADT
				  FROM DETAI AS DT
				  WHERE DT.MACD = 'QLGD')
				  EXCEPT 
				 (SELECT TGDT2.MADT
				  FROM THAMGIADT AS TGDT2
				  WHERE TGDT1.MAGV = TGDT2.MAGV) )

-- NOT EXISTS
SELECT DISTINCT GV.HOTEN
FROM GIAOVIEN AS GV, THAMGIADT AS TGDT1
WHERE GV.MAGV = TGDT1.MAGV
AND NOT EXISTS ( SELECT *
				 FROM DETAI AS DT
				 WHERE DT.MACD = 'QLGD'
				 AND NOT EXISTS (SELECT *
								 FROM THAMGIADT AS TGDT2
								 WHERE TGDT1.MAGV = TGDT2.MAGV 
								 AND DT.MADT = TGDT2.MADT) )

-- Gom nhóm
SELECT GV.HOTEN
FROM GIAOVIEN AS GV, THAMGIADT AS TGDT
WHERE GV.MAGV = TGDT.MAGV 
AND TGDT.MADT IN (SELECT MADT
				  FROM DETAI
				  WHERE MACD = 'QLGD')
GROUP BY GV.MAGV, GV.HOTEN
HAVING COUNT(DISTINCT TGDT.MADT) = (SELECT COUNT(DISTINCT MADT)
									 FROM DETAI
									 WHERE MACD = 'QLGD')


---- Check: 
SELECT *
FROM GIAOVIEN

SELECT *
FROM DETAI 

SELECT *
FROM THAMGIADT

------------------------------------- END -------------------------------------