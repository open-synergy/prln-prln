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

{
    'name': 'Purchase Management Enhancements',
    'version': '1.1',
    'category': 'Purchase Management',
    #'sequence': 19,
    'complexity': 'easy',
    'description': """
    This module provides some enhancements to the existing sales module:
    - Add additional configurable information state field to Purchase Requisition
    - Add additional department field to Purchase Requisition refering to HR module department
    """,
    'author': 'Vikasa Infinity Anugrah, PT',
    'website': 'http://www.infi-nity.com',
    #'images' : ['images/purchase_order.jpeg', 'images/purchase_analysis.jpeg', 'images/request_for_quotation.jpeg'],
    'depends': [
        'hr',
        'purchase_requisition',
        'via_code_decode',
    ],
    'data': [
        'data/data_CodeCategory.xml',
        'view/view_PurchaseRequisition.xml'
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
