<%@ page import="com.manydesigns.elements.xml.XhtmlBuffer" %>
<%@ page import="com.manydesigns.portofino.pageactions.timesheet.model.NonWorkingDaysModel" %>
<%@ page import="org.joda.time.DateMidnight" %>
<%@ page import="org.joda.time.DateTimeConstants" %>
<%@ page import="org.joda.time.Interval" %>
<%@ page import="org.joda.time.format.DateTimeFormatter" %>
<%@ page import="org.joda.time.format.DateTimeFormatterBuilder" %>
<%@ page import="java.util.Locale" %>
<%@ page contentType="text/html;charset=UTF-8" language="java"
         pageEncoding="UTF-8"
%><%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"
%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"
%><%@ taglib prefix="stripes" uri="http://stripes.sourceforge.net/stripes-dynattr.tld"
%><%@taglib prefix="mde" uri="/manydesigns-elements"
%><%@ taglib tagdir="/WEB-INF/tags" prefix="portofino" %>
<stripes:layout-render name="/skins/${skin}/modal-page.jsp">
    <jsp:useBean id="actionBean" scope="request" type="com.manydesigns.portofino.pageactions.timesheet.TimesheetAction"/>
    <stripes:layout-component name="contentHeader">
        <portofino:buttons list="timesheet-non-working-days" cssClass="contentButton" />
        <jsp:include page="/skins/${skin}/breadcrumbs.jsp" />
    </stripes:layout-component>
    <stripes:layout-component name="portletTitle">
        <c:out value="${actionBean.page.title}"/>
    </stripes:layout-component>
    <stripes:layout-component name="portletBody">
        <style type="text/css">
            div.tnwd-container {
                overflow-x: auto;
            }
            table.tnwd-table {
                width: 25em;
                table-layout: fixed;
            }
            table.tnwd-table th, table.tnwd-table td {
                border-color: #dddddd;
            }
            th.tndw-day-of-week {
                background-color: #94B47B;
                color: white;
            }
            th.tndw-saturday, th.tndw-sunday {
                background-color: #74936C;
            }
            table.tnwd-table tbody td {
                padding: 1px;
            }
            div.tnws-day, div.tnws-blank-day {
                padding: 0.5em 0 ;
            }
            div.tnws-day {
                text-align: center;
                cursor: pointer;
            }
            div.tnws-day.tnws-non-working {
                background-color: #F0F8E5;
                color: #993333;
                font-weight: bold;
            }
            div.tnws-day.tnws-hover {
                background-color: #FACE00;
            }
            div.tnws-buttons {
                text-align: right;
            }
        </style>
        <%
            NonWorkingDaysModel nonWorkingDaysModel =
                    actionBean.getNonWorkingDaysModel();
            XhtmlBuffer xb = new XhtmlBuffer(out);

            Locale locale = request.getLocale();
            DateTimeFormatter monthFormatter =
                    new DateTimeFormatterBuilder()
                    .appendMonthOfYearText()
                    .appendLiteral(" ")
                    .appendYear(4, 4)
                    .toFormatter().withLocale(locale);
        %>
        <div class="yui-gc">
            <div class="yui-u first">
                <fmt:message key="timesheet.month"/>:
                <%
                    xb.write(monthFormatter.print(nonWorkingDaysModel.getMonthStart()));
                %>
            </div>
            <div class="yui-u tnws-buttons">
                <portofino:buttons list="timesheet-nwd-navigation" cssClass="portletButton" />
            </div>
        </div>
        <div class="horizontalSeparator"></div>
        <div class="tnwd-container">
            <table class="tnwd-table">
                <thead>
                <tr>
                <%
                    DateTimeFormatterBuilder dayOfWeekFormatterBuilder =
                            new DateTimeFormatterBuilder()
                            .appendDayOfWeekShortText();
                    DateTimeFormatter dayOfWeekFormatter =
                            dayOfWeekFormatterBuilder
                                    .toFormatter()
                                    .withLocale(locale);
                    NonWorkingDaysModel.NWDWeek week = nonWorkingDaysModel.getWeek(0);
                    for (int i = 0; i < 7; i++) {
                        xb.openElement("th");
                        NonWorkingDaysModel.NWDDay day = week.getDay(i);
                        String htmlClass = "tndw-day-of-week";
                        DateMidnight dayStart = day.getDayStart();
                        int dayOfWeek = dayStart.getDayOfWeek();
                        if (dayOfWeek == DateTimeConstants.SATURDAY) {
                            htmlClass += " tndw-saturday";
                        } else if (dayOfWeek == DateTimeConstants.SUNDAY) {
                            htmlClass += " tndw-sunday";
                        }
                        xb.addAttribute("class", htmlClass);

                        xb.write(dayOfWeekFormatter.print(dayStart));

                        xb.closeElement("th");
                    }
                %>
                </tr>
                </thead>
                <tbody>
                <%
                    DateTimeFormatterBuilder dayOfMonthFormatterBuilder =
                            new DateTimeFormatterBuilder()
                            .appendDayOfMonth(1);
                    DateTimeFormatter dayOfMonthFormatter =
                            dayOfMonthFormatterBuilder
                                    .toFormatter()
                                    .withLocale(locale);
                    Interval monthInterval = nonWorkingDaysModel.getMonthInterval();
                    for (int i = 0; i < 6; i++) {
                        week = nonWorkingDaysModel.getWeek(i);
                        xb.openElement("tr");
                        for (int j = 0; j < 7; j++) {
                            NonWorkingDaysModel.NWDDay day = week.getDay(j);
                            DateMidnight dayStart = day.getDayStart();
                            xb.openElement("td");
                            if (monthInterval.contains(dayStart)) {
                                xb.openElement("div");
                                String htmlClass = "tnws-day";
                                if (day.isNonWorking()) {
                                    htmlClass += " tnws-non-working";
                                }
                                xb.addAttribute("class", htmlClass);
                                xb.write(dayOfMonthFormatter.print(dayStart));
                                xb.closeElement("div");
                            } else {
                                xb.openElement("div");
                                xb.addAttribute("class", "tnws-blank-day");
                                xb.writeNbsp();
                                xb.closeElement("div");
                            }
                            xb.closeElement("td");
                        }
                        xb.closeElement("tr");
                    }
                %>
                </tbody>
            </table>
        </div>
        <input type="hidden" name="month" value="<c:out value="${actionBean.referenceDate.month + 1}"/>"/>
        <input type="hidden" name="year" value="<c:out value="${actionBean.referenceDate.year + 1900}"/>"/>
        <input type="hidden" name="referenceDate" value="<c:out value="${actionBean.referenceDate}"/>"/>
        <script type="text/javascript">
            function setNotWorkingDay(cell, nonWorking) {
                var day = cell.text();
                var month = $('input[name$="month"]').val();
                var year = $('input[name$="year"]').val();
                cell.html('<fmt:message key="timesheet.saving"/>');
                var data = {
                    day : day,
                    month : month,
                    year : year,
                    nonWorking : nonWorking,
                    configureNonWorkingDay : ""
                };

                var postUrl = stripQueryString(location.href);
                jQuery.ajax({
                    type: "post",
                    url: postUrl,
                    data: data,
                    success: function(responseData) {
                        var options = responseData;
                        if('string' === typeof(options)) {
                            options = jQuery.parseJSON(options);
                        }
                        if (nonWorking) {
                            cell.addClass("tnws-non-working");
                        } else {
                            cell.removeClass("tnws-non-working");
                        }
                    },
                    error: function() {
                        alert("Ajax error")
                    }
                });
                cell.html(day);
            }
            $("div.tnws-day").mousemove(
                    function() {
                        $(this).addClass("tnws-hover");
                    }
            ).mouseleave(
                    function() {
                        $(this).removeClass("tnws-hover");
                    }
            ).click(
                    function() {
                        var cell = $(this);
                        if (cell.hasClass("tnws-non-working")) {
                            setNotWorkingDay(cell, false);
                        } else {
                            setNotWorkingDay(cell, true);
                        }
                        cell.removeClass("tnws-hover");
                    }
            )
        </script>
    </stripes:layout-component>
    <stripes:layout-component name="portletFooter"/>
    <stripes:layout-component name="contentFooter">
    </stripes:layout-component>
</stripes:layout-render>