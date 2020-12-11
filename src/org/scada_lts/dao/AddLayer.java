package org.scada_lts.dao;
import org.scada_lts.dao.LayerBean;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.*;
import org.scada_lts.dao.DAO;
import java.util.stream.*;
import com.google.gson.Gson;
import org.scada_lts.dao.LayerBean;
public class AddLayer   extends HttpServlet
{   
final String sqlLayerAdd =
		   "insert into layers (" +
			   "layerName, " +
			  
			   "layerDescription) " +
		   "values (?,?)";

	
    public void doPost(HttpServletRequest request,HttpServletResponse response) throws  IOException 
{
       String requestData = request.getReader().lines().collect(Collectors.joining());
    
       Gson gson = new Gson();
       LayerBean layer = gson.fromJson(requestData, LayerBean.class);
       try{
	DAO.getInstance().getJdbcTemp().update(sqlLayerAdd, new Object[]{
              layer.getLayerName(),layer.getLayerDescription()
	   });
       response.setStatus(200);
         response.setContentType("text/html");
  PrintWriter writer=response.getWriter();
  writer.append("{\"success\":\"Layer Added SuccessFully\"}");
 writer.flush();
       }catch(Exception e)
       {
 response.setStatus(500);
         response.setContentType("text/html");
  PrintWriter writer=response.getWriter();
  writer.append("{\"error\":\"Something went wrong\"}");
 writer.flush();
       }
   

}

}