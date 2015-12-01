<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>

<!-##############################################################################################################################################
															CSS STYLE AND STATEMENTS
##################################################################################################################################################-->

<head>

<style type="text/css">
.table {
    width: 100%;
    margin: 0px;
    padding: 0px;
    border-spacing: 0px;
    border-collapse: collapse;
}
.table_border {
    border: 1px solid black;
    font-weight: bold;
    padding-right: 3px;
    text-align: center;
    border-spacing: 0px;
    height: 20px;
}
.table_line {
    border: 1px solid black;
    border-collapse: collapse;
    text-align: center;
}

</style>

</head>

<!--################################################################################################################################################
								    							 DEKLARASI VARIABEL
####################################################################################################################################################-->
<%import math %>
<%import re%>

<%wrong_document_state = [] %>		                <!--Dipakai untuk menyimpan daftar dan status dari dokumen-dokumen yang tidak akan dicetak (status invalid)-->
<%total_document = len(objects)%>	                <!--Dipakai untuk mencek jumlah dokumen-dokumen yang akan dicetak-->

<!--KONFIGURASI untuk menentukan jumlah baris dari line item yang ingin dicetak setiap halamannya-->
<!--Variabel berikut menentukan atau mengikuti 'layout' dari halaman kertas, sehingga menandakan batasan atau limit kertas-->
<%max_lines = 10%>									<!--Jumlah baris maksimum untuk line item s/d akhir halaman-->
<%def_footer_lines = 5%>							<!--Jumlah pemakaian baris untuk footer yang akan dicetak setiap halamannya-->
<%last_page_footer_lines = 5%>						<!--Jumlah pemakaian baris untuk footer yang akan dicetak khusus untuk halaman akhir-->
<%target_lines = max_lines - def_footer_lines%>		<!--Jumlah line item yang akan dicetak setiap halamannya-->

<!--KONFIGURASI untuk menentukan jumlah dan spesifikasi dari kolom untuk setiap baris line item yang akan dicetak-->
<%line_item_columns=5%>								<!--Jumlah kolom dari setiap baris line item yang dicetak-->
<%column_width_in_chars=[11,256,64,20,20]%>			<!--Lebar masing-masing kolom line item dalam jumlah huruf/karakter-->
<%max_wrap_lines=3%>								<!--Maksimum jumlah baris yang dibentuk untuk teks yang wrapping, sisa teks yang tidak 'muat' di'buang'-->
													<!--Nilai satu berarti tidak akan ada wrapping, sehingga semua teks untuk kolom akan di'truncate'-->

<!--KONFIGURASI untuk menentukan layout HTML dari formulir-->
<%top_alignment_space = 3%>						    <!--'Quick fix' untuk menyamakan alignment 'top' margin antara halaman pertama dan yang lainnya-->
<%line_item_height = 55%>							<!--Tinggi dari setiap line item yang dicetak-->
<%font_size = 13%>									<!--Ukuran tulisan yang digunakan secara umum, dapat di-override apabila font-size juga ditentukan pada setiap tr atau td-->
<%page_width = 793%>								<!--Lebar formulir yang umum digunakan sebagai lebar tabel utama-->

<!--Proses semua dokumen satu per satu-->
%for vcr in objects :

    <!--Menentukan kondisi status object untuk data yang dicetak-->
    %if vcr.state not in ('draft', 'posted'):
		<!--Seluruh dokumen yang statusnya invalid akan di'catat' untuk kemudian diinfokan ke pengguna-->
    	<% wrong_document_state.append('%s: %s' % (vcr.name, vcr.state)) %>
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
		<%total_items = len(vcr.line_id)%>

		<!--Siapkan variabel 'penyimpanan'-->
		<%line_item_print=[]%>		<!--Tempat untuk menyimpan semua teks dari produk atau 'line item' yang telah di proses mengikuti konfigurasi kolom-->
		<%total_lines_print=0%>		<!--Jumlah baris yang harus dicetak-->

<!--################################################################################################################################################
								    					     PRE-PROCESSING LOGIC LINE ITEM
####################################################################################################################################################-->

		<!--Proses semua produk di dalam dokumen yang dimaksud-->
		%for item_no in range(0, total_items):
			<!--Ambil atau proses produk atau 'line item'nya-->
			<%item = vcr.line_id[item_no]%>

<!--================================================================== EDITABLE AREA ===============================================================-->

			<!--Tempat sementara untuk menyimpan data setiap produk atau 'line item'-->
			<%str_holder=[]%>
			<!--Proses seluruh kolom menjadi satu list-->
			<!--Kolom 1: kode akun-->
            <%str_holder.append(item.account_id and item.account_id.code or '')%>
			<!--Kolom 2: Nama akun-->
			<%str_holder.append(item.account_id and item.account_id.name or '')%>
			<!--Kolom 3: description-->
			<%str_holder.append(item.name or '')%>
			<!--Kolom 4: posisi debit-->
            <%str_holder.append(item.debit and formatLang(item.debit, digits=0) or '')%>
			<!--Kolom 5: posisi credit-->
            <%str_holder.append(item.credit and formatLang(item.credit, digits=0) or '')%>
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
			<%line_item_print.append(['12345678901234567890123456890','B','C','D','E'])%>
		%endfor>
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
		%for current_page in range(1, total_page+1):
<table style="text-align: left; width: ${page_width}px; margin: 0; padding: 0;" cellpadding="0" cellspacing="0">
    <tbody>
	    <tr>
	        <!--'Quick fix' untuk menyamakan alignment 'top' margin antara halaman pertama dan yang lainnya-->
    		%if current_page > 1:
			<div style="height: ${top_alignment_space}px; width: ${page_width}px;"></div>
			%endif
		</tr>

        <tr>
			<!--Blank space untuk area preprinted dari formulir-->
            <td style="width: 435px;">
                <div style="height: 113px; "></div>
            </td>
			<td style="width: 185px; vertical-align: bottom;">
                <table style="align: left;">
                    <tbody>
                        <tr height="26px">
                            <td style="width: 45px;">
                            </td>
                            <td style="width 170px; vertical-align: top; border: 1px solid white;">
                            ${vcr.state=="posted" and vcr.name or vcr.id or ''|entity}
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 45px;">
                            </td>
                            <td style="width 170px; vertical-align: top;">
                            ${date_order_fmt(vcr.date)|n}
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
			</td>
            <td style="width: 113px;">
            </td>
		</tr>

        <tr>
    		<td colspan="6" rowspan="1">
                <div style="height: 20px;"></div>
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
				<div style="height: 345px;">
				<table class="table" cellspacing="0" cellpadding="0">
		%else:
				<!--div Untuk mendorong sisa footer sehingga page number bisa tetap di akhir halaman-->
				<div style="height: 345px;">
				<table class="table" cellspacing="0" cellpadding="0">
		%endif
				<tbody>
				    <tr>
                        <td>
       		                <table class="table" cellpadding="2">
                                <tbody>
                                    <tr height="1px">
                                        <td style="width: 30%;" class="table_border" colspan="2">${_("ACCOUNT NAME")|entity} </td>
                                        <td style="width: 35%;" class="table_border">${_("DESCRIPTION")|entity} </td>
                                        <td style="width: 15%;" class="table_border">${_("DEBIT (Rp)")|entity} </td>
                                        <td style="width: 15%;" class="table_border">${_("CREDIT (Rp)")|entity} </td>
                                    </tr>

                <!--tampilan detail item body-->

			    <!--Menentukan-->
			    %if compact_page and (current_page == total_page):
				    <%last_line = current_line + (max_lines - last_page_footer_lines)%>
			    %else:
				    <%last_line = current_line + target_lines%>
			    %endif

			    %for line_no in range (current_line,last_line):
				    %if line_no < total_lines_print:

                                <!--Cetak line item yang telah diproses dari dokumen yang dimaksud-->
                                    <tr>
                                        <td class="table_line" style="text-align: center; height:${line_item_height}px;">
                                            <div style="width: 75px;">
		                                    ${line_item_print[line_no][0]}
                                            </div>
		                                </td>
                                        <td class="table_line" style="text-align: left; height:${line_item_height}px;">
                                            <div style="width: 230px;">
                                            ${line_item_print[line_no][1]}
                                            </div>
		                                </td>
                                        <td class="table_line" style="text-align: left; height:${line_item_height}px;">
                                            <div style="width: 215px; ">
                                            ${line_item_print[line_no][2]}
                                            </div>
		                                </td>
                                        <td class="table_line" style="text-align: right; height:${line_item_height}px;">
                                            <div style="width: 115px;">
		                                    ${line_item_print[line_no][3]}
                                            </div>
		                                </td>
                                        <td class="table_line" style="text-align: right; height:${line_item_height}px;">
                                            <div style="width: 115px;">
		                                    ${line_item_print[line_no][4]}
                                            </div>
		                                </td>
                                    </tr>
                    %else:
                                    <!--Cetak baris line item 'kosong', untuk mem-fill sisa tabel line item-->
          		                    <tr>
                                        <td class="table_line" style="height:${line_item_height}px;">
		                                </td>
                                        <td class="table_line" style="height:${line_item_height}px;">
		                                </td>
                                        <td class="table_line" style="height:${line_item_height}px;">
		                                </td>
                                        <td class="table_line" style="height:${line_item_height}px;">
		                                </td>
                                        <td class="table_line" style="height:${line_item_height}px;">
		                                </td>

          		                    </tr>
                    %endif
			    %endfor

			    <%current_line = last_line%>
        					    </tbody>
     						</table>
      					</td>
					</tr>
                </tbody>
                </table>
                </div>
            </td>
        </tr>

<!--##################################################################################################################################################
													BAGIAN FOOTER LAPORAN (PAGE NUMBER)
####################################################################################################################################################-->
                    <!--Area tampilan no halaman-->
                    <tr>
			            %if current_page != total_page:
			            <td  colspan="6" rowspan="1" style="text-align: right; vertical-align: bottom;">
				        page ${current_page} of ${total_page}
			            </td>
			            %else:
			            <td  colspan="6" rowspan="1" style="text-align: right; vertical-align: bottom;">
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
<p style="page-break-after:always; margin: 0px"></p>
<small>
<br/><br/><br/>
<b>Dokumen-dokumen ini tidak dicetak karena statusnya:</b><br/>
${', '.join(wrong_document_state)}
</small>
%endif

</body>

</html>
