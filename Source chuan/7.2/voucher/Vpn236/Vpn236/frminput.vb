﻿Imports ClsLookup

Public Class frminput

    Dim isloaded As Boolean = False

    Private Sub frminput_Activated(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Activated
        If isloaded = False Then
            Me.txtso_ct.Focus()
            Me.txtso_ct.SelectionStart = txtso_ct.Text.Length
        End If
    End Sub

    Private Sub frminput_FormClosed(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosedEventArgs) Handles Me.FormClosed
        isloaded = False
        For Each dvtab As ClsSV31.TabDetail20 In Voucher.Tabdetails.Values
            RemoveHandler dvtab.AfterCalcOnCell, AddressOf tinh_tong_tien
        Next
        RemoveHandler Voucher.Tabdetails("vvatvao").gridDetailKeyin.CellEndEdit, AddressOf grdvat_CellEndEdit
        RemoveHandler Voucher.Tabdetails("vvatvao").gridDetailKeyin.CellBeginEdit, AddressOf grdvat_CellBeginEdit
    End Sub

    Private Sub frminput_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        For Each dvtab As ClsSV31.TabDetail20 In Voucher.Tabdetails.Values
            AddHandler dvtab.AfterCalcOnCell, AddressOf tinh_tong_tien
        Next
        AddHandler Voucher.Tabdetails("vvatvao").gridDetailKeyin.CellEndEdit, AddressOf grdvat_CellEndEdit
        AddHandler Voucher.Tabdetails("vvatvao").gridDetailKeyin.CellBeginEdit, AddressOf grdvat_CellBeginEdit

    End Sub

   
    Private Sub frminput_show(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Shown
        Dim dvr As DataRowView = cbbma_nt.SelectedItem

        hide_show_control(dvr("ma_nt"))
        isloaded = True
        If Voucher.Action = ClsSV31.Voucher20.Actions.ADD Then
            Txtty_gia.Value = conn.GetValue("exec getty_gia " & conn.ConvertToSQLType(cbbma_nt.SelectedValue.trim) & "," & conn.ConvertToSQLType(Txtngay_ct.Value))
        End If
    End Sub
#Region "lay ty gia tu dong"
    Dim ngay_ctold As Date
    Private Sub Txtngay_ct_Validated(ByVal sender As Object, ByVal e As System.EventArgs) Handles Txtngay_ct.Validated
        If ngay_ctold <> Txtngay_ct.Value Then
            If isloaded Then
                If Voucher.Action = ClsSV31.Voucher20.Actions.ADD Then
                    Txtty_gia.Value = conn.GetValue("exec getty_gia " & conn.ConvertToSQLType(cbbma_nt.SelectedValue.trim) & "," & conn.ConvertToSQLType(Txtngay_ct.Value))
                End If
            End If
        End If
    End Sub
    Private Sub Txtngay_ct_endter(ByVal sender As Object, ByVal e As System.EventArgs) Handles Txtngay_ct.Enter
        ngay_ctold = Txtngay_ct.Value
    End Sub
#End Region
   

    Private Sub grdvat_CellBeginEdit(ByVal sender As Object, ByVal e As System.Windows.Forms.DataGridViewCellCancelEventArgs)
        If String.IsNullOrEmpty(Voucher.Tabdetails("vvatvao").gridDetailKeyin.Item("tk_du", e.RowIndex).Value.ToString) Then
            Try
                Voucher.Tabdetails("vvatvao").gridDetailKeyin.Item("tk_du", e.RowIndex).Value = Voucher.Tabdetails(Voucher.TabFirst).gridDetailKeyin.Item("tk_co", 0).Value
            Catch ex As Exception

            End Try

        End If

    End Sub
    Private Sub grdvat_CellEndEdit(ByVal sender As Object, ByVal e As System.Windows.Forms.DataGridViewCellEventArgs)
        On Error Resume Next
        Dim ty_gia As Double = Txtty_gia.Value
        If sender.Rows(e.RowIndex).IsNewRow = False Then
            Select Case sender.Columns(e.ColumnIndex).Name
                Case "so_seri"
                    sender.Item("so_seri", e.RowIndex).Value = sender.Item("so_seri", e.RowIndex).Value.ToString.ToUpper
                Case "so_hd"
                    Dim t_tien As Double = 0
                    Dim t_tien_nt As Double = 0
                    For Each r As DataGridViewRow In Voucher.Tabdetails(Voucher.TabFirst).gridDetailKeyin.Rows
                        If Not r.IsNewRow Then
                            If r.Cells("so_hd").Value.ToString.Trim.ToLower = sender.Item("so_hd", e.RowIndex).Value.ToString.Trim.ToLower Then
                                t_tien = t_tien + r.Cells("tien").Value
                                t_tien_nt = t_tien_nt + r.Cells("tien_nt").Value


                                sender.Item("t_tien", e.RowIndex).Value = t_tien
                                sender.Item("t_tien_nt", e.RowIndex).Value = t_tien_nt

                                sender.Item("t_thue_nt", e.RowIndex).Value = t_tien_nt * sender.Item("thue_suat", e.RowIndex).Value / 100
                                sender.Item("t_thue", e.RowIndex).Value = t_tien * sender.Item("thue_suat", e.RowIndex).Value / 100
                                sender.Item("ngay_hd", e.RowIndex).Value = Txtngay_ct.Value
                                sender.Item("tk_du", e.RowIndex).Value = r.Cells("tk_co").Value
                            End If
                        End If
                    Next
                    t_tien = Nothing
                    t_tien_nt = Nothing
                    tinh_tong_tien()
            End Select
        End If
    End Sub


    Private Sub btnLuu_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnLuu.Click
        If save() = False Then
            Exit Sub
        End If
        formtask.TD1.Visible = True
        formtask.TD1.Text = "Chi tiền"
        formtask.btnnew.Enabled = Voucher.rights.NewRight
        If formtask.btncopy.Enabled = True Then
            formtask.btncopy.Enabled = Voucher.rights.NewRight
        End If
        formtask.btnprint.Enabled = Voucher.rights.PrintRight
        formtask.ShowDialog(Me)
        Select Case formtask.task
            Case ClsSV31.frmTask.Tasks.AddNew
                Me.BindingContext(Voucher.BindingSource).EndCurrentEdit()
                Voucher.Mdatatable.AcceptChanges()
                Voucher.News2()
            Case ClsSV31.frmTask.Tasks.Copy
                Voucher.Copy()
            Case ClsSV31.frmTask.Tasks.TD1
                Dim f As New frmThanhToan
                f.Icon = Me.Icon
                f.Text = formtask.TD1.Text
                f.StartPosition = FormStartPosition.CenterParent
                f.txtma_kh.Text = txtma_kh.Text
                f.ten_kh.Text = txtten_kh.Text
                f.txttien_hd.Value = Voucher.CurrentVoucher.Item("t_tt")
                f.txtma_nt.Text = cbbma_nt.SelectedValue
                f.txtty_gia.Value = Txtty_gia.Value
                Dim dtpc As DataTable = conn.GetDatatable("select * from mpc1 where stt_rec_goc_hd ='" & Voucher.Stt_rec & "'")
                If dtpc.Rows.Count > 0 Then
                    f.txtty_gia.Value = dtpc.Rows(0).Item("ty_gia")
                    f.txtma_nt.Text = dtpc.Rows(0).Item("ma_nt")
                    f.txttien_nt.Value = conn.GetValue("select sum(tien_nt) from dpc1 where stt_rec='" & dtpc.Rows(0).Item("stt_rec") & "'")
                    f.txttien.Value = conn.GetValue("select sum(tien) from dpc1 where stt_rec='" & dtpc.Rows(0).Item("stt_rec") & "'")
                End If

                If f.ShowDialog(Me) = Windows.Forms.DialogResult.OK Then
                    Dim query As String
                    Dim query_tt As String = ""
                    'xoa phieu chi cu
                    If dtpc.Rows.Count > 0 Then
                        Dim stt_rec_pc As String = dtpc.Rows(0).Item("stt_rec")
                        query = "delete from dpc1 where stt_rec='" & stt_rec_pc & "'"
                        query = query & ChrW(13) & "GO" & ChrW(13) & "delete from tdttco where stt_rec='" & stt_rec_pc & "'"
                        query = query & ChrW(13) & "GO" & ChrW(13) & "delete from mpc1 where stt_rec='" & stt_rec_pc & "'"
                        conn.ExecuteWithMultiQuery(query)
                        'xoa post
                        ClsSV31.Functions.deletePost(conn, dtpc.Rows(0).Item("ma_ct"), dtpc.Rows(0))
                    End If
                    'tao phieu chi
                    query = "select * from mpc1 where 1=0"
                    query = query & ChrW(13) & "select * from dpc1 where 1=0"
                    Dim dspc As DataSet = conn.GetDataSet(query)
                    'get new stt_rec pt
                    Dim stt_rec_pt As String = conn.GetValue("select dbo.getnewsttrec('PC1')")
                    conn.Execute("update Dmct set stt_rec_ht = right('" & stt_rec_pt & "',9)  where ma_ct = 'PC1'")
                    'create master
                    Clsql.Data.CopyTable(Voucher.Mdatatable, dspc.Tables(0), "stt_rec='" & Voucher.Stt_rec & "'")
                    dspc.Tables(0).Rows(0).Item("ma_ct") = "PC1"
                    dspc.Tables(0).Rows(0).Item("ma_gd") = 0
                    dspc.Tables(0).Rows(0).Item("stt_rec") = stt_rec_pt
                    dspc.Tables(0).Rows(0).Item("ma_nt") = f.txtma_nt.Text
                    dspc.Tables(0).Rows(0).Item("ty_gia") = f.txtty_gia.Value
                    dspc.Tables(0).Rows(0).Item("stt_rec_goc_hd") = Voucher.Stt_rec
                    'create detail
                    Clsql.Data.CopyTable(dspc.Tables(0), dspc.Tables(1))
                    dspc.Tables(1).Rows(0).Item("ma_nvu") = f.txtma_nvu.Text
                    dspc.Tables(1).Rows(0).Item("tien_nt") = f.txttien_nt.Value
                    dspc.Tables(1).Rows(0).Item("tien") = f.txttien.Value
                    Dim nghvu As DataTable = conn.GetDatatable("select * from dmnvu where ma_nvu='" & f.txtma_nvu.Text & "'")
                    dspc.Tables(1).Rows(0).Item("tk_no") = nghvu.Rows(0).Item("tk_no")
                    dspc.Tables(1).Rows(0).Item("tk_co") = nghvu.Rows(0).Item("tk_co")
                    'create tdttco
                    Dim rowtdttco As DataRow = Nothing
                    If f.chbttthd.Checked Then
                        query = "Exec GetInvoice4Paid "
                        query = query & conn.ConvertToSQLType(Me.txtma_kh.Text)
                        query = query & "," & conn.ConvertToSQLType(Me.Txtngay_ct.Value)
                        If Voucher.Action = ClsSV31.Voucher20.Actions.ADD Then
                            query = query & ",1"
                        Else
                            query = query & ",2"
                        End If
                        query = query & "," & conn.ConvertToSQLType(Voucher.Stt_rec)
                        Dim tdttco As DataTable = conn.GetDatatable(query)

                        For Each r As DataRow In tdttco.Rows
                            If r.Item("stt_rec").ToString.Substring(0, 1) & r.Item("ma_ct").ToString & r.Item("stt_rec").ToString.Substring(4) = Voucher.Stt_rec Then
                                r.Item("stt_rec") = stt_rec_pt
                                r.Item("ma_ct") = "PC1"
                                r.Item("loai_tt") = "1"
                                r.Item("ngay_ct") = Me.Txtngay_ct.Value
                                r.Item("so_ct") = Me.txtso_ct.Text
                                r.Item("status") = Me.cbbstatus.SelectedValue
                                r.Item("tk_co") = nghvu.Rows(0).Item("tk_co")
                                r.Item("ma_nvu") = f.txtma_nvu.Text
                                dspc.Tables(1).Rows(0).Item("tk_no") = r.Item("tk_no")
                                dspc.Tables(0).Rows(0).Item("ma_gd") = 1
                                r.Item("ma_nt") = f.txtma_nt.Text
                                r.Item("ty_gia") = f.txtty_gia.Value
                                r.Item("tien_nt") = f.txttien_nt.Value
                                r.Item("tien") = f.txttien.Value
                                r.Item("tt_qd") = f.txttien.Value / r.Item("ty_gia_tt")
                                rowtdttco = r
                                If r.Item("tt_qd") >= r.Item("con_lai_nt") Then
                                    query_tt = "EXEC Tatoanco " & conn.ConvertToSQLType(r.Item("stt_rec_tt")) & "," & "'" & r.Item("ma_ct_tt") & "'"
                                End If

                                Exit For
                            End If
                        Next
                    End If

                    'run
                    query = conn.GetInsertQueryFromDatatable(dspc.Tables(0), "mpc1")
                    query = query & ChrW(13) & "GO" & conn.GetInsertQueryFromDatatable(dspc.Tables(1), "dpc1")
                    If rowtdttco IsNot Nothing Then
                        query = query & ChrW(13) & "GO" & conn.GetInsertQueryFromDataRow(rowtdttco, "tdttco")
                    End If
                    conn.ExecuteWithMultiQuery(query)
                    'post phieu chi
                    ClsSV31.Functions.Post(conn, dspc.Tables(0).Rows(0).Item("ma_ct"), "vmpc1", dspc.Tables(0).Rows(0).Item("stt_rec"), cbbstatus.SelectedValue)
                    'tat toan
                    If query_tt <> "" Then
                        conn.Execute(query_tt)
                    End If
                End If
                Me.Close()
            Case ClsSV31.frmTask.Tasks.Print
                For Each r As DataRow In Voucher.Mdatatable.Select("sel=true")
                    r("sel") = False
                Next
                Voucher.BindingSource.Current("sel") = True
                oPrint.Print()
                Me.Close()
            Case ClsSV31.frmTask.Tasks.Close
                Me.DialogResult = DialogResult.OK
                Me.Close()
        End Select
    End Sub
    Function save() As Boolean
        'kiem tra so chung tu
        If Voucher.CheckSoCT(Txtngay_ct.Value, txtso_ct.Text) = False Then
            Return False
        End If
        TabControl1.SelectedTab = TabControl1.TabPages(0)
        Voucher.BindingSource.EndEdit()
        'kiem tra da nhap chi tiet chua
        If Voucher.CheckKeyIn = False Then
            Return False
        End If
        'kiem tra han muc no
        If Clsql.Others.Options("td_cn_vdm", conn) = "1" Then
            Dim tk_dm As String = conn.GetValue("select tk_cn from dkh where ma_kh='" & txtma_kh.Text & "'")
            If tk_dm.Trim <> "" Then

                Dim ps_co As Double = 0
                Dim ps_co_nt As Double = 0
                'tien nhap
                Voucher.Tabdetails(Voucher.TabFirst).Datatable.AcceptChanges()
                For Each r As DataRow In Voucher.Tabdetails(Voucher.TabFirst).Datatable.Select("tk_co ='" & tk_dm.Trim & "'")
                    ps_co = ps_co + r("tien")
                    ps_co_nt = ps_co_nt + r("tien_nt")
                Next
                'tien thue
                Voucher.Tabdetails("vvatvao").Datatable.AcceptChanges()
                For Each r As DataRow In Voucher.Tabdetails("vvatvao").Datatable.Select("tk_du ='" & tk_dm.Trim & "'")
                    ps_co = ps_co + r("t_thue")
                    ps_co_nt = ps_co_nt + r("t_thue_nt")
                Next
                '
                If Voucher.Action = ClsSV31.Voucher20.Actions.EDIT Then
                    ps_co = ps_co - conn.GetValue("select ps_co from vsocai where stt_rec ='" & Voucher.Stt_rec & "' and tk ='" & tk_dm & "'")
                    ps_co_nt = ps_co_nt - conn.GetValue("select ps_co_nt from vsocai where stt_rec ='" & Voucher.Stt_rec & "' and tk ='" & tk_dm & "'")
                End If
                If ps_co > 0 Then
                    Dim vuot As Double = conn.GetValue("exec check_vuot_dinh_muc_co " & conn.ConvertToSQLType(txtma_kh.Text) _
                                     & "," & conn.ConvertToSQLType(Txtngay_ct.Value) _
                                    & "," & ps_co & "," & ps_co_nt)
                    If vuot > 0 Then
                        If MsgBox(Voucher.oLan("207").Replace("%t", Strings.FormatNumber(vuot)).Replace("%k", txtma_kh.Text), MsgBoxStyle.YesNo, Clsql.AboutMe.Name) <> MsgBoxResult.Yes Then
                            Return False
                        End If

                    End If
                End If
            End If

        End If
        'dien cac gia tri cu m vao d
        Voucher.SynMD()
        If Voucher.Action = 1 Then

            Voucher.Insert()
        Else
            Voucher.Update()
        End If
        'post
        ClsSV31.Functions.Post(conn, Voucherid, Voucher.Mviewname, Voucher.Stt_rec, cbbstatus.SelectedValue)

        Dim query As String = ""
        'xoa phieu chi cu
        Dim dtpc As DataTable = conn.GetDatatable("select * from mpc1 where stt_rec_goc ='" & Voucher.Stt_rec & "'")
        If dtpc.Rows.Count > 0 Then
            Dim stt_rec_pc As String = dtpc.Rows(0).Item("stt_rec")
            query = "delete from dpc1 where stt_rec='" & stt_rec_pc & "'"
            query = query & ChrW(13) & "GO" & ChrW(13) & "delete from mpc1 where stt_rec='" & stt_rec_pc & "'"
            conn.ExecuteWithMultiQuery(query)
            'xoa post
            ClsSV31.Functions.deletePost(conn, dtpc.Rows(0).Item("ma_ct"), dtpc.Rows(0))
        End If

        'tu tao phieu chi
        query = "exec CreatePCFromPN2 '" & Voucher.Stt_rec & "'"
        Dim dspc As DataSet = conn.GetDataSet(query)
        If dspc.Tables(0).Rows.Count > 0 Then
            query = conn.GetInsertQueryFromDatatable(dspc.Tables(0), "mpc1")
            query = query & ChrW(13) & "GO" & conn.GetInsertQueryFromDatatable(dspc.Tables(1), "dpc1")
            conn.ExecuteWithMultiQuery(query)
            'post phieu chi
            ClsSV31.Functions.Post(conn, dspc.Tables(0).Rows(0).Item("ma_ct"), "vmpc1", dspc.Tables(0).Rows(0).Item("stt_rec"), cbbstatus.SelectedValue)
        End If
        Return True
    End Function
   
    Dim t_tien, t_ck, t_thue, t_tt, t_cp, t_sl, t_tien_von, t_tien_nt, t_ck_nt, t_thue_nt, t_tt_nt, t_sl_nt, t_tien_von_nt, t_cp_nt As Double

    Sub tinh_tong_tien()
        If isloaded = False Then
            Return
        End If
        t_tien_nt = ClsControl2.PropertyOfGrid.Sum(Voucher.Tabdetails(Voucher.TabFirst).gridDetailKeyin, "tien_nt")
        t_tien = ClsControl2.PropertyOfGrid.Sum(Voucher.Tabdetails(Voucher.TabFirst).gridDetailKeyin, "tien")


        t_thue_nt = ClsControl2.PropertyOfGrid.Sum(Voucher.Tabdetails("vvatvao").gridDetailKeyin, "t_thue_nt")
        t_thue = ClsControl2.PropertyOfGrid.Sum(Voucher.Tabdetails("vvatvao").gridDetailKeyin, "t_thue")

        t_tt_nt = t_tien_nt + t_ck_nt + t_thue_nt
        t_tt = t_tien + t_cp + t_thue
        '

        Txtt_tien_nt.Value = t_tien_nt
        Txtt_tien.Value = t_tien


        txtt_thue_nt.Value = t_thue_nt
        txtt_thue.Value = t_thue

        txtt_tt_nt.Value = t_tt_nt
        txtt_tt.Value = t_tt


    End Sub
    Private Sub btnluuandmoi_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnluuandmoi.Click
        If save() = False Then
            Exit Sub
        End If
        Me.BindingContext(Voucher.BindingSource).EndCurrentEdit()
        Voucher.Mdatatable.AcceptChanges()
        Voucher.News2()
        'Dim dvr As DataRowView = cbbma_nt.SelectedItem
        Txtty_gia.Value = conn.GetValue("exec getty_gia " & conn.ConvertToSQLType(cbbma_nt.SelectedValue.trim) & "," & conn.ConvertToSQLType(Txtngay_ct.Value))
        txtso_ct.Focus()
    End Sub

    Private Sub btnhuy_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnhuy.Click
        If Voucher.Action = 1 Then
            Voucher.Mdatatable.Rows.Remove(Voucher.CurrentVoucher)
        End If
    End Sub


    Private Sub cbbma_nt_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles cbbma_nt.SelectedValueChanged
        If isloaded = False Then
            Exit Sub
        End If
        Try
            TabControl1.SelectedTab = TabControl1.TabPages(0)
            If cbbma_nt.SelectedItem IsNot Nothing Then
                Dim dvr As DataRowView = cbbma_nt.SelectedItem

                Txtty_gia.Value = conn.GetValue("exec getty_gia " & conn.ConvertToSQLType(cbbma_nt.SelectedValue.trim) & "," & conn.ConvertToSQLType(Txtngay_ct.Value))
                hide_show_control(dvr("ma_nt"))
            End If

        Catch ex As Exception

        End Try
    End Sub
    Sub hide_show_control(ByVal ma_nt As String)
        For Each t As ClsSV31.TabDetail20 In Voucher.Tabdetails.Values
            t.ma_nt = ma_nt
        Next
        If ma_nt.Trim.ToUpper = ma_nt_ht.Trim.ToUpper Then

            Txtty_gia.ReadOnly = True
            Txtt_tien.Hide() 'Visible = False
            txtt_thue.Hide() 'Visible = False
            txtt_tt.Hide() 'Visible = False

            Txtt_tien_nt.NumberDecimalDigits = Clsql.Others.Options("f_tien", conn)

            txtt_thue_nt.NumberDecimalDigits = Clsql.Others.Options("f_tien", conn)
            txtt_tt_nt.NumberDecimalDigits = Clsql.Others.Options("f_tien", conn)
        Else

            Txtty_gia.ReadOnly = False
            Txtt_tien.Show() 'Visible = True
            txtt_thue.Show() 'Visible = True
            txtt_tt.Show() 'Visible = True

            Txtt_tien_nt.NumberDecimalDigits = Clsql.Others.Options("f_tien_nt", conn)

            txtt_thue_nt.NumberDecimalDigits = Clsql.Others.Options("f_tien_nt", conn)
            txtt_tt_nt.NumberDecimalDigits = Clsql.Others.Options("f_tien_nt", conn)
            tinh_tong_tien()
        End If
    End Sub

    
End Class