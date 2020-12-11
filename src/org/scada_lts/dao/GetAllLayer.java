package org.scada_lts.dao;
import org.scada_lts.dao.LayerBean;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import org.scada_lts.dao.DAO;
import java.util.*;
import org.springframework.jdbc.core.RowMapper;

public class GetAllLayer   extends HttpServlet
{   
final String getAllLayers="select * from layers";
    public void doGet(HttpServletRequest request,HttpServletResponse response) throws  IOException 
{

       try{
		Statement statement;
		ResultSet rs;
	
			statement = DAO.getInstance().getJdbcTemp().getDataSource().getConnection().createStatement();
			rs = statement.executeQuery(getAllLayers);
			List<String> list=new ArrayList<String>();  
			while (rs.next()) {
              
            list.add("{\"layerId\": "+rs.getInt("layerId")+",\"layerName\": \" "+rs.getString("layerName")+" \",\"layerDescrption\": \" "+rs.getString("layerDescription")+"\"}");
        }
      
			rs.close();
       response.setStatus(200);
         response.setContentType("text/html");
  PrintWriter writer=response.getWriter();
  writer.append("{\"data\":"+list.toString()+"}");
 writer.flush();
       }catch(Exception e)
       {
 response.setStatus(500);
         response.setContentType("text/html");
  PrintWriter writer=response.getWriter();
  writer.append("Something Wrong");
 writer.flush();
       }
   

}

}