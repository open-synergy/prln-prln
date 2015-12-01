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


class rwk_purchase_order(report_sxw.rml_parse):
    def __init__(self, cr, uid, name, context):
        super(rwk_purchase_order, self).__init__(cr, uid, name, context=context)
        self.localcontext.update({
            'time': time,
            'cr': cr,
            'uid': uid,
            'amount_say': self.amount_say,
            'date_order_fmt': self.date_order_fmt,
            'signatory': self.signatory,
            'wrap_line': self.wrap_line,
        })

    def amount_say(self, nbr, lang='id', currency='Rupiah'):
        return utilities.amount_to_text_id.amount_to_text(nbr, lang=lang, currency=currency)

    def date_order_fmt(self, value=None):
        return utilities.date_order_fmt(value=value)

    def signatory(self, coy_id=False):
        rv = ''
        if coy_id:
            _doc_id = self.pool.get('ir.model.data').get_object_reference(self.cr, self.uid, 'pralon_forms', 'doc_type_purchase_order')
            _coy_po_sig = _doc_id and self.pool.get('res.company').get_signatory_by_doc_id(self.cr, self.uid, coy_id, _doc_id[1]) or False
            rv = _coy_po_sig and _coy_po_sig.signature or ''
        return rv

    def wrap_line(self, column_list_source, column_width_list, total_column):
        return utilities.wrap_line(column_list_source, column_width_list, total_column)

report_sxw.report_sxw('report.webkit_po_def',
                       'purchase.order',
                       'addons/pralon_forms/purchase/purchase_order_default.mako',
                       parser=rwk_purchase_order)
