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

from osv import fields, osv

class res_company(osv.osv):
    _name = 'res.company'
    _inherit = 'res.company'
    _description = 'VIA Financial Reports res.company'
    _columns = {
        'consolidation_exchange_rate': fields.related(
            'consolidation_exchange_rate_pl',
            type='many2one',
            relation='res.currency',
            string='Consolidation Target Currency',
            store=True,
            help=("This currency is used to convert the value of an account"
                  " in multi-company multi-currency setting.")),
    }
    def _auto_init(self, cr, context=None):
        super(res_company, self)._auto_init(cr, context=context)
        cr.execute(' UPDATE res_company'
                   ' SET consolidation_exchange_rate = consolidation_exchange_rate_pl')

res_company()
