
/*******************************************************************************
 *                                                                             *
 *  Vikasa Infinity Anugrah, PT                                                *
 *  Copyright (C) 2013 Vikasa Infinity Anugrah <http://www.infi-nity.com>      *
 *                                                                             *
 *  This program is free software: you can redistribute it and/or modify       *
 *  it under the terms of the GNU Affero General Public License as             *
 *  published by the Free Software Foundation, either version 3 of the         *
 *  License, or (at your option) any later version.                            *
 *                                                                             *
 *  This program is distributed in the hope that it will be useful,            *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 *  GNU Affero General Public License for more details.                        *
 *                                                                             *
 *  You should have received a copy of the GNU Affero General Public License   *
 *  along with this program.  If not, see http://www.gnu.org/licenses/.        *
 *                                                                             *
 *******************************************************************************/

import java.math.BigDecimal;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import net.sf.jasperreports.engine.*;

public class PoSummary implements JRDataSource
{
    private NestedDict dataset = null;

    private Comparator<Object[]> sorter = null;
    private Iterator<Object[]> itr = null;
    private long nth_row = 0;
    private Object[] currRecord = null;

    public PoSummary()
    {
        dataset = new NestedDict(new String[] {"po_supplier", "po_no"},
                                 new String[] {"po_to_is", "gjsc_avg_count"},
                                 new NestedDict.InitialValueFactory() {
                                     public Object getInitialValue(String fieldName)
                                     {
                                         
                                         if (fieldName.equals("po_to_is")) {
                                             return new java.math.BigDecimal("0");
                                         } else
    
                                         if (fieldName.equals("gjsc_avg_count")) {
                                             return new Long(0);
                                         } else {
                                             throw new IllegalArgumentException("Unknown field name: "
                                                                                + fieldName);
                                         }
                                     }
                                 });
        sorter = !false ? null : new Comparator<Object[]>() {
            public boolean equals(Object obj) {
                return obj.equals(this);
            }

            public int compare(Object[] o1, Object[] o2) {
                if (o1.length != o2.length) {
                    throw new ClassCastException("o1.length != o2.length");
                }
                int last_comparison = 0;
                
                return last_comparison;
            }
        };
    }

    public PoSummary addRecord(String poSupplier, String poNo, java.math.BigDecimal poToIs)
    {
        
        java.math.BigDecimal totalPoToIs;
        totalPoToIs = (java.math.BigDecimal) dataset.getValue(new String[] {
            poSupplier, poNo,
            "po_to_is"
        });
        totalPoToIs = totalPoToIs.add(
            poToIs == null ? new java.math.BigDecimal("0") : poToIs
        );
        dataset.setValue(new String[] {
            poSupplier, poNo,
            "po_to_is"
        }, totalPoToIs);


        Long gjscAvgCount = (Long) dataset.getValue(new String[] {
            poSupplier, poNo,
            "gjsc_avg_count"
        });
        dataset.setValue(new String[] {
            poSupplier, poNo,
            "gjsc_avg_count"
        }, new Long(gjscAvgCount + 1));

        return this;
    }

    public void reset()
    {
        itr = null;
    }

    public boolean next()
    {
        if (itr == null) {
            if (sorter == null) {
                itr = dataset.getList().iterator();
            } else {
                itr = dataset.getList(sorter).iterator();
            }
            nth_row = 0;
        }

        boolean res = itr.hasNext();
        if (res) {
            currRecord = itr.next();
            nth_row++;
        }
        return res;
    }

    public Object getFieldValue(JRField jrField) throws JRException
    {
        String fieldName = jrField.getName();
        if (fieldName.equals("nth_row")) {
            return new BigDecimal(nth_row);
        }

        Map<String, Integer> field2idx = dataset.getFieldToEntryIndexMapping();

        Integer idx = field2idx.get(fieldName);
        if (idx == null) {
            return null;
        }

        return currRecord[idx];
    }
}
