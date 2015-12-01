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


class rwk_purchase_requisition(report_sxw.rml_parse):
    def __init__(self, cr, uid, name, context):
        super(rwk_purchase_requisition, self).__init__(cr, uid, name, context=context)
        self.localcontext.update({
            'time': time,
            'cr': cr,
            'uid': uid,
            'amount_say': self.amount_say,
            'date_order_fmt': self.date_order_fmt,
        })

    def amount_say(self, nbr, lang='id', currency='Rupiah'):
        return utilities.amount_to_text_id.amount_to_text(nbr, lang=lang, currency=currency)

    def date_order_fmt(self, value=None):
        return utilities.date_order_fmt(value=value)

report_sxw.report_sxw('report.webkit_pr',
                       'purchase.requisition',
                       'addons/pralon_forms/purchase/purchase_requisition.mako',
                       parser=rwk_purchase_requisition)
