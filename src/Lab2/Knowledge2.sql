-- Knowledge 2: Truy vấn đơn giản
USE SCHOOL_MANAGEMENT
--------------------------------------------------------------------------------------------
---- 1. Cú pháp câu truy vấn tổng quát: (Trang 3/ Doc2) 
-- Ngoài SELECT, FROM, WHERE thì còn có các mệnh đề khác như GROUP BY, HAVING, ORDER BY,
-- các hàm hỗ trợ tính toán: MAX, MIN, COUNT, SUM, AVG,...
-- ALL: Chọn ra tất cả các dòng trong bảng
-- DISTINCT: Loại bỏ các dòng trùng lặp thông tin
-- TOP<n>: Chọn n dòng đầu tiên thỏa mãn điều kiện
-- Lưu ý: AS, ASC (Tăng), DESC (Giảm)

--------------------------------------------------------------------------------------------
---- 2. Câu truy vấn đơn giản
-- Ví dụ 1: Họ tên và lương của toàn bộ giáo viên
SELECT HOTEN, LUONG
FROM GIAOVIEN

-- Ví dụ 2: Cho biết danh sách các giáo viên trong trương
SELECT *
FROM GIAOVIEN

-- Ví dụ 3: Cho biết họ tên, lương của tất cả các giáo viên
SELECT HOTEN AS HOTEN_GV, LUONG AS LUONGGV
FROM GIAOVIEN

--------------------------------------------------------------------------------------------
---- 3. Tìm kiếm có sắp xếp
-- Ưu tiên sắp xếp: Từ trái sang phải
-- Dùng SELECT, FROM, ORDER BY

-- Ví dụ 4: Cho biết danh sách các giáo viên (họ tên, phái, lương) sắp xếp giảm dần theo lương
SELECT HOTEN, PHAI, LUONG
FROM GIAOVIEN
ORDER BY LUONG DESC

-- Ví dụ 5: Cho biết họ tên, mã bộ môn và lương của giáo viên. Sắp xếp tăng dần theo mã bộ môn và giảm dần
-- theo lương
SELECT HOTEN, MABM, LUONG
FROM GIAOVIEN
ORDER BY MABM ASC, LUONG DESC

--------------------------------------------------------------------------------------------
---- 4. Tìm kiếm với điều kiện đơn giản
-- Dùng SELECT, FROM, WHERE (AND/OR)

-- 4.1. Các toán tử so sánh: >, <, =, !=, <>, >=, <=
-- Ví dụ 6: Cho biết các giáo viên có lương lớn hơn 2000
SELECT *
FROM GIAOVIEN
WHERE LUONG > 2000

-- Ví dụ 7: Cho biết các giáo viên có phái là Nam
SELECT *
FROM GIAOVIEN
WHERE PHAI = 'Nam'

-- 4.2. AND, OR và NOT

-- Ví dụ 8: Cho biết các giáo viên của bộ môn HTTT mà có lương lớn hơn 2000
SELECT *
FROM GIAOVIEN
WHERE MABM = 'HTTT' AND LUONG > 2000

-- Ví dụ 9: Cho biết các giáo viên nhân viên không thuộc bộ môn HTTT và không
-- có lương lớn hơn 2000
SELECT *
FROM GIAOVIEN
WHERE NOT(MABM = 'HTTT') AND NOT(LUONG > 2000)

-- 4.3 BETWEEN... AND, NOT BETWEEN... AND
-- Kiếm tra miền giá trị

-- Ví dụ 10: Cho biết các giáo viên sinh trong khoảng năm 1955 đến 1960
SELECT *
FROM GIAOVIEN
WHERE YEAR(NGAYSINH) BETWEEN 1955 AND 1960

-- 4.4 IS NULL và IS NOT NULL

-- Ví dụ 11: Cho biết các giáo viên không có người quản lý trực tiếp
SELECT *
FROM GIAOVIEN
WHERE GVQLCM IS NULL

-- Ví dụ 12: Cho biết các giáo viên có người quản lý trực tiếp
SELECT *
FROM GIAOVIEN
WHERE GVQLCM IS NOT NULL

-- 4.5 IN và NOT IN

-- Ví dụ 13: Cho biết các giáo viên có lương là 2000, 1500 hoặc 1800
SELECT *
FROM GIAOVIEN
WHERE LUONG IN (1500, 1800, 2000)

--------------------------------------------------------------------------------------------
---- 5. Tìm kiếm với điều kiện liên quan đến chuỗi ký tự
-- Sử dụng toán tử LIKE
-- Các ký tự đại diện khi sử dụng LIKE: 
-- + %: đại diện cho một chuỗi ký tự bất kỳ
-- + _: đại diện cho một ký tự bất kỳ
-- + []: đại diện cho các ký tự nằm trong một khoảng nào đó
-- Chú ý: 
-- LIKE 'ab\%cd%' cho ra những chuỗi bắt đầu với 'ab%cd'
-- LIKE 'ab\\cd%' cho ra những chuỗi bắt đầu với 'ab\cd'

-- => Theo ý mình hiểu là 
-- '%words': % đại diện cho chuỗi từ trước đó + words 
-- 'words%': words + % đại diện cho chuỗi từ sau đó

-- Ví dụ 14: Cho biết các giáo viên có địa chỉ ở TP HCM
SELECT *
FROM GIAOVIEN
WHERE DIACHI LIKE N'%TP HCM'

-- Vì TP HCM luôn nằm cuối câu nên dùng sẽ ra được ra kết quả
-- Thử với ví dụ ở dưới:

-- Bonus: Cho biết các giáo viên có địa chỉ ở quận Bình Thạnh
SELECT *
FROM GIAOVIEN
WHERE DIACHI LIKE N'%Bình Thạnh%'

--------------------------------------------------------------------------------------------
---- 6. Tìm kiếm với điều kiện liên quan đến ngày giờ
-- Một số hàm liên quan đến ngày giờ cơ bản: 
-- datediff: Hàm tính khoảng cách (hiệu) 2 thời gian theo một đơn vị nào đó (đơn vị ngày, tháng, năm, giờ, phút, giây)
-- datepart: Hàm lấy một phần trong giá trị thời gian (ngày, tháng, năm, giờ, phút, giây)
-- year, month, day: Hàm lấy năm, tháng, ngày của một giá trị thời gian truyền vào
-- getdate: Hàm lấy ngày hiện hành của hệ thống
-- dateadd: Hàm thêm một số lượng cụ thể của một đơn vị thời gian vào một giá trị ngày
-- DATEADD(datepart, number, date)

-- Ví dụ 15: Cho biết những đề tài bắt đầu sau ngày 30/4/2005
SELECT *
FROM DETAI
WHERE DATEDIFF(d, '04/30/2005', NGAYBD) > 0

-- Ví dụ 16: Cho biết những đề tài kết thúc trước 1 tuần sao với ngày 31/12/2007
SELECT *
FROM DETAI
WHERE DATEDIFF(d, NGAYKT, '12/31/2007') > 7

-- Ví dụ 17: Cho biết các đề tài có ngày bắt đầu là 2000-10-12
SELECT *
FROM DETAI
WHERE DATEDIFF(d, NGAYBD, '10/12/2000') = 0

--------------------------------------------------------------------------------------------
---- 7. Sử dụng các hàm khi tìm kiếm:
-- Một số hàm mà SQL có hỗ trợ: 
-- Các hàm về chuỗi: len, replace, charindex, reverse
-- Các hàm chuyển đổi kiểu dữ liệu: convert, cast
-- Các hàm toán học: floor, ceil

-- Ví dụ 18: Cho biết họ tên và tuổi của các giáo viên
-- Cách 1:
SELECT HOTEN, DATEDIFF(yyyy, NGAYSINH, GETDATE()) AS TUOI
FROM GIAOVIEN

-- Cách 2: 
SELECT HOTEN, (YEAR(GETDATE()) - YEAR(NGAYSINH)) AS TUOI 
FROM GIAOVIEN 

-- Ví dụ 19: Cho biết các giáo viên sinh năm 1975
SELECT *
FROM GIAOVIEN 
WHERE YEAR(NGAYSINH) = 1975

-- Ví dụ 20: Cho biết lương và lương của giáo viên sau khi đã tăng 10%
SELECT LUONG AS LUONG_TRUOC, (LUONG*1.1) AS LUONG_SAU
FROM GIAOVIEN 

-- Ví dụ 21: Cho biết danh sách tên đề tài và năm bắt đầu thực hiện, sắp xếp giảm
-- dần theo năm bắt đầu.
SELECT TENDT, YEAR(NGAYBD) AS NAMBD
FROM DETAI
ORDER BY YEAR(NGAYBD) DESC

--------------------------------------------------------------------------------------------
---- 8. Các phép toán tập hợp:
-- UNION: Lấy tất cả những bản ghi và loại bỏ trùng lặp ở cả 2 bảng
-- INTERSECT: Lấy những bản ghi giống nhau ở cả 2 bảng
-- EXCEPT: Lấy những bản ghi có ở bảng 1 mà không có ở bảng 2
-- Cú pháp chung: 
-- SELECT ... FROM ... WHERE ...
-- UNION | INTERSECT | EXCEPT
-- SELECT ... FROM ... WHERE ...
-- Điều kiện để thực hiện được phép toán tập hợp: 
-- + Cùng số lượng thuộc tính
-- + Cùng kiểu dữ liệu của các thuộc tính

-- Ví dụ 22: Cho biết các trưởng bộ môn có tham gia đề tài
SELECT TRUONGBM
FROM BOMON
INTERSECT
SELECT MAGV
FROM THAMGIADT

--------------------------------------------------------------------------------------------
---- 9. Phép kết

-- Ví dụ 23: Cho biết tên giáo viên và tên bộ môn mà giáo viên đó làm việc
SELECT GV.HOTEN, BM.TENBM
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MABM = BM.MABM

-- Ví dụ 24:  Cho biết tên giáo viên và tên bộ môn mà giáo viên làm trưởng bộ môn
-- của bộ môn đó.
SELECT GV.HOTEN, BM.TENBM
FROM GIAOVIEN AS GV, BOMON AS BM
WHERE GV.MAGV = BM.TRUONGBM

--------------------------------------------------------------------------------------------
---- 10. Sử dụng ALIAS

-- Ví dụ 25: Cho biết tên khoa và tên trưởng khoa của khoa đó (Sử dụng ALIAS):
SELECT K.TENKHOA, GV.HOTEN
FROM KHOA AS K, GIAOVIEN AS GV
WHERE K.TRUONGKHOA = GV.MAGV

-- Ví dụ 26: Cho biết tên giáo viên và tên những người thân của giáo viên
SELECT GV.HOTEN, NT.TEN
FROM GIAOVIEN AS GV, NGUOITHAN AS NT
WHERE GV.MAGV = NT.MAGV

-- Ví dụ 27: Cho biết tên giáo viên và tên người quản lý của giáo viên đó
SELECT GV.HOTEN AS GV, NQL.HOTEN AS NQL
FROM GIAOVIEN AS GV, GIAOVIEN AS NQL 
WHERE GV.GVQLCM = NQL.MAGV

-- Ví dụ 28: Cho biết tên giáo viên và tên khoa mà giáo viên đó trực thuộc
SELECT GV.HOTEN, K.TENKHOA
FROM GIAOVIEN AS GV, BOMON AS BM, KHOA AS K
WHERE (GV.MABM = BM.MABM) AND (BM.MAKHOA = K.MAKHOA)

------------------- END -------------------


--------------------------------------------------------------------------------------------
---- 11. Sử dụng JOIN
-- Cú pháp: 
-- SELECT ...
-- FROM (TABLE1 JOIN TABLE 2 ON [Điều kiện kết]) JOIN TABLE3 ON [Điều kiện kết]
-- WHERE ...

-- Ví dụ 29: Cho biết tên giáo viên và tên bộ môn mà giáo viên đó làm việc (Viết lại
-- ví dụ 23 sử dụng JOIN)
SELECT GV.HOTEN, BM.TENBM
FROM GIAOVIEN AS GV JOIN BOMON AS BM ON GV.MABM = BM.MABM