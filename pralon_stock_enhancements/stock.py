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


class stock_picking(osv.osv):
    _inherit = "stock.picking"

    def _invoice_hook(self, cr, uid, picking, invoice_id):
        super(stock_picking, self)._invoice_hook(cr, uid, picking, invoice_id)
        # Write the field according to invoice
        self.pool.get('account.invoice').write(cr, uid, [invoice_id], {'picking_ids': [(4, picking.id)] })
        return

    def _invoice_line_hook(self, cr, uid, move_line, invoice_line_id):
        super(stock_picking, self)._invoice_line_hook(cr, uid, move_line, invoice_line_id)
        # Write the field according to invoice_line
        self.pool.get('account.invoice.line').write(cr, uid, [invoice_line_id], {'move_ids': [(4, move_line.id)] })
        return

    def _get_warehouse_from_location_stock(self, cr, uid, ids, name, args, context=None):
        res = {}
        
        for obj in self.pool.get('stock.picking').browse(cr, uid, ids, context=context):
            loc_id = False
            loc_ids=[]
            for line in obj.move_lines:
                if line.state != 'cancel':
                    loc_id = line.location_id
                if loc_id:
                    loc_ids = self.pool.get('stock.location').search(cr, uid, [('parent_left','<=',loc_id.parent_left), ('parent_right','>=',loc_id.parent_right)], context=context)
                    # while loc_id:
                    #     loc_ids.append(loc_id.id)
                    #     loc_id = loc_id.location_id
                    break
            warehouse_ids = loc_ids and self.pool.get('stock.warehouse').search(cr, uid, [('lot_stock_id', 'in', loc_ids)], context=context) or []
            
            res[obj.id] = warehouse_ids and warehouse_ids[0] or False
        return res
    _columns = {
        'area_address_id': fields.many2one('res.partner.address', 'End User Address', help="Address of end user"),
        'warehouse' : fields.function(_get_warehouse_from_location_stock, type='many2one', relation='stock.warehouse', string='Warehouse', readonly=True, 
            store=True), 
    }

stock_picking()

