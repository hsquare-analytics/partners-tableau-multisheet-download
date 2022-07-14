package com.planit.tableau.portal.standard.v1.excel.bindings;


import java.util.ArrayList;
import java.util.List;


public class WorkSheetList {
	public List<WorkSheetType> workbook;
	
	public List<WorkSheetType> getWorkSheet() {
        if (workbook == null) {
            workbook = new ArrayList<WorkSheetType>();
        }
        return this.workbook;
    }

}
