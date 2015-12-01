<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
  <style type="text/css">
    .main {
      font-size:   12px;
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
    }

    .header-row {
      border-bottom: 1px solid black;
    }

    .header-cell-header {
      border: 1px solid #eaeaea;
      vertical-align: middle;
      font-weight: bold;
      text-align: center;
    }

    .header-cell {
      text-align: center;
      border: 1px solid #eaeaea;
      vertical-align: top;
    }

    .info-cell-header {
      border-bottom:1px solid black;
      vertical-align: middle;
      font-weight: bold;
      text-align: left;
    }

    .info-cell {
      vertical-align: top;
      border-bottom:1px solid #eaeaea;
      text-align: left;
    }
  </style>
</head>
<% pages = len(objects) %>
<% pg = []%>
<% wrong_state = [] %>
<% first_page = True %>
%for obj in objects:
  <% limit = 25 %>
  <% inc = limit %>
  <% counter = 0 %>
  <% start_from = 0 %>
  %if obj.state not in ('in_progress', 'done'):
    <% wrong_state.append('%s: %s' % (obj.name, obj.state)) %>
  %else:
    %if first_page:
      <% first_page = False %>
    %else:
      <p class="pbreakaft"></p>
    %endif
    <% import math %>
    <% prod_lines = len(obj.line_ids) %>
    <% loop_page = prod_lines and int(math.ceil(prod_lines * 1.0 / limit)) or 1%>
    %for x in range(0, loop_page):
      %if start_from > limit or counter > 0:
        <p class="pbreakaft"></p><br/>
      %else:
        ${}
      %endif
      <body>
        <div class="main">
          <table cellpadding="2" cellspacing="2">
            <tbody>
              <tr>
                <td class="header-row" width="189px">
                  ${helper.embed_logo_by_name('pralon_logo', 166) | n}<br/>
                </td>
                <td class="header-row"><br/></td>
                <td class="header-row" style="vertical-align: bottom;text-align: right;" width="238px">
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
            </tbody>
          </table>
          <br/>
          <table height="30px">
            <tbody>
              <tr>
                <td style="font-weight: bold; font-size: 18px;">
                  Purchase Requisitions ${obj.name or '' | entity}
                </td>
              </tr>
            </tbody>
          </table>
          <br/>
          <table cellpadding="2" cellspacing="2">
            <tbody>
              <tr height="37">
                <td class="header-cell-header">Requisition Reference<br/></td>
                <td class="header-cell-header">Requisition Date<br/></td>
                <td class="header-cell-header">Type<br/></td>
                <td class="header-cell-header">Origin<br/></td>
              </tr>
              <tr>
                <td class="header-cell" style="text-align: left !important">${obj.name or '' | entity}</td>
                <td class="header-cell">${date_order_fmt(obj.date_start) |n}</td>
                <td class="header-cell">${obj.exclusive or '' | entity}</td>
                <td class="header-cell">${obj.origin or '' | entity}</td>
              </tr>
            </tbody>
          </table>
          <br/>
          <p style="font-weight:bold;">Product Detail</p>
          <table style="width: 100%; border-collapse: collapse;">
            <tr>
              <td class="info-cell-header">Description</td>
              <td class="info-cell-header" style="text-align:right !important;">Qty</td>
              <td class="info-cell-header" style="padding-left:15px;">Product UoM</td>
            </tr>
            %if start_from !=0:
              <% start_from = start_from%>
              <% pg = "<p class='pbreakaft'></p>" %>
            %else:
              <% start_from = 0%>
              <% count = 1%>
            %endif
            %for line_id in obj.line_ids[start_from:limit]:
              <tr>
                <td class="info-cell">
                  ${line_id.product_id and line_id.product_id.name or '' | entity}
                </td>
                <td class="info-cell" style="text-align: right !important; padding-right: 5px;">
                  ${line_id.product_qty and line_id.product_qty.name or '' | entity}
                </td>
                <td class="info-cell" style="padding-left:15px;">
                  ${line_id.product_uom_id and line_id.product_uom_id.name or '' | entity}
                </td>
              </tr>
              <% count += 1 %>
            %endfor
            <% count = count %>
            <% start_from += inc %>
            <% limit += inc %>
          </table>
          <br/>
          <p style="font-weight:bold;">Quotation Detail</p>
          <table>
            <tr>
              <td class="info-cell-header">Supplier</td>
              <td class="info-cell-header" style="text-align: center !important;">Date Ordered</td>
              <td class="info-cell-header">Order Reference</td>
            </tr>
            %if start_from !=0:
              <% start_from = start_from%>
              <% pg = "<p class='pbreakaft'></p>" %>
            %else:
              <% start_from = 0%>
              <% count = 1%>
            %endif
            %for purchase_id in obj.purchase_ids:
              <tr>
                <td class="info-cell">
                  ${purchase_id.partner_id and purchase_id.partner_id.name or '' | entity} 
                </td>
                <td class="info-cell" style="text-align: center !important; padding-right: 5px;">
                  ${date_order_fmt(purchase_id.date_order) | n}
                </td>
                <td class="info-cell">
                  ${purchase_id.name or '' | entity}
                </td>
              </tr>
              <% count += 1 %>
            %endfor
            <% count = count %>
            <% start_from += inc %>
            <% limit += inc %>
          </table>
        </div>
        <% counter += 1 %>
        <small>
          page ${counter} of ${loop_page}
        </small>
      </body>
    %endfor
  %endif
%endfor
%if wrong_state:
<p style="page-break-after: always;"></p>
<small>
<br/><br/><br/>
<b>The following documents are not printed because the state is not valid:</b><br/>
${', '.join(wrong_state)}
</small>
%endif
</html>
