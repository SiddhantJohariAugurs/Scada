package org.scada_lts.dao;
import org.scada_lts.dao.LayerBean;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import org.scada_lts.dao.DAO;
import java.util.stream.*;
import com.google.gson.Gson;
import org.scada_lts.dao.LayerBean;
public class DeleteLayer   extends HttpServlet
{   


	private static final String DELETE_LAYER = 
			 "delete from layers where layerId=?";
				

		  
    public void doPost(HttpServletRequest request,HttpServletResponse response) throws  IOException 
{
       String requestData = request.getReader().lines().collect(Collectors.joining());
    
       Gson gson = new Gson();
       LayerBean layer = gson.fromJson(requestData, LayerBean.class);
  
       
if(layer.getLayerId()==1)
{
    response.setStatus(412);
         response.setContentType("text/html");
  PrintWriter writer=response.getWriter();
  writer.append("{\"error\":\"Default Layer Can not be deleted\"}");
 writer.flush();
}
else{
       try{
	DAO.getInstance().getJdbcTemp().update(DELETE_LAYER, new Object[]{
              layer.getLayerId()
	   });
       response.setStatus(200);
         response.setContentType("text/html");
  PrintWriter writer=response.getWriter();
  writer.append("{\"success\":\"Layer Deleted SuccessFully\"}");
 writer.flush();
       }catch(Exception e)
       {
 response.setStatus(500);
         response.setContentType("text/html");
  PrintWriter writer=response.getWriter();
  writer.append("{\"error\":\"Something Went Wrong\"}");
 writer.flush();
       }
   

}
}

}