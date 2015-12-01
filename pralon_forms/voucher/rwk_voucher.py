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


class rwk_voucher(report_sxw.rml_parse):
    def __init__(self, cr, uid, name, context):
        super(rwk_voucher, self).__init__(cr, uid, name, context=context)
        self.localcontext.update({
            'time': time,
            'cr': cr,
            'uid': uid,
            'date_order_fmt': self.date_order_fmt,
            'wrap_line': self.wrap_line,
        })

    def date_order_fmt(self, value=None):
        return utilities.date_order_fmt(value=value)

    def wrap_line(self, column_list_source, column_width_list, total_column):
        return utilities.wrap_line(column_list_source, column_width_list, total_column)

report_sxw.report_sxw('report.webkit_journal_voucher',
                       'account.move',
                       'addons/pralon_forms/voucher/voucher.mako',
                       parser=rwk_voucher)
