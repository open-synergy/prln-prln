<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
  <style type="text/css">
    body {
      width:       700.700787402px;
      height:      900.842519685px;
      margin:      0px;
      font-family: "Sans-Serif", Times, serif;
      font-size:   11px;
    }

    .pbreakaft {
      page-break-after: always;
    }

    body table {
      width: 100%;
      border-collapse: collapse;
    }

    .header-row {
      border-bottom: 1px solid black;
    }

    .info-cell-header {
      text-align: center;
      border: 1px solid black;
      font-weight: bold;
      vertical-align: middle;
    }

    .info-cell {
      text-align: center;
      border-right: 1px solid black;
      vertical-align: top;
    }

    .left-cell {
      border-left: 0px !important;
    }

    .right-cell {
      border-right: 0px !important;
    }

    .bottom-cell {
      border-bottom: 1px solid black !important;
    }

    .extra-info {
      border: 1px solid #eaeaea;
    }
  </style>
</head>
<% wrong_state = [] %>
<% first_page = True %>
%for obj in objects:
  <% start_from = 0 %>
  <% limit = 5 %>
  <%increment = limit%>
  <%counter = 1%>
  %if obj.state != 'draft':
    <% wrong_state.append('%s: %s' % (obj.name, obj.state)) %>
  %else:
    %if first_page:
      <% first_page = False %>
    %else:
      <p class="pbreakaft"></p>
    %endif
    <% import math %>
    <% prod_lines = len(obj.order_line) %>
    <% loop_page = prod_lines and int(math.ceil(prod_lines * 1.0 / limit)) or 1%>
    %for x in range(0, loop_page):
      %if start_from > limit or counter > 0:
        <br/>
      %else:
        ${}
      %endif
      <body>
        <br/><br/>
        <table cellpadding="2" cellspacing="2">
          <tbody>
            <tr>
              <td class="header-row" width="320px">
                ${helper.embed_logo_by_name('pralon_logo', 166) | n}<br/>
              </td>
              <td class="header-row"><br/></td>
              <td class="header-row" style="vertical-align: bottom;text-align: right;" width="280px">
                PERTAMA dan TERBAIK<br/>
              </td>
            </tr>
            <tr>
              <td>
                ${obj.company_id and obj.company_id.name or '' | entity}<br/>
                ${obj.company_id and obj.company_id.street or '' | entity}<br/>
                ${obj.company_id and obj.company_id.zip or '' | entity} ${obj.company_id and obj.company_id.city or '' | entity} - ${obj.company_id and obj.company_id.country_id.name or '' | entity}<br/>
                Phone: ${obj.company_id and obj.company_id.phone or ''|entity}<br/>
                <table>
                  <tbody>
                  <tr>
                      <td class="header-row" width="200px">
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
              <td style="vertical-align: top;" colspan="2">
                <b>Expected Shipping Address :</b>
                <br/>
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
              <td style="vertical-align: top;">
                ${obj.partner_id and obj.partner_id.name or ''|entity}<br />
                <% address_obj = obj.partner_address_id or False %>
                %if address_obj:
                  ${address_obj.street or ''|entity}<br/>
                  ${address_obj.street2 or ''|entity}<br/>
                  ${address_obj.city or ''|entity}<br/>
                  ${address_obj.country_id and address_obj.country_id.name or ''|entity}<br />
		  Tel : ${address_obj.phone or ''|entity}<br/>
		  Fax : ${address_obj.fax or ''|entity}
                %endif
                <br/><br/><br/>
              </td>
            </tr>
            <tr>
              <td colspan="3">
              <p style="font-weight:bold; font-size:14px; padding:0px; margin:0px;">
                Request for Quotation : ${obj.name or '' | entity}</p>
              </td>
            </tr>
            <tr>
              <td colspan="3">
                <table>
                  <tr>
                    <td class="info-cell-header left-cell">Description</td>
                    <td class="info-cell-header">Expected Date</td>
                    <td class="info-cell-header right-cell">Qty</td>
                  </tr>
                  %for no in obj.order_line:
                  <tr>
                    <td class="info-cell" style="text-align: left !important;">
                      ${no.name or ''|entity}<br/>
                      &nbsp;&nbsp;&nbsp;&nbsp;${no.notes or ''|entity}
                    </td>
                    <td class="info-cell">
                      ${obj.minimum_planned_date and date_order_fmt(obj.minimum_planned_date) or '' | n}<br/>
                    </td>
                    <td class="info-cell right-cell">
                      ${no.product_qty or ''|entity} ${no.product_uom.name or '' | entity}
                    </td>
                  </tr>
                  %endfor
                  <tr>
                    <td class="bottom-cell info-cell">&nbsp;</td>
                    <td class="bottom-cell info-cell"></td>
                    <td class="bottom-cell info-cell right-cell"></td>
                  </tr>
                </table>
              </td>
            </tr>
            <tr>
              <td colspan="3">
                <br/><br/><br/>
                <table style="width:auto !important;">
                  <tr>
                    <td class="extra-info">Shipping Terms :</td>
                    <td class="extra-info" width="300px">
                      ${obj.get_purchase_info_by_name(info_name='Shipping Terms')[obj.id] or '' | n}
                    </td>
                  </tr>
                  <tr>
                    <td class="extra-info">Pricing Terms :</td>
                    <td class="extra-info">
                      ${obj.get_purchase_info_by_name(info_name='Pricing Terms')[obj.id] or '' | n}
                    </td>
                  </tr>
                  <tr>
                    <td class="extra-info">Payment Terms :</td>
                    <td class="extra-info">
                      ${obj.get_purchase_info_by_name(info_name='Payment Terms')[obj.id] or '' | n}
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
            <tr>
              <td colspan="3">
                <br/><br/>
                ${obj.notes or ''|entity}
                <br/><br/><br/>
                Regards,
                <br/><br/><br/><br/><br/>
                ${ get_user(cr, uid, uid) or ''| n }
              </td>
            </tr>
            <tr>
              <td></td>
              <td></td>
            </tr>
            <tr>
              <td><br/></td>
              <td><br/></td>
            </tr>
          </tbody>
        </table>
        <small>
          <div style="text-align:right;margin-top:300px;">
            page ${counter} of ${loop_page}
          </div>
        </small>
      </body>
    %endfor
  %endif
%endfor
%if wrong_state:
  <p style="page-break-after: always"></p>
  <small>
    <br/><br/><br/><br/>
    <b>The following documents are not printed because the state is not valid:</b><br/>
    ${', '.join(wrong_state)}
  </small>
%endif
</html>
