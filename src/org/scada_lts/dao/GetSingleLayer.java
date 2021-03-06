package org.scada_lts.dao;

import com.google.gson.Gson;
import java.io.*;
import java.sql.*;
import java.util.*;
import java.util.stream.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.scada_lts.dao.DAO;
import org.scada_lts.dao.LayerBean;
import org.scada_lts.dao.LayerBean;
import org.springframework.jdbc.core.RowMapper;

//GetSingleLayer Servlet
public class GetSingleLayer extends HttpServlet {

  public void doGet(HttpServletRequest request, HttpServletResponse response)
    throws IOException {
    try {
      String requestData = request
        .getReader()
        .lines()
        .collect(Collectors.joining());

      Gson gson = new Gson();
      LayerBean layer = gson.fromJson(requestData, LayerBean.class);
      Statement statement;
      ResultSet rs;

      statement =
        DAO
          .getInstance()
          .getJdbcTemp()
          .getDataSource()
          .getConnection()
          .createStatement();
      rs =
        statement.executeQuery(
          "select * from layers where layerId=" + layer.getLayerId() + ""
        );
      String respons = "";
      while (rs.next()) {
        respons =
          respons.concat(
            "{\"layerId\": " +
            rs.getInt("layerId") +
            ",\"layerName\": \"" +
            rs.getString("layerName") +
            "\",\"layerDescrption\": \"" +
            rs.getString("layerDescription") +
            "\"}"
          );
      }

      rs.close();
      response.setStatus(200);
      response.setContentType("text/html");
      PrintWriter writer = response.getWriter();
      writer.append("{\"data\":" + respons + "}");
      writer.flush();
    } catch (Exception e) {
      response.setStatus(500);
      response.setContentType("text/html");
      PrintWriter writer = response.getWriter();
      writer.append("Something Wrong");
      writer.flush();
    }
  }
}
