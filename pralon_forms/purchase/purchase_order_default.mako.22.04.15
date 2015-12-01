<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<!--
###################################################################################################
                                     CSS STYLE AND STATEMENTS
###################################################################################################
-->

<head>
<meta content="text/html; charset=UTF-8" http-equiv="content-type" />
<style type="text/css">
    body {
        font-size: 11px;
    }

    .main {
        font-size: 12px;
        width: 794px;
        height: 1050px;
        position: relative;
        left: 0px;
        top: 30px;
    }

    .pbreakaft {
        page-break-after: always;
    }

    body table {
        width: 100%;
        border-collapse: collapse;
        text-align: left;
        top: 0;
        left: 0;
    }

    .header-row {
        border-bottom: 1px solid black;
        margin: 0px;
        height: 80px;
    }

    .address {
        height: 120px;
    }

    .addressee {
        height: 130px;
    }

    .references {
        height: 50px;
    }

    .v-spacer {
        height: 20px;
    }

    .details {
        max-height: 500px;
    }

    .header-cell-header {
        border: 1px solid #eaeaea;
        vertical-align: middle;
        width: 155px;
        text-align: left;
    }

    .header-cell {
        text-align: left;
        border: 1px solid #eaeaea;
        vertical-align: top;
    }

    .info-cell-header {
        border-bottom: 1px solid black;
        vertical-align: middle;
        text-align: left;
    }

    .info-cell {
        vertical-align: top;
        text-align: left;
    }

    .top-cell {
        border-top: 1px solid black;
    }

    .extra-info {
        border: 1px solid #eaeaea;
    }
</style>
</head>

<!--
###################################################################################################
                                   DEKLARASI VARIABEL
###################################################################################################
-->
<%import math %>
<%import re%>

<%wrong_state = [] %>   <!--Dipakai untuk menyimpan daftar dan status dari dokumen-dokumen yang tidak akan dicetak (status invalid)-->
<%records = len(objects)%>  <!--Dipakai untuk mencek jumlah dokumen-dokumen yang akan dicetak-->

<!--KONFIGURASI untuk menentukan jumlah baris dari line item yang ingin dicetak setiap halamannya-->
<!--Variabel berikut menentukan atau mengikuti 'layout' dari halaman kertas, sehingga menandakan batasan atau limit kertas-->
<%max_lines = 30%>                                   <!--Jumlah baris maksimum untuk line item s/d akhir halaman-->
<%def_footer_lines = 2%>                             <!--Jumlah pemakaian baris untuk footer yang akan dicetak setiap halamannya-->
<%last_page_footer_lines = 19%>                      <!--Jumlah pemakaian baris untuk footer yang akan dicetak khusus untuk halaman akhir-->
<%target_lines = max_lines - def_footer_lines%>      <!--Jumlah line item yang akan dicetak setiap halamannya-->

<!--KONFIGURASI untuk menentukan jumlah dan spesifikasi dari kolom untuk setiap baris line item yang akan dicetak-->
<%column_width_in_chars=[150,14,10,5,15,3,16,16]%>    <!--Lebar masing-masing kolom line item dalam jumlah huruf/karakter-->
<%line_item_columns=len(column_width_in_chars)%>     <!--Jumlah kolom dari setiap baris line item yang dicetak-->
<%max_wrap_lines=3%>                                 <!--Maksimum jumlah baris yang dibentuk untuk teks yang wrapping, sisa teks yang tidak 'muat' di'buang'-->
                                                     <!--Nilai satu berarti tidak akan ada wrapping, sehingga semua teks untuk kolom akan di'truncate'-->

<!--HA:KONFIGURASI untuk menentukan running total untuk setiap halaman-->
<%show_line_item_cum_sum_by_page=True%>             <!--Hitung jumlah total per 'halaman' yang dicetak-->

<!--KONFIGURASI untuk menentukan layout HTML dari formulir-->
<%preprinted_header_space = 226%>                   <!--Blank space untuk area preprinted dari formulir-->
<%line_item_height = 15%>                           <!--Tinggi dari setiap line item yang dicetak-->
<%font_size = 11%>                                  <!--Ukuran tulisan yang digunakan secara umum, dapat di-override apabila font-size juga ditentukan pada setiap tr atau td-->
<%page_width = 794%>                                <!--Lebar formulir yang umum digunakan sebagai lebar tabel utama-->

<!--Proses semua dokumen satu per satu-->
%for obj in objects :
    <% counter = 0 %>
    <% start_from = 0 %>
    <% limit = 23 %>
    <% increment = limit %>
    <% currency = obj.pricelist_id and obj.pricelist_id.currency_id and obj.pricelist_id.currency_id.symbol %>
    <!--Menentukan kondisi status object untuk data yang dicetak-->
    %if obj.state not in ('approved', 'done'):
    <!--Seluruh dokumen yang statusnya invalid akan di'catat' untuk kemudian diinfokan ke pengguna-->
      <% wrong_state.append('%s: %s' % (obj.name, obj.state)) %>
    %else:
    <!--Hanya proses dokumen dengan status yang valid-->

    <!--
    PRA-PROSES DATA: bagian ini adalah untuk memproses data line item yang akan dicetak.  Diperlukan proses awal (preprocessing) di mana teks atau
    deskripsi dari line item yang akan dicetak di'parsing' untuk menentukan apakah akan ada 'wrapping' atau tidak.  Jika wrapping akan terjadi, maka
    teks yang telah dibaca akan dipotong/split ke baris berikutnya (jumlah maksimum baris ditentukan oleh variabel max_wrap_lines).
    Hasil akhir dari preprocessing data ini adalah suatu list dari baris atau line item yang akan dicetak (secara data type berupa list of list).
    Untuk setiap baris yang juga berupa list data type, akan berisikan teks yang akan dicetak bagi masing-masing kolomnya.
     -->
    <!--A. Menghitung baris line item yang akan dicetak-->
    <!--Hitung jumlah produk atau line item yang akan diproses untuk dicetak-->
    <%total_products = len(obj.order_line)%>
    <!--Siapkan variabel 'penyimpanan'-->
    <%line_item_print=[]%>        <!--Tempat untuk menyimpan semua teks dari produk atau 'line item' yang telah di proses mengikuti konfigurasi kolom-->
        <%total_lines_print=0%>       <!--Jumlah baris yang harus dicetak-->
        <%line_item_sum_by_page=[]%>    <!--Jumlah atau total dari seluruh line item untuk setiap halamannya-->
        <%line_item_to_sum=[]%>         <!--HA:List dari seluruh nilai line item yang akan/dapat dijumlah-->

<!--
###################################################################################################
                                   PRE-PROCESSING LOGIC LINE ITEM
###################################################################################################
-->

    <!--Proses semua produk di dalam dokumen yang dimaksud-->
    %for prod_no in range(0,total_products):
        <!--Ambil atau proses produk atau 'line item'nya-->
        <%prod = obj.order_line[prod_no]%>

<!--==================================== EDITABLE AREA =========================================-->

        <!--Tempat sementara untuk menyimpan data setiap produk atau 'line item'-->
        <%str_holder=[]%>
        <!--Proses seluruh kolom menjadi satu list-->
        <!--Kolom 1: nama produk-->
        <!--Buang kode produk (substitusikan seluruh teks dari awal s/d tanda ']' dengan empty string)-->
        <%prod_line_desc = (re.sub(r'.*?]', "", prod.name or (prod.product_id and prod.product_id.name) or '', 1)).strip()%>
        <%prod_line_desc = prod_line_desc + ' <br> ' + (prod.notes or '-')%>
        <%str_holder.append(prod_line_desc)%>
        <!--kolom 2: Taxes -->
        <%str_holder.append(', '.join([x.name for x in prod.taxes_id]))%>
        <!--Kolom 3: jumlah/kuantitas produk-->
        <%str_holder.append(formatLang(prod.product_qty, digits=0))%>
        <!--Kolom 4: satuan unit (UOM) produk-->
        <%str_holder.append(prod.product_uom and prod.product_uom.name or '')%>
        <!--Kolom 5: harga satuan produk-->
        <%str_holder.append(formatLang(prod.price_unit,2))%>
        <!--Kolom 6: Satuan unit price-->
        <!%str_holder.append("Rp.")%-->
		<%str_holder.append(currency)%>
        <!--Kolom 7: jumlah nilai produk-->
        <%str_holder.append(formatLang(prod.price_unit * prod.product_qty,2))%>
        <!--HA:Setiap nilai atau kolom yang akan dicari running totalnya disimpan ke dalam list ini-->

        <% sum_line = (prod.price_unit * prod.product_qty) %>
        <%str_holder.append(str(sum_line))%>
        <%str_holder.append(str(prod_no))%>
<!--============================================================================================-->

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

<!--==================================== EDITABLE AREA =========================================-->

    <!--For testing only: adding dummy line items-->
    <%test_lines = total_lines_print + 0%>
    %for line_number in range(total_lines_print,test_lines):
      <%line_item_print.append(['%04d - %s' % (line_number, '12345678901234567890123456890'),'B','C','D','E','F','0','1'])%>
      <% sum_line = sum_line + 1 %>
    %endfor
    <%total_lines_print = test_lines%>

<!--============================================================================================-->

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

<!--
###################################################################################################
                              BAGIAN PRE-PRINTED LAPORAN (LOGO)
###################################################################################################
-->

<!--pengaturan body dan tabel formulir-->
<body style="font-size: ${font_size}px; font-family: Sans-Serif; margin: 0px">
        <%sum_line = 0 %>
      <!--Looping untuk menghasilkan ('render') halaman dari formulir-->
        %for current_page in range (1, total_page+1):
    <table cellpadding="2" cellspacing="2" style="height: 1000px;">
        <tbody>
            <tr>
                <td class="header-row" width="189px">
                    ${helper.embed_logo_by_name('pralon_logo', 166) | n}<br/>
                </td>
                <td class="header-row" width="520px"><br/></td>
                <td class="header-row" style="vertical-align: bottom;text-align: right;" width="238px">
                PERTAMA dan TERBAIK<br/>
                </td>
            </tr>

           <tr>
                <td class="address">
                <table>
                    <tbody>
                    <tr>
                        <td style="border-bottom: 1px solid black; margin: 0px;" width="200px">
                        ${obj.company_id and obj.company_id.name or '' | entity}<br/>
                        ${obj.company_id and obj.company_id.street or '' | entity}<br/>
                        ${obj.company_id and obj.company_id.zip or '' | entity} ${obj.company_id and obj.company_id.city or '' | entity} - ${obj.company_id and obj.company_id.country_id.name or '' | entity}<br/>
                        Phone: ${obj.company_id and obj.company_id.phone or ''|entity}<br/>
                        Mail: ${obj.company_id and obj.company_id.email or ''|entity}<br/>
                        </td>
                    </tr>
                    </tbody>
                </table>
                <br/><br/>
                </td>
                <td><br/></td>
                <td><br/></td>
            </tr>
            <tr>
                <td class="addressee" style="vertical-align: top;"><b>Shipping address :</b><br/>
                <% address_obj = obj.dest_address_id or False %>
                %if address_obj:
                    ${address_obj.partner_id and address_obj.partner_id.name  and address_obj.name or ''|entity}<br/>
                %else:
                    %if obj.location_id:
                        <% address_obj = obj.location_id.address_id or False %>
                        ${obj.location_id.company_id and obj.location_id.company_id.name or ''|entity}<br/>
                        ${obj.location_id.location_id and obj.location_id.location_id.name or ''|entity}<br/>
                        ${obj.location_id.name or ''|entity}<br/>
                    %endif
                %endif
                %if address_obj:
                    ${address_obj.street or ''|entity}<br/>
                    ${address_obj.city or ''|entity}, ${address_obj.zip or ''|entity}<br/>
                    ${address_obj.country_id and address_obj.country_id.name or ''|entity}<br/>
                %endif
                </td>
                <td><br/></td>
                <td style="vertical-align: top;">
                ${obj.partner_id and obj.partner_id.name or ''|entity}<br />
                <% address_obj = obj.partner_address_id or False %>
                %if address_obj:
                    ${address_obj.street or ''|entity}<br/>
                    ${address_obj.street2 or ''|entity}<br/>
                    ${address_obj.city or ''|entity}<br/>
                    ${address_obj.country_id and address_obj.country_id.name or ''|entity}
                %endif
                <br/>
                Tel : ${address_obj.phone or ''|entity}<br/>
                Fax : ${address_obj.fax or ''|entity}
                <br/><br/>
                </td>
            </tr>
            <tr>
                <td style="vertical-align: top;" colspan="3">
                    <h3><b>Purchase Order Confirmation No ${obj.order_number or ''|entity}</b></h3>
                    <br/>
                    <table class="references">
                        <tbody>
                        <tr>
                            <td class="header-cell-header">Our Order Reference</td>
                            <td class="header-cell-header">Your Order Reference</td>
                            <td class="header-cell-header">Order Date</td>
                            <td class="header-cell-header">Validated by</td>
                        </tr>
                        <tr>
                            <td class="header-cell">${obj.order_number or ''|entity}</td>
                            <td class="header-cell">${obj.partner_ref or ''|entity}</td>
                            <td class="header-cell">${date_order_fmt(obj.date_approve) or ''|n}</td>
                            <td class="header-cell">${obj.validator.name or ''|entity}</td>
                        </tr>
                        </tbody>
                    </table>
                        <br/>

        <!--Area untuk pencetakan line item-->

                    <table class="details">
                    <tbody>
                        <tr>
                            <td class="info-cell-header" width="419px">Description</td>
                            <td class="info-cell-header" width="50px">Taxes</td>
                            <td class="info-cell-header" style="text-align:right; padding-right:15px;" width="50px">Qty</td>
                            <td class="info-cell-header" style="text-align:right;" width="61px">Unit Price</td>
                            <td class="info-cell-header" style="text-align:right;" width="100px">Amount</td>
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
                            <td class="table_line" style="text-align: left; height:${line_item_height}px;">${line_item_print[line_no][0]}
                            </td>
                            <td class="table_line" style="text-align: left; height:${line_item_height}px;">${line_item_print[line_no][1]}
                            </td>
                            <td class="table_line" style="text-align: right; height:${line_item_height}px; padding-right:15px;">${line_item_print[line_no][2]} ${line_item_print[line_no][3]}
                            </td>
                            <td class="table_line" style="text-align: right; height:${line_item_height}px;">${line_item_print[line_no][4]}
                            </td>
                            <td class="table_line" style="text-align: right; height:${line_item_height}px;">${line_item_print[line_no][5]} ${line_item_print[line_no][6]}
                            </td>
                        </tr>
                        <% sum_line += float(line_item_print[line_no][7] or '0.0') %>
                    %endif
                %endfor

                            <%current_line = last_line%>
                    </tbody>
                </table>
            %if current_page == total_page:
                <table>
                    <tbody>
                        <tr>
                            <td class="v-spacer"></td>
                            <td></td>
                            <td></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td width="auto"></td>
                            <td width="146px" class="top-cell">Total Amount :</td>
                            <td width="10px" class="top-cell">${currency}</td>
                            <%amount_untaxed = formatLang(obj.amount_untaxed,2)%>
                            <td width="91px" class="top-cell" style="text-align: right;">${amount_untaxed or '0.00'|entity}</td>
                            <!--td width="91px" class="top-cell" style="text-align: right;">${obj.amount_untaxed or '0.00'|entity}</td-->
                        </tr>
                        <tr>
                            <td></td>
                            <td>Taxes :</td>
                            <td>${currency}</td>
                            <%amount_tax = formatLang(obj.amount_tax,2)%>
                            <td style="text-align:right;">${amount_tax or '0.00'|entity}</td>
                            <!--td style="text-align:right;">${obj.amount_tax or '0.00'|entity}</td-->
                        </tr>
                        <tr>
                            <td></td>
                            <td class="top-cell"><b>Grand Total :</b></td>
                            <td class="top-cell">${currency}</td>
                            <%amount_total = formatLang(obj.amount_total,2)%>
                            <td class="top-cell" style="text-align: right;">${amount_total or '0.00'|entity}</td>
                        </tr>
                        <tr>
                            <td class="v-spacer"></td>
                            <td></td>
                            <td></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td class="extra-info" width="155px">Consignee :</td>
                            <td class="extra-info" width="250px">
                            ${obj.get_purchase_info_by_name(info_name='Consignee')[obj.id] or '' | n}
                            </td>
                            <td></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td class="extra-info">Shipping Date :</td>
                            <td class="extra-info">
                            ${obj.get_purchase_info_by_name(info_name='Shipping Date')[obj.id] or '' | n}
                            </td>
                            <td></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td class="extra-info">Shipping Terms :</td>
                            <td class="extra-info">
                            ${obj.get_purchase_info_by_name(info_name='Shipping Terms')[obj.id] or '' | n}
                            </td>
                            <td></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td class="extra-info">Payment Terms :</td>
                            <td class="extra-info">
                            ${obj.get_purchase_info_by_name(info_name='Payment Terms')[obj.id] or '' | n}
                            </td>
                            <td></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <br/>
                                ${obj.notes or ''|entity}
                                <br/><br/><br/><br/><br/>
                            </td>
                            <td></td>
                        </tr>
                    </tbody>
                </table>
              </td>
              <td><br/></td>
            </tr>
            <tr>
                <td style="text-align:center;">
                    Authorized by,
                    <br/><br/><br/><br/><br/>Djoko Widjaja
                    ${signatory(obj.company_id.id)}<br/>
                    ${obj.company_id and obj.company_id.name or ''|entity}
                </td>
                <td></td>
                <td style="text-align:center;">
                    Approved by,
                    <br/><br/><br/><br/><br/>
                    (&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;)
                </td>
            </tr>
            %endif
        </tbody>
    </table>
    <table>
        <tbody>
            <tr>
                <td colspan="6" rowspan="2" style="text-align: right; vertical-align: bottom;">
                    Page ${current_page} of ${total_page}
                </td>
            </tr>
        </tbody>
    </table>
    %if current_page < total_page:
        <p style="page-break-after:always; margin: 0px;"></p>
    %endif
%endfor
</body>
    <!-- Tambahkan page break kecuali untuk dokumen terakhir-->
    %if records > 1:
    <p style="page-break-after:always; margin: 0px;"></p>
      <%records = records - 1 %>
    %endif
  %endif
%endfor

<!--
###################################################################################################
                                WRONG STATE STATEMENT
###################################################################################################
-->
%if wrong_state:
    <p style="page-break-after:always"></p>
    <small>
        <br/><br/><br/>
        <b>The following documents are not printed because the state is not valid:</b><br/>
            ${', '.join(wrong_state)}
    </small>
%endif
</html>
