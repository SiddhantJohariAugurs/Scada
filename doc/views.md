1. View create/edit page WebContent/WEB-INF/jsp/views.jsp /views.shtm?viewId=2#/ this page contains the dropdown view list and create edit box the full screen message. And the current view.
2. The current view is rendered using WebContent/WEB-INF/tags/displayView.tag uses com.serotonin.mango.view.View class to access viewComponents. Which are rendered in a table.
3. From the view.jsp page it is possible to edit a view this will take you to /view_edit.shtm
        