delete  from listinfo where listid ='dnv'

INSERT INTO listinfo (listid,ctable,cview,gridid,inherit,showoldvalue,ma_qct,field_auto,allow_edit,title,title2,condition_copy,allow_change_code,grid4import,showtop,ma_phan_nhom ) VALUES ( N'dnv', N'dnv', N'vdnv', N'dnv', N'', 0, N'', N'', 1, N'Danh mục nhân viên', N'Sales Employee List', N'1=1', 1, N'dnv_imp', 5000.00000, N'' )
GO
alter table dnv add ma_nt nvarchar(16)
alter table dnv add tg_bh_xh bit
alter table dnv add tg_bh_yt bit
alter table dnv add tg_bh_tn bit
alter table dnv add tg_bh_cd bit
alter table dnv add cu_tru bit
alter table dnv add di_chuyen_noi_bo bit
GO
update dnv set ma_nt ='VND',tg_bh_xh = 0, tg_bh_yt = 0, tg_bh_tn = 0, tg_bh_cd=1,cu_tru =1,di_chuyen_noi_bo =0 where tg_bh_xh is null
GO
ALTER VIEW [dbo].[vdnv]
AS
	SELECT a.*
	,b.ten_bp,b.ten_bp2
	,c.ten_chuc_vu as ten_cv,c.ten_chuc_vu2 as ten_cv2
	,d.ten_cong_viec,d.ten_cong_viec2
	,e.ten as ten_qg,e.ten2 as ten_qg2
	,f.ten_loai_nv,f.ten_loai_nv2
	,h.ten_ly_do
	, g.[Text] AS ten_tt_hon_nhan
	FROM dnv a WITH (INDEX(PK_dnv)) 
		LEFT JOIN dmbp b on a.ma_bp=b.ma_bp
		LEFT JOIN hdchucvu c on a.ma_cv=c.ma_chuc_vu
		LEFT JOIN hdcongviec d on a.ma_cong_viec=d.ma_cong_viec
		LEFT JOIN dqg e on a.quoc_tich=e.ma_qg
		LEFT JOIN hdloainv f on a.ma_loai_nv=f.ma_loai_nv
		LEFT JOIN dmlydo h on a.ly_do_nghi_viec=h.ma_ly_do
		LEFT JOIN dmItemOfCbb g ON a.tt_hon_nhan = g.Inds AND g.form = 'dnv' AND g.NAME = 'tt_hon_nhan'

GO
alter table bangtinhluong add ma_nt nvarchar(16)
GO
update bangtinhluong set ma_nt ='VND' where ma_nt is null
GO
exec notnull 'dnv'
GO
delete  from gridinfo where gridid like N'%dmqtdong_bhxh%'
INSERT INTO gridinfo (gridid,columnsv,columnse,headersv,headerse,widths,formats,readonlys,hides,defaultvalues,carrys ) VALUES ( N'dmqtdong_bhxh', N'tu_ngay,den_ngay,ten_tt_bhxh,ghi_chu', N'tu_ngay,den_ngay,ten_tt_bhxh2,ghi_chu', N'Từ ngày,Đến ngày,Trạng thái đóng BHXH,Ghi chú', N'Từ ngày,Đến ngày,Trạng thái đóng BHXH,Ghi chú', N'100,100,150,100', N',,,', N'1,1,1,1', N'0,0,1,0', N',,,', N'0,0,0,0' )
GO
delete  from gridinfo  where gridid like N'%hrbangluong%'

INSERT INTO gridinfo (gridid,columnsv,columnse,headersv,headerse,widths,formats,readonlys,hides,defaultvalues,carrys ) VALUES ( N'hrbangluong', N'ma_bp,ma_nv,ten_nv,cong_quy_dinh,luong_co_ban,phu_cap_ky_nang,phu_cap_chuyen_can,phu_cap_chuc_vu,phu_cap_com_trua,phu_cap_xang,phu_cap_tieng_nhat,phu_cap_ket_hon,luong_san_pham,so_gio_ban_thoi_gian,luong_ban_thoi_gian,so_gio_tang_ca,luong_tang_ca,so_gio_ngay_nghi,luong_ngay_nghi,so_gio_le_tet,luong_le_tet,gio_nghi_buoc,luong_nghi_buoc,gio_bo_sung,luong_bo_sung,phu_cap_cong_tac,tong_cong,ma_nt', N'ma_bp,ma_nv,ten_nv,cong_quy_dinh,luong_co_ban,phu_cap_ky_nang,phu_cap_chuyen_can,phu_cap_chuc_vu,phu_cap_com_trua,phu_cap_xang,phu_cap_tieng_nhat,phu_cap_ket_hon,luong_san_pham,so_gio_ban_thoi_gian,luong_ban_thoi_gian,so_gio_tang_ca,luong_tang_ca,so_gio_ngay_nghi,luong_ngay_nghi,so_gio_le_tet,luong_le_tet,gio_nghi_buoc,luong_nghi_buoc,gio_bo_sung,luong_bo_sung,phu_cap_cong_tac,tong_cong,ma_nt', N'Bộ phận,Mã nv,Tên nhân viên,Công quy định,Lương cơ bản,Kỹ năng,Chuyên cần,Chức vụ,Cơm trưa,Xăng,Tiếng nhật,Kết hôn,Lương sản phẩm,Số giờ bán thời gian,Lương bán thời gian,Số giờ tăng ca,Lương tăng ca,Số giờ làm ngày nghỉ,Lương làm ngày nghỉ,Số giờ làm ngày lễ%p tết,Lương làm ngày lễ tết,Số Giờ Nghỉ Buộc,Lương Nghỉ Buộc,Số giờ bổ sung,Lương bổ sung,Công tác ngoài,Tổng cộng,Ngoại tệ', N'Bộ phận,Mã nv,Tên nhân viên,Ngày công SX,Lương cơ bản,Phụ cấp kỹ năng,Phụ cấp chuyên cần,Phụ cấp chức vụ,Phụ cấp cơm trưa,Phụ cấp xăng,Tiếng nhật,Kết hôn,Lương sản phẩm,Số giờ bán thời gian,Bán thời gian,Số giờ tăng ca,Lương tăng ca,Số giờ làm ngày nghỉ,Lương ngày nghỉ,Số giờ lễ tết,Lương lễ tết,Số Giờ Nghỉ Buộc,Lương Nghỉ Buộc,Số giờ bổ sung,Lương bổ sung,Công tác ngoài,Tổng,Ngoại tệ', N'80,60,120,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100', N',,,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,,f_tien,f_sl,f_tien,f_sl,f_tien,f_sl,f_tien,,f_tien,,f_tien,f_tien,f_tien,', N'1,1,1,0,1,1,0,0,1,1,1,1,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,1', N'0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0', N',,,,,,,,,,,,,,,,,,,,,,,,,,,', N'0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0' )
INSERT INTO gridinfo (gridid,columnsv,columnse,headersv,headerse,widths,formats,readonlys,hides,defaultvalues,carrys ) VALUES ( N'hrbangluong_bh', N'ma_bp,ma_nv,ten_nv,luong_bhxh,bhxh_t,bhyt_t,bhtn_t,cong_t,bhxh_c,bhyt_c,bhtn_c,cong_c,cong_tc,ma_nt', N'ma_bp,ma_nv,ten_nv,luong_bhxh,bhxh_t,bhyt_t,bhtn_t,cong_t,bhxh_c,bhyt_c,bhtn_c,cong_c,cong_tc,ma_nt', N'Bộ phận,Mã nv,Tên nhân viên,Tiền căn cứ tính BHXH%pBHYT%pBHTN,BHXH (8% trích từ lương),BHYT (1%p5 % trích từ lương),BHTN (1% trích từ lương),Tổng trích,BHXH (18% công ty),BHYT (3 % công ty),BHTN (1% công ty),Tổng công ty,Tổng phải nộp,Ngoại tệ', N'Bộ phận,Mã nv,Tên nhân viên,Lương tính ,BHXH ,BHYT,BHTN,Cộng trích,BHXH,BHYT,BHTN,Cộng trích,Tổng cộng,Ngoại tệ', N'80,60,120,100,100,100,100,100,100,100,100,100,100,100', N',,,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,', N'1,1,1,1,1,1,1,1,1,1,1,1,1,1', N'0,0,0,0,0,0,0,0,0,0,0,0,0,0', N',,,,,,,,,,,,,', N'0,0,0,0,0,0,0,0,0,0,0,0,0,0' )
INSERT INTO gridinfo (gridid,columnsv,columnse,headersv,headerse,widths,formats,readonlys,hides,defaultvalues,carrys ) VALUES ( N'hrbangluong_cd', N'ma_bp,ma_nv,ten_nv,luong_bhxh,cong_doan_t,cong_doan_c,cong_doan', N'ma_bp,ma_nv,ten_nv,luong_bhxh,cong_doan_t,cong_doan_c,cong_doan', N'Bộ phận,Mã nv,Tên nhân viên,Tiền căn cứ tính,Trích từ lương (1% nhưng không quá 83 ngàn),Công ty đóng (2%),Tổng cộng', N'Bộ phận,Mã nv,Tên nhân viên,Lương tính,Trich,Cty,Tổng', N'80,60,120,100,100,100,100', N',,,f_tien,f_tien,f_tien,f_tien', N'1,1,1,1,1,1,1', N'0,0,0,0,0,0,0', N',,,,,,', N'0,0,0,0,0,0,0' )
INSERT INTO gridinfo (gridid,columnsv,columnse,headersv,headerse,widths,formats,readonlys,hides,defaultvalues,carrys ) VALUES ( N'hrbangluong_nn', N'ma_bp,ma_nv,ten_nv,luong_bhxh,bhyt_t,bhyt_c,cong_tc,ma_nt', N'ma_bp,ma_nv,ten_nv,luong_bhxh,bhyt_t,bhyt_c,cong_tc,ma_nt', N'Bộ phận,Mã nv,Tên nhân viên,Tiền căn cứ tính,BHYT (1%p5 % trích từ lương),BHYT (3 % công ty),Tổng phải nộp,Ngoại tệ', N'Bộ phận,Mã nv,Tên nhân viên,Lương tính,BHYT,BHYT,Tổng cộng,Ngoại tệ', N'80,60,120,100,100,100,100,100', N',,,f_tien,f_tien,f_tien,f_tien,', N'1,1,1,1,1,1,1,1', N'0,0,0,0,0,0,0,0', N',,,,,,,', N'0,0,0,0,0,0,0,0' )
INSERT INTO gridinfo (gridid,columnsv,columnse,headersv,headerse,widths,formats,readonlys,hides,defaultvalues,carrys ) VALUES ( N'hrbangluong_pl', N'print_yn,ten_nhom_luong,ten_bp,ten_cong_viec,ma_nv,ten_nv,cong_lam_viec,cong_tang_ca,he_so,tien_cong_ngay,tien_cong_sp,cong_lam_them,tien_lam_them,tien_phu_cap,tien_tong_cong,tien_dong_qcn,tien_bh,tien_tra_qcn,ly_do_khau_tru,tien_khau_tru,tien_tong_tru,tien_con_lai', N'print_yn,ten_nhom_luong,ten_bp,ten_cong_viec,ma_nv,ten_nv,cong_lam_viec,cong_tang_ca,he_so,tien_cong_ngay,tien_cong_sp,cong_lam_them,tien_lam_them,tien_phu_cap,tien_tong_cong,tien_dong_qcn,tien_bh,tien_tra_qcn,ly_do_khau_tru,tien_khau_tru,tien_tong_tru,tien_con_lai', N'In phiếu lương,Nhóm,Bộ phận,Công việc,Mã nv,Tên nhân viên,Ngày công SX,Ngày công tăng ca,Hệ số,Lương ngày,Lương sản phẩm,Công làm thêm,Tiền làm thêm,Phụ cấp lương,Tổng cộng lương,Quỹ công nhân,BHXH%p YT%p CĐ,Trả quỹ CN,Lý do,Khấu trừ,Tổng khấu trừ,Lương còn lại', N'In phiếu lương,Nhóm,Bộ phận,Công việc,Mã nv,Tên nhân viên,Ngày công SX,Ngày công tăng ca,Hệ số,Lương ngày,Lương sản phẩm,Công làm thêm,Tiền làm thêm,Phụ cấp lương,Tổng cộng lương,Quỹ công nhân,BHXH-YT-CĐ,Trả quỹ CN,Lý do,Khấu trừ,Tổng khấu trừ,Lương còn lại', N'50,100,80,80,60,120,50,50,50,60,60,50,60,60,70,50,60,60,100,60,60,70', N',,,f_tien,,,,,,f_tien,f_tien,,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,,f_tien,f_tien,f_tien', N'1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1', N'0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0', N',,,,,,,,,,,,,,,,,,,,,', N'0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0' )
INSERT INTO gridinfo (gridid,columnsv,columnse,headersv,headerse,widths,formats,readonlys,hides,defaultvalues,carrys ) VALUES ( N'hrbangluong_thuc_tra', N'ma_bp,ma_nv,ten_nv,tong_luong,bhxh_t,bhyt_t,bhtn_t,cong_doan_t,phu_cap_chuyen_can,so_ngay_nghi,nghi_tru_luong,thue_tncn,tong_tru,thuc_tra,ma_nt', N'ma_bp,ma_nv,ten_nv,tong_luong,bhxh_t,bhyt_t,bhtn_t,cong_doan_t,phu_cap_chuyen_can,so_ngay_nghi,nghi_tru_luong,thue_tncn,tong_tru,thuc_tra,ma_nt', N'Bộ phận,Mã nv,Tên nhân viên,Tổng lương,BHXH,BHYT,BHTN,Chi phí công đoàng,Chuyên cần,Số ngày nghỉ,Nghỉ trừ lương,Thuế TNCN,Tổng trừ,Thực trả,Ngoại tệ', N'Bộ phận,Mã nv,Tên nhân viên,Lương chính,BHXH,BHYT,BHTN,Chi phí công đoàn,Chuyên cần,Số ngày nghỉ,Nghỉ trừ lương,Thuế TNCN tạm tính,Tổng trừ,Thực trả,Ngoại tệ', N'80,60,120,100,100,100,100,100,100,100,100,100,100,100,100', N',,,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,', N'1,1,1,1,1,1,1,1,0,0,1,1,1,1,1', N'0,0,0,0,0,0,0,0,0,0,0,0,0,0,0', N',,,,,,,,,,,,,,', N'0,0,0,0,0,0,0,0,0,0,0,0,0,0,0' )
INSERT INTO gridinfo (gridid,columnsv,columnse,headersv,headerse,widths,formats,readonlys,hides,defaultvalues,carrys ) VALUES ( N'hrbangluong_tncn', N'ma_bp,ma_nv,ten_nv,luong_chinh,luong_thanh_tich,thu_nhap_chiu_thue,bhxh_t,bhyt_t,bhtn_t,phu_cap_com_trua,giam_tru_ca_nhan,giam_tru_phu_thuoc,tong_giam_tru,thu_nhap_tinh_thue,thue_tncn', N'ma_bp,ma_nv,ten_nv,luong_chinh,luong_thanh_tich,thu_nhap_chiu_thue,bhxh_t,bhyt_t,bhtn_t,phu_cap_com_trua,giam_tru_ca_nhan,giam_tru_phu_thuoc,tong_giam_tru,thu_nhap_tinh_thue,thue_tncn', N'Bộ phận,Mã nv,Tên nhân viên,Lương chính,Lương thành tích,Tổng thu nhập chịu thuế,BHXH,BHYT,BHTN,Cơm trưa,Bản thân,Phụ thuộc,Tổng cộng,Thu nhập tính thuế,Thuế TNCN tạm tính', N'Bộ phận,Mã nv,Tên nhân viên,Lương chính,Lương thành tích,Thu nhập chịu thuế,BHXH,BHYT,BHTN,Cơm trưa,Giảm trừ cá nhân,Giảm trừ phụ thuộc,Tổng cộng,Thu nhập tính thuế,Thuế TNCN tạm tính', N'80,60,120,100,100,100,100,100,100,100,100,100,100,100,100', N',,,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien,f_tien', N'1,1,1,1,1,1,1,1,1,1,0,0,1,1,1', N'0,0,0,0,0,0,0,0,0,0,0,0,0,0,0', N',,,,,,,,,,,,,,', N'0,0,0,0,0,0,0,0,0,0,0,0,0,0,0' )
