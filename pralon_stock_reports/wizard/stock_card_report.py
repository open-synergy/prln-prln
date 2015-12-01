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

from osv import osv
from tools.translate import _
from via_jasper_report_utils.framework import register_report_wizard, wizard


RPT_NAME = 'Stock Card'

RPT_SQL = """
          WITH raw_data AS (
                SELECT
                  (CASE WHEN sm.location_id IN ($P!{SCR_LOCATION_IDS})
                       THEN sm.location_id
                       ELSE sm.location_dest_id
                       END) AS _this_id,
                  sm.product_id AS _product_id,
                  pp.default_code AS _product_code,
                  pp.name_template AS _product_name,
                  sm.id AS _move_id,
                  (CASE WHEN sm.location_id IN ($P!{SCR_LOCATION_IDS})
                       THEN sm.location_dest_id
                       ELSE sm.location_id
                       END) AS _ctr_id,
                  sm.date::DATE AS _move_date,
                  -1 AS _sign,
                  sm.product_qty / move_uom.factor * product_uom.factor AS _product_qty,
                  sm.product_qty / move_uom.factor * product_uom.factor * COALESCE(pt.weight_net, 0.000) AS _product_weight,
                  product_uom.name AS _uom,
                  rp.name AS _partner_name,
                  21 AS _running_total
                FROM
                  stock_move sm
                  JOIN product_product pp ON sm.product_id = pp.id
                  JOIN product_template pt ON pp.product_tmpl_id = pt.id
                  JOIN product_uom move_uom ON sm.product_uom = move_uom.id
                  JOIN product_uom product_uom ON pt.uom_id = product_uom.id
                  LEFT JOIN res_partner rp ON sm.partner_id = rp.id
                WHERE
                  sm.company_id IN ($P!{COMPANY_IDS})
                  AND sm.state = 'done'
                  AND sm.date::DATE <= '$P!{TO_DATE_2_YR}-$P!{TO_DATE_2_MO}-$P!{TO_DATE_2_DY}'
                  AND sm.location_id IN ($P!{SCR_LOCATION_IDS})
                  AND sm.product_id IN ($P!{PROD_IDS})

                UNION ALL
                  SELECT
                  (CASE WHEN sm.location_dest_id IN ($P!{SCR_LOCATION_IDS})
                       THEN sm.location_dest_id
                       ELSE sm.location_id
                       END) AS _this_id,
                  sm.product_id AS _product_id,
                  pp.default_code AS _product_code,
                  pp.name_template AS _product_name,
                  sm.id AS _move_id,
                 (CASE WHEN sm.location_dest_id IN ($P!{SCR_LOCATION_IDS})
                       THEN sm.location_id
                       ELSE sm.location_dest_id
                       END) AS _ctr_id,
                  sm.date::DATE AS _move_date,
                  1 AS _sign,
                  sm.product_qty / move_uom.factor * product_uom.factor AS _product_qty,
                  sm.product_qty / move_uom.factor * product_uom.factor * COALESCE(pt.weight_net, 0.000) AS _product_weight,
                  product_uom.name AS _uom,
                  rp.name AS _partner_name,
                  22 AS _running_total
                FROM
                  stock_move sm
                  JOIN product_product pp ON sm.product_id = pp.id
                  JOIN product_template pt ON pp.product_tmpl_id = pt.id
                  JOIN product_uom move_uom ON sm.product_uom = move_uom.id
                  JOIN product_uom product_uom ON pt.uom_id = product_uom.id
                  LEFT JOIN res_partner rp ON sm.partner_id = rp.id
                WHERE
                  sm.company_id IN ($P!{COMPANY_IDS})
                  AND sm.state = 'done'
                  AND sm.date::DATE <= '$P!{TO_DATE_2_YR}-$P!{TO_DATE_2_MO}-$P!{TO_DATE_2_DY}'
                  AND sm.location_dest_id IN ($P!{SCR_LOCATION_IDS})
                  AND sm.product_id IN ($P!{PROD_IDS})

                ORDER BY
                  _this_id ASC,
                  _product_id ASC,
                  _move_date ASC,
                  _move_id ASC
                ),

      summarized_data AS (
              SELECT
                rd._this_id,
                this_loc.complete_name AS _this_name,
                rd._product_code,
                rd._product_name,
                10 AS _sort,
                0 AS _move_id,
                '$P!{FROM_DATE_2_YR}-$P!{FROM_DATE_2_MO}-$P!{FROM_DATE_2_DY}'::DATE AS _move_date,
                '' AS _ref,
                '' AS _origin,
                'Beginning Balance' AS _type,
                '' AS _ctr_name,
                0.0 AS _move_qty_in,
                0.0 AS _move_weight_in,
                0.0 AS _move_qty_out,
                0.0 AS _move_weight_out,

                SUM(CASE WHEN (rd._move_date < '$P!{FROM_DATE_2_YR}-$P!{FROM_DATE_2_MO}-$P!{FROM_DATE_2_DY}') THEN rd._sign * rd._product_qty ELSE 0.0 END) AS _move_qty,
                SUM(CASE WHEN (rd._move_date < '$P!{FROM_DATE_2_YR}-$P!{FROM_DATE_2_MO}-$P!{FROM_DATE_2_DY}') THEN rd._sign * rd._product_weight ELSE 0.0 END) AS _move_weight,

                rd._uom,
                '' AS _partner_name,
                10 AS _running_total
              FROM
                raw_data rd
                JOIN stock_location this_loc ON rd._this_id = this_loc.id
                JOIN stock_location ctr_loc ON rd._ctr_id = ctr_loc.id

              GROUP BY
                rd._this_id,
                _this_name,
                rd._product_code,
                rd._product_name,
                rd._uom

              UNION ALL
              SELECT
                rd._this_id,
                this_loc.complete_name AS _this_name,
                rd._product_code,
                rd._product_name,
                30 AS _sort,
                0 AS _move_id,
                NULL::DATE AS _move_date,
                '' AS _ref,
                '' AS _origin,
                'Ending Balance' AS _type,
                '' AS _ctr_name,
                0.0 AS _move_qty_in,
                0.0 AS _move_weight_in,
                0.0 AS _move_qty_out,
                0.0 AS _move_weight_out,
                SUM(rd._sign * rd._product_qty) AS _move_qty,
                SUM(rd._sign * rd._product_weight) AS _move_weight,
                rd._uom,
                '' AS _partner_name,
                30 AS _running_total
              FROM
                raw_data rd
                JOIN stock_location this_loc ON rd._this_id = this_loc.id
                JOIN stock_location ctr_loc ON rd._ctr_id = ctr_loc.id
              WHERE
                rd._move_date <= '$P!{TO_DATE_2_YR}-$P!{TO_DATE_2_MO}-$P!{TO_DATE_2_DY}'
              GROUP BY
                rd._this_id,
                _this_name,
                rd._product_code,
                rd._product_name,
                rd._uom

              UNION ALL
              SELECT
                rd._this_id,
                this_loc.complete_name AS _this_name,
                rd._product_code,
                rd._product_name,
                20 AS _sort,
                rd._move_id,
                rd._move_date,
                COALESCE(pick.name, cons_pt.name, fin_pt.name, inv.name, 'No Ref') AS _ref,
                sm.origin AS _origin,
                (CASE WHEN ctr_loc.usage IN ('internal', 'production') THEN 'INT'
                      WHEN ctr_loc.usage IN ('customer', 'supplier') AND rd._sign = 1 THEN 'IS'
                      WHEN ctr_loc.usage IN ('customer', 'supplier') AND rd._sign = -1 THEN 'DO'
                      WHEN ctr_loc.usage NOT IN ('internal', 'production', 'customer', 'supplier') THEN 'ADJ'
                      ELSE 'N/A'
                      END ) AS _type,
                COALESCE(ctr_loc.name, 'No Name') AS _ctr_name,
                (CASE WHEN rd._sign = 1 THEN rd._product_qty ELSE 0.0 END) AS _move_qty_in,
                (CASE WHEN rd._sign = 1 THEN rd._product_weight ELSE 0.0 END) AS _move_weight_in,
                (CASE WHEN rd._sign = -1 THEN rd._product_qty ELSE 0.0 END) AS _move_qty_out,
                (CASE WHEN rd._sign = -1 THEN rd._product_weight ELSE 0.0 END) AS _move_weight_out,
                rd._sign * rd._product_qty AS _move_qty,
                rd._sign * rd._product_weight AS _move_weight,
                rd._uom,
                rd._partner_name,
                rd._running_total

              FROM
                raw_data rd
                JOIN stock_location this_loc ON rd._this_id = this_loc.id
                JOIN stock_location ctr_loc ON rd._ctr_id = ctr_loc.id
                JOIN stock_move sm ON sm.id = rd._move_id
                LEFT JOIN stock_picking pick ON pick.id = sm.picking_id
                LEFT JOIN product_consume_line cons ON cons.stock_move_id = sm.id
                LEFT JOIN product_transformation cons_pt ON cons_pt.id = COALESCE(cons.prod_trans_id, cons.prod_trans2_id)
                LEFT JOIN finish_goods_line fin ON fin.stock_move_id = sm.id
                LEFT JOIN product_transformation fin_pt ON fin_pt.id = fin.prod_trans_id
                LEFT JOIN stock_inventory_move_rel rel ON rel.move_id = sm.id
                LEFT JOIN stock_inventory inv ON inv.id = rel.inventory_id
                LEFT JOIN res_partner partner ON partner.id = sm.partner_id
              WHERE
                rd._move_date BETWEEN '$P!{FROM_DATE_2_YR}-$P!{FROM_DATE_2_MO}-$P!{FROM_DATE_2_DY}' AND '$P!{TO_DATE_2_YR}-$P!{TO_DATE_2_MO}-$P!{TO_DATE_2_DY}'
              ORDER BY
                _this_name,
                _product_code,
                _sort,
                _move_date,
                _move_id)
      SELECT
          sd._this_id,
              sd._this_name,
              sd._product_code,
              sd._product_name,
              sd._sort,
              sd._move_id,
              sd._move_date,
              sd._ref,
              sd._origin,
              sd._type,
              sd._ctr_name,
              sd._move_qty_in,
              sd._move_weight_in,
              sd._move_qty_out,
              sd._move_weight_out,
              sd._move_weight,
              sd._uom,
              sd._partner_name,
              sd._move_qty,
              SUM(sd._move_qty) OVER (PARTITION BY sd._this_id, sd._product_code ORDER BY sd._this_name, sd._product_code, sd._sort, sd._move_date, sd._move_id, sd._running_total) AS _running_total,
              SUM(sd._move_weight) OVER (PARTITION BY sd._this_id, sd._product_code ORDER BY sd._this_name, sd._product_code, sd._sort, sd._move_date, sd._move_id, sd._running_total) AS _running_total_weight
      FROM
              summarized_data sd
      ORDER BY
              sd._this_name,
              sd._product_code,
              sd._sort,
              sd._move_date,
              sd._move_id,
              sd._running_total

"""


class via_jasper_report(osv.osv_memory):
    _inherit = 'via.jasper.report'
    _description = 'Stock Card'

via_jasper_report()


class wizard(wizard):

    def onchange_company_ids(cr, uid, ids, com_ids, context=None):
        # Sample com_ids = [(6, 0, [14, 11])]
        if len(com_ids) == 0:
            val = {
                'domain': {
                    'location_ids': [('company_id', '=', False), ('usage', 'in', ['internal', 'production'])],
                    'prod_ids': [('product_tmpl_id.company_id', '=', False)],
                },
                'value': {
                    'location_ids': False,
                    'prod_ids': False,
                },
            }
            return val

        val = {
            'domain': {
                'location_ids': [('usage', 'in', ['internal', 'production']), '|', ('company_id', '=', False), ('company_id', 'in', com_ids[0][2])],
                'prod_ids': [('product_tmpl_id.company_id', 'in', com_ids[0][2])],
            },
            'value': {
                'location_ids': False,
                'prod_ids': False,
            },
        }
        return val

    _onchange = {
        'company_ids': (onchange_company_ids, 'company_ids', 'context'),
    }

    _visibility = [
        'company_ids',
        'location_ids',
        'prod_ids',
        ['from_dt', 'to_dt'],
    ]

    _label = {
        'from_dt': 'Stock Date From',
        'location_ids': 'Stock Location Name',
    }

    _required = ['from_dt', 'to_dt', 'prod_group_level']

    def get_locations_str(self, cr, uid, form, context=None):
        obj_loc = self.pool.get('stock.location')
        if not form.location_ids:
            loc_domain = ['&', '|', ('company_id', '=', False), ('company_id', 'in',
                          [com_id.id for com_id in form.company_ids]), ('usage', 'in', ['internal', 'production'])]
            res_ids = obj_loc.search(cr, uid, loc_domain, context=context)
            res_ids_str = ','.join(str(_id) for _id in obj_loc.search(cr, uid, loc_domain, context=context))
            res_names = ', '.join(loc.name for loc in obj_loc.browse(cr, uid, res_ids, context=context))
        else:
            res_ids = [loc.id for loc in form.location_ids]
            res_ids_str = ','.join(str(loc_id) for loc_id in res_ids)
            res_names = '. '.join(loc.name for loc in obj_loc.browse(cr, uid, res_ids, context=context))
        return {
            'ids': res_ids_str,
            'names': res_names
        }

    def get_products_str(self, cr, uid, form, context=None):
        obj_prod = self.pool.get('product.product')
        if not form.prod_ids:
            prod_domain = [('product_tmpl_id.company_id', 'in', [com_id.id for com_id in form.company_ids])]
            res_ids = obj_prod.search(cr, uid, prod_domain, context=context)
            res_ids_str = ','.join(str(_id) for _id in obj_prod.search(cr, uid, prod_domain, context=context))
            res_names = ', '.join(prod.name for prod in obj_prod.browse(cr, uid, res_ids, context=context))
        else:
            res_ids = [prod.id for prod in form.prod_ids]
            res_ids_str = ','.join(str(loc_id) for loc_id in res_ids)
            res_names = ', '.join(prod.name for prod in obj_prod.browse(cr, uid, res_ids, context=context))
        return {
            'ids': res_ids_str,
            'names': res_names
        }

    def validate_parameters(self, cr, uid, form, context=None):
        if len(form.company_ids) == 0:
            raise osv.except_osv(_('Caution !'),
                                 _('No page will be printed !'))

        form.validate_prod_level(context=context)

    def print_report(self, cr, uid, form, context=None):
        locations = self.get_locations_str(cr, uid, form, context=context)
        products = self.get_products_str(cr, uid, form, context=context)
        self.validate_parameters(cr, uid, form, context=context)
        form.add_marshalled_data('PROD_NAMES', products['names'])
        form.add_marshalled_data('SCR_LOCATION_IDS', locations['ids'])
        form.add_marshalled_data('LOCATION_NAMES', locations['names'])
        form.add_marshalled_data('RPT_SQL', RPT_SQL)

        prec = self.pool.get('decimal.precision').precision_get(cr, uid, 'Product UoM')
        zero = '0' * prec
        form.add_marshalled_data('DEC_FORMAT', "#,##0.%s;-#,##0.%s" % (zero, zero))

register_report_wizard(RPT_NAME, wizard)
