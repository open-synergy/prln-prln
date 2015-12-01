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

from osv import fields, osv
import decimal_precision as dp


class sale_order_line(osv.osv):
    _inherit = 'sale.order.line'

    def _compound_discount(self, cr, uid, discount, context=None):
        _discount = 1.0
        for _disc in discount:
            _discount = _discount * (1.0 - _disc / 100.00)

        _discount = (1.0 - _discount) * 100.00
        return _discount

    _columns = {
        'weight': fields.float(string='Weight', digits_compute=dp.get_precision('Stock Weight')),
        'total_weight': fields.float(string='Total Weight', digits_compute=dp.get_precision('Stock Weight')),
        'discount_1': fields.float(string='Discount 1', digits=(16, 2)),
        'discount_2': fields.float(string='Discount 2', digits=(16, 2)),
        'discount_3': fields.float(string='Discount 3', digits=(16, 2)),
        'discount_4': fields.float(string='Discount 4', digits=(16, 2)),
        'discount_5': fields.float(string='Discount 5', digits=(16, 2)),
        'discount_6': fields.float(string='Discount 6', digits=(16, 2)),
        'discount_7': fields.float(string='Discount 7', digits=(16, 2)),
    }

    def onchange_multi_discount(self, cr, uid, ids, discount_1, discount_2, discount_3, discount_4, discount_5, discount_6, discount_7, context=None):
        value = {}
        domain = {}
        warning = {}

        _disc_list = [discount_1, discount_2, discount_3, discount_4, discount_5, discount_6, discount_7]
        total_discount = self._compound_discount(cr, uid, _disc_list, context=context)
        value.update({
            'discount': total_discount,
            'discount_dummy': total_discount,
        })

        return {'value': value, 'domain': domain, 'warning': warning}

    def onchange_discount(self, cr, uid, ids, discount_1, discount_2, discount_3, discount_4, discount_5, discount_6, discount_7, context=None):
        value = {}
        domain = {}
        warning = {}

        _disc_list = [discount_1, discount_2, discount_3, discount_4, discount_5, discount_6, discount_7]
        total_discount = self._compound_discount(cr, uid, _disc_list, context=context)
        value.update({
            'discount': total_discount,
            'discount_dummy': total_discount,
        })

        return {'value': value, 'domain': domain, 'warning': warning}

    def product_id_change(self, cr, uid, ids, pricelist, product, qty=0,
            uom=False, qty_uos=0, uos=False, name='', partner_id=False,
            lang=False, update_tax=True, date_order=False, packaging=False, fiscal_position=False, flag=False, context=None):

        val = super(sale_order_line, self).product_id_change(cr, uid, ids, pricelist, product, qty, uom, qty_uos, uos, name, partner_id, lang, update_tax, date_order, packaging, fiscal_position, flag, context)

        if product:
            obj_uom = self.pool.get('product.uom')
            obj_product = self.pool.get('product.product')

            _product_obj = obj_product.browse(cr, uid, product)
            weight_factor = 1.0
            if qty and uom and uom != _product_obj.product_tmpl_id.uom_id.id:
                weight_factor = obj_uom._compute_qty(cr, uid, uom, 1.0, _product_obj.product_tmpl_id.uom_id.id)
            uom_weight = weight_factor * _product_obj.product_tmpl_id.weight_net

            value = {
                'weight': uom_weight,
                'total_weight': uom_weight * qty,
            }

            val['value'].update(value)

        return val

sale_order_line()
