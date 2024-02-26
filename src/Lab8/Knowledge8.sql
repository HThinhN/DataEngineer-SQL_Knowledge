-- Knowledge 8: Ràng buộc toàn vẹn và TRIGGER

-- 1. Giới thiệu:
-- Ràng buộc toàn vẹn là những quy tắc, quy định trên CSDL, nhằm đảm bảo cho CSDL được nhất quán và đúng đắn 
-- với ngữ nghĩa của thực tể hay mong muốn của con người

-- Các thành phần cơ bản của một ràng buộc toàn vẹn:
-- + Phát biểu RBTV bằng ngôn ngữ tự nhiên: Là một phát biểu tự nhiên về ràng buộc toàn vẹn.
-- + Bối cảnh: Là những quan hệ liên quan đến RBTV. Những quan hệ "liên quan" là khi thực hiện những thao tác
-- cập nhật dữ liệu lên những quan hệ này thì RBTV bị vi phạm
-- + Nội dung: Là phát biểu lại của RBTV bằng ngôn ngữ hình thức để thể hiện được sự chặt chẽ. Một số ngôn ngữ hình
-- thức được sử dụng như: Phép tính quan hệ, đại số quan hệ hoặc mã giả.
-- + Bảng tầm ảnh hưởng: Là bảng mô tả các sự ảnh hưởng đến RBTV của các thao tác cập nhật lên các bảng dữ liệu.

-------------------------------
-- Các loại RBTV: 
-- + RBTV miền giá trị
-- + RBTV duy nhất 
-- + RBTV tham chiếu
-- + RBTV liên thuộc tính trên một quan hệ
-- + RBTV liên bộ trên một quan hệ
-- + RBTV liên bộ liên quan hệ
-- + RBTV thuộc tính tổng hợp

--------------------------------------------------------------
-- 2. Các kỹ thuật cài đặt ràng buộc toàn vẹn đơn giản
---------------------------
-- 2.1. Các kỹ thuật cơ bản:
-- + NOT NULL
-- + PRIMARY KEY
-- + FOREIGN KEY
-- + CHECK

-- Các trường hợp sử dụng:
-- + PRIMARY KEY: Sử dụng dành riêng cho RBTV khóa chính. Mỗi bảng có mô hình dữ liệu quan hệ của SQL Server
-- có tối đa một khóa chính
-- + UNIQUE: Sử dụng dành riêng của RBTV duy nhất. Các thuộc tính được khai báo RBTV duy nhất có thể xem như các thuộc tính
-- của khóa ứng viên. Mỗi bảng có thể khai báo nhiều khóa ứng viên.
-- + FOREIGN KEY: Sử dụng dành riêng cho việc tạo RBTV tham chiếu hoặc khóa ngoại. Các thuộc tính khóa ngoại phải tham chiếu 
-- đến các thuộc tính khóa (khóa chính hoặc khóa ứng viên).
-- + CHECK: Sử dụng dành riêng cho việc tạo ra các RBTV khác. Lúc này các RBTV được mô tả như một biểu thức điều kiện mà
-- các dữ liệu phải thỏa biểu thức điều kiện đó.

-- Cách sử dụng các kỹ thuật này được trình bày trong phần xây dựng cấu trúc Cơ sở dữ liệu.
---------------------------
-- 2.2. RULE
-- RULE được thiết lập như là một quy tắc của một thuộc tính. 
-- Trình tự các bước tạo và sử dụng RULE:

---------------------------
/* Tạo RULE: */
-- CREATE RULE [Tên_Rule]
-- AS [Biểu_thức_mô_tả_điều_kiện]
-- [;]
-- Trong đó:
-- [Tên_Rule]: Tên do người lập trình đặt
-- [Biểu_thức_mô_tả_điều_kiện]: Biểu thức tương ứng với nội dung của RULE.

-- Trong biểu thức này chỉ được sử dụng 1 biến (bắt đầu bằng @) để mô tả RULE. Khi gắn RULE cho thuộc tính
-- nào thì biến tương ứng với thuộc tính đó

---------------------------
/* Gắn RULE cho thuộc tính: */
-- EXEC sp_bindrule [ @rulename = ] 'Tên_Rule', [@objname = ] 'Tên_bảng.Tên_thuộc_tính'

-- Ghi chú: Một số cú pháp sử dụng RULE khác: Sử dụng các tham số FUTUREONLY, gắn RULE cho kiểu dữ liệu,...

/* Tháo bỏ RULE cho thuộc tính: */
-- EXEC sp_unbindrule [ @objname = ] 'Tên_bảng.Tên_thuộc_tính' 

-- Ghi chú: Khi gỡ bỏ RULE thì gỡ bỏ toàn bộ RULE mà đã được gắn vào thuộc tính.

/* Xóa RULE */
-- DROP RULE [Tên_Rule]

-----------------------------------------
USE SCHOOL_MANAGEMENT
-- Ví dụ 1: Cài đặt RBTV lương của giáo viên thuộc khoảng ($1000, $20000) bằng cách sử dụng RULE
/* Tạo RULE để biểu diễn ràng buộc thuộc 1 khoảng */
CREATE RULE range_rule
AS
@range > 1000 AND @range < 20000

/* Gắn RULE vừa tạo cho thuộc tính LUONG của bảng GIAOVIEN */
sp_bindrule 'range_rule', 'GIAOVIEN.LUONG'

/* Khi không sử dụng RBTV này nữa thì tháo bỏ RULE khỏi thuộc tính LUONG */
sp_unbindrule 'GIAOVIEN.LUONG'

-- Test:
SELECT *
FROM GIAOVIEN

-- Lỗi với rule
UPDATE GIAOVIEN 
SET LUONG = 1000000
WHERE MAGV = '012'

--------------------------------------------------------------
-- 3. Kỹ thuật cài đặt RBTV nâng cao: TRIGGER 
-- 3.1. Giới thiệu:
-- Là một cơ chế để đảm bảo ràng buộc toàn vẹn sử dụng khả năng lập trình của Hệ quản trị cơ sở dữ liệu.

-- 3.2. Tạo Trigger:
-- CREATE TRIGGER [Tên_trigger]
-- ON [Tên_bảng]
-- FOR [Các_thao_tác: insert, update hoặc delete]
-- AS
-- IF UPDATE [Tên thuộc tính] (Chỉ có ý nghĩa đối với trigger for insert, update)
-- BEGIN
-- Thân_của_trigger: Mã nguồn kiểm tra hoặc cập nhật,
-- END


-- Một số lưu ý khi sử dụng trigger:

-- + Một trigger được gắn với 1 bảng để giám sát sự thay đổi dữ liệu của bảng đó. Mã nguồn trong phần 
-- Thân_của_trigger sẽ được tự động gọi thực hiện khi xảy ra Các_thao_tác cập nhật dữ liệu (insert, update
-- hoặc delete) lên bảng Tên_bảng. Do đó nội dung mã nguồn của Thân_của_trigger thường sẽ thực hiện những 
-- công việc như: kiểm tra dữ liệu, thay đổi dữ liệu, hủy bỏ thao tác để làm cho ràng buộc toàn vẹn không 
-- bị vi phạm

-- + Trong phần thân của trigger để dễ dàng cho các thao tác kiểm tra dữ liệu, hệ quản trị cung cấp 2 bảng tạm 
-- cho người viết trigger sử dụng. Hai bảng này có cấu trúc giống hệt như bảng chính:
-- + ~ Bảng inserted: Chứa những dòng mới thêm vào
-- + ~ Bảng deleted: Chứa những dòng vừa mới bị xóa đi

-- Lưu ý: Không có bảng updated vì thao tác cập nhật được xem là bao gồm thao tác xóa và thêm mới. Khi thực
-- hiện thao tác cập nhật, bảng inserted chứa dữ liệu mới, bảng deleted chứa dữ liệu cũ.

-- Trong MS SQL Server, trigger được gọi thực hiện sau khi thao tác tương ứng (insert, update, delete) được thực
-- hiện trên bảng chính. Người dùng nếu muốn khôi phục lại dữ liệu trong bảng chỉnh thì gọi lệnh rollback.
-- Ngoài ra sử dụng hàm raiserror để thông báo lỗi khi phát hiện thấy sự vi phạm RBTV.

----------------------------------------------------
-- 3.3. Xóa trigger
-- DROP TRIGGER [Tên_trigger]

-- Cập nhật nội dung Trigger:
-- ALTER TRIGGER [Tên_trigger]
-- ON [Tên_bảng]
-- FOR [Các_thao_tác: insert, update hoặc delete]
-- AS
-- IF UPDATE (Tên thuộc tính) <Chỉ có ý nghĩa đối với trigger for insert, update>
-- BEGIN 
-- Thân_của_trigger: Mã nguồn kiểm tra hoặc cập nhật
-- **
	/* TH1: Mã nguồn kiểm tra: */

	-- IF (điều kiện để RBTV vi phạm)
	-- BEGIN
	--		raiserror(N'Lỗi: XXXX ', 16, 1)
	--      rollback
	-- END

	/* TH2: Mã nguồn cập nhật: */

	-- UPDATE ...
	-- ...
-- **
-- END

----------------------------------------------------
-- 3.4. Một số ví dụ:

-- Ví dụ 2: Cài đặt RBTV "Lương của giáo viên phải >= 1000" sử dụng kỹ thuật trigger.
-- Nhận xét: RBTV này liên quán đến bảng GIAOVIEN (-> ON GIAOVIEN), khi thêm mới một dòng
-- (insert) hoặc cập nhật thuộc tính LUONG (update) thì RBTV này có khả năng bị vi phạm. 
-- Khi xóa thì sẽ không ảnh hưởng đến RBTV này (-> FOR insert, update)

-- Sử dụng trigger để kiểm tra những dữ liệu mới đưa vào, nếu vi phạm quy định -> báo lỗi 
-- và khôi phục lại dữ liệu
-- Thực hiện:
CREATE TRIGGER trgLuong
ON GIAOVIEN
FOR INSERT, UPDATE
AS 
IF UPDATE(LUONG)
BEGIN
	IF EXISTS(SELECT * FROM INSERTED WHERE LUONG < 1000)
	BEGIN 
		raiserror(N'Lỗi: Lương của giáo viên phải >= 1000', 16, 1)
		rollback
	END
END

--  Test:
UPDATE GIAOVIEN 
SET LUONG = 900
WHERE MAGV = '001'

-- Ví dụ 3: Giả sử có bảng CTHD(MAHD, MASD, SOLUONG, DONGIA, THANHTIEN).
-- Cài đặt RBTV sau: "Thành tiền phải bằng Số lượng * Đơn giá"
-- Nhận xét : RBTV này liên quan đến bảng CTHD, khi thêm mới một dòng dữ liệu
-- hoặc khi cập nhật các thuộc tính như SOLUONG, DONGIA thì cần cập nhật lại
-- THANHTIEN tương ứng
USE TestDB

CREATE TABLE CTHD
(
	MAHD char(5) NOT NULL,
	MASD char(5) NOT NULL,
	SOLUONG int,
	DONGIA float,
	THANHTIEN float
) 

ALTER TABLE CTHD
ADD CONSTRAINT PK_CTHD
PRIMARY KEY (MAHD,MASD)

INSERT INTO CTHD VALUES ('001', '001', 1, 20000, 30000)

-- Sử dụng trigger để cập nhật dữ liệu đúng với RBTV
CREATE TRIGGER trgCapNhatThanhTien
ON CTHD
FOR INSERT, UPDATE
AS
IF UPDATE(SOLUONG) OR UPDATE(DONGIA) OR UPDATE(THANHTIEN)
BEGIN
	UPDATE CTHD
	SET THANHTIEN = SOLUONG * DONGIA
	WHERE EXISTS(SELECT *
				 FROM INSERTED AS I
				 WHERE I.MAHD = CTHD.MAHD AND 
				 I.MASD = CTHD.MASD)
END

DROP TRIGGER trgCapNhatThanhTien

-- Check: 
SELECT *
FROM CTHD

-- Test: 
UPDATE CTHD
SET THANHTIEN = 40000
WHERE MAHD = '001'

INSERT INTO CTHD VALUES ('002', '001', 2, 20000, 30000)

-- Ví dụ 4: Cài đặt RBTV sau: "Giáo viên làm trưởng bộ môn thì phải thuộc bộ môn đó"
USE SCHOOL_MANAGEMENT
-- Đối với bảng BOMON:
/* Xem thông tin bảng BOMON */
SELECT *
FROM BOMON

/* Trigger cho bảng BOMON */
CREATE TRIGGER trgTruongBoMon_BOMON
ON BOMON
FOR UPDATE
AS
IF UPDATE(TRUONGBM)
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED I
				WHERE I.TRUONGBM IS NOT NULL
				AND I.TRUONGBM NOT IN (SELECT GV.MAGV
									   FROM GIAOVIEN AS GV
									   WHERE GV.MABM = I.MABM)) )
	BEGIN
		RAISERROR(N'Lỗi: Trưởng bộ môn phải là người trong bộ môn', 16,1)
		ROLLBACK
	END
END

/* Test */
UPDATE BOMON
SET TRUONGBM = '012'
WHERE MABM = 'HHC'

-- Đối với bảng GIAOVIEN:
/* Xem thông tin bảng GIAOVIEN */
SELECT *
FROM GIAOVIEN

/* Trigger cho bảng GIAOVIEN */
CREATE TRIGGER trgTruongBoMon_GIAOVIEN
ON GIAOVIEN
FOR UPDATE
AS 
IF UPDATE(MABM)
BEGIN
	IF ( EXISTS(SELECT *
				FROM INSERTED I, BOMON AS BM
				WHERE I.MABM != BM.MABM
				AND I.MAGV = BM.TRUONGBM) )
	BEGIN
		RAISERROR(N'Lỗi: Trưởng bộ môn phải là người trong bộ môn',16, 1)
		ROLLBACK
	END
END

/* Test */
UPDATE GIAOVIEN
SET MABM = 'CNTT'
WHERE MAGV = '001'

----------------------------------------- END -----------------------------------------
