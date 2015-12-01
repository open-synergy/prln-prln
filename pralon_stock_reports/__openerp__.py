# -*- encoding: utf-8 -*-
##############################################################################
#
#    OpenERP, Open Source Management Solution
#    Copyright (c) 2011 - 2015 Vikasa Infinity Anugrah <http://www.infi-nity.com>
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
    'name': 'Pralon Stock Reports',
    'version': '1.2',
    'category': 'Pralon/Reporting/Stock',
    'description': """
    This module provides stock report menu and the stock reports.
    """,
    'author': 'Vikasa Infinity Anugrah, PT',
    'website': 'http://www.infi-nity.com',
    'images': [],
    'depends': [
        'pralon_reports',
        'stock',
        'stock_location',
        'procurement',
        'via_product_transformation',
    ],
    'data': [
        'report/inventory/inventory_registration.xml',
        'report/stock_card/stock_card_registration.xml',
        'report/product_transformation/product_transformation_registration.xml',
        'menu.xml',
        'wizard/product_transformation_view.xml',
        'wizard/inventory_report_view.xml',
        'wizard/stock_card_report_view.xml',

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
