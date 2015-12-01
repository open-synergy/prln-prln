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
    'name': 'Pralon Purchase Reports',
    'version': '1.0',
    'category': 'Pralon/Reporting/Purchase',
    'description': """
    This module provides purchase report menu and the purchase reports.
    """,
    'author': 'Vikasa Infinity Anugrah, PT',
    'website': 'http://www.infi-nity.com',
    'images' : [],
    'depends': [
        'pralon_reports',
        'via_jasper_report_utils',
        'purchase',
        'purchase_requisition',
        'product',
        'via_purchase_enhancements',
        'pralon_purchase_enhancements',
        'account_voucher',
    ],
    'data': [
        'report/pr_fulfillment_and_po_tracking/pr_fulfillment_and_po_tracking_registration.xml',
        'menu.xml',
        'wizard/pr_fulfillment_and_po_tracking_view.xml',
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
