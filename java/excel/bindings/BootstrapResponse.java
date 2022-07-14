package com.planit.tableau.portal.standard.v1.excel.bindings;

import org.json.JSONObject;

public class BootstrapResponse {
	/**
	 * sessionId
	 */
	private String newSessionId;
	/**
	 * vizqlRoot
	 */
	private JSONObject viewIds;
	
	/**
	 * sheetId
	 */
	private String sheetName;
	
	
	public String getNewSessionId() {
		return newSessionId;
	}
	public void setNewSessionId(String newSessionId) {
		this.newSessionId = newSessionId;
	}

	public String getSheetName() {
		return sheetName;
	}
	public void setSheetName(String sheetName) {
		this.sheetName = sheetName;
	}
	
	public JSONObject getViewIds() {
		return viewIds;
	}
	public void setViewIds(JSONObject viewIds) {
		this.viewIds = viewIds;
	}
	

}
