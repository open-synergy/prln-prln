# -*- encoding: utf-8 -*-
##############################################################################
#
#    Vikasa Infinity Anugrah, PT
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

from osv import osv, fields


class account_invoice(osv.osv):
    _inherit = "account.invoice"

    def _get_sale_note(self, cr, uid, ids, name, arg, context=None):
        res = {}
        if not ids:
            return res
        cr.execute('SELECT sol.invoice_id, so.id, so.note '\
                   'FROM sale_order so '\
                   'INNER JOIN sale_order_invoice_rel sol '\
                   'ON so.id = sol.order_id '\
                   'WHERE sol.invoice_id IN %s'\
                   'ORDER BY so.id DESC',
                   (tuple(ids),))
        for r in cr.fetchall():
            res.setdefault(r[0], '')
            res.update({r[0]: r[2]})
        return res

    _columns = {
        'sale_note': fields.function(_get_sale_note, type='text', string='Sale Order Note', readonly=True),
    }

account_invoice()
