# -*- encoding: utf-8 -*-

##############################################################################
#
#    Vikasa Infinity Anugrah, PT
#    Copyright (c) 2011 - 2012 Vikasa Infinity Anugrah <http://www.infi-nity.com>
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

    _columns = {
        'picking_ids': fields.many2many('stock.picking', 'stock_picking_invoice_rel', 'invoice_id', 'picking_id', 'Stock Picking', readonly=True),
    }

account_invoice()


class account_invoice_line(osv.osv):
    _inherit = "account.invoice.line"

    _columns = {
        'move_ids': fields.many2many('stock.move', 'stock_move_invoice_line_rel', 'invoice_line_id', 'move_id', 'Stock Move', readonly=True),
    }

account_invoice_line()

