# -*- encoding: utf-8 -*-
###############################################################################
#
#  Vikasa Infinity Anugrah, PT
#  Copyright (C) 2013 Vikasa Infinity Anugrah <http://www.infi-nity.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as
#  published by the Free Software Foundation, either version 3 of the
#  License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see http://www.gnu.org/licenses/.
#
###############################################################################

from osv import osv, fields
from tools.translate import _
from via_jasper_report_utils.framework import register_report_wizard, wizard
from sales_report_by_area_sql import sales_report_by_area_sql
from via_reporting_utility.pgsql import list_to_pgTable


RPT_NAME = 'Sales Report by Area'


class via_jasper_report(osv.osv_memory):
    _inherit = 'via.jasper.report'
    _description = 'Sales Report by Area'

    _columns = {
        'customer_addr_ids': fields.many2many('res.partner.address',
                                              'via_report_customer_addr_rel',
                                              'via_report_id',
                                              'customer_addr_id',
                                              string='Customer'),
    }

via_jasper_report()


class wizard(wizard):
    def onchange_company_ids(cr, uid, ids, com_ids, context=None):
        # Sample com_ids = [(6, 0, [14, 11])]
        if len(com_ids) == 0:
            return {
                'domain': {'customer_addr_ids': [('company_id', '=', False),
                                                 ('partner_id.customer', '=', True)]},
                'value': {'customer_addr_ids': False},
            }
        return {
            'domain': {'customer_addr_ids': [('company_id', 'in', com_ids[0][2]),
                                             ('partner_id.customer', '=', True)]},
            'value': {'customer_addr_ids': False},
        }

    _onchange = {
        'company_ids': (onchange_company_ids, 'company_ids', 'context'),
    }

    _visibility = [
        'company_ids',
        'customer_addr_ids',
        ['from_dt', 'to_dt'],
    ]

    _required = [
        'from_dt',
        'to_dt',
    ]

    _readonly = [
    ]

    _attrs = {
    }

    _domain = {
    }

    _label = {
        'from_dt': 'Invoice Date From',
    }

    # The values in the dictionary below must be callables with signature:
    #     lambda self, cr, uid, context
    _defaults = {
    }

    # The following is used to specify what columns should appear in a
    # one-to-many or many-to-many widget.  The key must be the field name while
    # the value must be a list of column names that should appear.
    _tree_columns = {
    }

    def validate_parameters(self, cr, uid, form, context=None):
        if len(form.company_ids) == 0:
            raise osv.except_osv(_('Caution !'),
                                 _('No page will be printed !'))

    def print_report(self, cr, uid, form, context=None):
        self.validate_parameters(cr, uid, form, context=context)

        cust_list = form.get_customer_addr_ids(context=context)
        if len(cust_list) == 0:
            sql_cust_ids = ''
        else:
            cust_addr_ids = ",".join(str(n) for n in cust_list)
            sql_cust_ids = 'COALESCE(sp.area_address_id, sp.address_id) IN (%s)' % cust_addr_ids
            sql_cust_ids_is_null = '(' + sql_cust_ids + ' OR COALESCE(sp.area_address_id, sp.address_id) IS NULL)'
        form.add_marshalled_data('CUSTOMER_IDS', 'AND ' + sql_cust_ids)
        form.add_marshalled_data('CUSTOMER_IDS_IS_NULL', 'AND ' + sql_cust_ids_is_null)
        form.add_marshalled_data('RPT_SQL', sales_report_by_area_sql())

register_report_wizard(RPT_NAME, wizard)
