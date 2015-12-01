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

from datetime import datetime
from via_l10n_id.via_tools import amount_to_text_id
from openerp.tools import DEFAULT_SERVER_DATE_FORMAT
import pooler


def date_order_fmt(value=None):
    _date = False
    _fmt_len = len((datetime.now()).strftime(DEFAULT_SERVER_DATE_FORMAT))
    try:
        _date = datetime.strptime(value[:_fmt_len], DEFAULT_SERVER_DATE_FORMAT)
    except:
        pass

    if _date:
        _month = amount_to_text_id.number_to_month(_date.strftime("%m"))

    return _date and _month and _date.strftime("%d %%s %Y") % (_month) or ''


def sum_subtotal(taxform_lines):
    total = 0.0
    for tax in taxform_lines:
        subtotal = ((tax.price_subtotal * 100.0) / (100.0 - (tax.discount or 0.00)))
        total += subtotal
    return total


def sum_discount(taxform_lines):
    total = 0.0
    for tax in taxform_lines:
        subdiscount = (tax.discount * ((tax.price_subtotal * 100.0) / (100.0 - (tax.discount or 0.00)))) / 100.0
        total += subdiscount
    return total


def get_base(taxform_lines):
    base = 0.0
    _at_pool = False
    _cr = False
    _uid = False
    for tax in taxform_lines:
        if not _at_pool:
            _cr = tax._cr
            _uid = tax._uid
            _at_pool = pooler.get_pool(_cr.dbname).get('account.tax')

        # To handle different types of line, one is account_invoice_line and another is account_taxform_line
        _tax = getattr(tax, 'invoice_line_id', False) or tax
        if getattr(_tax, 'invoice_line_tax_id', []):
            _info = _at_pool.compute_all(_cr, _uid, _tax.invoice_line_tax_id,
                (_tax.price_unit * (1 - (_tax.discount or 0.0)/100.0)), _tax.quantity,
                _tax.invoice_id.address_invoice_id.id, _tax.product_id, _tax.invoice_id.partner_id)
            base += _info.get('total', 0.0)

    return base


def wrap_line(column_list_source, column_width_list, total_column):
    #Validasi parameter
    if total_column < 1:
        return [-1, [], [], 0]

    source_list = column_list_source[:]
    dest_list = []
    rv = 0
    wrappable_column = 0

    #Proses semua kolom
    for column_no in range(0, total_column):
        #Jika terjadi wrapping, tandai rv
        if (len(source_list[column_no]) > column_width_list[column_no]) and (rv < 1):
            rv = 1

        #Tambah teks dari source sepanjang width yang ditentukan ke dest
        dest_list.append(source_list[column_no][0:column_width_list[column_no]])
        #Kurangi teks awal dari source sepanjang width yang ditentukan
        source_list[column_no] = source_list[column_no][column_width_list[column_no]:]

        #Tes apakah teks berikutnya dapat diwrapping kembali atau tidak
        if len(source_list[column_no]) > column_width_list[column_no]:
            wrappable_column = wrappable_column + 1
            rv = 2

    return [rv, source_list, dest_list, wrappable_column]
