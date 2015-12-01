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

{
    'name': 'Pralon Sales Reports',
    'version': '1.1',
    'category': 'Pralon/Reporting/Sales',
    'description': """
    This module provides sales report menu and the sales reports.
    """,
    'author': 'Vikasa Infinity Anugrah, PT',
    'website': 'http://www.infi-nity.com',
    'images' : [],
    'depends': [
        'pralon_reports',
        'via_jasper_report_utils',
        'sale',
        'product',
        'pralon_stock_enhancements',
        'via_account_invoice_refund',
    ],
    'data': [
        'report/detail_sales_report_by_product/detail_sales_report_by_product_registration.xml',
        'report/detail_sales_report_by_salesman/detail_sales_report_by_salesman_registration.xml',
        'report/pending_order_report_by_customer/pending_order_report_by_customer_registration.xml',
        'report/pending_order_report_by_product/pending_order_report_by_product_registration.xml',
        'report/sales_report_by_area/sales_report_by_area_registration.xml',
        'report/sales_report_rekap/sales_report_rekap_registration.xml',
        'menu.xml',
        'wizard/sales_report_by_area_view.xml',
        'wizard/sales_report_rekap_view.xml',
        'wizard/detail_sales_report_by_product_view.xml',
        'wizard/detail_sales_report_by_salesman_view.xml',
        'wizard/pending_order_report_by_customer_view.xml',
        'wizard/pending_order_report_by_product_view.xml',
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
