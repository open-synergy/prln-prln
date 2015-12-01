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

from osv import osv


class account_taxform(osv.osv):
    _inherit = "account.taxform"

    def _report_taxform(self, cr, uid, ids, rml, rpt_name, context=None):
        select = (isinstance(ids, (int, long)) and [ids]) or ids
        select = map(lambda x: isinstance(x, dict) and x['id'] or x, select)
        for _obj in self.pool.get('account.taxform').browse(cr, uid, select, context=context):
            if _obj.taxform_id != '/' and _obj.state != 'canceled':
                counter = _obj.counter + 1
                _obj.write({'state': 'printed', 'counter': counter}, context=context)
        datas = {
            'ids': select,
            'model': 'account.taxform',
            'rml': rml,
        }

        return {
            'type': 'ir.actions.report.xml',
            'nodestroy': True,
            'report_name': rpt_name,
            'datas': datas,
        }

    def report_taxform(self, cr, uid, ids, context=None):
        _rml = 'pralon_forms/accounting/account_taxform.mako'
        _rpt_name = 'webkit_taxform'
        return self.pool.get('account.taxform')._report_taxform(cr, uid, ids, _rml, _rpt_name, context=context)

    def report_taxform_one_page(self, cr, uid, ids, context=None):
        _rml = 'pralon_forms/accounting/account_taxform_single_page.mako'
        _rpt_name = 'webkit_one_taxform'
        return self.pool.get('account.taxform')._report_taxform(cr, uid, ids, _rml, _rpt_name, context=context)

    def report_taxform_preprinted(self, cr, uid, ids, context=None):
        _rml = 'pralon_forms/accounting/account_taxform_preprinted.mako'
        _rpt_name = 'webkit_taxform_preprinted'
        return self.pool.get('account.taxform')._report_taxform(cr, uid, ids, _rml, _rpt_name, context=context)

account_taxform()
