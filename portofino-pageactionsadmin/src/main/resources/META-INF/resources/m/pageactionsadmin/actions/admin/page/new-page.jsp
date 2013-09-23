<%@ page import="com.manydesigns.portofino.breadcrumbs.BreadcrumbItem" %>
<%@ page import="com.manydesigns.portofino.breadcrumbs.Breadcrumbs" %>
<%@ page import="com.manydesigns.portofino.dispatcher.PageInstance" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java"
         pageEncoding="UTF-8" %><%@
    taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%><%@
    taglib prefix="stripes" uri="http://stripes.sourceforge.net/stripes-dynattr.tld"%><%@
    taglib prefix="mde" uri="/manydesigns-elements"%><%@
    taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@
    taglib tagdir="/WEB-INF/tags" prefix="portofino" %>
<stripes:layout-render name="${actionBean.pageTemplate}/modal.jsp">
    <jsp:useBean id="actionBean" scope="request" type="com.manydesigns.portofino.actions.admin.page.PageAdminAction"/>
    <stripes:layout-component name="portletTitle">
        <fmt:message key="layouts.page-crud.new-page.add_new_page"/>
    </stripes:layout-component>
    <stripes:layout-component name="portletBody">
        <stripes:form action="/actions/admin/page" method="post" enctype="multipart/form-data"
                      class="form-horizontal">
            <input type="hidden" name="originalPath" value="${actionBean.dispatch.originalPath}" />
            <mde:write name="actionBean" property="newPageForm"/>
            <fieldset>
                <legend><fmt:message key="layouts.page-crud.new-page.preview"/></legend>
                <table>
                    <tbody>
                    <tr>
                        <th><label class="control-label" for="url">Url:</label></th>
                        <td><span id="url"></span></td>
                    </tr>
                    <tr>
                        <th><label class="control-label" for="breadcrumbs">Breadcrumbs:</label></th>
                        <td><span id="breadcrumbs"></span></td>
                    </tr>
                    </tbody>
                </table>
            </fieldset>
            <input type="hidden" name="cancelReturnUrl" value="<c:out value="${actionBean.cancelReturnUrl}"/>"/>
            <div class="form-actions">
                <portofino:buttons list="page-create" />
            </div>
        </stripes:form>
        <% PageInstance pageInstance = actionBean.dispatch.getLastPageInstance(); %>
        <script type="text/javascript">
            $(function() {
                var rootPath = "<%= request.getContextPath() %>";
                var rootBreadcrumbs = "";

                var currentPath = "<%= pageInstance.getPath() %>";
                var currentBreadcrumbs =
                        "<%= generateBreadcrumbs(new Breadcrumbs(actionBean.dispatch)) %>";

                var parentPath = "<%= pageInstance.getParent().getPath() %>";
                var parentBreadcrumbs =
                        "<%= generateBreadcrumbs(new Breadcrumbs(actionBean.dispatch,
                                                    actionBean.dispatch.getPageInstancePath().length - 1)) %>";

                var urlField = $("#url");
                var breadcrumbsField = $("#breadcrumbs");
                var fragmentField = $("#fragment");
                var titleField = $("#title");

                var position = $("input[name=insertPositionName][checked=checked]").val();
                function recalculateUrlAndBreadcrumbs() {
                    var basePath;
                    var baseBreadcrumbs;
                    if("TOP" == position) {
                        basePath = rootPath;
                        baseBreadcrumbs = rootBreadcrumbs;
                    } else if("CHILD" == position) {
                        basePath = rootPath + currentPath;
                        baseBreadcrumbs = currentBreadcrumbs;
                    } else if("SIBLING" == position) {
                        basePath = rootPath + parentPath;
                        baseBreadcrumbs = parentBreadcrumbs;
                    }

                    urlField.html(htmlEscape(basePath + "/" + fragmentField.val()));
                    breadcrumbsField.html(htmlEscape(baseBreadcrumbs + titleField.val()));
                }

                fragmentField.change(recalculateUrlAndBreadcrumbs);
                titleField.change(recalculateUrlAndBreadcrumbs);
                $("input[name=insertPositionName]").change(function() {
                    if($(this).prop('checked')) {
                        position = $(this).val();
                        recalculateUrlAndBreadcrumbs();
                    }
                });
                recalculateUrlAndBreadcrumbs();
            });
        </script>
    </stripes:layout-component>
</stripes:layout-render>
<%!
    private String generateBreadcrumbs(Breadcrumbs breadcrumbs) {
        List<BreadcrumbItem> items = breadcrumbs.getItems();
        StringBuilder sb = new StringBuilder();
        for (BreadcrumbItem current : items) {
            sb.append(current.getText());
            sb.append(" > ");
        }
        return StringEscapeUtils.escapeJavaScript(sb.toString());
    }
%>