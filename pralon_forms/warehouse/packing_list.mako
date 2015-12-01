<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head><meta content="text/html; charset=ISO-8859-1" http-equiv="content-type" /></head>
  <style>
    body {
    font-size: 11px;
    }
  </style>
<%pages = len(objects)%>
<% wrong_state = [] %>
<% records = len(objects)%>
%for pl in objects:
  <% counter = 0 %><% nomer = 1 %>
  <%start_from = 0%>
  <%limit = 20%>
  <%increment = limit%>
  %if pl.state not in ('draft','confirmed','assigned','approved', 'done'):
    <% wrong_state.append('%s: %s' % (pl.name, pl.state)) %>
  %else:
    <body>
      <table style="text-align: left; width: 100%;border-collapse: collapse;" cellpadding="2" cellspacing="2">
        <tr>
          <td style="vertical-align: top;border-bottom:1px solid #000000;" width="188.976377953px"><br/>${helper.embed_logo_by_name('pralon_logo', 166)|n}<br /></td>
          <td style="vertical-align: top; border-bottom:1px solid #000000;"><br /></td>
          <td style="vertical-align: bottom;text-align:right;border-bottom:1px solid #000000;" width="238.11023622px">PERTAMA dan TERBAIK<br /></td>
        </tr>
        <tr>
          <td style="vertical-align: top;">${pl.company_id and pl.company_id.name or ''|entity}<br />
            ${pl.company_id and pl.company_id.street or ''|entity}<br />
            ${pl.company_id and pl.company_id.zip or ''|entity} ${pl.company_id and pl.company_id.city or ''|entity} - ${pl.company_id and pl.company_id.country_id and pl.company_id.country_id.name or ''|entity}<br />
            <table style="width: 100%;border-collapse: collapse;">
              <tr>
                <td width="200px">Phone: ${pl.company_id and pl.company_id.phone or ''|entity}</td>
              </tr>
              <tr>
                <td style="border-bottom:1px solid #000000;">Mail: ${pl.company_id and pl.company_id.email or ''|entity}</td>
              </tr>
            </table>
            <br/>
            <br/>
          </td>
          <td style="vertical-align: top;"><br /></td>
          <td style="vertical-align: top;"><br /></td>
        </tr>
        <tr>
          <td style="vertical-align: top;">
            <b>Shipping address :</b><br />
            ${pl.address_id and pl.address_id.partner_id and pl.address_id.partner_id.name or ''|entity}<br />
            ${pl.address_id and pl.address_id.street or ''|entity}<br />
            ${pl.address_id and pl.address_id.city or ''|entity},
            ${pl.address_id and pl.address_id.zip or ''|entity}<br />
            ${pl.address_id and pl.address_id.country_id and pl.address_id.country_id.name or ''|entity}
            </td>
          <td style="vertical-align: top;">
            <b>Contact Address :</b><br />
            ${pl.address_id and pl.address_id.partner_id and pl.address_id.partner_id.name or ''|entity}<br />
            ${pl.address_id and pl.address_id.street or ''|entity}<br />
            ${pl.address_id and pl.address_id.city or ''|entity},
            ${pl.address_id and pl.address_id.zip or ''|entity}<br />
            ${pl.address_id and pl.address_id.country_id and pl.address_id.country_id.name or ''|entity}
          </td>
          <td style="vertical-align: top;"><br/><br/><br/></td>
        </tr>
        <tr>
          <td colspan="3">
            <h2>
              %if pl.type == 'in':
                Reception: ${pl.name or ''|entity}
              %elif pl.type == 'out':
                Packing List: ${pl.name or ''|entity}
              %else:
                Picking List: ${pl.name or ''|entity}
              %endif
            </h2>
          </td>
        </tr>
        <tr>
          <table border="1" style="width: 100%;border-collapse: collapse;border:solid 1px #eaeaea;">
            <tr>
              <td><b>Journal</b></td>
              <td><b>Order(Origin)</b></td>
              <td><b>Recipient</b></td>
              <td><b>Expected Shipping Date</b></td>
              <td><b>Weight</b></td>
            </tr>
            <tr>
              <td>${pl.stock_journal_id and pl.stock_journal_id.name or ''|entity}</td>
              <td>${pl.origin or ''|entity}</td>
              <td>${pl.address_id and pl.address_id.name or ''|entity}</td>
              <td>${ date_order_fmt(pl.min_date) or '' |entity}</td>
              <td>${pl.weight or ''|entity}</td>
            </tr>
          </table>
          <br/>
        </tr>
        <tr>
          <table style="width: 100%;border-collapse: collapse;">
            <tr>
	      <td style="border-bottom:solid 1px #000000;">No.</td>
              <td style="border-bottom:solid 1px #000000;" width="450px"><b>Description</b></td>
              <!--td style="border-bottom:solid 1px #000000;" width="150px"><b>Lot</b></td-->
              <!--td style="border-bottom:solid 1px #000000;"><b>State</b></td-->
              <td style="border-bottom:solid 1px #000000;" width="150px"><b>Location</b></td>
              <td style="border-bottom:solid 1px #000000;text-align:center;" colspan="2"><b>Quantity</b></td>
            </tr>
            <%total = 0%>
            %for items in pl.move_lines:
            <tr>
	      <td align=right>${nomer}.<% nomer += 1 %></td>
              <td>${items.product_id and items.product_id.name or ''|entity}</td>
              <!--td>${items.prodlot_id and items.prodlot_id.name or ''|entity}</td-->
              <!--td>${items.state or ''|entity}</td-->
              <td>${items.location_id.name or ''|entity}</td>
              <td style="text-align:right;">${items.product_qty or ''|entity}</td>
              <td>${items.product_uom.name or ''|entity}</td>
            </tr>
            <% total += items.product_qty%>
            %endfor
            <tr>
              <td style="border-top:solid 1px #eaeaea;"></td>
	      <td style="border-top:solid 1px #eaeaea;"></td>
              <!--td style="border-top:solid 1px #eaeaea;"></td>
              <td style="border-top:solid 1px #eaeaea;"></td-->
              <td style="border-top:solid 1px #000000;"><b>Total</b></td>
              <td style="border-top:solid 1px #000000;text-align:right;"><b>${formatLang(total) or ''|entity}</b></td>
              <td style="border-top:solid 1px #000000;"><b></b></td>
            </tr>
          </table>
        </tr>
      </table>
    </body>
    %if records  > 1:
      <p style="page-break-after:always;"></p><br/><br/>
      <% records = records - 1 %>
    %else:
      ${}
    %endif
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
