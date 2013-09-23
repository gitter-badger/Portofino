<%@ page contentType="text/html;charset=UTF-8" language="java"
         pageEncoding="UTF-8"
%><%@ page import="org.apache.commons.lang.StringEscapeUtils"
%><%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"
%><%@ taglib prefix="stripes" uri="http://stripes.sourceforge.net/stripes-dynattr.tld"
%><%@ taglib prefix="mde" uri="/manydesigns-elements"
%><%@ taglib tagdir="/WEB-INF/tags" prefix="portofino"
%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"
%><jsp:useBean id="actionBean" scope="request"
               type="com.manydesigns.portofino.actions.admin.page.PageAdminAction"
/><stripes:layout-render name="${actionBean.pageTemplate}/modal.jsp">
    <stripes:layout-component name="portletTitle">
        <fmt:message key="page.children.title">
            <fmt:param value="<%= StringEscapeUtils.escapeHtml(actionBean.getPage().getTitle()) %>" />
        </fmt:message>
    </stripes:layout-component>
    <stripes:layout-component name="portletBody">
        <stripes:form action="/actions/admin/page" method="post" enctype="multipart/form-data">
            <%@include file="children-tables.jsp"%>
            <div class="form-actions">
                <portofino:buttons list="page-children-edit" />
            </div>
        </stripes:form>
    </stripes:layout-component>
</stripes:layout-render>