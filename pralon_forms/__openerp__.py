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
    "name": "Pralon Forms",
    "version": "1.2",
    "category": "Reporting",
    'complexity': 'normal',
    "description": """
This module hosts all forms related to the Pralon OpenERP project
    """,
    'author': 'Vikasa Infinity Anugrah, PT',
    'website': 'http://www.infi-nity.com',
    "depends": [
        "via_report_webkit",
        "via_document_signature",
        "stock",
        "sale",
        "purchase",
        "purchase_requisition",
        "account",
        "via_account_taxform",
    ],
    "data": [
        "template_headers.xml",
        "header_images.xml",
        "warehouse/warehouse_forms.xml",
        "sales/sales_forms.xml",
        "sales/sales_view.xml",
        "purchase/purchase.xml",
        "purchase/purchase_view.xml",
        "purchase/pralon_form_purchase_data.xml",
        "accounting/accounting_forms.xml",
        "voucher/voucher_form.xml",
        "accounting/account_taxform_wizard.xml",
    ],
    'test': [
    ],
    'demo': [
    ],
    "installable": True,
    "auto_install": False,
    'application': False,
    'images': [],
}
