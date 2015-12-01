<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">

<html>

<!-##############################################################################################################################################
															CSS STYLE AND STATEMENTS
##################################################################################################################################################-->

<head>
<style type="text/css">
.diva {
 		overflow: hidden;
        text-overflow: ellipsis;
        height: 80px;
		width: 750px;
}

.table {
		width: 100%;
		margin: 0px;
		padding: 0px;
		border-spacing: 0px;
    	border-collapse: collapse;
}

.table_border {
		border-left: 1px solid black;
		border-top: 1px solid black;
		border-bottom: 1px solid black;
		font-size: 15px;
		font-weight: bold;
		padding-right: 3px;
		text-align: center;
		border-spacing: 0px;
}

.table_line {
		border-left: 1px solid black;
		text-align: right;
		padding-right: 3px;
		border-spacing: 0px;
}

.total {
		text-align: right;
		font-weight: bold;
		border-right:1px solid black;
		padding-right: 3px;
		border-spacing: 0px;
}

</style>
</head>

<!--################################################################################################################################################
								    							 DEKLARASI VARIABEL
####################################################################################################################################################-->
<%import math %>
<%import re%>

<%wrong_document_state = [] %>		<!--Dipakai untuk menyimpan daftar dan status dari dokumen-dokumen yang tidak akan dicetak (status invalid)-->
<%total_document = len(objects)%>	<!--Dipakai untuk mencek jumlah dokumen-dokumen yang akan dicetak-->

<!--KONFIGURASI untuk menentukan jumlah baris dari line item yang ingin dicetak setiap halamannya-->
<!--Variabel berikut menentukan atau mengikuti 'layout' dari halaman kertas, sehingga menandakan batasan atau limit kertas-->
<%max_lines = 35%>									<!--Jumlah baris maksimum untuk line item s/d akhir halaman-->
<%def_footer_lines = 12%>							<!--Jumlah pemakaian baris untuk footer yang akan dicetak setiap halamannya-->
<%last_page_footer_lines = 17%>						<!--Jumlah pemakaian baris untuk footer yang akan dicetak khusus untuk halaman akhir-->
<%target_lines = max_lines - def_footer_lines%>		<!--Jumlah line item yang akan dicetak setiap halamannya-->

<!--KONFIGURASI untuk menentukan jumlah dan spesifikasi dari kolom untuk setiap baris line item yang akan dicetak-->
<%line_item_columns=7%>								<!--Jumlah kolom dari setiap baris line item yang dicetak-->
<%column_width_in_chars=[3,70,7,6,14,7,16]%>		<!--Lebar masing-masing kolom line item dalam jumlah huruf/karakter-->
<%max_wrap_lines=3%>								<!--Maksimum jumlah baris yang dibentuk untuk teks yang wrapping, sisa teks yang tidak 'muat' di'buang'-->
													<!--Nilai satu berarti tidak akan ada wrapping, sehingga semua teks untuk kolom akan di'truncate'-->

<!--KONFIGURASI untuk menentukan layout HTML dari formulir-->
<%preprinted_header_space = 226%>					<!--Blank space untuk area preprinted dari formulir-->
<%line_item_height = 15%>							<!--Tinggi dari setiap line item yang dicetak-->
<%font_size = 13%>									<!--Ukuran tulisan yang digunakan secara umum, dapat di-override apabila font-size juga ditentukan pada setiap tr atau td-->
<%page_width = 793.700787402%>						<!--Lebar formulir yang umum digunakan sebagai lebar tabel utama-->

<!--Proses semua dokumen satu per satu-->
%for document in objects :

	<!--Menentukan kondisi status object untuk data yang dicetak  HWT: Aslinya '!=draft'-->
	%if document.state == 'cancel': 
		<!--Seluruh dokumen yang statusnya invalid akan di'catat' untuk kemudian diinfokan ke pengguna-->
    	<% wrong_document_state.append('%s: %s' % (document.name, document.state)) %>
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
		<%total_products = len(document.order_line)%>

		<!--Siapkan variabel 'penyimpanan'-->
		<%line_item_print=[]%>		<!--Tempat untuk menyimpan semua teks dari produk atau 'line item' yang telah di proses mengikuti konfigurasi kolom-->
		<%total_lines_print=0%>		<!--Jumlah baris yang harus dicetak-->

<!--################################################################################################################################################
								    					     PRE-PROCESSING LOGIC LINE ITEM
####################################################################################################################################################-->

		<!--Proses semua produk di dalam dokumen yang dimaksud-->
		%for prod_no in range(0,total_products):
			<!--Ambil atau proses produk atau 'line item'nya-->
			<%prod = document.order_line[prod_no]%>

<!--================================================================== EDITABLE AREA ===============================================================-->

			<!--Tempat sementara untuk menyimpan data setiap produk atau 'line item'-->
			<%str_holder=[]%>
			<!--Proses seluruh kolom menjadi satu list-->
			<!--Kolom 1: no urut produk-->
			<%str_holder.append(str(prod_no + 1))%>
			<!--Kolom 2: nama produk-->
			<!--Buang kode produk (substitusikan seluruh teks dari awal s/d tanda ']' dengan empty string)-->
			<%prod_line_desc = re.sub(r'.*]', "", prod.name)%>
			<%str_holder.append(prod_line_desc)%>
			<!--Kolom 3: jumlah/kuantitas produk-->
			<%str_holder.append(formatLang(prod.product_uom_qty, digits=0))%>
			<!--Kolom 4: satuan unit (UOM) produk-->
			<%str_holder.append(prod.product_uom and prod.product_uom.name or '')%>
			<!--Kolom 5: harga satuan produk-->
			<%str_holder.append(formatLang(prod.price_unit))%>
			<!--Kolom 6: diskon produk-->
			<%str_holder.append(formatLang(prod.discount))%>
			<!--Kolom 7: jumlah nilai produk-->
			<%disc = (prod.price_unit * prod.discount) / 100 %>
			<%disc_price = prod.price_unit - disc%>
			<%str_holder.append(formatLang(disc_price * prod.product_uom_qty))%>

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
		<!--%test_lines = total_lines_print + 245%-->
		<!--%for line_number in range(total_lines_print,test_lines):-->
			<!--%line_item_print.append([str(line_number+1),'12345678901234567890123456890','B','C','D','E','F'])%-->
		<!--%endfor-->
		<!--%total_lines_print = test_lines%-->

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

<!--################################################################################################################################################
								    					    OTHER PROCESSING LOGIC
####################################################################################################################################################-->

		<!-- Menentukan tanggal waktu pengiriman bagi setiap dokumen (penawaran) -->
		<%val = 0 %>
		%for vals in document.order_line :
		    %if vals.delay > val:
		        <%val = vals.delay %>
	    	%endif
		%endfor

<!--##################################################################################################################################################
															BAGIAN PRE-PRINTED LAPORAN (LOGO)
####################################################################################################################################################-->

<!--pengaturan body dan tabel formulir-->
<body style="font-size: ${font_size}px; font-family: Sans-Serif; margin: 0px;">

		<!--Looping untuk menghasilkan ('render') halaman dari formulir-->
		%for current_page in range (1, total_page+1):
<table style="text-align: left; width: ${page_width}px; margin: 0; padding: 0;" cellpadding="0" cellspacing="0">
	<tbody>
		<tr>
			<!--Blank space untuk area preprinted dari formulir-->
      		<td colspan="3" rowspan="1" style="vertical-align: top;">
				<div style="height: ${preprinted_header_space}px;"></div>
      		</td>
    	</tr>

<!--##################################################################################################################################################
															BAGIAN HEADER LAPORAN (INFO PARTNER)
####################################################################################################################################################-->

    	<tr>
			<!--Area untuk tempat dan tanggal dari formulir-->
      		<td colspan="3" rowspan="1" style="vertical-align: top;">
     			<div style="height: 15px;">
      				<hr style="border: 1px solid black; margin-top: -10px;">
      				<p style="text-align: right;">Jakarta, ${document.date_order and date_order_fmt(document.date_order) or '' | n}</p>
      			</div>
      			<center>
				<!--Area untuk Nomor formulir-->
      			<div style="height: 75px;">
      			<table class="table_title">
        			<tbody>
          				<tr>
		    				<td style="font-size: 20px; font-weight: bold;">Penawaran No. : </td>
		    				<td style="padding-top: 7px;">${document.name or '' | entity}</td>
          				</tr>
          				<tr>
		    				<td style="text-align: center;" colspan="2">
                                ( Masa Berlaku. :
                                ${document.validity and date_order_fmt(document.validity) or '&nbsp;' * 20| n}
                                )
                            </td>
          				</tr>
        			</tbody>
      			</table>
      			</div>
      			</center>
      		</td>
    	</tr>
    	<tr>
      		<td colspan="3" rowspan="1" style="vertical-align: top;">
      			<div style="height: 85px;">
					Kepada Yth,<br>
					<!--${document.partner_order_id and document.partner_order_id.name or '' | entity}<br-->
					${document.partner_id.name or '' | entity}<br>
					${document.partner_order_id and document.partner_order_id.street or '' | entity}<br>
					${document.partner_order_id and document.partner_order_id.city or 'Indonesia' | entity}<br>
					Up.: ${document.partner_order_id and document.partner_order_id.name or '' | entity}<br>
      				<br>
				</div>
      		</td>
    	</tr>
		<tr>
			<td>
      			<div style="height: 105px;">
      			<table>
        		<tbody>
        			<tr>
		    			<td>Berdasarkan</td>
		    			<td width="10">:</td>
		    			<td>${document.client_order_ref or ''|entity}</td>
          			</tr>
						%if document.date_order:
							<%from datetime import datetime, timedelta %>
							<%max_date = datetime.strptime(document.date_order, "%Y-%m-%d") + timedelta(days=val)%>
							<%res = datetime.strftime(max_date, "%Y-%m-%d")%>
						%endif
          			<!--tr>
		    			<td>Waktu Pengiriman</td>
		    			<td width="10">:</td>
		    			<td>${date_order_fmt(res)|n} ( ${int(val) or ''|entity} hari )</td>
          			</tr>
          			<tr>
		    			<td>Tempat Pengiriman</td>
		    			<td width="10">:</td>
		    			<td>${document.shop_id and document.shop_id.name or '' | entity}</td>
          			</tr>
          			<tr>
		    			<td>Tujuan</td>
		    			<td width="10">:</td>
		    			<td>${document.partner_shipping_id and document.partner_shipping_id.street or '' | entity}</td>
          			</tr>
          			<tr>
		    			<td>Syarat Pembayaran</td>
		    			<td width="10">:</td>
		    			<td>${document.payment_term.name or '' | entity}</td>
          			</tr-->
          			<tr>
							<td>Waktu Pengiriman</td>
							<td width="10">:</td>
							<td>${document.x_waktu_kirim or '' | entity}</td>
							<!--td>${date_order_fmt(res)|n} ( ${int(val) or ''|entity} hari )</td-->
					</tr>
					<tr>
							<td>Tujuan Pengiriman</td>
							<td width="10">:</td>
							<td>${document.x_tujuan_kirim or '' | entity}</td>
					</tr>
					<tr>
							<td>Syarat Pembayaran</td>
							<td width="10">:</td>
							<td>${document.x_syarat_bayar or '' | entity}</td>
					</tr>

        		</tbody>
      			</table>
				</div>
			</td>
    	</tr>

<!--##################################################################################################################################################
													BAGIAN BODY / LINE ITEM LAPORAN (TABEL ITEM)
####################################################################################################################################################-->

    	<!--Area untuk pencetakan line item-->
    	<tr>
    		<td>
		%if current_page == total_page:
				<!--div untuk mendorong sisa footer sehingga page number bisa tetap di akhir halaman (untuk last page)-->
				<div style="height: 505px;">
				<table class="table" cellspacing="0" cellpadding="0">
		%else:
				<!--div Untuk mendorong sisa footer sehingga page number bisa tetap di akhir halaman-->
				<div style="height: 505px;">
				<table class="table" cellspacing="0" cellpadding="0">
		%endif
				<tbody>
					<tr>
						<td>
   							<table class="table" cellpadding="2">
        					<tbody>
    				<!--Cetak header dari area line item -->
          						<tr style="height:1px;">
				    				<td style="width: 4%;" class="table_border">NO.</td>
				    				<td style="width: 48%;" class="table_border">NAMA BARANG / UKURAN</td>
				    				<td style="width: 12%;" class="table_border" colspan="2">KWANTUM</td>
				    				<td style="width: 13%;" class="table_border">HARGA SATUAN (Rp)</td>
				    				<td style="width: 9%;" class="table_border">DISKON</td>
									<td style="width: 18%; border-right: 1px solid black" class="table_border">J U M L A H (Rp)</td>
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
		    						<td class="table_line" style="text-align: center; height:${line_item_height}px;">${line_item_print[line_no][0]}
		    						</td>
		    						<td class="table_line" style="text-align: left; height:${line_item_height}px;">${line_item_print[line_no][1]}
		    						</td>
		    						<td class="table_line" style="text-align: right; height:${line_item_height}px;" colspan="2">${line_item_print[line_no][2]} ${line_item_print[line_no][3]}
		    						</td>
		    						<td class="table_line" style="text-align: right; height:${line_item_height}px;">${line_item_print[line_no][4]}
		    						</td>
		    						<td class="table_line" style="text-align: right; height:${line_item_height}px;">${line_item_print[line_no][5]}
		    						</td>
		    						<td class="table_line" style="text-align: right; height:${line_item_height}px; border-right: 1px solid black;">${line_item_print[line_no][6]}
		    						</td>
	          					</tr>
				%else:
								<!--Cetak baris line item 'kosong', untuk mem-fill sisa tabel line item-->
	          					<tr>
			    					<td class="table_line" style="height:${line_item_height}px;"></td>
			    					<td class="table_line" style="height:${line_item_height}px;"></td>
									<td class="table_line" style="height:${line_item_height}px;" colspan="2"></td>
									<td class="table_line" style="height:${line_item_height}px;"></td>
									<td class="table_line" style="height:${line_item_height}px;"></td>
									<td class="table_line" style="height:${line_item_height}px; border-right: 1px solid black"></td>
								</tr>
				%endif
			%endfor

			<%current_line = last_line%>
								<!--Cetak baris kosong di bagian bawah tabel line item (ini adalah filler)-->
								<tr>
	          						<td style="width: 4%;  border-bottom: 1px solid black; border-left: 1px solid black; border-right: 1px solid black" ></td>
				    				<td style="width: 48%; border-bottom: 1px solid black; border-right: 1px solid black"></td>
				    				<td style="width: 12%; border-bottom: 1px solid black; border-right: 1px solid black" colspan="2"></td>
				    				<td style="width: 13%; border-bottom: 1px solid black; border-right: 1px solid black"></td>
				    				<td style="width: 9%;  border-bottom: 1px solid black; border-right: 1px solid black"></td>
									<td style="width: 18%; border-bottom: 1px solid black; border-left: 1px solid black; border-right: 1px solid black; "></td>
	         					</tr>
        					</tbody>
     						</table>
      					</td>
					</tr>

<!--##################################################################################################################################################
													BAGIAN FOOTER LAPORAN (SIGNATURE, NOTE, TOTAL)
####################################################################################################################################################-->

		<!--Area total dari line item dan tanda-tangan yang hanya ditampilkan di halaman akhir-->
			<!--Area total dari line item dan tanda-tangan yang hanya ditampilkan di halaman akhir-->
			%if current_page == total_page:
					<tr>
      					<td>
							<div style="height: 30px;">
  	  						<table style="text-align: left;" class="table" cellpadding="1" cellspacing="1">
     	   					<tbody>
        						<tr>
       								<td style="text-align: right; height:18px; border-bottom: 1px solid black; border-left: 1px solid black; width: 500px;" class="total" colspan="6">Untaxed Amount
                                    </td>
        							<td style="text-align: right; width: 106px;" class="total">${document.amount_untaxed or '0.00' | entity}
                                    </td>
								</tr>
								<tr style="border-top: 1px solid black;">
        							<td style="border-left: 1px solid black; height:18px; width: 500px;" class="total" colspan="6">Taxes</td>
        							<td style="text-align: right;" class="total">${document.amount_tax or '0.00' | entity}</td>
        						</tr>
        						<tr>
            						<td style="border-top: 1px solid black; height:25px; border-left: 1px solid black; border-bottom: 1px solid black;" colspan="6">
            							<p><b>Total :</b>
										%if document.amount_total >=0.0:
											${amount_say(abs(document.amount_total))[0:250] or ''|n}
										%endif
										</p>
									</td>
            						<td style="border: 1px solid black; text-align: right; padding-right: 3px;"><b>${document.amount_total or '' | entity}</b> </td>
         						</tr>
        					</tbody>
      						</table>
      						</div>
      					</td>
					</tr>
				</tbody>
				</table>
				</div>
			</td>
    	</tr>

    	<tr>
     		<td colspan="2">
			<div style="height: 95px;">
    			<table>
				<tbody>
					<tr>
    					<td style="vertical-align: top; text-align: left; font-size: 10pt; width: 700px;">
      					</td>
      					<td style="vertical-align: top; text-align: right; font-size: 10pt; width: 400px;">Hormat kami,<br><br><br><br>
      					</td>
    				</tr>
   					<tr>
   						<td style="vertical-align: top; width: 700px;"><left>...................</left>
			    		</td>
			    		<td style="vertical-align: top; text-align: right; width: 400px;">${document.x_signature or '' | entity}</td>
    				</tr>
    				<tr>
    					<td style="vertical-align: top; text-align: left; font-size: 10pt; width: 700px;">(Customer)</td>
      					<td style="vertical-align: top; text-align: right; font-size: 10pt; width: 400px;"></td>
    				</tr>
   	   			</tbody>
				</table>
    		</div>
			</td>
    	</tr>
    	<tr>
      		<td colspan="3" rowspan="1" style="width: 100%">
				<div style="height: 65px;">
      				<p class="diva" style="text-align: justify;"><b>NOTE :</b> 
      				Harga dan Stock tidak mengikat, sewaktu-waktu dapat berubah tanpa pemberitahuan terlebih dahulu.
      				<br />${document.note and document.note[0:400] or ''|entity}</p>
				</div>
      		</td>
    	</tr>

			%else:
				</tbody>
				</table>
				</div>
			</td>
    	</tr>
		<tr>
			<td>
				<div style="height: 172px;">
				<table style="width: 100%">
				<tbody>
    				<tr>
      					<td style="text-align: center; font-weight: bold; font-size: 11pt;">
                            <br><br><br><br><br>
                            BERSAMBUNG KE HALAMAN BERIKUTNYA
						</td>
    				</tr>
				</tbody>
				</table>
				</div>
			</td>
		</tr>
			%endif

 		<tr>
			%if current_page != total_page:
			<td style="text-align: right; vertical-align: bottom; width: 750px;">
				page ${current_page} of ${total_page}
			</td>
			%else:
			<td style="text-align: right; vertical-align: bottom; width: 750px;">
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
<p style="page-break-after:always"></p>
<small>
<br/><br/><br/>
<b>Dokumen-dokumen ini tidak dicetak karena statusnya:</b><br/>
${', '.join(wrong_document_state)}
</small>
%endif
</html>
