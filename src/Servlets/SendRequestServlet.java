package Servlets;

import Database.HikeDM;
import Database.MainDM;
import Models.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Created by Saba on 7/3/2017.
 * Adds new request to database whenever Send Request button is pressed.
 */
@WebServlet("/SendRequest")
public class SendRequestServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        int senderId = (Integer)session.getAttribute("userID");
        int hikeId = Integer.parseInt(request.getParameter("hikeId"));
        User creator = MainDM.getInstance().getCreator(hikeId);
        int receiverId = creator.getId();
        int requestId = HikeDM.getInstance().addRequest(senderId, receiverId, hikeId);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}
