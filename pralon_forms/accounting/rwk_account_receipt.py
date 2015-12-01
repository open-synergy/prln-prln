# -*- encoding: utf-8 -*-
##############################################################################
#
#    OpenERP, Open Source Management Solution
#    Copyright (c) 2011 - 2013 Vikasa Infinity Anugrah <http://www.infi-nity.com>
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
from report import report_sxw
from .. import utilities


class rwk_account_receipt(report_sxw.rml_parse):
    def __init__(self, cr, uid, name, context):
        super(rwk_account_receipt, self).__init__(cr, uid, name, context=context)
        self.localcontext.update({
            'time': time,
            'cr': cr,
            'uid': uid,
            'amount_say': self.amount_say,
            'date_order_fmt': self.date_order_fmt,
            'get_taxform': self.get_taxform,
        })

    def get_taxform(self, invoice_id, context=None):
        _pool = self.pool.get('account.taxform')
        _obj_id = _pool.search(self.cr, self.uid, [('invoice_id', '=', invoice_id)], context=context)
        _obj = _obj_id and _pool.browse(self.cr, self.uid, _obj_id[0], context=context) or False
        return _obj and (_obj.taxform_id != '/') and _obj.taxform_id or ''

    def amount_say(self, nbr, lang='id', currency='Rupiah'):
        return utilities.amount_to_text_id.amount_to_text(abs(nbr), lang=lang, currency=currency)

    def date_order_fmt(self, value=None):
        return utilities.date_order_fmt(value=value)

report_sxw.report_sxw('report.webkit_receipt',
                       'account.invoice',
                       'addons/pralon_forms/accounting/receipt.mako',
                       parser=rwk_account_receipt)
