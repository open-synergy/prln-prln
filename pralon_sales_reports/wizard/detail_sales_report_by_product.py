# -*- encoding: utf-8 -*-
###############################################################################
#
#  Vikasa Infinity Anugrah, PT
#  Copyright (C) 2013 Vikasa Infinity Anugrah <http://www.infi-nity.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as
#  published by the Free Software Foundation, either version 3 of the
#  License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see http://www.gnu.org/licenses/.
#
###############################################################################

from osv import osv, fields
from tools.translate import _
from via_reporting_utility.pgsql import list_to_pgTable
from via_jasper_report_utils.framework import register_report_wizard, wizard
import decimal_precision as dp

RPT_NAME = 'Detail Sales Report By Product'

_ARRAY_NAME = 'account_invoice_lines'

_TABLE_NAME = 'ACCOUNT_INVOICE_LINE_TABLE'

RPT_SQL = """
SELECT
    ai.date_invoice AS so_date,
    ai.number AS inv_number,
    (CASE
        WHEN ai.type = 'out_invoice'
            THEN so.name
        WHEN ai.type = 'out_refund'
            THEN COALESCE ('R-' || acc_i.number, 'REFUND NO INVOICE')
        ELSE ''
    END) AS so_number,
    COALESCE(rp.ref, '') || COALESCE( '-' || rpt.name || '. ','') || COALESCE(rp.name, '')  AS so_cust_name,
    COALESCE(pp.name_template, 'Without Product ID') AS prod,
    (CASE
        WHEN ai.type = 'out_invoice'
            THEN ail.quantity * 1
        ELSE ail.quantity * -1
    END) AS sol_qty,
    uom.name AS prod_uom,
    (CASE
        WHEN ai.type = 'out_invoice'
            THEN pt.weight_net * 1
        ELSE pt.weight_net * -1
    END) AS prod_weight,
    (CASE
        WHEN ai.type = 'out_invoice'
            THEN ail.quantity * pt.weight_net * 1
        ELSE ail.quantity * pt.weight_net * -1
    END) AS sol_weight,
    (CASE
        WHEN ai.type = 'out_invoice'
            THEN ail.price_subtotal * 1
        ELSE ail.price_subtotal * -1
    END) / cr.rate AS sol_subtotal,
    (CASE
        WHEN ai.type = 'out_invoice'
            THEN ail.price_subtotal / NULLIF(ail.quantity * pt.weight_net, 0.0) * 1
        ELSE ail.price_subtotal / NULLIF(ail.quantity * pt.weight_net, 0.0) * -1
    END) / cr.rate AS sol_unit_price,
    COALESCE(pc$P!{PROD_GROUP_LEVEL}.name, 'Without Product Category') AS prod_cat,
    ai.number AS sol_discount
FROM
    $P!{%s}
INNER JOIN account_invoice_line ail
    ON ail.id = %s.id
INNER JOIN account_invoice ai
    ON ai.id = ail.invoice_id
LEFT JOIN account_invoice_refund_invoice airi
    ON airi.invoice_refund_id = ai.id
LEFT JOIN account_invoice acc_i
    ON acc_i.id = airi.invoice_id
INNER JOIN res_partner rp
    ON rp.id = ai.partner_id
LEFT JOIN res_partner_title rpt
    ON rpt.id = rp.title
LEFT JOIN sale_order_line_invoice_rel soir
    ON soir.invoice_id = ail.id
LEFT JOIN sale_order_line sol
    ON sol.id = soir.order_line_id
LEFT JOIN sale_order so
    ON so.id = sol.order_id
LEFT JOIN product_product pp
    ON pp.id = ail.product_id
LEFT JOIN product_template pt
    ON pt.id = pp.product_tmpl_id
LEFT JOIN product_uom uom
    ON uom.id = ail.uos_id
$P!{PROD_CAT_CLAUSE},
res_currency_rate cr
WHERE cr.id IN
    (SELECT id
    FROM res_currency_rate cr2
    WHERE (cr2.currency_id = ai.currency_id)
    AND ((ai.date_invoice IS NOT NULL AND cr.name <= ai.date_invoice)
    OR (ai.date_invoice is null and cr.name <= NOW()))
    ORDER BY id DESC LIMIT 1)
ORDER BY pc$P!{PROD_GROUP_LEVEL}.name, prod, inv_number, so_number
""" % (_TABLE_NAME, _ARRAY_NAME)


class wizard(wizard):
    def onchange_company_ids(cr, uid, ids, com_ids, context=None):
        # Sample com_ids = [(6, 0, [14, 11])]
        if len(com_ids) == 0:
            return {
                'domain': {'prod_ids': [('product_tmpl_id.company_id', '=', False)]},
                'value': {'prod_ids': False},
            }
        return {
            'domain': {'prod_ids': [('product_tmpl_id.company_id', 'in', com_ids[0][2])]},
            'value': {'prod_ids': False},
        }

    _onchange = {
        'company_ids': (onchange_company_ids, 'company_ids', 'context'),
    }

    _visibility = [
        'company_ids',
        ['from_dt', 'to_dt'],
        'prod_group_level',
    ]

    _label = {
        'from_dt': 'Invoice Date From',
    }

    _required = ['from_dt', 'to_dt', 'prod_group_level']

    def get_ail(self, cr, uid, form, context=None):
        _sql = """
            SELECT
                ail.id
            FROM
                account_invoice_line ail
            INNER JOIN account_invoice ai
                ON ail.invoice_id = ai.id
            LEFT JOIN product_product pp
                ON ail.product_id = pp.id
            WHERE
                ai.type in ('out_invoice', 'out_refund')
            AND ai.state in ('open', 'paid')
            AND ai.company_id IN (%s)
            AND (ail.product_id IN (%s) OR ail.product_id IS NULL)
            AND pp.excluded_product IS NOT TRUE
            AND ai.date_invoice BETWEEN '%s' AND '%s'
        """
        cr.execute(_sql % (
            ','.join(str(com_id.id) for com_id in form.company_ids),
            ','.join(str(prod_id) for prod_id in form.get_prod_ids(context=context)),
            form.from_dt,
            form.to_dt))

        return [(record[0]) for record in cr.fetchall()]

    def validate_parameters(self, cr, uid, form, context=None):
        if len(form.company_ids) == 0:
            raise osv.except_osv(_('Caution !'),
                                 _('No page will be printed !'))

        form.validate_prod_level(context=context)

    def print_report(self, cr, uid, form, context=None):
        self.validate_parameters(cr, uid, form, context=context)

        _ails = self.get_ail(cr, uid, form, context=context)
        _ails_table = list_to_pgTable(_ails, _ARRAY_NAME, [('id', 'INTEGER')])
        form.add_marshalled_data(_TABLE_NAME, _ails_table)
        form.add_marshalled_data('RPT_SQL', RPT_SQL)
        prec = self.pool.get('decimal.precision').precision_get(cr, uid, 'Product UoM')
        zero = '0' * prec
        form.add_marshalled_data('QTY_FORMAT', "#,##0.%s;-#,##0.%s" % (zero,zero))
        
register_report_wizard(RPT_NAME, wizard)
