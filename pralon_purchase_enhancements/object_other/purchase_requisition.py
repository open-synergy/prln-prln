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

from osv import fields, osv


class purchase_requisition(osv.osv):
    _inherit = 'purchase.requisition'

    def _selection_information_state(self, cr, uid, context=None):
        obj_model_data = self.pool.get('ir.model.data')
        obj_category = self.pool.get('code.category')
        obj_user = self.pool.get('res.users')

        res_id = obj_model_data.get_object_reference(cr, uid, 'pralon_purchase_enhancements', 'purchase_info_state')
        category_id = obj_category.search(cr, uid, [('id', '=', res_id[1])], context=context)
        user = obj_user.browse(cr, uid, uid)

        res = self.pool.get('code.decode').get_selection(cr, uid, category_id, user.company_id.id)

        return res

    def _default_department_id(self, cr, uid, context={}):
        obj_user = self.pool.get('res.users')
        user = obj_user.browse(cr, uid, [uid])[0]
        return user.context_department_id and user.context_department_id.id or False

    def create(self, cr, user, vals, context=None):
        if ('name' not in vals):
            vals['name'] = self.pool.get('ir.sequence').get(cr, user, 'purchase.order.requisition')
        new_id = super(purchase_requisition, self).create(cr, user, vals, context)
        return new_id    

    _columns = {
        'information_state': fields.selection(selection=_selection_information_state, string='Information State'),
        'department_id': fields.many2one('hr.department', 'Department', select=True, required=False, help="Department that initiate the Purchase Requisition"),
    }

    _defaults = {
        'department_id': _default_department_id,
        'name': lambda *a: False,
    }

purchase_requisition()

