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

{
    'name': 'Sales Management Enhancements',
    'version': '1.2',
    'category': 'Sales Management',
    'complexity': 'easy',
    'description': """
    This module provides some enhancements to the existing sales module:
    - Displaying Sale Order's Note in the related delivery orders and customer invoices
    - Displaying Warehouse Code in the moves of delivery orders based on the Sale Order's Shop's Warehouse
    - Add weight and total weight of the related product in the Sale Order Line
    - Add 7 additional discount fields in the Sale Order Line and calculcate the discount based on the given 7
    """,
    'author': 'Vikasa Infinity Anugrah, PT',
    'website': 'http://www.infi-nity.com',
    'depends': ['sale','product', ],
    'data': [
        'stock_view.xml',
        'account_invoice_view.xml',
        'sale_order_view.xml',
        'product_view.xml',
    ],
    'test': [
    ],
    'demo': [
    ],
    'installable': True,
    'auto_install': False,
    #'certificate': '0057234283549',
    'application': False,

}
