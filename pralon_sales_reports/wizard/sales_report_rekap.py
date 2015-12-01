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

from osv import osv, fields
from tools.translate import _
from via_jasper_report_utils.framework import register_report_wizard, wizard
from via_reporting_utility.pgsql import list_to_pgTable
from via_reporting_utility.pgsql import create_composite_type
from via_reporting_utility.pgsql import create_plpgsql_proc


RPT_NAME = 'Sales Report (Rekap)'


_SRR_DECORATOR_DEF = """
DECLARE
    record_to_return SRR_DECORATED_RECORD;
    sales_rec SRR_DATA_POINT;
    refund_rec SRR_DATA_POINT;

    curr_nth BIGINT := 0;

    total_rec RECORD;
    month_rec RECORD;

    prod_cat_rec RECORD;
    last_prod_cat VARCHAR := NULL;

    last_prod VARCHAR := NULL;
BEGIN
    -- Normal Category
    FOR prod_cat_rec IN (SELECT DISTINCT prod_cat
                         FROM UNNEST(sales_data)
                         WHERE prod_cat NOT ILIKE other_cat_name
                         ORDER BY prod_cat) LOOP

        IF last_prod_cat IS NOT NULL AND last_prod_cat != prod_cat_rec.prod_cat THEN

            -- Refund data
            curr_nth := curr_nth + 1;
            FOR refund_rec IN (SELECT *
                               FROM UNNEST(refund_data)
                               WHERE prod_cat = last_prod_cat
                               ORDER BY prod_cat, month) LOOP
                record_to_return := (curr_nth,
                                     FALSE,
                                     TRUE,
                                     FALSE,
                                     refund_rec.prod_cat,
                                     refund_rec.prod,
                                     refund_rec.year,
                                     refund_rec.month,
                                     refund_rec.weight,
                                     refund_rec.sales)::SRR_DECORATED_RECORD;
                RETURN NEXT record_to_return;
            END LOOP;

            -- Credit notes data
            curr_nth := curr_nth + 1;
            FOR refund_rec IN (SELECT *
                               FROM UNNEST(credit_notes_data)
                               WHERE prod_cat = last_prod_cat
                               ORDER BY prod_cat, month) LOOP
                record_to_return := (curr_nth,
                                     FALSE,
                                     TRUE,
                                     FALSE,
                                     refund_rec.prod_cat,
                                     refund_rec.prod,
                                     refund_rec.year,
                                     refund_rec.month,
                                     refund_rec.weight,
                                     refund_rec.sales)::SRR_DECORATED_RECORD;
                RETURN NEXT record_to_return;
            END LOOP;

            -- prod_cat footer
            curr_nth := curr_nth + 1;
            FOR total_rec IN (SELECT
                               prod_cat,
                               year,
                               month,
                               COALESCE(SUM(weight), 0.0) AS weight,
                               COALESCE(SUM(sales), 0.0) AS sales
                              FROM UNNEST(sales_data || refund_data || credit_notes_data)
                              WHERE prod_cat = last_prod_cat
                              GROUP BY
                               prod_cat,
                               year,
                               month) LOOP
                record_to_return := (curr_nth,
                                     FALSE,
                                     FALSE,
                                     TRUE,
                                     total_rec.prod_cat,
                                     NULL,
                                     total_rec.year,
                                     total_rec.month,
                                     total_rec.weight,
                                     total_rec.sales)::SRR_DECORATED_RECORD;
                RETURN NEXT record_to_return;
            END LOOP;
        END IF;

        IF last_prod_cat IS NULL OR last_prod_cat != prod_cat_rec.prod_cat THEN
            -- prod_cat header
            curr_nth := curr_nth + 1;
            FOR month_rec IN (SELECT DISTINCT prod_cat, DATE_TRUNC('year', month)::DATE AS year, month AS month
                              FROM UNNEST(sales_data)
                              WHERE prod_cat = prod_cat_rec.prod_cat
                              ORDER BY month) LOOP
                record_to_return := (curr_nth,
                                     TRUE,
                                     FALSE,
                                     FALSE,
                                     month_rec.prod_cat,
                                     NULL,
                                     month_rec.year,
                                     month_rec.month,
                                     NULL,
                                     NULL)::SRR_DECORATED_RECORD;
                RETURN NEXT record_to_return;
            END LOOP;
        END IF;

        -- prod record
        last_prod := NULL;
        FOR sales_rec IN (SELECT *
                          FROM UNNEST(sales_data)
                          WHERE prod_cat = prod_cat_rec.prod_cat
                          ORDER BY prod, month) LOOP
            IF last_prod IS NULL OR last_prod != sales_rec.prod THEN
                curr_nth := curr_nth + 1;
            END IF;
            record_to_return := (curr_nth,
                                 FALSE,
                                 TRUE,
                                 FALSE,
                                 sales_rec.prod_cat,
                                 sales_rec.prod,
                                 sales_rec.year,
                                 sales_rec.month,
                                 sales_rec.weight,
                                 sales_rec.sales)::SRR_DECORATED_RECORD;
            RETURN NEXT record_to_return;
            last_prod := sales_rec.prod;
        END LOOP;

        last_prod_cat := prod_cat_rec.prod_cat;

    END LOOP;

    -- For the last normal category
    IF last_prod_cat IS NOT NULL THEN

        -- Refund data
        curr_nth := curr_nth + 1;
        FOR refund_rec IN (SELECT *
                           FROM UNNEST(refund_data)
                           WHERE prod_cat = last_prod_cat
                           ORDER BY month) LOOP
            record_to_return := (curr_nth,
                                 FALSE,
                                 TRUE,
                                 FALSE,
                                 refund_rec.prod_cat,
                                 refund_rec.prod,
                                 refund_rec.year,
                                 refund_rec.month,
                                 refund_rec.weight,
                                 refund_rec.sales)::SRR_DECORATED_RECORD;
            RETURN NEXT record_to_return;
        END LOOP;

        -- Credit notes data
        curr_nth := curr_nth + 1;
        FOR refund_rec IN (SELECT *
                           FROM UNNEST(credit_notes_data)
                           WHERE prod_cat = last_prod_cat
                           ORDER BY month) LOOP
            record_to_return := (curr_nth,
                                 FALSE,
                                 TRUE,
                                 FALSE,
                                 refund_rec.prod_cat,
                                 refund_rec.prod,
                                 refund_rec.year,
                                 refund_rec.month,
                                 refund_rec.weight,
                                 refund_rec.sales)::SRR_DECORATED_RECORD;
            RETURN NEXT record_to_return;
        END LOOP;

        -- prod_cat footer
        curr_nth := curr_nth + 1;
        FOR total_rec IN (SELECT
                           prod_cat,
                           year,
                           month,
                           COALESCE(SUM(weight), 0.0) AS weight,
                           COALESCE(SUM(sales), 0.0) AS sales
                          FROM UNNEST(sales_data || refund_data || credit_notes_data)
                          WHERE prod_cat = last_prod_cat
                          GROUP BY
                           prod_cat,
                           year,
                           month) LOOP
            record_to_return := (curr_nth,
                                 FALSE,
                                 FALSE,
                                 TRUE,
                                 total_rec.prod_cat,
                                 NULL,
                                 total_rec.year,
                                 total_rec.month,
                                 total_rec.weight,
                                 total_rec.sales)::SRR_DECORATED_RECORD;
            RETURN NEXT record_to_return;
        END LOOP;
    END IF;
    -- Normal Category [END]

    -- Other Product Category
    -- prod_cat header
    curr_nth := curr_nth + 1;
    FOR month_rec IN (SELECT DISTINCT prod_cat, DATE_TRUNC('year', month)::DATE AS year, month AS month
                      FROM UNNEST(sales_data)
                      WHERE prod_cat ILIKE other_cat_name
                      ORDER BY month) LOOP
        record_to_return := (curr_nth,
                             TRUE,
                             FALSE,
                             FALSE,
                             month_rec.prod_cat,
                             NULL,
                             month_rec.year,
                             month_rec.month,
                             NULL,
                             NULL)::SRR_DECORATED_RECORD;
        RETURN NEXT record_to_return;
    END LOOP;

    -- prod record
    last_prod := NULL;
    FOR sales_rec IN (SELECT *
                      FROM UNNEST(sales_data)
                      WHERE prod_cat ILIKE other_cat_name
                      ORDER BY prod, month) LOOP
        IF last_prod IS NULL OR last_prod != sales_rec.prod THEN
            curr_nth := curr_nth + 1;
        END IF;
        record_to_return := (curr_nth,
                             FALSE,
                             TRUE,
                             FALSE,
                             sales_rec.prod_cat,
                             sales_rec.prod,
                             sales_rec.year,
                             sales_rec.month,
                             sales_rec.weight,
                             sales_rec.sales)::SRR_DECORATED_RECORD;
        RETURN NEXT record_to_return;
        last_prod := sales_rec.prod;
    END LOOP;

    -- Refund data
    curr_nth := curr_nth + 1;
    FOR refund_rec IN (SELECT *
                       FROM UNNEST(refund_data)
                       WHERE prod_cat ILIKE other_cat_name
                       ORDER BY month) LOOP
        record_to_return := (curr_nth,
                             FALSE,
                             TRUE,
                             FALSE,
                             refund_rec.prod_cat,
                             refund_rec.prod,
                             refund_rec.year,
                             refund_rec.month,
                             refund_rec.weight,
                             refund_rec.sales)::SRR_DECORATED_RECORD;
        RETURN NEXT record_to_return;
    END LOOP;

    -- Credit notes data
    curr_nth := curr_nth + 1;
    FOR refund_rec IN (SELECT *
                       FROM UNNEST(credit_notes_data)
                       WHERE prod_cat ILIKE other_cat_name
                       ORDER BY month) LOOP
        record_to_return := (curr_nth,
                             FALSE,
                             TRUE,
                             FALSE,
                             refund_rec.prod_cat,
                             refund_rec.prod,
                             refund_rec.year,
                             refund_rec.month,
                             refund_rec.weight,
                             refund_rec.sales)::SRR_DECORATED_RECORD;
        RETURN NEXT record_to_return;
    END LOOP;

    -- prod_cat footer
    curr_nth := curr_nth + 1;
    FOR total_rec IN (SELECT
                       prod_cat,
                       year,
                       month,
                       COALESCE(SUM(weight), 0.0) AS weight,
                       COALESCE(SUM(sales), 0.0) AS sales
                      FROM UNNEST(sales_data || refund_data || credit_notes_data)
                      WHERE prod_cat ILIKE other_cat_name
                      GROUP BY
                       prod_cat,
                       year,
                       month) LOOP
        record_to_return := (curr_nth,
                             FALSE,
                             FALSE,
                             TRUE,
                             total_rec.prod_cat,
                             NULL,
                             total_rec.year,
                             total_rec.month,
                             total_rec.weight,
                             total_rec.sales)::SRR_DECORATED_RECORD;
        RETURN NEXT record_to_return;
    END LOOP;
    -- Other Product Category [END]
END
"""

REPORT_SQL = """
WITH period_axis AS
  ( SELECT DATE_TRUNC('year', selected_period)::DATE AS year,
           DATE_TRUNC('month', selected_period)::DATE AS month,
           (CASE WHEN selected_period::DATE < '$P!{FROM_DATE_2_YR}-$P!{FROM_DATE_2_MO}-$P!{FROM_DATE_2_DY}'::DATE
            THEN '$P!{FROM_DATE_2_YR}-$P!{FROM_DATE_2_MO}-$P!{FROM_DATE_2_DY}'::DATE
            ELSE selected_period::DATE END) AS period_start,
           (CASE WHEN (selected_period + '1 month'::INTERVAL - '1 day'::INTERVAL)::DATE > '$P!{TO_DATE_2_YR}-$P!{TO_DATE_2_MO}-$P!{TO_DATE_2_DY}'::DATE
            THEN '$P!{TO_DATE_2_YR}-$P!{TO_DATE_2_MO}-$P!{TO_DATE_2_DY}'::DATE
            ELSE (selected_period + '1 month'::INTERVAL - '1 day'::INTERVAL)::DATE END) AS period_stop
   FROM GENERATE_SERIES(DATE_TRUNC('month', '$P!{FROM_DATE_2_YR}-$P!{FROM_DATE_2_MO}-$P!{FROM_DATE_2_DY}'::DATE), DATE_TRUNC('month', '$P!{TO_DATE_2_YR}-$P!{TO_DATE_2_MO}-$P!{TO_DATE_2_DY}'::DATE), '1 month'::INTERVAL) selected_period ),
     sales_data AS (-- Period axis data points as well as the category axis
       SELECT pa.year as year,
              pa.month as month,
              COALESCE(pc$P!{PROD_GROUP_LEVEL}.name,
                       'Without Product Category')as prod_cat,
              COALESCE(pp.name_template,
                       'Without Product ID') as prod,
              SUM(ail.quantity * pt.weight_net) as weight,
              SUM(sol_subtotal.subtotal / cr.rate) as sales
       FROM $P!{SOL_SUBTOTAL_TABLE}
       INNER JOIN account_invoice_line ail ON ail.id = sol_subtotal.id
       INNER JOIN account_invoice ai ON ail.invoice_id = ai.id
       INNER JOIN period_axis pa ON ai.date_invoice::DATE BETWEEN pa.period_start AND pa.period_stop
       LEFT JOIN product_product pp ON ail.product_id = pp.id
       LEFT JOIN product_template pt ON pt.id = pp.product_tmpl_id $P!{PROD_CAT_CLAUSE},
       res_currency_rate cr
       WHERE cr.id IN
           (SELECT id
             FROM res_currency_rate cr2
            WHERE (cr2.currency_id = ai.currency_id)
              AND ((ai.date_invoice IS NOT NULL
                    AND cr.name <= ai.date_invoice)
                   OR (ai.date_invoice is null
                       AND cr.name <= NOW()))
            ORDER BY id DESC limit 1)
       GROUP BY pc$P!{PROD_GROUP_LEVEL}.name,
                pa.year,
                pa.month,
                pp.name_template ),
     prod_cat_period_axes AS
  ( SELECT DISTINCT sales_data.prod_cat,
                    period_axis.year,
                    period_axis.month,
                    period_axis.period_start,
                    period_axis.period_stop
   FROM sales_data
   INNER JOIN period_axis ON TRUE ),
     prod_cat_prod_period_axes AS
  ( SELECT DISTINCT sales_data.prod_cat,
                    sales_data.prod,
                    period_axis.year,
                    period_axis.month,
                    period_axis.period_start,
                    period_axis.period_stop
   FROM sales_data
   INNER JOIN period_axis ON TRUE ),
     refund_data AS (-- Axis data points
       SELECT axes.prod_cat,
              axes.year,
              axes.month,
              -SUM(ail.quantity * pt.weight_net) AS weight,
              -SUM(ail.price_subtotal) AS sales,
              (CASE WHEN returned_goods.invoice_id IS NULL
                THEN 'credit_notes'
                ELSE 'retur' END) AS type
       FROM account_invoice ai
       INNER JOIN prod_cat_prod_period_axes axes ON ai.date_invoice::DATE BETWEEN axes.period_start AND axes.period_stop
       INNER JOIN account_invoice_line ail ON ail.invoice_id = ai.id
       INNER JOIN product_product pp ON pp.id = ail.product_id
       INNER JOIN product_template pt ON pt.id = pp.product_tmpl_id $P!{PROD_CAT_CLAUSE}
       LEFT JOIN
         (SELECT DISTINCT invoice_id
          FROM stock_picking_invoice_rel spir) returned_goods ON returned_goods.invoice_id = ai.id
       WHERE ai.company_id IN ($P!{COMPANY_IDS})
         AND ai.state IN ('open',
                          'paid')
         AND ai.type = 'out_refund'
         AND pc$P!{PROD_GROUP_LEVEL}.name = axes.prod_cat
         AND pp.name_template = axes.prod
       GROUP BY axes.prod_cat,
                axes.year,
                axes.month,
                returned_goods.invoice_id )
SELECT *
FROM srr_decorator(
                     (SELECT ARRAY_AGG((axes.prod_cat, axes.prod, axes.year, axes.month, weight, sales)::SRR_DATA_POINT)
                      FROM prod_cat_prod_period_axes axes
                      LEFT JOIN sales_data ON (axes.prod_cat, axes.prod, axes.year, axes.month) = (sales_data.prod_cat, sales_data.prod, sales_data.year, sales_data.month)),
                     (SELECT ARRAY_AGG((axes.prod_cat, 'Retur', axes.year, axes.month, weight, sales)::SRR_DATA_POINT)
                      FROM prod_cat_period_axes axes
                      LEFT JOIN refund_data ON ((axes.prod_cat, axes.year, axes.month) = (refund_data.prod_cat, refund_data.year, refund_data.month)
                                                AND refund_data.type = 'retur')),
                     (SELECT ARRAY_AGG((axes.prod_cat, 'Credit Note', axes.year, axes.month, weight, sales)::SRR_DATA_POINT)
                      FROM prod_cat_period_axes axes
                      LEFT JOIN refund_data ON ((axes.prod_cat, axes.year, axes.month) = (refund_data.prod_cat, refund_data.year, refund_data.month)
                                                AND refund_data.type = 'credit_notes')), 'other product category')
ORDER BY nth,
         month
"""


class via_jasper_report(osv.osv_memory):
    _inherit = 'via.jasper.report'
    _description = 'Sales Report (Rekap)'

    def _auto_init(self, cr, context=None):
        super(via_jasper_report, self)._auto_init(cr, context=context)
        create_composite_type(cr, 'srr_axes',
                              [('prod_cat', 'VARCHAR'),
                               ('year', 'DATE'),
                               ('month', 'DATE'),
                               ('period_start', 'DATE'),
                               ('period_stop', 'DATE')])
        create_composite_type(cr, 'srr_data_point',
                              [('prod_cat', 'VARCHAR'),
                               ('prod', 'VARCHAR'),
                               ('year', 'DATE'),
                               ('month', 'DATE'),
                               ('weight', 'NUMERIC'),
                               ('sales', 'NUMERIC')])
        create_composite_type(cr, 'srr_decorated_record',
                              [('nth', 'BIGINT'),
                               ('decorator_prod_cat_header', 'BOOLEAN'),
                               ('decorator_prod', 'BOOLEAN'),
                               ('decorator_prod_cat_footer', 'BOOLEAN'),
                               ('prod_cat', 'VARCHAR'),
                               ('prod', 'VARCHAR'),
                               ('year', 'DATE'),
                               ('month', 'DATE'),
                               ('weight', 'NUMERIC'),
                               ('sales', 'NUMERIC')])
        create_plpgsql_proc(cr, 'srr_decorator',
                            [('IN', 'sales_data', 'SRR_DATA_POINT[]'),
                             ('IN', 'refund_data', 'SRR_DATA_POINT[]'),
                             ('IN', 'credit_notes_data', 'SRR_DATA_POINT[]'),
                             ('IN', 'other_cat_name', 'VARCHAR')],
                            'SETOF SRR_DECORATED_RECORD',
                            _SRR_DECORATOR_DEF)

    _columns = {
    }

    # DO NOT use the following default dictionary. Use the one in class wizard.
    # The following is presented for your information regarding the system-
    # wide defaults.
    _defaults = {
    }

via_jasper_report()


class wizard(wizard):
    def onchange_company_ids(cr, uid, ids, com_ids, context=None):
        # Sample com_ids = [(6, 0, [14, 11])]
        if len(com_ids) == 0:
            return {
                'domain': {'prod_ids': [('product_tmpl_id.company_id', '=', False)]},
                'value': {'prod_ids': False},
            }
        return {
            'domain': {'prod_ids': [('product_tmpl_id.company_id', 'in', com_ids[0][2])]},
            'value': {'prod_ids': False},
        }

    _onchange = {
        'company_ids': (onchange_company_ids, 'company_ids', 'context'),
    }

    _visibility = [
        'company_ids',
        ['from_dt', 'to_dt'],
        'prod_group_level',
    ]

    _required = [
        'from_dt',
        'to_dt',
        'prod_group_level',
    ]

    _readonly = [
    ]

    _attrs = {
    }

    _domain = {
    }

    _label = {
        'from_dt': 'Invoice Date From',
    }

    _defaults = {
    }

    _states = [
    ]

    _tree_columns = {
    }

    def get_credit_notes(self, cr, uid, form, context=None):
        partner_pool = self.pool.get('res.partner')
        sql_get_customer = (' SELECT DISTINCT ai.partner_id'
                            ' FROM'
                            '  account_invoice ai'
                            '  INNER JOIN account_invoice_line ail'
                            '   ON ail.invoice_id = ai.id'
                            '  LEFT JOIN product_product pp'
                            '   ON ail.product_id = pp.id'
                            '  LEFT JOIN product_template pt'
                            '   ON pp.product_tmpl_id = pt.id'
                            ' WHERE'
                            "  ai.type in ('out_invoice', 'out_refund')"
                            "  AND ai.state in ('open','paid')"
                            '  AND ai.company_id IN (%s)'
                            '  AND (ail.product_id IN (%s) OR ail.product_id IS NULL)'
                            "  AND ai.date_invoice BETWEEN '%s' AND '%s'")
        cr.execute(sql_get_customer % (','.join(str(com_id.id)
                                                for com_id in form.company_ids),
                                       ','.join(str(prod_id)
                                                for prod_id in form.get_prod_ids(context=context)),
                                       form.from_dt,
                                       form.to_dt))
        res = 0.0
        for partner in partner_pool.browse(cr, uid, [record[0] for record in cr.fetchall()], context=context):
            res += (partner.credit < 0) and partner.credit or 0.0
        return res

    def get_sol_subtotal(self, cr, uid, form, context=None):
        sol_pool = self.pool.get('account.invoice.line')
        sql_get_sol = (' SELECT ail.id'
                       ' FROM'
                       '  account_invoice ai'
                       '  INNER JOIN account_invoice_line ail'
                       '   ON ail.invoice_id = ai.id'
                       '  LEFT JOIN product_product pp'
                       '   ON ail.product_id = pp.id'
                       '  LEFT JOIN product_template pt'
                       '   ON pp.product_tmpl_id = pt.id'
                       ' WHERE'
                       "  ai.type in ('out_invoice', 'out_refund')"
                       "  AND ai.state in ('open','paid') "
                       '  AND ai.company_id IN (%s)'
                       '  AND (ail.product_id IN (%s) OR ail.product_id IS NULL)'
                       '  AND pp.excluded_product IS NOT TRUE'
                       "  AND ai.date_invoice BETWEEN '%s' AND '%s'")
        cr.execute(sql_get_sol % (','.join(str(com_id.id)
                                           for com_id in form.company_ids),
                                  ','.join(str(prod_id)
                                           for prod_id in form.get_prod_ids(context=context)),
                                  form.from_dt,
                                  form.to_dt))
        res = []
        for sol in sol_pool.browse(cr, uid, [record[0] for record in cr.fetchall()], context=context):
            res.append((sol.id, sol.price_subtotal))
        return res

    def validate_parameters(self, cr, uid, form, context=None):
        if len(form.company_ids) == 0:
            raise osv.except_osv(_('Caution !'),
                                 _('No page will be printed !'))

        form.validate_prod_level(context=context)

    def print_report(self, cr, uid, form, context=None):
        self.validate_parameters(cr, uid, form, context=context)

        sol_subtotal = self.get_sol_subtotal(cr, uid, form, context=context)
        sol_subtotal_table = list_to_pgTable(sol_subtotal,
                                             'sol_subtotal',
                                             [('id', 'INTEGER'),
                                              ('subtotal', 'NUMERIC')])
        form.add_marshalled_data('SOL_SUBTOTAL_TABLE', sol_subtotal_table)

        all_customers_credit_notes = self.get_credit_notes(cr, uid, form,
                                                           context=context)
        form.add_marshalled_data('CREDIT_NOTES', all_customers_credit_notes)
        form.add_marshalled_data('REPORT_SQL', REPORT_SQL)

register_report_wizard(RPT_NAME, wizard)
