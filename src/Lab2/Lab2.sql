-- Lab 2: Truy vấn đơn giản
USE SCHOOL_MANAGEMENT
--  Viết các câu truy vấn cho bài tập Quản lý đề tài bằng ngôn ngữ SQL

---------------------------------------------------------------------------
-- Q1. Cho biết họ tên và mức lương của các giáo viên nữ
SELECT HOTEN, LUONG
FROM GIAOVIEN
WHERE PHAI = N'Nữ'

-- Q2. Cho biết họ tên của các giáo viên và lương của họ sau khi tăng 10%
SELECT HOTEN, LUONG*1.1 AS LUONG_SAU
FROM GIAOVIEN

-- Q3. Cho biết mã của các giáo viên có họ tên bắt đầu là “Nguyễn” và lương trên $2000 hoặc,
-- giáo viên là trưởng bộ môn nhận chức sau năm 1995.
SELECT DISTINCT(GV.MAGV)
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE (GV.HOTEN LIKE N'Nguyễn%' AND GV.LUONG > 2000) 
OR    (GV.MAGV = BM.TRUONGBM AND YEAR(BM.NGAYNHANCHUC) > 1995)

-- Q4. Cho biết tên những giáo viên khoa Công nghệ thông tin
SELECT GV.HOTEN
FROM GIAOVIEN AS GV, BOMON AS BM, KHOA AS K
WHERE GV.MABM = BM.MABM AND BM.MAKHOA = K.MAKHOA AND K.TENKHOA = N'Công nghệ thông tin'

-- Q5. Cho biết thông tin của bộ môn cùng thông tin giảng viên làm trưởng bộ môn đó
SELECT BM.*, GV.*
FROM BOMON AS BM, GIAOVIEN AS GV
WHERE BM.TRUONGBM = GV.MAGV

SELECT *
FROM BOMON JOIN GIAOVIEN ON TRUONGBM = MAGV

---- Có cách nào chỉ xuất hiện 1 MABM không ???
---- Có vẻ hơi phức tạp

-- Q6. Với mỗi giáo viên, hãy cho biết thông tin của bộ môn mà họ đang làm việc. 
SELECT GV.MAGV, GV.HOTEN, BM.* 
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MABM = BM.MABM

-- Q7. Cho biết tên đề tài và giáo viên chủ nhiệm đề tài
-- Xem thông tin bảng DETAI
SELECT *
FROM DETAI

SELECT DT.TENDT, GV.HOTEN
FROM DETAI AS DT, GIAOVIEN AS GV
WHERE DT.GVCNDT = GV.MAGV

-- Q8. Với mỗi khoa cho biết thông tin trưởng khoa.
SELECT K.MAKHOA, K.TRUONGKHOA, GV.*
FROM KHOA AS K, GIAOVIEN AS GV
WHERE K.TRUONGKHOA = GV.MAGV

-- Q9. Cho biết các giáo viên của bộ môn “Vi sinh” có tham gia đề tài 006
---- Xem thông tin bảng THAMGIADT
SELECT *
FROM THAMGIADT 

SELECT DISTINCT GV.MAGV, GV.HOTEN
FROM GIAOVIEN AS GV, BOMON AS BM, THAMGIADT AS TGDT
WHERE GV.MABM = BM.MABM AND BM.TENBM = N'Vi sinh' 
AND TGDT.MAGV = GV.MAGV AND TGDT.MADT = '006'

---- Check:
SELECT *
FROM GIAOVIEN

-- Q10. Với những đề tài thuộc cấp quản lý “Trường”, cho biết mã đề tài, đề tài thuộc về chủ
-- đề nào, họ tên người chủ nghiệm đề tài cùng với ngày sinh và địa chỉ của người ấy (Sửa đề)
---- Xem thông tin bảng DETAI, CHUDE
SELECT *
FROM DETAI

SELECT *
FROM CHUDE

SELECT DT.MADT, DT.TENDT, CD.TENCD, GV.HOTEN, GV.NGAYSINH, GV.DIACHI
FROM DETAI AS DT, CHUDE AS CD, GIAOVIEN AS GV
WHERE DT.CAPQL = N'Trường' AND DT.MACD = CD.MACD AND DT.GVCNDT = GV.MAGV	  

-- Q11. Tìm họ tên của từng giáo viên và người phụ trách chuyên môn trực tiếp của giáo viên đó
SELECT GV.HOTEN, NQL.HOTEN AS NQL
FROM GIAOVIEN AS GV, GIAOVIEN AS NQL
WHERE GV.GVQLCM = NQL.MAGV

SELECT GV.HOTEN, NQL.HOTEN AS NQL
FROM GIAOVIEN AS GV LEFT JOIN GIAOVIEN AS NQL ON GV.GVQLCM = NQL.MAGV

-- Q12. Tìm họ tên của những giáo viên được 'Nguyễn An Trung' phụ trách trực tiếp (Sửa đề)
SELECT GV.HOTEN AS GV_NAT_QL
FROM GIAOVIEN AS GV, GIAOVIEN AS NAT
WHERE GV.GVQLCM = NAT.MAGV AND NAT.HOTEN = N'Nguyễn An Trung'

-- Q13. Cho biết tên giáo viên là trưởng bộ môn “Hệ thống thông tin”
SELECT GV.HOTEN AS TRUONGBMHTTT 
FROM GIAOVIEN AS GV, BOMON AS BM 
WHERE GV.MAGV = BM.TRUONGBM AND BM.TENBOMON = N'Hệ thống thông tin'

-- Q14. Cho biết tên người chủ nhiệm đề tài của những đề tài thuộc chủ đề "Quản lý giáo dục"
---- Xem thông tin bảng DETAI, CHUDE
SELECT *
FROM DETAI

SELECT *
FROM CHUDE

SELECT DISTINCT GV.HOTEN AS CHUNHIEMDETAIQLGD
FROM GIAOVIEN AS GV, DETAI AS DT, CHUDE AS CD
WHERE GV.MAGV = DT.GVCNDT AND DT.MACD = CD.MACD AND CD.TENCD = N'Quản lý giáo dục'

-- Q15.  Cho biết tên các công việc của đề tài "HTTT quản lý các trường ĐH" có thời gian bắt đầu
-- trong tháng 3/2008
---- XEM thông tin bảng CONGVIEC, DETAI
SELECT *
FROM CONGVIEC

SELECT *
FROM DETAI

SELECT CV.TENCV
FROM CONGVIEC AS CV, DETAI AS DT
WHERE DT.TENDT = N'HTTT quản lý các trường ĐH' AND DT.MADT = CV.MADT
AND  YEAR(CV.NGAYBD) = 2008 AND MONTH(CV.NGAYBD) = 3

-- Q16. Cho biết tên giáo viên và tên người quản lý chuyên môn của giáo viên đó.
SELECT GV.HOTEN, NQL.HOTEN AS NQL
FROM GIAOVIEN AS GV, GIAOVIEN AS NQL
WHERE GV.GVQLCM = NQL.MAGV

SELECT GV.HOTEN, NQL.HOTEN AS NQL
FROM GIAOVIEN AS GV LEFT JOIN GIAOVIEN AS NQL ON GV.GVQLCM = NQL.MAGV

---- Check:
SELECT *
FROM GIAOVIEN

-- Q17. Cho biết các công việc bắt đầu trong khoảng từ 01/01/2007 đến 01/08/2007
SELECT *
FROM CONGVIEC
WHERE NGAYBD BETWEEN '01/01/2007' AND '08/01/2007'

-- Q18. Cho biết họ tên các giáo viên cùng bộ môn với giáo viên “Trần Trà Hương”
SELECT GV.HOTEN
FROM GIAOVIEN AS GV, GIAOVIEN AS GV_TTH
WHERE GV.MABM = GV_TTH.MABM AND GV_TTH.HOTEN = N'Trần Trà Hương'
AND GV.MAGV != GV_TTH.MAGV

-- Check:
SELECT *
FROM GIAOVIEN

-- Q19. Tìm những giáo viên vừa là trưởng bộ môn vừa chủ nhiệm đề tài
SELECT GV.MAGV, GV.HOTEN, BM.TENBM AS TRUONGBM, DT.TENDT AS CHUNHIEMDT
FROM GIAOVIEN AS GV, BOMON AS BM, DETAI AS DT
WHERE GV.MAGV = BM.TRUONGBM AND DT.GVCNDT = GV.MAGV

SELECT DISTINCT GV.MAGV, GV.HOTEN
FROM GIAOVIEN AS GV, BOMON AS BM, DETAI AS DT
WHERE GV.MAGV = BM.TRUONGBM AND DT.GVCNDT = GV.MAGV

-- Q20. Cho biết tên những giáo viên vừa là trưởng khoa và vừa là trưởng bộ môn.
SELECT GV.HOTEN, K.TENKHOA AS TRUONGKHOA, BM.TENBM AS TRUONGBM
FROM GIAOVIEN AS GV, KHOA AS K, BOMON AS BM
WHERE GV.MAGV = K.TRUONGKHOA AND BM.TRUONGBM = GV.MAGV

-- Q21. Cho biết tên những trưởng bộ môn mà vừa chủ nhiệm đề tài.
SELECT GV.MAGV, GV.HOTEN, BM.TENBM AS TRUONGBM, DT.TENDT AS CHUNHIEMDT
FROM GIAOVIEN AS GV, BOMON AS BM, DETAI AS DT
WHERE GV.MAGV = BM.TRUONGBM AND DT.GVCNDT = GV.MAGV

SELECT DISTINCT GV.MAGV, GV.HOTEN
FROM GIAOVIEN AS GV, BOMON AS BM, DETAI AS DT
WHERE GV.MAGV = BM.TRUONGBM AND DT.GVCNDT = GV.MAGV

-- Q22. Cho biết mã số các trưởng khoa có chủ nhiệm đề tài
SELECT GV.MAGV,GV.HOTEN, K.TENKHOA AS TRUONGKHOA, DT.TENDT AS CHUNHIEMDT
FROM GIAOVIEN AS GV, DETAI AS DT, KHOA AS K
WHERE GV.MAGV = K.TRUONGKHOA AND DT.GVCNDT = GV.MAGV

SELECT DISTINCT GV.MAGV
FROM GIAOVIEN AS GV, DETAI AS DT, KHOA AS K
WHERE GV.MAGV = K.TRUONGKHOA AND DT.GVCNDT = GV.MAGV

-- Q23. Cho biết mã số các giáo viên thuộc bộ môn “HTTT” hoặc có tham gia đề tài mã “001”
SELECT DISTINCT GV.MAGV
FROM GIAOVIEN AS GV, THAMGIADT AS TGDT
WHERE TGDT.MADT = '001' AND GV.MABM = 'HTTT' AND TGDT.MAGV = GV.MAGV

---- Check: 
SELECT DISTINCT GV.MAGV, GV.HOTEN, DT.TENDT
FROM GIAOVIEN AS GV, THAMGIADT AS TGDT, DETAI AS DT
WHERE TGDT.MADT = '001' AND GV.MABM = 'HTTT' AND TGDT.MAGV = GV.MAGV
AND DT.MADT = TGDT.MADT

-- Q24. Cho biết giáo viên làm việc cùng bộ môn với giáo viên 002
SELECT GV.MAGV, GV.HOTEN
FROM GIAOVIEN AS GV, GIAOVIEN AS GV_002
WHERE GV.MABM = GV_002.MABM AND GV_002.MAGV = '002'
AND GV.MAGV != '002'

-- Q25. Tìm những giáo viên là trưởng bộ môn
SELECT GV.MAGV, GV.HOTEN, BM.TENBM AS TRUONGBM
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE BM.TRUONGBM = GV.MAGV

-- Q26. Cho biết họ tên và mức lương của các giáo viên
SELECT HOTEN, LUONG
FROM GIAOVIEN


----------------- END -----------------