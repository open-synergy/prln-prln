<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>

<!--
##############################################################################################################################################
															CSS STYLE AND STATEMENTS
##############################################################################################################################################
-->

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
	font-weight: bold;
	font-size: 15px;
	padding-right: 3px;
	text-align: center;
	border-spacing: 0px;
}

.strikethrough {
	color: black;
	text-decoration:line-through;
}
.invis {
	color: white;
    font-size: 13px;

}
</style>

</head>

<!--
################################################################################################################################################
								    							 DEKLARASI VARIABEL
################################################################################################################################################
-->
<%import math %>
<%import re%>

<%wrong_document_state = [] %>		                <!--Dipakai untuk menyimpan daftar dan status dari dokumen-dokumen yang tidak akan dicetak (status invalid)-->
<%total_document = len(objects)%>	                <!--Dipakai untuk mencek jumlah dokumen-dokumen yang akan dicetak-->

<!--KONFIGURASI untuk menentukan jumlah baris dari line item yang ingin dicetak setiap halamannya-->
<!--Variabel berikut menentukan atau mengikuti 'layout' dari halaman kertas, sehingga menandakan batasan atau limit kertas-->
<%max_lines = 18%>									<!--Jumlah baris maksimum untuk line item s/d akhir halaman-->
<%def_footer_lines = 3%>							<!--Jumlah pemakaian baris untuk footer yang akan dicetak setiap halamannya-->
<%last_page_footer_lines = 3%>						<!--Jumlah pemakaian baris untuk footer yang akan dicetak khusus untuk halaman akhir-->
<%target_lines = max_lines - def_footer_lines%>		<!--Jumlah line item yang akan dicetak setiap halamannya-->

<!--KONFIGURASI untuk menentukan jumlah dan spesifikasi dari kolom untuk setiap baris line item yang akan dicetak-->
<%line_item_columns=8%>								<!--Jumlah kolom dari setiap baris line item yang dicetak-->
<%column_width_in_chars=[3,70,7,6,3,15,3,16]%>		<!--Lebar masing-masing kolom line item dalam jumlah huruf/karakter-->
<%max_wrap_lines=3%>								<!--Maksimum jumlah baris yang dibentuk untuk teks yang wrapping, sisa teks yang tidak 'muat' di'buang'-->
													<!--Nilai satu berarti tidak akan ada wrapping, sehingga semua teks untuk kolom akan di'truncate'-->

<!--HA:KONFIGURASI untuk menentukan running total untuk setiap halaman-->
<%show_line_item_cum_sum_by_page=True%>			    <!--Hitung jumlah total per 'halaman' yang dicetak-->

<!--KONFIGURASI untuk menentukan layout HTML dari formulir-->
<%line_item_height = 15%>							<!--Tinggi dari setiap line item yang dicetak-->
<%font_size = 13%>									<!--Ukuran font yang dicetak-->
<%page_width = 813%>								<!--Lebar formulir yang umum digunakan sebagai lebar tabel utama-->


<!--Proses semua dokumen satu per satu-->
%for tax in objects :

	<!--Menentukan kondisi status object untuk data yang dicetak-->
	%if tax.state != 'draft' and tax.state != 'printed':
		<!--Seluruh dokumen yang statusnya invalid akan di'catat' untuk kemudian diinfokan ke pengguna-->
		<% wrong_document_state.append('%s: %s' % (tax.taxform_id, tax.state)) %>
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
		<%total_products = len(tax.taxform_line)%>

		<!--Siapkan variabel 'penyimpanan'-->
		<%line_item_print=[]%>	    	<!--Tempat untuk menyimpan semua teks dari produk atau 'line item' yang telah di proses mengikuti konfigurasi kolom-->
		<%total_lines_print=0%>		    <!--Jumlah baris yang harus dicetak-->
        <%line_item_sum_by_page=[]%>    <!--Jumlah atau total dari seluruh line item untuk setiap halamannya-->
        <%line_item_to_sum=[]%>         <!--HA:List dari seluruh nilai line item yang akan/dapat dijumlah-->

<!--################################################################################################################################################
								    					     PRE-PROCESSING LOGIC LINE ITEM
####################################################################################################################################################-->

		<!--Proses semua produk di dalam dokumen yang dimaksud-->
		%for prod_no in range (0,total_products):
			<!--Ambil atau proses produk atau 'line item'nya-->
			<%prod = tax.taxform_line[prod_no]%>

<!--================================================================== EDITABLE AREA ===============================================================-->

			<!--Tempat sementara untuk menyimpan data setiap produk atau 'line item'-->
			<%str_holder=[]%>
			<!--Proses seluruh kolom menjadi satu list-->
			<!--Kolom 1: no urut produk-->
			<%str_holder.append(str(prod_no+1))%>
			<!--Kolom 2: nama produk-->
			<!--Buang kode produk (substitusikan seluruh teks dari awal s/d tanda ']' dengan empty string)-->
			<%prod_line_desc = re.sub(r'.*]', "", (prod.product_id and prod.product_id.name) or prod.name or '')%>
			<%str_holder.append(prod_line_desc)%>
			<!--Kolom 3: jumlah/kuantitas produk-->
			<%str_holder.append(formatLang(prod.quantity, digits=0))%>
			<!--Kolom 4: satuan unit (UOM) produk-->
			<%str_holder.append(prod.uom or '')%>
            <!--Kolom 5: Satuan unit price-->
			<%str_holder.append("Rp.")%>
			<!--Kolom 6: harga satuan produk-->
			<% subtotal = (prod.price_subtotal * 100.0) / (100.0-(prod.discount or 0.0))%>
                %if prod.quantity != 0:
			        <% price_unit = (subtotal or 0.00) / (prod.quantity or 0.00)%>
                %else:
                    <% price_unit = 0%>
                %endif
			<%str_holder.append(formatLang(price_unit))%>
            <!--Kolom 7: Satuan harga jual-->
			<%str_holder.append("Rp.")%>
			<!--Kolom 8: harga jual produk-->
			<%str_holder.append(formatLang(subtotal, digits=0))%>
            <!--HA:Setiap nilai atau kolom yang akan dicari running totalnya disimpan ke dalam list ini-->
            <%line_item_to_sum.append(subtotal)%>

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
		<!--%test_lines = total_lines_print + 50%-->
		<!--%for line_number in range(total_lines_print,test_lines):-->
			<!--%line_item_print.append([str(line_number+1),'12345678901234567890123456890','B','C','D','E','F','1000'])%-->
            <!--%line_item_to_sum.append(1000)%-->
		<!--%endfor-->
		<!--%total_lines_print = test_lines%-->

<!--================================================================================================================================================-->

		<!--B. Menghitung jumlah halaman formulir berdasarkan perhitungan target_lines-->
		<%total_page = total_lines_print / target_lines%>
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
															BAGIAN PRE-PRINTED LAPORAN (LOGO)
####################################################################################################################################################-->

<!--pengaturan body dan tabel formulir-->
<body style="font-size: ${font_size}px; font-family: Sans-Serif; margin: 0px;">

    <!--Looping untuk menghasilkan ('render') halaman dari formulir-->
	%for current_page in range (1, total_page+1):
<center><h2 style="width: ${page_width}px; font-size: 20px; margin: 2px; padding: 2px;"></h2></center>

<table style="text-align: left; width: ${page_width}px; height: 925px; margin: 0; padding: 0; border-right: 1px solid white; border-left: 1px solid white; border-top: 1px solid white; border-bottom: 1px solid white; border-collapse:collapse;" cellpadding="0" cellspacing="0">
	<tbody>

<!--##################################################################################################################################################
															BAGIAN HEADER LAPORAN (INFO PARTNER)
####################################################################################################################################################-->

        <!--Area Kode dan Nomor seri faktur pajak-->
        <tr height="28px">
            <td style="border-bottom: 1px solid white; border-top: 1px solid white; border-right: 1px solid white; width: ${page_width}px;" colspan="7">
                <table>
                    <tr>
                        <td style="vertical-align: top; width: 283px;"></td>
                        <td style="vertical-align: top; width: 2px;"></td>
                        <td style="vertical-align: top;">${tax.trx_code or ''}.${tax.branch_code or ''}-${tax.taxform_id or ''}</td>
                    </tr>
                </table>
            </td>
        </tr>

        <!--Area pengusaha kena pajak-->
        <tr height="28px">
            <td style="border-bottom: 1px solid white; border-top: 1px solid white; border-right: 1px solid white; width: ${page_width}px;" colspan="7">
                <table>
                    <tr>
                        <td style="vertical-align: top;" colspan="3"><b></b></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr height="86px">
            <td style="border-bottom: 1px solid white; border-top: 1px solid white; border-right: 1px solid white; width: ${page_width}px;" colspan="7">
                <table>
                    <tr>
                        <td style="vertical-align: top; width: 283px;"></td>
                        <td style="vertical-align: top; width: 5px;"></td>
                        <td style="vertical-align: top;"><b>${tax.company_id and tax.company_id.name or ''}</b>
                        </td>
                    </tr>
                    <tr>
                        <td style="vertical-align: top;"></td>
                        <td style="vertical-align: top; width: 5px;"></td>
                        <td style="vertical-align: top;">
                        % if tax.company_address_id:
		                    ${tax.company_address_id.street or ''}
		                    ${tax.company_address_id.street2 or ''}<br/>
		                    ${tax.company_address_id.zip or ''}
		                    ${tax.company_address_id.city or ''}
		                    ${tax.company_address_id.state_id and tax.company_address_id.state_id.name or ''}
		                % endif
                        </td>
                    </tr>
                    <tr>
                        <td style="vertical-align: top;"></td>
                        <td style="vertical-align: top; width: 5px;"></td>
                        <td style="vertical-align: top;"> ${tax.company_id and tax.company_id.vat or ''}
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <!--Area info partner-->
        <tr height="28px">
            <td style="border-bottom: 1px solid white; border-top: 1px solid white; border-right: 1px solid white; width: ${page_width}px;" colspan="7">
                <table>
                    <tr>
                        <td style="vertical-align: top;" colspan="7"></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr height="86px">
            <td style="width: ${page_width}px; border: 1px solid white;" colspan="7">
                <table>
                    <tr>
                        <td style="vertical-align: top; width: 283px;"></td>
                        <td style="vertical-align: top; width: 5px;"></td>
                        <td style="vertical-align: top;"> <b>${tax.partner_id and tax.partner_id.name or ''}</b>
                        </td>
                    </tr>
                    <tr>
                        <td style="vertical-align: top;"></td>
                        <td style="vertical-align: top; width: 5px;"></td>
                        <td style="vertical-align: top;">
                        % if tax.partner_address_id:
	                        ${tax.partner_address_id.street or ''}
	                        ${tax.partner_address_id.street2 or ''}<br/>
	                        ${tax.partner_address_id.zip or ''}
	                        ${tax.partner_address_id.city or ''}
	                        ${tax.partner_address_id.state_id and tax.partner_address_id.state_id.name or ''}
	                    % endif
                        </td>
                    </tr>
                    <tr>
                        <td style="vertical-align: top;"></td>
                        <td style="vertical-align: top;width: 5px;"></td>
                        <td style="vertical-align: top;"> ${tax.partner_npwp and tax.partner_npwp.value or ''}
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

<!--##################################################################################################################################################
													BAGIAN BODY / LINE ITEM LAPORAN (TABEL ITEM)
####################################################################################################################################################-->

        <!--Area untuk pencetakan line item-->
        <tr>
            <td colspan="7" rowspan="1" style="vertical-align: top; border-right: 1px solid white;">
            %if current_page == total_page:
                <!--div untuk mendorong sisa footer sehingga page number bisa tetap di akhir halaman (untuk last page)-->
                <div style="height: 395px;">
                <table class="table" cellspacing="0" cellpadding="0">
            %else:
                <!--div Untuk mendorong sisa footer sehingga page number bisa tetap di akhir halaman-->
				<div style="height: 395px;">
                <table class="table" cellspacing="0" cellpadding="0">
            %endif
                <tbody>
                    <tr>
					    <td colspan="15">
   						    <table class="table" cellpadding="3">
        					<tbody>
                                <!--Cetak header dari area line item -->
                                <tr>
                                    <td style="width: 5%; font-family: Sans-Serif; border-top: 1px solid white; border-right: 1px solid white; border-bottom: 1px solid white; font-weight: bold; font-size: 15px; padding-right: 3px; text-align: center; border-spacing: 0px;"><br>
                                    </td>
                                    <td style="width: 50%; font-family: Sans-Serif; font-weight: bold; font-size: 15px;" class="table_border" colspan="3"><br>
                                    </td>
                                    <td style="width: 35%; font-family: Sans-Serif; border-top: 1px solid white; border-bottom: 1px solid white; font-weight: bold; font-size: 15px; padding-right: 3px; text-align: center; border-spacing: 0px;" colspan="4"><br>
                                    </td>
                                </tr>

                <!--tampilan detail item body-->

			    <!--Menentukan-->
			    %if compact_page and (current_page == total_page):
				    <%last_line = current_line + (max_lines - last_page_footer_lines)%>
			    %else:
				    <%last_line = current_line + target_lines%>
			    %endif

                <!--HA:Tambahkan running total untuk halaman yang akan diproses ini-->
                <%line_item_sum_by_page.append(0)%>
                %if show_line_item_cum_sum_by_page and (current_page > 1):
                    <%line_item_sum_by_page[current_page-1] = line_item_sum_by_page[current_page-2]%>
                %endif

			    %for line_no in range (current_line,last_line):
				    %if line_no < total_lines_print:

                        <!--HA:Penghitungan running total untuk halaman yang diproses-->
                        <!--Jika no urut bukan nol (0), maka diasumsikan item dengan nomor urut tersebut (di kurangi 1 karena 0 indexing)-->
                        <!--akan dirunning totalkan-->
                        %if line_item_print[line_no][0] != '':
                            <%line_item_sum_by_page[current_page-1] = line_item_sum_by_page[current_page-1] + line_item_to_sum[int(line_item_print[line_no][0])-1]%>
                        %endif

                                <!--Cetak line item yang telah diproses dari dokumen yang dimaksud-->
                                <tr>
                                    <td style="text-align: center; height:${line_item_height}px; border-right: 1px solid white;">
                                        ${line_item_print[line_no][0]}
                                    </td>
                                    <td style="text-align: left; height:${line_item_height}px;">
                                        <div style="width: 375px;">
                                        ${line_item_print[line_no][1]}
                                        </div>
                                    </td>
                                    <td style="text-align: right; height:${line_item_height}px;">
                                        <div style="width: 50px;">
                                        ${line_item_print[line_no][2]}
                                        </div>
                                    </td>
                                    <td style="text-align: left; height:${line_item_height}px; border-right: 1px solid white;">
                                        <div style="width: 40px;">
                                        ${line_item_print[line_no][3]}
                                        </div>
                                    </td>
                                    <td style="text-align: left; padding-left: 4px; height:${line_item_height}px;">
                                        <div style="width: 20px;">
                                        ${line_item_print[line_no][4]}
                                        </div>
                                    </td>
                                    <td style="height:${line_item_height}px;">
                                        <div style="width: 90px; text-align: right;">
                                        ${line_item_print[line_no][5]}
                                        </div>
                                    </td>
                                    <td style="text-align: left; height:${line_item_height}px;">
                                        <div style="width: 20px;">
                                        ${line_item_print[line_no][6]}
                                        </div>
                                    </td>
                                    <td style="padding-right: 2px; height:${line_item_height}px;">
                                        <div style="width: 120px; text-align: right">
                                        ${line_item_print[line_no][7]}
                                        </div>
                                    </td>
                                </tr>
                        <% disc = (subtotal * prod.discount) / 100 %>
                    %else:
                                <!--Cetak baris line item 'kosong', untuk mem-fill sisa tabel line item-->
	          					<tr>
                                    <td style="text-align: center; height:${line_item_height}px; border-right: 1px solid white;">
                                    </td>
                                    <td style="text-align: left; height:${line_item_height}px;">
                                    </td>
                                    <td style="text-align: right; height:${line_item_height}px;">
                                    </td>
                                    <td style="text-align: left; height:${line_item_height}px; border-right: 1px solid white;">
                                    </td>
                                    <td style="text-align: left; padding-left: 4px; height:${line_item_height}px;">
                                    </td>
                                    <td style="height:${line_item_height}px;">
                                    </td>
                                    <td style="text-align: left; height:${line_item_height}px;">
                                    </td>
                                    <td style="padding-right: 2px; height:${line_item_height}px;">
                                    </td>
								</tr>
                    %endif
			    %endfor

			        <%current_line = last_line%>
								<!--Cetak baris kosong di bagian bawah tabel line item (ini adalah filler)-->
								<tr>
                                    <td style="width: 5%; border-right: 1px solid white;">
                                    </td>
                                    <td style="width: 50%; border-right: 1px solid white;" colspan="3">
                                    </td>
                                    <td style="width: 35%;" colspan="4">
                                    </td>
	         					</tr>
        					</tbody>
     						</table>
      					</td>
					</tr>
<!--##################################################################################################################################################
													BAGIAN FOOTER LAPORAN (SIGNATURE, TOTAL)
####################################################################################################################################################-->
                    <!--Area Harga Jual/Penggantian/Uang Muka/Termin-->
                    <tr>
                        <td colspan="7" rowspan="1" style="height:25px; padding-left: 4px; vertical-align: middle; border-right: 1px solid white; border-top: 1px solid white; border-bottom: 1px solid white;">
                            <div style="width: 510px;">
                               %if tax.trx_type == "hargajual":
                                    <span class="invis">Harga Jual</span><span class="strikethrough"><span class="invis">/Penggantian/Uang Muka/Termin</span></span>
                                %elif tax.trx_type == "penggantian":
                                    <span class="strikethrough"><span class="invis">Harga Jual/</span></span><span class="invis">Penggantian</span><span class="strikethrough"><span class="invis">/Uang Muka/Termin</span></span>
                                %elif tax.trx_type == "uangmuka":
                                    <span class="strikethrough"><span class="invis">Harga Jual/Penggantian/</span></span><span class="invis">Uang Muka</span><span class="strikethrough"><span class="invis">/Termin</span></span>
                                %elif tax.trx_type == "termin":
                                    <span class="strikethrough"><span class="invis">Harga Jual/Penggantian/Uang Muka/</span></span><span class="invis">Termin</span>
                                %else:
                                    <span class="invis">Harga Jual/Penggantian/Uang Muka/Termin</span>
                                %endif
                            </div>
                        </td>
                        <td style="border-bottom: 1px solid white; border-top: 1px solid white; vertical-align: middle;">
                            <div style="width: 120px; text-align: right; padding-right: 6px;">
                            %if current_page == total_page:
                                ${"&nbsp;&nbsp;&nbsp;"}
                            %else:
                                ${"Dipindahkan"}
                            %endif
                            </div>
                        </td>
                        <td style="border-bottom: 1px solid white; border-top: 1px solid white;">
                            <div style="width: 35px;">Rp.</div>
                        </td>
                        <td style="vertical-align: middle; text-align: right; padding-right: 4px; border-top: 1px solid white; border-bottom: 1px solid white;">
                            <div style="width: 110px;  text-align: right">
                            %if current_page == total_page:
                                ${formatLang(sum_subtotal(tax.taxform_line), digits=0)}
                            %else:
                                ${formatLang(line_item_sum_by_page[current_page-1],digits=0)}
                            %endif
                            </div>
                        </td>
                    </tr>

                    <!--Area Potongan Harga-->
                    <tr>
                        <td colspan="7" rowspan="1" style="height:25px; padding-left: 4px; vertical-align: middle; border-right: 1px solid white; border-top: 1px solid white; border-bottom:1px solid white;">
                        </td>
                        <td style="border-bottom: 1px solid white; border-top: 1px solid white; vertical-align: top; text-align:left;">
                        </td>
                        <td style="border-bottom: 1px solid white; text-align: left;">Rp.
                        </td>
                        <td style="vertical-align: middle; text-align: right; padding-right: 8px; border-top: 1px solid white; border-bottom: 1px solid white; text-align: right;">
                        %if current_page == total_page:
                            ${formatLang(sum_discount(tax.taxform_line), digits=0)}
                        %endif
                        </td>
                    </tr>

                    <!-- Area Uang Muka-->
                    <tr>
                        <td colspan="7" rowspan="1" style="height:25px; padding-left: 4px; vertical-align: middle; border-right: 1px solid white; border-top: 1px solid white; border-bottom: 1px solid white;">
                        </td>
                        <td style="border-bottom: 1px solid white; border-top: 1px solid white; vertical-align: top; text-align:left;">
                        </td>
                        <td style="border-bottom: 1px solid white; text-align: left;">Rp.
                        </td>
                        <td style="vertical-align: middle; text-align: right; padding-right: 8px; border-top: 1px solid white; border-bottom: 1px solid white; text-align: right;">
                        %if current_page == total_page:
                            ${formatLang(abs(tax.amount_advance_payment), digits=0)}
                        %endif
                        </td>
                    </tr>

                    <!--Area DPP-->
                    <tr>
                        <td colspan="7" rowspan="1" style="height:25px; padding-left: 4px; vertical-align: middle; border-right:1px solid white;border-top:1px solid white;">
                        </td>
                        <td style="border-bottom: 1px solid white; border-top: 1px solid white; vertical-align: top; text-align:left;">
                        </td>
                        <td style="border-bottom: 1px solid white; text-align: left;">Rp.
                        </td>
                        <td style="vertical-align: middle; text-align: right; padding-right: 8px; border-top: 1px solid white; border-bottom: 1px solid white; text-align: right;">
                        %if current_page == total_page:
                            ${formatLang(get_base(tax.taxform_line) - abs(tax.amount_advance_payment), digits=0)}
                        %endif
                        </td>
                    </tr>

                   <!--Area ppn-->
                   <tr>
                        <td colspan="7" rowspan="1" style="height:25px; padding-left: 4px; vertical-align: middle; border-bottom: 1px solid white; border-right: 1px solid white; border-top: 1px solid white;">
                        </td>
                        <td style="border-bottom: 1px solid white; border-top: 1px solid white; vertical-align: top; text-align:left;">
                        </td>
                        <td style="border-bottom: 1px solid white; text-align: left;">Rp.
                        </td>
                        <td style="vertical-align: middle; text-align: right; padding-right: 8px; border-top: 1px solid white; border-bottom: 1px solid white; text-align: right;">
                        %if current_page == total_page:
                            ${formatLang(get_ppn(tax.taxform_line, tax.amount_advance_payment), digits=0)}
                        %endif
                        </td>
                   </tr>
        		</tbody>
     		    </table>
                </div>
            </td>
        </tr>

        <!--Area Ppn BM-->
        <tr>
            <td style="vertical-align: middle; width: 140px; height:20px; text-align: left; padding-left: 6px;" colspan="3">
                <div style="height: 25px;">
                </div>
            </td>
            <td style="width:88px; text-align: right; border-bottom:1px dashed;">
                <div style="height: 18px; width: 75px;">
                %if tax.company_address_id and tax.company_address_id.city:
                    ${tax.company_address_id.city}
                %else:
                	Tanggal,
                %endif
                </div>
            </td>
            <td style="width: 50px; text-align:left; border-bottom:1px dashed;">
                <div style="height: 18px; width: 70px;">

                </div>
            </td>
            <%inv_date = date_order_fmt(tax.invoice_date or '') %>
            <td style="width: 135px; text-align: center; padding-right: 2px;  border-bottom:1px dashed;" >
                <div style="height: 18px;">
                ${inv_date}
                </div>
            </td>
            <td style="width: 30px; border-right: 1px solid white;">
            </td>
        </tr>
        <tr>
            <td style="vertical-align: top; border-right: 1px solid white;" colspan="7">
                <div style="height: 28px;">
                <table style="border-collapse: collapse; margin-left: 5px;">
                    <tr height="16px">
                        <td width="71px" style="text-align: center; border-collapse: collapse; border: 1px solid white;">
                        </td>
                        <td colspan="2" rowspan="1" width="151px" style="text-align: center; border-collapse: collapse; border: 1px solid white;">
                        </td>
                        <td colspan="2" rowspan="1" width="151px" style="text-align: center; border-collapse: collapse; border: 1px solid white;">
                        </td>
                        <td width="151px">
                        </td>
                    </tr>
                    <% _grouped = {} %>
                    %for _line in tax.taxform_ppnbm:
                        <%tariff = _line.tariff %>
                        %if (tariff) in _grouped:
                            <%_grouped [tariff]['amount_tax'] += _line.amount_tax%>
                            <%_grouped [tariff]['tax_base'] += _line.tax_base%>
                        %else:
                            <%_grouped [tariff] = {'amount_tax' : _line.amount_tax, 'tax_base' : _line.tax_base}%>
                        %endif
                    %endfor

                    <% _grouped_info = [] %>
                    %for k,v in _grouped.iteritems():
                        <%v.update({'tariff': k})%>
                        <%_grouped_info.append(v)%>
                    %endfor

                    <%lines = _grouped_info + [False, False, False, False]%>
                        %for p in lines[:4]:
                            %if p:
                                    <tr height="16px">
                                        <td style="text-align: right; padding-right: 5px;">
                                        ${formatLang(p.get('tariff') * 100.0, digits=0)} %
                                        </td>
                                        <td style="vertical-align: top; padding-left: 5px;">Rp.</td>
                                        <td style="text-align: right; padding-left: 5px;">
                                        ${formatLang(p.get('tax_base'), digits=0)}
                                        </td>
                                        <td style="vertical-align: top; padding-left: 15px;">Rp.</td>
                                        <td style="text-align: right; padding-right: 5px;">
                                        ${formatLang(p.get('amount_tax'), digits=0)}
                                        </td>
                                    </tr>
                            %else:
                                    <!--Cetak baris line item 'kosong', untuk mem-fill sisa tabel line item-->
                                    <tr>
                                        <td style="text-align: right; border-right: 1px solid white; border-left: 1px solid white; padding-right: 5px;"> 
                                        </td>
                                        <td style="text-align: left; border-right: 1px solid white; border-left: 1px solid white; padding-left: 5px;"> 
                                        </td>
                                        <td style="text-align: left; border-right: 1px solid white; border-left: 1px solid white; padding-left: 5px;"> 
                                        </td>
                                    </tr>
                            %endif
                        %endfor
                    <tr>
                        <td colspan="3" style="border-collapse: collapse; border: 1px solid white; width: 257px; height: 16px;">
                        </td>
                        <td style="vertical-align: top; padding-left: 15px; border-top: 1px solid white; border-bottom: 1px solid white;">Rp.</td>
                        <td style="text-align: right; border-collapse: collapse; border: 1px solid white; padding-left: 5px;">${tax.amount_total_ppnbm and formatLang(tax.amount_total_ppnbm, digits=0) or ''}
                        </td> 
                        <td style="width:37px; text-align: right;" colspan="2">
                        </td>
                        <td style="width: 45px; text-align:left; border-bottom:1px dashed;">
                        </td>
                        <td style="width: 5px; border-bottom:1px dashed;">
                        </td>
                        <td style="border-bottom:1px dashed; width: 200px;" colspan="5">Gunawan Rusli
                        </td>
                        <td style="width: 80px;">
                        </td>
                    </tr>
                </table>
                </div>
            </td>
        </tr>
    </tbody>
</table>
<left><h2 style="width: ${page_width}px; font-size: 8px; margin: 0px; padding: 2px;"></h2></left>

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
<p style="page-break-after:always"></p>
<small>
<br/><br/><br/>
<b>Dokumen-dokumen ini tidak dicetak karena statusnya:</b><br/>
${', '.join(wrong_document_state)}
</small>
%endif
</html>
