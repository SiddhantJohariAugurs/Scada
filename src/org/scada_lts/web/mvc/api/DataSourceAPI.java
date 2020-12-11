/*
 * (c) 2017 Abil'I.T. http://abilit.eu/
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
package org.scada_lts.web.mvc.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.serotonin.mango.Common;
import com.serotonin.mango.view.ShareUser;
import com.serotonin.mango.vo.User;
import com.serotonin.mango.vo.dataSource.DataSourceVO;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.scada_lts.mango.service.DataSourceService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import javax.servlet.http.HttpServletRequest;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * @author Arkadiusz Parafiniuk arkadiusz.parafiniuk@gmail.com
 */
@Controller
public class DataSourceAPI {

    private static final Log LOG = LogFactory.getLog(DataSourceAPI.class);
    class DatasourceJSON implements Serializable {
        /**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		private long id;
        private String xid;
        private String name;
        private int permission;

        DatasourceJSON(long id,String xid, String name, Integer permission) {
            this.setId(id);
            this.setXid(xid);
            this.name = name;
            this.setPermission(permission);
        }

        public long getId() { return id; }
        public void setId(long id) { this.id = id; }
        public String getXid() {
            return xid;
        }
        public String getName() {
            return name;
        }
        public void setXid(String xid) {
            this.xid = xid;
        }

		public int getPermission() {
			return permission;
		}

		public void setPermission(int permission) {
			this.permission = permission;
		}
    }

    DataSourceService dataSourceService = new DataSourceService();

    @RequestMapping(value = "/api/datasource/getAll", method = RequestMethod.GET)
    public ResponseEntity<String> getAll(HttpServletRequest request) {
        LOG.info("/api/datasource/getAll");

        try {
            User user = Common.getUser(request);

            if (user != null) {
                List<DataSourceVO<?>> lstDS = dataSourceService.getDataSources();

                List<DatasourceJSON> lst = new ArrayList<DatasourceJSON>();
                for (DataSourceVO<?> ds:lstDS) {
            		int permission = 0;
            		if (user.isAdmin()) {
            			permission = 3;
            		} else if (user.getDataSourcePermissions().contains(ds.getId())) {
            			permission = 2;
            			if (user.getView() != null) {
                			Optional<ShareUser> shareUser = user.getView().getViewUsers().stream().filter(p -> p.getUserId() == user.getId()).findFirst();
 
            				if (shareUser.isPresent()) {
            					permission = shareUser.get().getAccessType();
            				} 
                		} 
            		}
            		DatasourceJSON dsJ = new DatasourceJSON(ds.getId(), ds.getXid(), ds.getName(), permission);
                    lst.add(dsJ);
                }

                String json = null;
                ObjectMapper mapper = new ObjectMapper();
                json = mapper.writeValueAsString(lst);

                return new ResponseEntity<>(json,HttpStatus.OK);
            }

            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);

        } catch (Exception e) {
            LOG.error(e);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

}
