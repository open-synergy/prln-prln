# -*- encoding: utf-8 -*-
##############################################################################
#
#    OpenERP, Open Source Management Solution
#    Copyright (c) 2011 - 2014 Vikasa Infinity Anugrah <http://www.infi-nity.com>
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

{
    'name': 'Pralon Accounting Reports',
    'version': '1.3',
    'category': 'Pralon/Reporting/Accounting',
    'description': """
    This module provides accounting report menu and the accounting reports.
    """,
    'author': 'Vikasa Infinity Anugrah, PT',
    'website': 'http://www.infi-nity.com',
    'images': [],
    'depends': [
        'pralon_reports',
        'stock',
        'via_lot_valuation',
    ],
    'data': [
        'report/inventory/inventory_registration.xml',
        'report/sales_journal/sales_journal_registration.xml',
        'report/account_receivable_report_by_customer/account_receivable_report_by_customer_registration.xml',
        'report/trade_account_receivable_list/trade_account_receivable_list_registration.xml',
        'menu.xml',
        'wizard/trade_account_receivable_list_view.xml',
        'wizard/account_receivable_report_by_customer_view.xml',
        'wizard/sales_journal_view.xml',
        'wizard/inventory_report_view.xml',
    ],
    'test': [
    ],
    'demo': [
    ],
    'license': 'GPL-3',
    'installable': True,
    'auto_install': False,
    'application': False,
}
