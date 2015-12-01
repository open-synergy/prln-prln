<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>

<!-##############################################################################################################################################
															CSS STYLE AND STATEMENTS
##################################################################################################################################################-->

<head>

<style type="text/css">

h1 {
    font-size: 25pt;
    padding-top: 8px;
    margin:0px;
}
.diva {
    overflow: hidden;
    text-overflow: ellipsis;
    height: 40px;
    text-align: justify;
    border: 1px solid black;
}
.table {
    width: 100%;
    margin: 0px;
    padding: 0px;
    border-spacing: 0px;
    border-collapse: collapse;
}
.table_from_dept{
    width: 132px;
    text-align: left;
    border: 1px solid black;
    border-collapse: collapse;
    font-weight:bold;
}
.td_from_dept{
    width: 43px;
    border: 1px solid black;
    border-collapse: collapse;
    font-weight:bold;
    text-align:center;
}
.table_border {
    border: 1px solid black;
    font-weight: bold;
    padding-right: 3px;
    text-align: center;
    border-spacing: 0px;
}
.table_line {
    border: 1px solid black;
    border-collapse: collapse;
    text-align: center;
    height: 18px;
}

</style>

</head>

<!--################################################################################################################################################
								    							 DEKLARASI VARIABEL
####################################################################################################################################################-->
<%import math %>
<%import re%>

<%wrong_document_state = [] %>		<!--Dipakai untuk menyimpan daftar dan status dari dokumen-dokumen yang tidak akan dicetak (status invalid)-->
<%not_incoming = [] %>
<%total_document = len(objects)%>	<!--Dipakai untuk mencek jumlah dokumen-dokumen yang akan dicetak-->

<!--KONFIGURASI untuk menentukan jumlah baris dari line item yang ingin dicetak setiap halamannya-->
<!--Variabel berikut menentukan atau mengikuti 'layout' dari halaman kertas, sehingga menandakan batasan atau limit kertas-->
<%max_lines = 15%>									<!--Jumlah baris maksimum untuk line item s/d akhir halaman-->
<%def_footer_lines = 5%>							<!--Jumlah pemakaian baris untuk footer yang akan dicetak setiap halamannya-->
<%last_page_footer_lines = 5%>						<!--Jumlah pemakaian baris untuk footer yang akan dicetak khusus untuk halaman akhir-->
<%target_lines = max_lines - def_footer_lines%>		<!--Jumlah line item yang akan dicetak setiap halamannya-->

<!--KONFIGURASI untuk menentukan jumlah dan spesifikasi dari kolom untuk setiap baris line item yang akan dicetak-->
<%line_item_columns=3%>								<!--Jumlah kolom dari setiap baris line item yang dicetak-->
<%column_width_in_chars=[88,8,8]%>			        <!--Lebar masing-masing kolom line item dalam jumlah huruf/karakter-->
<%max_wrap_lines=3%>								<!--Maksimum jumlah baris yang dibentuk untuk teks yang wrapping, sisa teks yang tidak 'muat' di'buang'-->
													<!--Nilai satu berarti tidak akan ada wrapping, sehingga semua teks untuk kolom akan di'truncate'-->

<!--KONFIGURASI untuk menentukan layout HTML dari formulir-->
<%preprinted_header_space = 48%>					<!--Blank space untuk area preprinted dari formulir-->
<%line_item_height = 15%>							<!--Tinggi dari setiap line item yang dicetak-->
<%font_size = 12%>									<!--Ukuran tulisan yang digunakan secara umum, dapat di-override apabila font-size juga ditentukan pada setiap tr atau td-->
<%page_width = 793%>								<!--Lebar formulir yang umum digunakan sebagai lebar tabel utama-->

<!--Proses semua dokumen satu per satu-->
%for ins in objects :
    <!--Menentukan kondisi status object untuk data yang dicetak-->
    %if ins.type != 'in':
        <% not_incoming.append(ins.name) %>
    %elif ins.state != 'done':
		<!--Seluruh dokumen yang statusnya invalid akan di'catat' untuk kemudian diinfokan ke pengguna-->
    	<% wrong_document_state.append('%s: %s' % (ins.name, ins.state)) %>
	%else:
		<!--Hanya proses dokumen dengan status yang valid-->

		<!----------------------------------------------------------------------------------------------------------------------------------------------
		PRA-PROSES DATA: bagian ini adalah untuk memproses data line item yang akan dicetak.  Diperlukan proses awal (preprocessing) di mana teks atau
		deskripsi dari line item yang akan dicetak di'parsing' untuk menentukan apakah akan ada 'wrapping' atau tidak.  Jika wrapping akan terjadi, maka
		teks yang telah dibaca akan dipotong/split ke baris berikutnya (jumlah maksimum baris ditentukan oleh variabel max_wrap_lines).
		Hasil akhir dari preprocessing data ini adalah suatu list dari baris atau line item yang akan dicetak (secara data type berupa list of list).
		Untuk setiap baris yang juga berupa list data type, akan berisikan teks yang akan dicetak bagi masing-masing kolomnya.
		-------------------------------------------------------------------------------------------------------------------------------------------------->
		<!--A. Menghitung baris line item yang akan dicetak-->
		<!--Hitung jumlah produk atau line item yang akan diproses untuk dicetak-->
		<%total_products = len(ins.move_lines)%>

		<!--Siapkan variabel 'penyimpanan'-->
		<%line_item_print=[]%>		<!--Tempat untuk menyimpan semua teks dari produk atau 'line item' yang telah di proses mengikuti konfigurasi kolom-->
		<%total_lines_print=0%>		<!--Jumlah baris yang harus dicetak-->

<!--################################################################################################################################################
								    					     PRE-PROCESSING LOGIC LINE ITEM
####################################################################################################################################################-->

		<!--Proses semua produk di dalam dokumen yang dimaksud-->
		%for prod_no in range (0,total_products):
			<!--Ambil atau proses produk atau 'line item'nya-->
			<%prod = ins.move_lines[prod_no]%>

<!--================================================================== EDITABLE AREA ===============================================================-->

			<!--Tempat sementara untuk menyimpan data setiap produk atau 'line item'-->
			<%str_holder=[]%>
			<!--Proses seluruh kolom menjadi satu list-->
			<!--Kolom 1: nama produk-->
			<!--Buang kode produk (substitusikan seluruh teks dari awal s/d tanda ']' dengan empty string)-->
			<%prod_line_desc = re.sub(r'.*]', "", prod.name)%>
			<%str_holder.append(prod_line_desc)%>
			<!--Kolom 2: jumlah/kuantitas produk-->
			<%str_holder.append(formatLang(prod.product_qty, digits=0))%>
			<!--Kolom 3: satuan unit (UOM) produk-->
			<%str_holder.append(prod.product_uom and prod.product_uom.name or '')%>

<!--================================================================================================================================================-->

            <!--Untuk setiap produk yang diproses, kita tambahkan satu list baru, jika terdapat wrapping akan diproses/tambahkan di bagian wrapping-->
			<%no_lines=0%>
			<%line_item_print.append([])%>
			<%wrappable_column=0%>

            <%rv = wrap_line(str_holder, column_width_in_chars, line_item_columns)%>

			<!--Ambil teks yang terbaru atau yang sudah diproses wrapping-nya-->
	        <%str_holder = rv[1][:]%>
	        <%line_item_print[total_lines_print] = rv[2][:]%>

			<!--Jika terdapat baris yang diproses, maka naikkan counter (hitungan)-->
			%if rv[0] >= 0:
				<%no_lines = no_lines + 1%>
				<%total_lines_print = total_lines_print + 1%>
			%endif
			%while (no_lines < max_wrap_lines) and (rv[0] > 0):
				<%line_item_print.append([])%>
				<%rv=wrap_line(str_holder, column_width_in_chars, line_item_columns)%>

				<!--Ambil teks yang terbaru atau yang sudah diproses wrapping-nya-->
		        <%str_holder = rv[1][:]%>
		        <%line_item_print[total_lines_print] = rv[2][:]%>

				<%no_lines = no_lines + 1%>
			    <%total_lines_print = total_lines_print + 1%>
			%endwhile
		%endfor

<!--================================================================== EDITABLE AREA ===============================================================-->

		<!--For testing only: adding dummy line items-->
		<%test_lines = total_lines_print + 0%>
		%for line_number in range(total_lines_print,test_lines):
			<%line_item_print.append([str(line_number+1),'12345678901234567890123456890','B'])%>
		%endfor
		<%total_lines_print = test_lines%>

<!--================================================================================================================================================-->

        <!--B. Menghitung jumlah halaman formulir berdasarkan perhitungan target_lines-->
		<% total_page = total_lines_print / target_lines%>
		%if last_page_footer_lines <= def_footer_lines:
			<!--Footer untuk halaman akhir akan muat, sehingga tidak perlu dibuatkan halaman terakhir tambahan-->
			<%blank_last_page = False%>
			<%compact_page = False%>
			%if math.fmod(total_lines_print, target_lines) > 0:
				<!--Jika terdapat sisa baris,maka sisa baris tersebut akan dicetak dihalaman baru, yaitu halaman terakhir-->
				<%total_page = total_page + 1%>
			%endif
		%else:
			<!--Footer untuk halaman akhir bisa bisa 'memakan' area line items, sehingga mungkin perlu dibuatkan halaman baru-->
			<%compact_page = True%>
			%if math.fmod(total_lines_print, target_lines) == 0:
				<!--Jika tidak terdapat sisa baris,maka footer halaman akhir akan dicetak di halaman baru-->
				<%total_page = total_page + 1%>
				<%blank_last_page = True%>
			%elif (math.fmod(total_lines_print, target_lines) + last_page_footer_lines) > max_lines:
				<!--Jika terdapat sisa baris dan area footer tidak cukup, maka akan ditambahkan 2 halaman baru-->
				<%total_page = total_page + 2%>
				<%blank_last_page = True%>
			%else:
				<%total_page = total_page + 1%>
				<%blank_last_page = False%>
			%endif
		%endif

		<%current_line = 0%>

<!--##################################################################################################################################################
															BAGIAN BODY FOMULIR
####################################################################################################################################################-->

<!--pengaturan body dan tabel formulir-->
<body style="font-size: ${font_size}px; font-family: Sans-Serif; margin: 0px">

		<!--Looping untuk menghasilkan ('render') halaman dari formulir-->
		%for current_page in range (1, total_page+1):
<table style="text-align: left; width: ${page_width}px; margin: 0; padding: 0;" cellpadding="0" cellspacing="0">
    <tbody>
        <tr>
			<!--Blank space untuk area preprinted dari formulir-->
			<td colspan="4" rowspan="1" style="vertical-align: top;">
				<div style="height: ${preprinted_header_space}px;">
                 <h1><center>P.T.PRALON</center></h1>
                </div>
			</td>
            <td style="vertical-align: top; text-align: right; padding-top:15px;">
                <right>${helper.embed_logo_by_name('iso_9001_logo', 22, 49)|n}</right>
            </td>
		</tr>

<!--##################################################################################################################################################
															BAGIAN HEADER LAPORAN
####################################################################################################################################################-->

       <!--Area untuk Nama formulir-->
        <tr>
            <td colspan="6" rowspan="1">
                <div style="height: 30px;">
                <center>
                <table>
                    <tbody>
                        <tr>
                            <td style="align: left; width: 150px;">
                            </td>
                            <td style="vertical-align: top; font-size: 18px; text-decoration: underline; font-weight: bold; font-type: Sans-Serif; font-weight: bold; text-align: center;">
                                <div style="width: 100%;">BON PEMASUKAN
                                </div>
                            </td>
                            <td style="align: left; width: 80px;">
                            </td>
                            <td style="vertical-align: top;"> DARI DEPT :<br>
                                <table class="table_from_dept text-align: right;" cellpadding="2" cellspacing="2">
                                    <tbody>
                                        <tr>
                                            <td class="td_from_dept" height="18">
                                            <br></td>
                                            <td class="td_from_dept" height="18">MGR
                                            </td>
                                            <td class="td_from_dept" height="18">
                                            <br></td>
                                        </tr>
                                        <tr>
                                          <td class="td_from_dept" height="30">
                                          <br></td>
                                          <td class="td_from_dept" height="30">
                                          <br></td>
                                          <td class="td_from_dept" height="30">
                                          <br></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
          	            </tr>
                    </tbody>
                </table>
                </center>
                </div>
            </td>
        </tr>


        <!--Area untuk Nomor dan tanggal formulir-->
        <tr>
            <td colspan="3" rowspan="1">
                <div style="height: 50px;">
                <center>
                <table style="vertical-align: top;">
                    <tbody>
                        <tr>
                            <td style="font-size: ${font_size}px; font-family: Sans-Serif; text-align: center; padding-left: 3px;">
                                <div style="height: 20px;">
                                No. ${ins.name or ''|entity}<br>
	                            Tgl. ${date_order_fmt(ins.date_done)|n}
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
                </center>
                </div>
            </td>
        </tr>

<!--##################################################################################################################################################
													BAGIAN BODY / LINE ITEM LAPORAN (TABEL ITEM)
####################################################################################################################################################-->

        <!--Area untuk pencetakan line item-->
        <tr>
    		<td colspan="6" rowspan="1">
		%if current_page == total_page:
				<!--div untuk mendorong sisa footer sehingga page number bisa tetap di akhir halaman (untuk last page)-->
				<div style="height: 120px;">
				<table class="table" cellspacing="0" cellpadding="0">
		%else:
				<!--div Untuk mendorong sisa footer sehingga page number bisa tetap di akhir halaman-->
				<div style="height: 120px;">
				<table class="table" cellspacing="0" cellpadding="0">
		%endif
				<tbody>
				    <tr>
                        <td>
       		                <table class="table" cellpadding="2">
                                <tbody>
                                    <tr height="10px">
                                        <td style="width: 80%;" class="table_border">${_("Nama Barang")|entity} </td>
                                        <td style="width: 12%;" class="table_border">${_("Banyaknya")|entity} </td>
                                        <td style="width: 8%;" class="table_border">${_("Satuan")|entity} </td>
                                    </tr>

                <!--tampilan detail item body-->

			    %if compact_page and (current_page == total_page):
				    <%last_line = current_line + (max_lines - last_page_footer_lines)%>
			    %else:
				    <%last_line = current_line + target_lines%>
			    %endif

			    %for line_no in range (current_line,last_line):
				    %if line_no < total_lines_print:

                                <!--Cetak line item yang telah diproses dari dokumen yang dimaksud-->
                                    <tr>
                                        <td class="table_line" style="text-align: left; height:${line_item_height}px; padding-left:4px;">
		                                ${line_item_print[line_no][0]}
		                                </td>
                                        <td class="table_line" style="text-align: right; height:${line_item_height}px; padding-right:4px;">
                                        ${line_item_print[line_no][1]}
		                                </td>
                                        <td class="table_line" style="text-align: center; height:${line_item_height}px;">
		                                ${line_item_print[line_no][2]}
		                                </td>
                                    </tr>
                    %else:
                                    <!--Cetak baris line item 'kosong', untuk mem-fill sisa tabel line item-->
          		                    <tr>
                                        <td class="table_line" style="text-align: left; height:${line_item_height}px;">
                		                </td>
                                        <td class="table_line" style="text-align: right; height:${line_item_height}px;">
                		                </td>
                                        <td class="table_line" style="text-align: center; height:${line_item_height}px;">
                		                </td>
          		                    </tr>
                    %endif
			    %endfor

			    <%current_line = last_line%>
        					    </tbody>
     						</table>
      					</td>
					</tr>

<!--##################################################################################################################################################
													BAGIAN FOOTER LAPORAN (NAMA PARTNER, NO PR, NOTE)
####################################################################################################################################################-->

                    <!--Cetak No. PR -->
                    <tr>
                        <td colspan="5" rowspan="1" style="font-size: 10px;">
                            ${ins.purchase_id and ins.purchase_id.requisition_id and ins.purchase_id.requisition_id.name or ''| entity}
                        </td>
                        <td style="vertical-align: top;">
                        </td>
                        <td style="vertical-align: top;">
                        </td>
                    </tr>

                    <!--Cetak Nama Partner-->
                    <tr>
                        <td colspan="5" rowspan="1" style="font-size: 10px; width: 100%">
                            <div style="height: 3px; border: 1px solid white;">
                            di Terima dari:&nbsp;${ins.purchase_id and ins.purchase_id.partner_id and ins.purchase_id.partner_id.name or ins.partner_id.name or ''| entity}
                            </div>
                        </td>
                        <td style="vertical-align: top;">
                        </td>
                        <td style="vertical-align: top;">
                        </td>
                    </tr>

                    <!-- Area cetak keterangan-->
                    <tr>
                        <td colspan="3" rowspan="1" style="width: 100%">
                            <div style="height: 55px; border: 1px solid white;">
                          	<p class="diva"><b>KETERANGAN :</b> ${ins.note and ins.note[0:450] or ''|entity}</p>
                            </div>
                        </td>
                    </tr>

                    <!--Area tampilan no halaman-->
                    <tr>
			            %if current_page != total_page:
			            <td style="text-align: right; vertical-align: bottom; width: 100%;">
				        page ${current_page} of ${total_page}
			            </td>
			            %else:
			            <td style="text-align: right; vertical-align: bottom; width: 100%;">
				        page ${current_page} of ${total_page}
			            </td>
			            %endif
		            </tr>
    </tbody>
</table>

                        %if current_page < total_page:
			                <p style="page-break-after:always; margin: 0px;"></p>
			            %endif
		%endfor

</body>

		<!-- Tambahkan page break kecuali untuk dokumen terakhir-->
		%if total_document > 1:
		<p style="page-break-after:always; margin: 0px;"></p>
			<%total_document = total_document - 1 %>
		%endif
    %endif
%endfor

<!--##################################################################################################################################################
																WRONG STATE STATEMENT
####################################################################################################################################################-->

%if wrong_document_state:
<p style="page-break-after:always; margin: 0px;"></p>
<small>
<br/><br/><br/>
<b>Dokumen-dokumen ini tidak dicetak karena statusnya:</b><br/>
${', '.join(wrong_document_state)}
</small>
%endif
</html>
