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
    height: 125px;
    width: 100%;
    text-align: justify;
}

.message {
    border: 1px solid black;
    text-align: left;
}

.table {
    width: 100%;
    margin: 0px;
    padding: 0px;
    border-spacing: 0px;
    border-collapse: collapse;
}

.table_border {
    border-right: 1px solid black;
    border-top: 1px solid black;
    border-bottom: 1px solid black;
    font-weight: bold;
    font-size: 15px;
    padding-right: 3px;
    text-align: center;
    border-spacing: 0px;
}

.table_line {
    border-right: 1px solid black;
    text-align: right;
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

<%wrong_document_state = [] %>        <!--Dipakai untuk menyimpan daftar dan status dari dokumen-dokumen yang tidak akan dicetak (status invalid)-->
<%total_document = len(objects)%>    <!--Dipakai untuk mencek jumlah dokumen-dokumen yang akan dicetak-->

<!--KONFIGURASI untuk menentukan jumlah baris dari line item yang ingin dicetak setiap halamannya-->
<!--Variabel berikut menentukan atau mengikuti 'layout' dari halaman kertas, sehingga menandakan batasan atau limit kertas-->
<%max_lines = 30%>                                    <!--Jumlah baris maksimum untuk line item s/d akhir halaman-->
<%def_footer_lines = 8%>                            <!--Jumlah pemakaian baris untuk footer yang akan dicetak setiap halamannya-->
<%last_page_footer_lines = 8%>                        <!--Jumlah pemakaian baris untuk footer yang akan dicetak khusus untuk halaman akhir-->
<%target_lines = max_lines - def_footer_lines%>        <!--Jumlah line item yang akan dicetak setiap halamannya-->

<!--KONFIGURASI untuk menentukan jumlah dan spesifikasi dari kolom untuk setiap baris line item yang akan dicetak-->
<%line_item_columns=6%>                                <!--Jumlah kolom dari setiap baris line item yang dicetak-->
<%column_width_in_chars=[3,80,7,6,7,5]%>            <!--Lebar masing-masing kolom line item dalam jumlah huruf/karakter-->
<%max_wrap_lines=3%>                                <!--Maksimum jumlah baris yang dibentuk untuk teks yang wrapping, sisa teks yang tidak 'muat' di'buang'-->
                                                    <!--Nilai satu berarti tidak akan ada wrapping, sehingga semua teks untuk kolom akan di'truncate'-->

<!--KONFIGURASI untuk menentukan layout HTML dari formulir-->
<%preprinted_header_space = 226%>                    <!--Blank space untuk area preprinted dari formulir-->
<%line_item_height = 15%>                            <!--Tinggi dari setiap line item yang dicetak-->
<%font_size = 13%>                                    <!--Ukuran tulisan yang digunakan secara umum, dapat di-override apabila font size juga ditentukan pada setiap tr atau td-->
<%page_width = 812.598425197%>                        <!--Lebar formulir yang umum digunakan sebagai lebar tabel utama-->

<!--Proses semua dokumen satu per satu-->
%for document in objects :
    <%state = document.state%>

    <!--Menentukan kondisi status object untuk data yang dicetak-->
    %if state not in ('assigned', 'done'):
        <!--Seluruh dokumen yang statusnya invalid akan di'catat' untuk kemudian diinfokan ke pengguna-->
        <% wrong_document_state.append('%s: %s' % (document.name, state)) %>
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
        <%total_products = len(document.move_lines)%>

        <!--Siapkan variabel 'penyimpanan'-->
        <%line_item_print=[]%>        <!--Tempat untuk menyimpan semua teks dari produk atau 'line item' yang telah di proses mengikuti konfigurasi kolom-->
        <%total_lines_print=0%>        <!--Jumlah baris yang harus dicetak-->

<!--################################################################################################################################################
                                                             PRE-PROCESSING LOGIC LINE ITEM
####################################################################################################################################################-->

        <!--Proses semua produk di dalam dokumen yang dimaksud-->
        <%line_counter = 0%>
        %for prod_no in range(0, total_products):
            <!--Ambil atau proses produk atau 'line item'nya-->
            <%prod = document.move_lines[prod_no]%>

    <!--================================================================== EDITABLE AREA ===============================================================-->
            <!--Proses hanya yang memenuhi kriteria tertentu-->
            %if prod.state not in ['cancel']:
                <%line_counter += 1%>
                <!--Tempat sementara untuk menyimpan data setiap produk atau 'line item'-->
                <%str_holder=[]%>
                <!--Proses seluruh kolom menjadi satu list-->
                <!--Kolom 1: no urut produk-->
                <%str_holder.append(str(line_counter))%>
                <!--Kolom 2: nama produk-->
                <!--Buang kode produk (substitusikan seluruh teks dari awal s/d tanda ']' dengan empty string)-->
                <%prod_line_desc = re.sub(r'.*]', "", prod.product_id.name)%>
                <%str_holder.append(prod_line_desc)%>
                <!--Kolom 3: jumlah/kuantitas produk-->
                <%str_holder.append(formatLang(prod.product_qty, digits=0) or "")%>
                <!--Kolom 4: satuan unit (UOM) produk-->
                <%str_holder.append(prod.product_uom and prod.product_uom.name or '')%>
                <!--Kolom 5: jumlah box produk-->
                <% pack_qty = prod.product_packaging and prod.product_packaging.qty or '' %>
                %if pack_qty == '' :
                    <%str_holder.append("")%>
                %else:
                    <%str_holder.append(formatLang(int(prod.product_packaging and prod.product_packaging.qty),digits=0) or "")%>
                %endif
                <!--Kolom 6: nama satuan box produk-->
                <%str_holder.append(prod.product_packaging and prod.product_packaging.ul and prod.product_packaging.ul.name or '')%>

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
            %endif
        %endfor

<!--================================================================== EDITABLE AREA ===============================================================-->

        <!--For testing only: adding dummy line items-->
        <%test_lines = total_lines_print + 0%>
        %for line_number in range(total_lines_print, test_lines):
            <%line_item_print.append([str(line_number+1),'12345678901234567890123456890','B','C','D','E','F'])%>
        %endfor
        <%total_lines_print = test_lines%>

<!--================================================================================================================================================-->

        <!--B. Menghitung jumlah halaman formulir berdasarkan perhitungan target_lines-->
        <% total_page = total_lines_print / target_lines%>
        %if last_page_footer_lines != def_footer_lines:
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
<body style="font-size: ${font_size}px; font-family: Sans-Serif; margin: 0px">

        <!--Looping untuk menghasilkan ('render') halaman dari formulir-->
        %for current_page in range(1, total_page + 1):
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


        <!--Area untuk Nama formulir-->
        <tr>
            <td colspan="6" rowspan="1">
                <center>
                <table>
                    <tbody>
                        <tr>
                            <td style="font-size: 22px; font-type: Sans-Serif; font-weight: bold; text-align: center;">
                                <div style="width: 100%;">SURAT JALAN
                                </div>
                            </td>
                          </tr>
                    </tbody>
                </table>
                </center>
            </td>
        </tr>


        <!--Area untuk Nomor dan tanggal formulir-->
        <tr>
            <td colspan="5" rowspan="1">
                <center>
                <table style="vertical-align: middle;">
                    <tbody>
                        <tr>
                            <td style="font-size: ${font_size}px; font-family: Sans-Serif; text-align: left; padding-left: 5px;">
                                <div style="height: 60px;">
                                No. ${document.name or ''|entity}<br>
                                Tgl.
                                %if state == 'assigned':
                                    ${date_order_fmt(time.strftime("%Y-%m-%d"))|n}
                                %elif state =='done':
                                    ${date_order_fmt(document.date_done)|n}
                                %else:
                                    ${''}
                                %endif
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
                </center>
            </td>
        </tr>


        <!--Area untuk Alamat partner-->
        <tr>
            <td>
                <left>
                <table>
                    <tbody>
                        <tr>
                            <td style="font-size: ${font_size}px; font-family: Sans-Serif; text-align:left;">
                                  <div style="height: 80px;">Kepada Yth:<br>
                                <% end_user = ' '.join([document.area_address_id and document.area_address_id.name or '', document.area_address_id and document.area_address_id.street or '', document.area_address_id and document.area_address_id.city or '']) %>
                                %if len(end_user) == 2 or len(end_user) == 0:
                                    ${document.address_id and document.address_id.partner_id and document.address_id.partner_id.name or ''|entity}
                                    <br/>${document.address_id and document.address_id.street or ''|entity}
                                    <br/>${document.address_id and document.address_id.city or ''|entity} ${document.address_id.zip or ''|entity}
                                    <br/>${document.address_id and document.address_id.state_id and document.address_id.state_id.name or ''|entity} - ${document.address_id and document.address_id.country_id and document.address_id.country_id.name or ''|entity}
                                %else:
                                    ${document.area_address_id and document.area_address_id.partner_id and document.area_address_id.partner_id.name or ''|entity}
                                    <br/>${document.area_address_id and document.area_address_id.street or ''|entity} ${document.area_address_id.zip or ''|entity}
                                    <br/>${document.area_address_id and document.area_address_id.city or ''|entity}
                                    <br/>${document.area_address_id and document.area_address_id.state_id and document.area_address_id.state_id.name or ''|entity}  ${document.area_address_id and document.area_address_id.country_id and document.area_address_id.country_id.name or ''|entity}
                                %endif
                                </div>
                              </td>
                          </tr>
                    </tbody>
                  </table>
                </left>
            </td>
        </tr>


        <!--Area untuk Nomor dan Tanggal Order Customer-->
        <tr>
            <td>
                <right>
                <table border="1" align='right' style="border-collapse:collapse;" cellpadding="2" cellspacing="1">
                    <tbody>
                        <tr height=20px>
                            <td colspan="2" width=235px>
                            No. Order : ${document.sale_id and document.sale_id.client_order_ref or '' | entity}
                            </td>
                        </tr>
                        <tr height=20px>
                            <td colspan="2" width=235px>
                            Tgl. Order : ${document.sale_id.origin or ''|entity}
                            </td>
                        </tr>
                    </tbody>
                </table>
                </right>
            </td>
        </tr>

        <tr>
            <td>
                  <table>
                    <tbody>
                        <tr>
                            <td>
                                <div style="height: 40px;">
                                Dengan hormat,<br/>
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Agar diterima dalam keadaan baik, barang - barang sbb :
                                </div>
                            </td>
                          </tr>
                    </tbody>
                </table>
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
                <div style="height: 445px;">
                <table class="table" cellspacing="0" cellpadding="0">
            %else:
                <!--div Untuk mendorong sisa footer sehingga page number bisa tetap di akhir halaman-->
                <div style="height: 445px;">
                <table class="table" cellspacing="0" cellpadding="0">
            %endif
                    <tbody>
                        <tr>
                            <td>
                                   <table class="table" cellpadding="2">
                                    <tbody>

                                        <!--Cetak header dari area line item -->
                                        <tr>
                                            <td style="width: 4%; border-left: 1px solid black;"  class="table_border">No.</td>
                                            <td style="width: 68%;" class="table_border">Nama Barang / Ukuran</td>
                                            <td style="width: 10%;" class="table_border">Jumlah</td>
                                            <td style="width: 8%;"  class="table_border">Satuan</td>
                                            <td style="width: 12%;" class="table_border" colspan="2">Box</td>
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
                                            <td class="table_line" style="text-align: center; border-left: 1px solid black; height:${line_item_height}px;">
                                            ${line_item_print[line_no][0]}
                                            </td>
                                            <td class="table_line" style="text-align: left; height:${line_item_height}px; paddiing-left: 4px;">
                                            ${line_item_print[line_no][1]}
                                            </td>
                                            <td class="table_line" style="text-align: right; height:${line_item_height}px; padding-right: 4px;">
                                            ${line_item_print[line_no][2]}
                                            </td>
                                            <td class="table_line" style="text-align: center; height:${line_item_height}px;">
                                            ${line_item_print[line_no][3]}
                                            </td>
                                            <td class="table_line" style="text-align: center; height:${line_item_height}px;" colspan="2">
                                            ${line_item_print[line_no][4]} ${line_item_print[line_no][5]}
                                            </td>
                                        </tr>
                    %else:
                                        <!--Cetak baris line item 'kosong', untuk mem-fill sisa tabel line item-->
                                        <tr>
                                            <td class="table_line" style="border-left: 1px solid black; height:${line_item_height}px;"></td>
                                            <td class="table_line" style="height:${line_item_height}px;"></td>
                                            <td class="table_line" style="height:${line_item_height}px;"></td>
                                            <td class="table_line" style="height:${line_item_height}px;"></td>
                                            <td class="table_line" style="height:${line_item_height}px;" colspan="2"></td>
                                          </tr>
                    %endif
                %endfor

                <%current_line = last_line%>
                                        <!--Cetak baris kosong di bagian bawah tabel line item (ini adalah filler)-->
                                        <tr>
                                               <td style="border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black;"></td>
                                            <td style="border-right: 1px solid black; border-bottom: 1px solid black;"></td>
                                            <td style="border-right: 1px solid black; border-bottom: 1px solid black;"></td>
                                            <td style="border-right: 1px solid black; border-bottom: 1px solid black;"></td>
                                            <td style="border-right: 1px solid black; border-bottom: 1px solid black;" colspan="2"></td>
                                          </tr>
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
                                                    BAGIAN FOOTER LAPORAN (SIGNATURE, NOTE)
####################################################################################################################################################-->

        <!-- Area cetak keterangan-->
        <tr>
            <td colspan="5" rowspan="1" style="padding-left:4px;">
                <div style="height: 65px;">
                      <p class="diva"><b>KETERANGAN :</b> ${document.note and document.note[0:400] or ''|entity}</p>
                </div>
            </td>
        </tr>

        <!-- Area cetak Tanggal Pengiriman, No.Perintah Pengiriman-->
        <tr>
            <td colspan="3">
                <div style="height: 40px;">
                <table style="width: 100%; border-top:1px solid black; border-bottom:1px solid black; border-collapse:collapse;">
                    <td align='left' width="430px; padding-left: 4px;">
                    Tgl. Pengiriman :
                    ${date_order_fmt(time.strftime("%Y-%m-%d"))|n}
                    <br>
                    No. Kendaraan :
                    </td>
                    <td align='left' style="border-left:1px solid black; padding-left: 4px;" width="350px">No. Packing List :
                    </td>
                    <td align='left' style="border-left:1px solid black; padding-left: 4px;" width="480px">No. Perintah Pengiriman : ${document.sale_id and document.sale_id.name or ''|entity}
                    </td>
                </table>
                </div>
            </td>
        </tr>

        <!--Area tanda tangan-->
        <tr>
            <td colspan="3">
                <div style="height: 150px;">
                <table style="width: 100%;">
                    <td align='left' width="450px">Yang Menerima,<br><br><br><br><br><br>
                    (&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;)
                    </td>
                    <td style="vertical-align: middle; font-align: left; font-family: Sans-Serif; font-size: 10px;" width="720px">
                    <p class="message">
                    1. Harap barang dihitung dan di check, sebelum Surat Jalan di t.t.<br />
                    2. Claim tidak dilayani jika Surat Jalan sudah di t.t.
                    </p>
                    </td>
                    <td align="right" width="450px">Yang menyerahkan,<br><br><br><br><br><br>
                    ( Kabag. Logistik )
                    </td>
                </table>
                </div>
            </td>
        </tr>

        <!--Area tampilan no halaman-->
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
