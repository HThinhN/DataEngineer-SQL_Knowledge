-- Lab 3: Truy vấn sử dụng hàm kết hợp và gom nhóm 
USE SCHOOL_MANAGEMENT
-- Viết các câu truy vấn cho bài tập Quản lý đề tài bằng ngôn ngữ SQL

-------------------------------------------------------------------------
-- Q27. Cho biết số lượng giáo viên và tổng lương của họ.
SELECT COUNT(*) AS SLGV, SUM(LUONG) AS TONGLUONG
FROM GIAOVIEN

-- Q28. Cho biết số lượng giáo viên và lương trung bình của từng bộ môn.
SELECT MABM, COUNT(*) AS SLGV, AVG(LUONG) AS LUONGTB
FROM GIAOVIEN
GROUP BY MABM

-- Q29. Cho biết tên chủ đề và số lượng đề tài thuộc về chủ đề đó
-- Xem thông tin bảng CHUDE, DETAI
SELECT *
FROM CHUDE

SELECT *
FROM DETAI

SELECT CD.TENCD, COUNT(*) AS SLDT
FROM CHUDE AS CD, DETAI AS DT
WHERE CD.MACD = DT.MACD
GROUP BY CD.MACD, CD.TENCD

-- Q30. Cho biết tên giáo viên và số lượng đề tài mà giáo viên đó tham gia
---- Xem thông tin bảng THAMGIADT
SELECT *
FROM THAMGIADT

SELECT GV.HOTEN, COUNT(DISTINCT MADT) AS SLDT
FROM GIAOVIEN AS GV, THAMGIADT AS TGDT
WHERE GV.MAGV = TGDT.MAGV
GROUP BY GV.MAGV, GV.HOTEN

-- Q31. Cho biết tên giáo viên và số lượng đề tài mà giáo viên đó làm chủ nhiệm
---- Xem thông tin bảng DETAI
SELECT *
FROM DETAI

SELECT GV.MAGV, GV.HOTEN, COUNT(*) AS SLDT_GVCN
FROM GIAOVIEN AS GV, DETAI AS DT
WHERE GV.MAGV = DT.GVCNDT
GROUP BY GV.MAGV, GV.HOTEN

-- Q32. Với mỗi giáo viên cho biết tên giáo viên và số người thân của giáo viên đó
---- Xem thông tin bảng NGUOITHAN
SELECT *
FROM NGUOITHAN

SELECT GV.HOTEN, COUNT(*) AS SLNT
FROM GIAOVIEN AS GV, NGUOITHAN AS NT
WHERE GV.MAGV = NT.MAGV
GROUP BY GV.MAGV, GV.HOTEN

-- Q33. Cho biết tên những giáo viên đã tham gia từ 3 đề tài trở lên (Sửa đề thành 1 đề tài trở lên thì có kết quả)
---- Xem thông tin bảng THAMGIADT
SELECT *
FROM THAMGIADT

SELECT GV.HOTEN, COUNT(DISTINCT TGDT.MADT) AS SLDT
FROM GIAOVIEN AS GV, THAMGIADT AS TGDT
WHERE GV.MAGV = TGDT.MAGV
GROUP BY GV.MAGV, GV.HOTEN
HAVING COUNT(DISTINCT TGDT.MADT) >= 1

-- Q34. Cho biết số lượng giáo viên đã tham gia vào đề tài Ứng dụng hóa học xanh
---- Xem bảng THAMGIADT, DETAI
SELECT *
FROM THAMGIADT

SELECT *
FROM DETAI

SELECT COUNT(DISTINCT MAGV) AS SLGV_DTUDHHX
FROM DETAI AS DT, THAMGIADT AS TGDT
WHERE DT.MADT = TGDT.MADT AND DT.TENDT = N'Ứng dụng hóa học xanh'
GROUP BY DT.MADT

---------------------------- END ----------------------------