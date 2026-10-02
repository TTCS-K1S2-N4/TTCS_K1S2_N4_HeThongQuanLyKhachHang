<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%
  List<Map<String,Object>> list = new ArrayList<>();
  Map<String,Object> a = new HashMap<>();
  a.put("fieldName", "Ngày sinh");   // đổi key theo JSP của bạn
  a.put("fieldType", "DATE");
  a.put("required", true);
  a.put("active", true);
  list.add(a);
  request.setAttribute("customFields", list);
  // test hiển thị lỗi:
  // request.setAttribute("errors", Arrays.asList("Tên trường không được trống"));
%>
<jsp:include page="/WEB-INF/views/customers/custom-fields.jsp" />