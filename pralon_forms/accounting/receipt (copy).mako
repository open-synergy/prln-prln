<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <style>
  .border_npwp {
    border: 1px solid black;
    border-collapse: collapse;
    text-align: center;
  }
  </style>
</head>
<% counter = 0 %>
<%pages = len(objects)%>
<% wrong_state = [] %>
%for inv in objects:
  %if inv.state != 'open' and inv.state !='paid' and inv.state != 'proforma' and inv.state != 'proforma2':
    <% wrong_state.append('%s: %s' % (inv.name, inv.state)) %>
  %else:
	<!--% bea_materai = (inv.amount_total >= 1000000) and 6000 or 3000 %-->
    <!--HWT : MEnambah level pengecekan utk materai-->
    %if (inv.amount_total <= 250000):
		<%bea_materai = 0%>
	%elif (inv.amount_total > 250000 and inv.amount_total <= 999999):
		<%bea_materai = 3000%>
	%else:
		<%bea_materai = 6000%>
	%endif
    <!--end HWT-->
    <% total = inv.amount_total + bea_materai %>
    <body style="font-size:12px;font-family:Sans-Serif;">
      <table style="text-align: left; width: 640px;" border="0" cellpadding="0" cellspacing="0">
        <tbody>
          <tr>
            <!--td height="120.622047244px"></td-->
            <td height="120px"></td>
          </tr>
          <tr height="300px">
            <td style="vertical-align: top;max-height: 404px;">
              <table style="text-align: left; width: 100%;" border="0" cellpadding="1" cellspacing="1">
                <tbody>
                  <tr>
                      <td width="20px"></td>
                      <td width="40px"></td>
                      <td width="120px"></td>
                      <td width="10px"></td>
                      <td width="360px"></td>
                      <td width="160px"></td>
                      <td width="1px"></td>
                  </tr>
                  <tr>
                    <td style="vertical-align: top;"><br/></td>
                    <td style="vertical-align: top;"><br/></td>
                    <td style="vertical-align: top;"><br/></td>
                    <td style="vertical-align: top;"><br/></td>
                    <td colspan="3" rowspan="1" style="vertical-align: top; font-size: 18px; font-weight: bold; text-decoration: underline;">
                      ${inv.state in ('proforma', 'proforma2') and 'BUKTI TANDA TERIMA' or 'BUKTI PEMBAYARAN'}
                      <br/>
                    </td>
                  </tr>
                  <tr>
                    <td style="vertical-align: top;"><br/></td>
                    <td colspan="2" rowspan="1" style="vertical-align: top; font-size: 10px; width: 350px;">No</td>
                    <td style="vertical-align: top;">:<br/></td>
                    <td style="vertical-align: top;font-size: 11px;">
                        ${inv.state not in ('proforma', 'proforma2') and inv.internal_number or ''}
                    </td>
                    <td style="vertical-align: top;"><br/></td>
                    <td style="vertical-align: top;"><br/></td>
                  </tr>
                  <tr>
                    <td style="vertical-align: top;"><br/></td>
                    <td colspan="2" rowspan="1" style="vertical-align: top; font-size: 10px;">TELAH TERIMA DARI<br/></td>
                    <td style="vertical-align: top;">:<br/></td>
                    <% xtitle = '' %>
                    %if inv.partner_id.title.name:
                        <% xtitle = inv.partner_id.title.name + '. '%>
                    %endif
                    <td style="vertical-align: top; font-size: 11px;" colspan="2">${xtitle} ${inv.partner_id and inv.partner_id.name or '' | entity}<br/>${inv.address_invoice_id and inv.address_invoice_id.street or '' | entity}<br/>
                    %if inv.address_invoice_id and inv.address_invoice_id.city != '' or inv.address_invoice_id and inv.address_invoice_id.zip != '' :
                    ${inv.address_invoice_id and inv.address_invoice_id.city or '' | entity} ${inv.address_invoice_id and inv.address_invoice_id.zip or '' | entity}<br/>${inv.address_invoice_id and inv.address_invoice_id.country_id and inv.address_invoice_id.country_id.name or '' | entity}
                    %else:
                    ${inv.address_invoice_id and inv.address_invoice_id.country_id and inv.address_invoice_id.country_id.name or '' | entity}
                    %endif
                    </td>
                    <!--td style="vertical-align: top;"><br/></td-->
                    <td style="vertical-align: top;"><br/></td>
                  </tr>
                  <tr>
                    <td style="vertical-align: top;"><br/></td>
                    <td colspan="2" rowspan="1" style="vertical-align: top; font-size: 10px;">UANG SEJUMLAH<br/></td>
                    <td style="vertical-align: top; font-size: 11px;">:<br/></td>
                    <td colspan="3" rowspan="1" style="vertical-align: top;font-size: 11px;">
                      ${total and amount_say(abs(total)) or '' | n}
                    </td>
                  </tr>
                  <tr>
                    <td style="vertical-align: top;"><br/></td>
                    <td colspan="2" rowspan="1" style="vertical-align: top; font-size: 10px;">UNTUK PEMBAYARAN<br/><br/><br/><br/><br/><br/><br/></td>
                    <td style="vertical-align: top; font-size: 11px;">:<br/></td>
                    <td style="vertical-align: top;" colspan="2">
                      <table style="font-size:12px;" width="461px">
                        <tbody>
                          <tr style="vertical-align: top; font-size: 10px;">
                            <td>Faktur No</td>
                            <td>:</td>
                            <td>${inv.internal_number or '' | entity}</td>
                            <td></td>
                            <td>Rp.&nbsp;</td>
                            <td style="text-align:right;">${inv.amount_untaxed or '' | entity}</td>
                          </tr>
                          <tr style="vertical-align: top; font-size: 10px;">
                            <td>Faktur Pajak No</td>
                            <td>:</td>
                            <td>010.000-
                              ${get_taxform(inv.id) or ''}
                            </td>
                            <td></td>
                            <td>Rp.&nbsp;</td>
                            <td style="text-align:right;">${inv.amount_tax or '0.00' | entity}</td>
                          </tr>
                          <tr style="vertical-align: top; font-size: 10px;">
                            <td>Sub Total</td>
                            <td>:</td>
                            <td></td>
                            <td></td>
                            <td>Rp.&nbsp;</td>
                            <td style="text-align:right;">${inv.amount_total or '' | entity}</td>
                          </tr>
                          <tr style="vertical-align: top; font-size: 10px;">
                            <td>Biaya Materai</td>
                            <td>:</td>
                            <td></td>
                            <td></td>
                            <td>Rp.&nbsp;</td>
                            <td style="text-align:right;">${bea_materai and formatLang(bea_materai) or '0,00' | n}</td>
                          </tr>
                          <tr style="vertical-align: top; font-size: 10px;">
                            <td>Total</td>
                            <td>:</td>
                            <td></td>
                            <td></td>
                            <td>Rp. </td>
                            <td style="text-align:right;">${total and formatLang(total) or '' | entity}</td>
                          </tr>
                        </tbody>
                      </table>
                    </td>
                    <td style="vertical-align: top;"><br/></td>
                  </tr>
                  <tr style="height: 20px;">
                    <td style="vertical-align: top;"><br/></td>
                    <td style="vertical-align: top; font-size: 18px; font-weight: bold;">Rp.&nbsp;</td>
                    <td colspan="3" rowspan="1" style="vertical-align: top; font-size: 18px;"><b>${total and formatLang(total) or '' | entity}</b></td>
                    
                    <td style="vertical-align: top; font-size: 11px;">Jakarta,&nbsp;
                    ${inv.date_invoice and date_order_fmt(inv.date_invoice) or '' |n}
                    </td>
                    <td style="vertical-align: top; font-size: 11px;"></td>
                  </tr>
                  <tr>
                    <td style="vertical-align: top;"></td>
                    <td colspan="4" rowspan="1" style="vertical-align: top; font-size: 9px; ">
                      <fieldset style="border: 1px solid ; padding: 3px; width:180px;">PEMBAYARAN DENGAN GIRO, CEK, DIANGGAP SAH APABILA CEK, GIRO TERSEBUT SUDAH DICAIRKAN.</fieldset>
                    </td>
		    
                    <td style="vertical-align: top; align: center;"><br /><br/><br/><br/><br />&nbsp;&nbsp;&nbsp;Tjiam Wahyu</td>
                    <!--td style="vertical-align: top;"><br/></td-->
                    <td style="vertical-align: top;"></td>
                  </tr>
                </tbody>
              </table>
            </td>
          </tr>
          <tr>
            <td style="vertical-align: top;"></td>
          </tr>
          </tbody>
      </table>
      <p style="page-break-after: always"></p>
    </body>
    <% counter+=1%>
  %endif
%endfor
%if wrong_state:
  <small>
    <br/><br/><br/>
    <b>The following documents are not printed because the state is not valid:</b><br/>
    ${', '.join(wrong_state)}
  </small>
%endif
</html>
