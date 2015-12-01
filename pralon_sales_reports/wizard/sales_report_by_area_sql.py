# -*- encoding: utf-8 -*-
##############################################################################
#
#    OpenERP, Open Source Management Solution
#    Copyright (c) 2011 - 2014 Vikasa Infinity Anugrah <http://www.infi-nity.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see http://www.gnu.org/licenses/.
#
##############################################################################

sales_report_by_area_sql = lambda: """
WITH sales_per_customer_per_area AS
  (SELECT DISTINCT ai.id AS ai_id,
                   (CASE WHEN sp.area_address_id IS NULL THEN addr.state_id ELSE end_user_addr.state_id END) AS state_id,
                   ai.partner_id AS partner_id,
                   cr.rate,
                   (CASE WHEN ai.type = 'out_invoice' THEN NULLIF(ail.quantity * pt.weight_net, 0.0) * 1 ELSE NULLIF(ail.quantity * pt.weight_net, 0.0) * -1 END) AS weight,
                   (CASE WHEN ai.type = 'out_invoice' THEN (ail.price_subtotal / cr.rate) * 1 ELSE (ail.price_subtotal / cr.rate) * -1 END) AS amount
   FROM account_invoice_line ail
   LEFT JOIN account_invoice ai ON ai.id = ail.invoice_id
   LEFT JOIN stock_move_invoice_line_rel smilr ON smilr.invoice_line_id = ail.id
   LEFT JOIN stock_move sm ON sm.id = smilr.move_id
   LEFT JOIN stock_picking sp ON sp.id = sm.picking_id
   LEFT JOIN res_partner_address end_user_addr ON sp.area_address_id = end_user_addr.id
   LEFT JOIN res_partner_address addr ON sp.address_id = addr.id
   LEFT JOIN product_product pp ON ail.product_id = pp.id
   INNER JOIN product_template pt ON pp.product_tmpl_id = pt.id
   INNER JOIN res_currency_rate cr ON cr.currency_id = ai.currency_id
   WHERE cr.id IN
       (SELECT cr2.id
        FROM res_currency_rate cr2
        WHERE cr2.currency_id = ai.currency_id
          AND cr2.name <= ai.date_invoice
        ORDER BY cr2.name DESC LIMIT 1)
     AND ai.state IN ('open',
                      'paid')
     AND ai.type IN ('out_invoice',
                     'out_refund')
     $P!{CUSTOMER_IDS}
     AND ai.date_invoice::DATE BETWEEN '$P!{FROM_DATE_2_YR}-$P!{FROM_DATE_2_MO}-$P!{FROM_DATE_2_DY}' AND '$P!{TO_DATE_2_YR}-$P!{TO_DATE_2_MO}-$P!{TO_DATE_2_DY}'
     AND ai.company_id IN ($P!{COMPANY_IDS}))
SELECT sba.partner_id AS cust_id,
       COALESCE(area.name, 'Without Area') AS area,
       rp.name AS cust_name,
       sba.state_id AS state_id,
       SUM(sba.amount) AS cust_amt,
       SUM(sba.weight) AS weight
FROM sales_per_customer_per_area sba
LEFT JOIN res_partner rp ON sba.partner_id = rp.id
LEFT JOIN res_country_state area ON sba.state_id = area.id
GROUP BY area.name,
         cust_id,
         state_id,
         cust_name
ORDER BY area.name NULLS LAST,
         cust_name
"""
