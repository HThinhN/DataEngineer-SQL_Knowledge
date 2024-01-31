-- Knowledge 3: Truy vấn sử dụng hàm kết hợp và gom nhóm
USE SCHOOL_MANAGEMENT
--------------------------------------------------------------------------------------------
-- 1. Sử dụng các hàm kết hợp khi truy vấn
-- Hàm kết hợp: Là hàm được sử dụng khi truy vấn, và kết quả trả về của hàm chỉ có được khi kết
-- hợp nhiều giá trị lại với nhau
-- Các hàm kết hợp: SQL hỗ trợ các hàm kết hợp sau:
-- + COUNT: Đếm số dòng dữ liệu hoặc đếm số lượng giá trị của một thuộc tính.
-- + AVG: Tính giá trị trung bình
-- + MAX: Tính giá trị lớn nhất
-- + MIN: Tính giá trị nhỏ nhất
-- + SUM: Tính tổng

-- Ví dụ 1: Cho biết số lượng giáo viên của toàn trường
SELECT COUNT(*) AS SLGV
FROM GIAOVIEN 

-- Ví dụ 2: Cho biết số lượng giáo viên của bộ môn HTTT
SELECT COUNT(*) AS SLGV_HTTT
FROM GIAOVIEN
WHERE MABM = 'HTTT'

-- Ví dụ 3: Tính số lượng giáo viên có người quản lý về mặt chuyên môn
SELECT COUNT(*) AS SLGV_ĐQLCM
FROM GIAOVIEN 
WHERE GVQLCM IS NOT NULL

SELECT COUNT(GVQLCM) AS SLGV_ĐQLCM
FROM GIAOVIEN

-- Ví dụ 4: Tính số lượng giáo viên làm nhiệm vụ quản lý chuyên môn cho giáo viên khác
-- mà thuộc bộ HTTT
SELECT COUNT(DISTINCT GVQLCM) AS SLGVQL_HTTT
FROM GIAOVIEN 
WHERE MABM = 'HTTT'
-- Phương pháp trên có vẻ bị nhầm, hãy xem thêm ở phần Check ở phía dưới
---- Check: 
SELECT *
FROM GIAOVIEN

UPDATE GIAOVIEN 
SET GVQLCM = '001'
WHERE MAGV = '002'

-- => Nên kết quả này nó sẽ trả lời cho câu hỏi tính số lượng giáo viên làm nhiệm vụ quản lý chuyên môn 
-- cho giáo viên khác mà giáo viên khác đó thuộc bộ HTTT

-- Cập nhật lại:
UPDATE GIAOVIEN 
SET GVQLCM = NULL
WHERE MAGV = '002'

SELECT COUNT(DISTINCT NQL.MAGV) AS SLGVQL_HTTT
FROM GIAOVIEN AS GV, GIAOVIEN AS NQL
WHERE NQL.MABM = 'HTTT' AND NQL.MAGV = GV.GVQLCM

-- Ví dụ 5: Tính lương trung bình của giáo viên bộ môn Hệ thống thông tin
SELECT AVG(LUONG) AS LUONGTB_HTTT
FROM GIAOVIEN 
WHERE MABM = 'HTTT'

SELECT AVG(GV.LUONG) AS LUONGTB_HTTT
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MABM = BM.MABM AND BM.TENBM = N'Hệ thống thông tin'

--------------------------------------------------------------------------------------------
-- 2. Truy vấn gom nhóm với GROUP BY
-- GROUP BY: Được sử dụng khi có nhu cầu gom nhóm dữ liệu để thực hiện các thao tác tính toán.
-- Do đó GROUP BY thường được sử dụng kèm với các hàm kết hợp.
-- Khi sử dụng GROUP BY với các hàm kết hợp, các hàm kết hợp chỉ tính toán trên các dòng cùng 
-- một nhóm dữ liệu
-- Các nhóm dữ liệu có được khi gom nhóm với từ khóa GROUP BY sẽ giống nhau ở thuộc tính gom nhóm

-- Ví dụ 6: Với mỗi bộ môn cho biết bộ môn (MABM) và số lượng giáo viên của bộ môn đó
SELECT MABM, COUNT(MAGV) AS SLGV
FROM GIAOVIEN 
GROUP BY MABM

-- Ví dụ 7: Với mỗi giáo viên, cho biết MAGV và số lượng công việc mà giáo viên đó tham gia
---- Xem thông tin bảng CONGVIEC
SELECT *
FROM THAMGIADT

---- Muốn các giáo viên không có tham gia công việc cũng hiện 0 :(((( 
---- (Chưa làm được)
SELECT GV.MAGV, COUNT(*) AS SLCV
FROM GIAOVIEN AS GV, THAMGIADT AS TGDT
WHERE GV.MAGV = TGDT.MAGV
GROUP BY GV.MAGV

SELECT MAGV, COUNT(*) AS SLCV
FROM THAMGIADT
GROUP BY MAGV

-- Ví dụ 8: Với mỗi giáo viên, cho biết MAGV và số lượng đề tài mà giáo viên 
-- đó có tham gia
SELECT MAGV, COUNT(DISTINCT MADT) AS SLDT
FROM THAMGIADT
GROUP BY MAGV

-- Ví dụ 9: Với mỗi bộ môn, cho biết số đề tài mà giáo viên của bộ môn đó chủ trì
---- Xem thông tin bảng DETAI
SELECT *
FROM DETAI

SELECT GV.MABM, COUNT(*) AS SLDT_BMQL
FROM GIAOVIEN AS GV, DETAI AS DT
WHERE GV.MAGV = DT.GVCNDT
GROUP BY GV.MABM

-- Ví dụ 10: Với mỗi bộ môn, cho biết tên bộ môn và số lượng giáo viên của bộ môn đó
SELECT BM.TENBM, COUNT(*) AS SLGV
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MABM = BM.MABM
GROUP BY BM.MABM, BM.TENBM

-- Lưu ý: Các thuộc tính có trong mệnh đề SELECT phải là các thuộc tính của nhóm. Nghĩa là:
-- + Các thuộc tính có trong mệnh đề GROUP BY
-- + Các hàm kết hợp

--------------------------------------------------------------------------------------------
-- 3. Truy vấn với GROUP BY + HAVING
-- Sử dụng HAVING khi câu truy vấn yêu cầu điều kiện liên quan đến việc sử dụng kết quả của
-- việc gom nhóm: Kết quả của các hàm kết hợp, ...
-- Biểu thức điều kiện sau mệnh đề HAVING là điều kiện sau khi gom nhóm. Và ở biểu thức điều kiện
-- này chỉ được sử dụng các thuộc tính của nhóm (thuộc tính có mệnh đề GROUP BY hoặc các hàm kết hợp)


-- Ví dụ 11: Cho biết những bộ môn từ 2 giáo viên trở lên
SELECT MABM, COUNT(*) AS SLGV
FROM GIAOVIEN
GROUP BY MABM
HAVING COUNT(*) > 2

-- Ví dụ 12: Cho biết tên những giáo viên và số lượng đề tài của những GV tham gia từ
-- 2 đề tài trở lên
SELECT GV.HOTEN, COUNT(DISTINCT TGDT.MADT) AS SLDT
FROM GIAOVIEN AS GV, THAMGIADT AS TGDT
WHERE GV.MAGV = TGDT.MAGV
GROUP BY GV.HOTEN
HAVING COUNT(DISTINCT TGDT.MADT) >= 2

--------------------------------------------------------------------------------------------
-- 4. GROUP BY với các thuộc tính mở rộng
-- Ngoài việc sử dụng các thuộc tính có sẵn của bảng, cú pháp của GROUP BY còn cho phép sử dụng
-- các thuộc tính mở rộng (kết hợp sử dụng các hàm trên các thuộc tính)

-- Ví dụ 13: Cho biết số lượng đề tài được thực hiện trong từng năm
SELECT YEAR(NGAYBD) AS NAM,COUNT(*) AS SLDT
FROM DETAI
GROUP BY YEAR(NGAYBD)

------------- END -------------
