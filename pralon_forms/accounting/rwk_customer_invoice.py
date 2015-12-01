# -*- encoding: utf-8 -*-
##############################################################################
#
#    OpenERP, Open Source Management Solution
#    Copyright (c) 2011 - 2015 Vikasa Infinity Anugrah <http://www.infi-nity.com>
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

import time
import re
from report import report_sxw
from .. import utilities


class rwk_customer_invoice(report_sxw.rml_parse):
    def __init__(self, cr, uid, name, context):
        super(rwk_customer_invoice, self).__init__(cr, uid, name, context=context)
        self.localcontext.update({
            'time': time,
            'cr': cr,
            'uid': uid,
            'sum_subtotal': self.sum_subtotal,
            'sum_discount': self.sum_discount,
            'get_base': self.get_base,
            'get_ppn': self.get_ppn,
            'amount_say': self.amount_say,
            'filter_npwp': self.filter_npwp,
            'date_order_fmt': self.date_order_fmt,
            'wrap_line': self.wrap_line,
            'currency': self.localcontext.get('user').company_id.currency_id,
        })

    def round_currency(self, amount):
        currency = self.localcontext.get('currency', False)
        rv = currency and self.pool.get('res.currency').round(self.cr, self.uid, currency, amount) or amount
        return rv

    def sum_subtotal(self, taxform_lines):
        return self.round_currency(utilities.sum_subtotal(taxform_lines))

    def sum_discount(self, taxform_lines):
        return self.round_currency(utilities.sum_discount(taxform_lines))

    def get_base(self, taxform_lines, round=True):
        if round:
            _base = 0.0
            for _line in taxform_lines:
                _base += self.round_currency(utilities.get_base([_line]))
            return _base
        else:
            return utilities.get_base(taxform_lines)

    def get_ppn(self, invoice_lines):
        return self.round_currency(self.get_base(invoice_lines, round=False) * 10.0 / 100.0)

    def date_order_fmt(self, value=None):
        return utilities.date_order_fmt(value=value)

    def wrap_line(self, column_list_source, column_width_list, total_column):
        return utilities.wrap_line(column_list_source, column_width_list, total_column)

    def amount_say(self, nbr, lang='id', currency='Rupiah'):
        return utilities.amount_to_text_id.amount_to_text(abs(nbr), lang=lang, currency=currency)

    def filter_npwp(self, npwp_list=[]):
        res_id = self.pool.get('ir.model.data').get_object_reference(self.cr, self.uid, 'via_account_taxform', 'partner_parameter_taxform')
        npwp = ''
        for item in npwp_list:
            if item.parameter_id.id == res_id[1]:
                npwp = item.value
                break

        npwp = list(re.sub(r'[^0-9.-]+', '', npwp))
        return npwp or []

report_sxw.report_sxw('report.webkit_cust_invoice',
                      'account.invoice',
                      'addons/pralon_forms/accounting/customer_invoice.mako',
                      parser=rwk_customer_invoice)
