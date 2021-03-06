
ALTER proc [dbo].[tonghop_tncn_nam]	
	@nam int,
	@ma_nv varchar(16)='',
	@ma_bp varchar(16)=''
	--@quoc_tich int = 0--0:khong phan biet quoc tich,1:nguoi viet,2:nguoi nuoc ngoai
as
begin
	declare @cong_quy_dinh numeric(18,0)
	DECLARE @strSQL VARCHAR(max)	
	select @cong_quy_dinh = value1 from options where name ='hr_ngay_chuan'
	if @cong_quy_dinh is null set @cong_quy_dinh = 25

	select ma_nv,cu_tru,di_chuyen_noi_bo into #nguoi_nuoc_ngoai from dnv where  quoc_tich <>'00000001' and quoc_tich<>''

	select * into #dnv from dnv where (@ma_nv = '' or ma_nv = @ma_nv) and (@ma_bp ='' or ma_bp = @ma_bp)
	and ma_nv not in (select ma_nv from #nguoi_nuoc_ngoai where cu_tru=1)

	select * into #bangtinhluong from bangtinhluong		
		where nam = @nam
		and ma_nv in (select ma_nv from #dnv)
	
	select a.ma_nv,a.ma_bp,a.ten_nv,a.nv_thu_viec,a.quoc_tich, b.thang, b.nam
			,@cong_quy_dinh as cong_quy_dinh
			,isnull(b.ngay_cong,0) as ngay_cong --tinh tu bang cham cong theo thoi gian
			,isnull(a.luong_bhxh,0) as luong_bhxh
			,isnull(a.luong_co_ban,0) as luong_co_ban
			,isnull(a.phu_cap_ky_nang,0) as phu_cap_ky_nang
			,isnull(b.phu_cap_chuyen_can,a.phu_cap_chuyen_can) as phu_cap_chuyen_can
			,isnull(a.phu_cap_chuc_vu,0) as phu_cap_chuc_vu
			,isnull(a.phu_cap_com_trua,0) as phu_cap_com_trua
			,isnull(a.phu_cap_xang,0) as phu_cap_xang
			,isnull(c.tro_cap,0) as phu_cap_tieng_nhat--lay tu tiengnhat table
			,isnull(a.phu_cap_ket_hon,0) as phu_cap_ket_hon			
			,isnull(b.luong_san_pham,0) as luong_san_pham --tinh tu bang luong thanh pham									
			,isnull(b.so_gio_tang_ca,0) as so_gio_tang_ca --tinh
			,isnull(b.so_gio_ban_thoi_gian,0) as so_gio_ban_thoi_gian --tinh
			,isnull(b.so_gio_ngay_nghi,0) as so_gio_ngay_nghi --tinh
			,isnull(b.so_gio_le_tet,0) as so_gio_le_tet --tinh
			,isnull(b.gio_nghi_buoc,0) as gio_nghi_buoc --tu go			
			,isnull(b.luong_tang_ca,0) as luong_tang_ca --tinh
			,isnull(b.luong_ban_thoi_gian,0) as luong_ban_thoi_gian --tinh
			,isnull(b.luong_ngay_nghi,0) as luong_ngay_nghi --tinh
			,isnull(b.luong_le_tet,0) as luong_le_tet --tinh
			,isnull(b.luong_nghi_buoc,0) as luong_nghi_buoc --cong thuc
			,isnull(b.phu_cap_cong_tac,0) as phu_cap_cong_tac --tu go			
			,isnull(b.gio_bo_sung,0) as gio_bo_sung --tu go			
			,isnull(b.luong_bo_sung,0) as luong_bo_sung --cong thuc
			,cast(0 as numeric(18,5)) as bhxh_t,cast(0 as numeric(18,5)) as bhxh_c
			,cast(0 as numeric(18,5)) as bhyt_t,cast(0 as numeric(18,5)) as bhyt_c
			,cast(0 as numeric(18,5)) as bhtn_t,cast(0 as numeric(18,5)) as bhtn_c			
			,cast(0 as numeric(18,5)) as cong_tc
			,cast(0 as numeric(18,5)) as tong_cong	
			,cast(0 as numeric(18,5)) as luong_chinh

			,isnull(b.giam_tru_ca_nhan,9000000) as giam_tru_ca_nhan
			,isnull(a.giam_tru_phu_thuoc,0) as giam_tru_phu_thuoc
											
			,isnull(b.so_ngay_nghi,0) as so_ngay_nghi
			,isnull(b.nghi_tru_luong,0) as nghi_tru_luong			
			,isnull(b.luong_thanh_tich,0) as luong_thanh_tich		
			-- thu nhap chiu thue
			,isnull(b.thu_nhap_tinh_thue,0) as thu_nhap_tinh_thue
			,isnull(b.thue_tncn,0) as thue_tncn
										
		into #tmp
		from #dnv a 
			left join #bangtinhluong b on a.ma_nv = b.ma_nv 
			left join tiengnhat c on a.tieng_nhat = c.ma

	--tinh luong thu viec
	update #tmp set luong_co_ban = luong_co_ban *80/100 where nv_thu_viec = 1
	--tinh luong san pham
	
	--tinh bhxh,bhyt,bhtn
	update #tmp set bhxh_t = round(luong_bhxh * 8/100,0) where quoc_tich ='00000001' or quoc_tich=''
	update #tmp set bhyt_t = round(luong_bhxh * 1.5/100,0) 
	update #tmp set bhtn_t = round(luong_bhxh * 1/100,0) where quoc_tich ='00000001' or quoc_tich=''
	
	update #tmp set bhxh_c = round(luong_bhxh * 18/100,0) where quoc_tich ='00000001' or quoc_tich=''
	update #tmp set bhyt_c = round(luong_bhxh * 3/100,0)
	update #tmp set bhtn_c = round(luong_bhxh * 1/100,0) where quoc_tich ='00000001' or quoc_tich=''
		
	update #tmp set cong_tc = bhxh_t+ bhyt_t+bhtn_t + bhxh_c+ bhyt_c+bhtn_c

	select stt_rec into #mbtp from mbtp where year(ngay_ct) = @nam and month(ngay_ct) = 1
	select ma_nv, sum(result) as luong_san_pham into #luongthanhpham from dbtp
	where stt_rec in (select stt_rec from #mbtp) and ma_nv in (select ma_nv from #tmp) group by ma_nv	
	update #tmp set luong_san_pham = isnull(b.luong_san_pham,0) from #tmp a left join #luongthanhpham b on a.ma_nv = b.ma_nv 
		
	--luong nghi buoc
	update #tmp set luong_nghi_buoc = (((luong_co_ban + phu_cap_ky_nang)/25)/8) * gio_nghi_buoc
	--tinh luong tang ca
	update #tmp set luong_tang_ca =((luong_co_ban +phu_cap_ky_nang)/25/8)*so_gio_tang_ca *1.5	
	--tinh luong ngay nghi
	update #tmp set luong_ngay_nghi =((luong_co_ban +phu_cap_ky_nang)/25/8)*so_gio_ngay_nghi *2
	--tinh luong le tet
	update #tmp set luong_le_tet =((luong_co_ban +phu_cap_ky_nang)/25/8)*so_gio_le_tet *3
	--luong ban thoi gian	
	-- luong bo sung
	update #tmp set luong_bo_sung = ((luong_co_ban +phu_cap_ky_nang)/25/8) * gio_bo_sung
	--nghi tru luong
	update #tmp set nghi_tru_luong = round(((luong_co_ban + phu_cap_ky_nang + phu_cap_chuyen_can + phu_cap_chuc_vu + phu_cap_com_trua + phu_cap_xang + phu_cap_tieng_nhat + phu_cap_ket_hon  - phu_cap_chuyen_can)/25)*so_ngay_nghi,0) 
	
	--thanh tich thuc tra
	update #tmp set luong_chinh = luong_co_ban 
		+ phu_cap_ky_nang + phu_cap_chuyen_can + phu_cap_chuc_vu + phu_cap_com_trua + phu_cap_xang + phu_cap_tieng_nhat + phu_cap_ket_hon 
		+ luong_tang_ca + luong_ban_thoi_gian + luong_ngay_nghi + luong_le_tet + phu_cap_cong_tac + luong_nghi_buoc - nghi_tru_luong  + luong_bo_sung --+ luong_san_pham 

	update #tmp set tong_cong = luong_chinh + luong_thanh_tich
	-- tax 
	update #tmp set thu_nhap_tinh_thue = tong_cong + luong_thanh_tich - phu_cap_chuyen_can - nghi_tru_luong - bhxh_t-bhyt_t-bhtn_t - giam_tru_ca_nhan - giam_tru_phu_thuoc
	update #tmp set thue_tncn =round(thu_nhap_tinh_thue * 5/100,0) where thu_nhap_tinh_thue<=5000000
	update #tmp set thue_tncn =round(thu_nhap_tinh_thue * 10/100,0) - 250000 where thu_nhap_tinh_thue > 5000000 and thu_nhap_tinh_thue<=10000000
	update #tmp set thue_tncn =round(thu_nhap_tinh_thue * 15/100,0) - 750000 where thu_nhap_tinh_thue > 10000000 and thu_nhap_tinh_thue<=18000000
	update #tmp set thue_tncn =round(thu_nhap_tinh_thue * 20/100,0) - 1650000 where thu_nhap_tinh_thue > 18000000 and thu_nhap_tinh_thue<=32000000
	update #tmp set thue_tncn =round(thu_nhap_tinh_thue * 25/100,0) - 3250000 where thu_nhap_tinh_thue > 32000000 and thu_nhap_tinh_thue<=52000000
	update #tmp set thue_tncn =round(thu_nhap_tinh_thue * 30/100,0) - 5850000 where thu_nhap_tinh_thue > 52000000 and thu_nhap_tinh_thue<=80000000
	update #tmp set thue_tncn =round(thu_nhap_tinh_thue * 35/100,0) - 9850000 where thu_nhap_tinh_thue > 80000000
	update #tmp set thu_nhap_tinh_thue =0 where thu_nhap_tinh_thue < 0
	update #tmp set thue_tncn =0 where thue_tncn < 0

	-- theo thang

	select ma_nv, isnull(tong_cong,0) as tong_cong1 into #thang1 from #tmp where thang=1 and nam=@nam
	select ma_nv, isnull(tong_cong,0) as tong_cong2 into #thang2 from #tmp where thang=2 and nam=@nam
	select ma_nv, isnull(tong_cong,0) as tong_cong3 into #thang3 from #tmp where thang=3 and nam=@nam
	select ma_nv, isnull(tong_cong,0) as tong_cong4 into #thang4 from #tmp where thang=4 and nam=@nam
	select ma_nv, isnull(tong_cong,0) as tong_cong5 into #thang5 from #tmp where thang=5 and nam=@nam
	select ma_nv, isnull(tong_cong,0) as tong_cong6, isnull(luong_thanh_tich, 0) as luong_thanh_tich6 into #thang6 from #tmp where thang=6 and nam = @nam
	select ma_nv, isnull(tong_cong,0) as tong_cong7 into #thang7 from #tmp where thang=7 and nam=@nam
	select ma_nv, isnull(tong_cong,0) as tong_cong8 into #thang8 from #tmp where thang=8 and nam=@nam
	select ma_nv, isnull(tong_cong,0) as tong_cong9 into #thang9 from #tmp where thang=9 and nam=@nam
	select ma_nv, isnull(tong_cong,0) as tong_cong10, isnull(luong_thanh_tich, 0) as luong_thanh_tich10 into #thang10 from #tmp where thang=10 and nam = @nam
	select ma_nv, isnull(tong_cong,0) as tong_cong11, isnull(luong_thanh_tich, 0) as luong_thanh_tich11 into #thang11 from #tmp where thang=11 and nam = @nam
	select ma_nv, isnull(tong_cong,0) as tong_cong12, isnull(luong_thanh_tich, 0) as luong_thanh_tich12 into #thang12 from #tmp where thang=12 and nam = @nam
	-- Quy 1
	select ma_nv, isnull(sum(phu_cap_com_trua),0) as phu_cap_com_trua, isnull(sum(cong_tc),0) as cong_tc , isnull(sum(thue_tncn), 0) as thue_tncn
	into #comtrua_q1 from #tmp where thang = 1 or thang = 2 or thang = 3 group by ma_nv
	-- Quy 2
	select ma_nv, isnull(sum(phu_cap_com_trua),0) as phu_cap_com_trua , isnull(sum(cong_tc),0) as cong_tc , isnull(sum(thue_tncn), 0) as thue_tncn
	into #comtrua_q2 from #tmp where thang = 4 or thang = 5 or thang = 6 group by ma_nv
	-- Quy 3
	select ma_nv, isnull(sum(phu_cap_com_trua),0) as phu_cap_com_trua , isnull(sum(cong_tc),0) as cong_tc , isnull(sum(thue_tncn), 0) as thue_tncn
	into #comtrua_q3 from #tmp where thang = 7 or thang = 8 or thang = 9 group by ma_nv
	-- Quy 4
	select ma_nv, isnull(sum(phu_cap_com_trua),0) as phu_cap_com_trua , isnull(sum(cong_tc),0) as cong_tc , isnull(sum(thue_tncn), 0) as thue_tncn
	into #comtrua_q4 from #tmp where thang = 10 or thang = 11 or thang = 12 group by ma_nv
	-- giam tru ca nhan, phu thuoc 
	select ma_nv, isnull(sum(giam_tru_ca_nhan),0) as giam_tru_ca_nhan , isnull(sum(giam_tru_phu_thuoc),0) as giam_tru_phu_thuoc
	into #giam_tru from #tmp group by ma_nv

	select a.ten_nv as ten_nv, a.ma_nv as ma_nv 
		, isnull(z.tong_cong1 ,0) as tong_cong1
		, isnull(b.tong_cong2 ,0) as tong_cong2
		, isnull(c.tong_cong3 ,0) as tong_cong3
		, isnull(d.tong_cong4 ,0) as tong_cong4
		, isnull(e.tong_cong5, 0) as tong_cong5
		, isnull((f.tong_cong6 - f.luong_thanh_tich6),0) as luong_chinh6 , isnull(f.luong_thanh_tich6, 0) as luong_thanh_tich6
		, isnull(g.tong_cong7 , 0) as tong_cong7
		, isnull(h.tong_cong8 , 0) as tong_cong8
		, isnull(i.tong_cong9 , 0) as tong_cong9		
		, isnull((j.tong_cong10 - j.luong_thanh_tich10),0) as luong_chinh10 , isnull(j.luong_thanh_tich10, 0) as luong_thanh_tich10
		, isnull((k.tong_cong11 - k.luong_thanh_tich11),0) as luong_chinh11 , isnull(k.luong_thanh_tich11, 0) as luong_thanh_tich11
		, isnull((l.tong_cong12 - l.luong_thanh_tich12),0) as luong_chinh12 , isnull(l.luong_thanh_tich12, 0) as luong_thanh_tich12
		
		, cast(0 as numeric(18,5)) as tong_tn_tax				
		, isnull(m.phu_cap_com_trua,0) as com_trua_q1, isnull(m.cong_tc,0) as cong_tc_q1, isnull(m.thue_tncn, 0 ) as thue_tncn_q1
		, isnull(n.phu_cap_com_trua,0) as com_trua_q2, isnull(n.cong_tc,0) as cong_tc_q2, isnull(n.thue_tncn, 0 ) as thue_tncn_q2
		, isnull(p.phu_cap_com_trua,0) as com_trua_q3, isnull(p.cong_tc,0) as cong_tc_q3, isnull(p.thue_tncn, 0 ) as thue_tncn_q3
		, isnull(q.phu_cap_com_trua,0) as com_trua_q4, isnull(q.cong_tc,0) as cong_tc_q4, isnull(q.thue_tncn, 0 ) as thue_tncn_q4
		, isnull(o.giam_tru_ca_nhan,0) as giam_tru_ca_nhan, isnull(o.giam_tru_phu_thuoc,0) as giam_tru_phu_thuoc		
		, cast(0 as numeric(18,5)) as tong_tru		
		, cast(0 as numeric(18,5)) as tong_tn_tinh	
		, cast(0 as numeric(18,5)) as tn_binhquan
		, cast(0 as numeric(18,5)) as thue_tncn
		, cast(0 as numeric(18,5)) as tong_thue_nop 
		, cast(0 as numeric(18,5)) as tong_tax_trich 
		, cast(0 as numeric(18,5)) as nop_thua 
		into #kqthang from #dnv a
		left join #thang1 z on a.ma_nv = z.ma_nv
		left join #thang2 b on a.ma_nv = b.ma_nv
		left join #thang3 c on a.ma_nv = c.ma_nv
		left join #thang4 d on a.ma_nv = d.ma_nv
		left join #thang5 e on a.ma_nv = e.ma_nv
		left join #thang6 f on a.ma_nv = f.ma_nv
		left join #thang7 g on a.ma_nv = g.ma_nv
		left join #thang8 h on a.ma_nv = h.ma_nv
		left join #thang9 i on a.ma_nv = i.ma_nv
		left join #thang10 j on a.ma_nv = j.ma_nv
		left join #thang11 k on a.ma_nv = k.ma_nv
		left join #thang12 l on a.ma_nv = l.ma_nv
		left join #comtrua_q1 m on a.ma_nv = m.ma_nv
		left join #comtrua_q2 n on a.ma_nv = n.ma_nv
		left join #comtrua_q3 p on a.ma_nv = p.ma_nv
		left join #comtrua_q4 q on a.ma_nv = q.ma_nv
		left join #giam_tru o on a.ma_nv = o.ma_nv

		
	update #kqthang set tong_tn_tax = tong_cong1 + tong_cong2 + tong_cong3 + tong_cong4 + tong_cong5 + luong_chinh6 + luong_thanh_tich6 + tong_cong7 + tong_cong8 + tong_cong9 
									+ luong_chinh10 + luong_thanh_tich10 +  luong_chinh11 + luong_thanh_tich11 +  luong_chinh12 + luong_thanh_tich12

	update #kqthang set tong_tru = com_trua_q1 + com_trua_q2 + com_trua_q3 + com_trua_q4 + cong_tc_q1 + cong_tc_q2 + cong_tc_q3 + cong_tc_q4 
									+ giam_tru_ca_nhan + giam_tru_phu_thuoc

	update #kqthang set tong_tn_tinh = tong_tn_tax - tong_tru

	update #kqthang set tn_binhquan = (case when (tong_tn_tinh > 0) then round(tong_tn_tinh/12,0) else 0 end) 
	update #kqthang set thue_tncn =round(tn_binhquan * 5/100,0) where tn_binhquan<=5000000
	update #kqthang set thue_tncn =round(tn_binhquan * 10/100,0) - 250000 where tn_binhquan > 5000000 and tn_binhquan<=10000000
	update #kqthang set thue_tncn =round(tn_binhquan * 15/100,0) - 750000 where tn_binhquan > 10000000 and tn_binhquan<=18000000
	update #kqthang set thue_tncn =round(tn_binhquan * 20/100,0) - 1650000 where tn_binhquan > 18000000 and tn_binhquan<=32000000
	update #kqthang set thue_tncn =round(tn_binhquan * 25/100,0) - 3250000 where tn_binhquan > 32000000 and tn_binhquan<=52000000
	update #kqthang set thue_tncn =round(tn_binhquan * 30/100,0) - 5850000 where tn_binhquan > 52000000 and tn_binhquan<=80000000
	update #kqthang set thue_tncn =round(tn_binhquan * 35/100,0) - 9850000 where tn_binhquan > 80000000
	update #kqthang set thue_tncn =0 where thue_tncn < 0

	update #kqthang set tong_thue_nop = thue_tncn * 12 

	update #kqthang set tong_tax_trich = thue_tncn_q1 + thue_tncn_q2 + thue_tncn_q3 + thue_tncn_q4

	update #kqthang set nop_thua = tong_tax_trich - tong_thue_nop 
				
	-- ket qua 
	select * from #kqthang 
end
